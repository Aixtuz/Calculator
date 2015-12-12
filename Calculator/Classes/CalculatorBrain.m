//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Aixtuz Kang on 15/12/6.
//  Copyright © 2015年 Aixtuz Kang. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain ()

///  运算步骤数组
@property (nonatomic, strong) NSMutableArray *programStack;

@end

@implementation CalculatorBrain

#pragma mark - Provide data

// 获取操作符信息集合
+ (NSDictionary *)operations {
    
    // 定义元数
    NSNumber *zero = [NSNumber numberWithInt:0];
    NSNumber *one = [NSNumber numberWithInt:1];
    NSNumber *two = [NSNumber numberWithInt:2];
    
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    
    // 零元操作符
    [dictM setObject:[NSDictionary dictionaryWithObjectsAndKeys:zero, @"variableCount", @"π", @"printFormat", nil] forKey:@"π"];
    
    // 一元操作符
    [dictM setObject:[NSDictionary dictionaryWithObjectsAndKeys:one, @"variableCount", @"sin(%@)", @"printFormat", nil] forKey:@"sin"];
    [dictM setObject:[NSDictionary dictionaryWithObjectsAndKeys:one, @"variableCount", @"cos(%@)", @"printFormat", nil] forKey:@"cos"];
    [dictM setObject:[NSDictionary dictionaryWithObjectsAndKeys:one, @"variableCount", @"sqrt(%@)", @"printFormat", nil] forKey:@"sqrt"];
    
    // 二元操作符
    [dictM setObject:[NSDictionary dictionaryWithObjectsAndKeys:two, @"variableCount", @"(%@ + %@)", @"printFormat", nil] forKey:@"+"];
    [dictM setObject:[NSDictionary dictionaryWithObjectsAndKeys:two, @"variableCount", @"(%@ - %@)", @"printFormat", nil] forKey:@"-"];
    [dictM setObject:[NSDictionary dictionaryWithObjectsAndKeys:two, @"variableCount", @"%@ * %@", @"printFormat", nil] forKey:@"*"];
    [dictM setObject:[NSDictionary dictionaryWithObjectsAndKeys:two, @"variableCount", @"%@ / %@", @"printFormat", nil] forKey:@"/"];
    
    return dictM;
}

// 返回运算所用变量集合
+ (NSSet *)variablesUsedInProgram:(id)program {
    
    NSMutableSet *variables = [NSMutableSet set];
    
    // 确认已存在才遍历
    if ([program isKindOfClass:[NSArray class]]) {
        
        // 遍历 Stack, 判断变量存入 NSSet
        [program enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            if ([CalculatorBrain isVariable:obj]) {
                [variables addObject:obj];
            }
        }];
    }
    return variables;
}

// Getter 运算步骤
- (id)program {
    
    // 取出数组
    return [self.programStack mutableCopy];
}

#pragma mark - Prepare description

// 显示运算步骤
+ (NSString *)descriptionOfProgram:(id)program {
    
    NSMutableArray *stack;
    
    // 可变复制 stack 数组
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    // 出栈结果, 过滤最外层括号
    NSString *result = [self extremeBrackets:[self descriptionOfTopOfStack:stack]];
    
    // 栈不空,继续出栈
    if (stack.count != 0) {
        result = [[self extremeBrackets:[self descriptionOfTopOfStack:stack]] stringByAppendingFormat:@", %@", result];
    }
    return result;
}

// 出栈后的判断
+ (NSString *)descriptionOfTopOfStack:(NSMutableArray *)stack {
    
    // 前后操作数和打印结果
    NSString *first, *second, *stepStr;
    
    // 取出栈顶元素
    id element = [stack lastObject];
    
    if (element) {
        
        // 成功取出, 则删除
        [stack removeLastObject];
        
        // 若是操作符, 取出对应: "元数" "格式";
        NSDictionary *operation = [[self operations] objectForKey:element];
        if (operation) {
            
            // 元数
            int variableCount = [[operation objectForKey:@"variableCount"] intValue];
            // 打印格式
            NSString *format = [operation objectForKey:@"printFormat"];
            
            // 元数决定后续出栈次数
            switch (variableCount) {
                    
                case 0:
                    stepStr = format;
                    break;
                    
                case 1: {
                    first = [self descriptionOfTopOfStack:stack];
                    if (!first) {
                        first = @"0";
                    }
                    stepStr = [NSString stringWithFormat:format, first];
                    break;
                }
                    
                case 2: {
                    second = [self descriptionOfTopOfStack:stack];
                    if (!second) {
                        second = @"0";
                    }
                    first = [self descriptionOfTopOfStack:stack];
                    if (!first) {
                        first = @"0";
                    }
                    stepStr = [NSString stringWithFormat:format, first, second];
                    break;
                }
                    
                default:
                    break;
            }
            
        } else {
            
            // operations 无此 key 对应内容, 则非操作符, 直接打印;
            stepStr = [element description];
        }
    }
    return stepStr;
}

// 过滤最外层括号
+ (NSString *)extremeBrackets:(NSString *)str {
    
    // 首尾是括号则舍弃
    if ([str hasPrefix:@"("] && [str hasSuffix:@")"]) {
        return [str substringWithRange:NSMakeRange(1, str.length - 2)];
        
    } else {
        
        // 否则不变
        return str;
    }
}

#pragma mark - Perform function

// 带参执行操作
- (double)performOperation:(NSString *)operation withVariables:(NSDictionary *)variableValues {
    
    // 操作符入栈
    [self.programStack addObject:operation];
    
    // 执行带参运算
    return [[self class] runProgram:self.program usingVariableValues:variableValues];
}

// 执行运算步骤
+ (double)runProgram:(id)program {
    
    return [self runProgram:program usingVariableValues:nil];
}

// 执行带参数的运算步骤
+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues {
    
    NSMutableArray *stack;
    
    // 可变复制 stack 数组
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    // 遍历 Stack
    for (int i = 0; i < stack.count; i++) {
  
        id element = [stack objectAtIndex:i];
        
        // 非操作符的字符串 为 变量
        if ([self isVariable:element]) {
            
            // 取出变量对应值(可能为空)
            id value = [variableValues objectForKey:element];
            
            if ([value isKindOfClass:[NSNumber class]]) {
                
                // 有值则替换对应值
                [stack replaceObjectAtIndex:i withObject:value];
                
            } else {
                
                // 无值则替换 0
                [stack replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:0]];
            }
        }
    }
    return [self popOfProgramStack:stack];
}

// 出栈运算
+ (double)popOfProgramStack:(NSMutableArray *)stack {
    
    double result = 0;
    
    // 取出数组末位元素
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        
        // 操作数, 直接返回;
        result = [topOfStack doubleValue];
        
    } else if ([topOfStack isKindOfClass:[NSString class]]) {
        
        // 操作符, 执行计算;
        result = [self calculateOperation:topOfStack withStack:stack];
    }
    return result;
}

// 计算方法
+ (double)calculateOperation:(NSString *)operation withStack:(NSMutableArray *)stack {
    
    double result = 0;
    
    if ([operation isEqualToString:@"+"]) {
        result = [self popOfProgramStack:stack] + [self popOfProgramStack:stack];

    } else if ([operation isEqualToString:@"*"]) {
        result = [self popOfProgramStack:stack] * [self popOfProgramStack:stack];

    } else if ([operation isEqualToString:@"-"]) {
        double subtrahend = [self popOfProgramStack:stack];
        result = [self popOfProgramStack:stack] - subtrahend;

    } else if ([operation isEqualToString:@"/"]) {
        double divisor = [self popOfProgramStack:stack];
        if (divisor) {
            result = [self popOfProgramStack:stack] / divisor;
        }

    } else if ([operation isEqualToString:@"sin"]) {
        result = sin([self popOfProgramStack:stack]);

    } else if ([operation isEqualToString:@"cos"]) {
        result = cos([self popOfProgramStack:stack]);

    } else if ([operation isEqualToString:@"sqrt"]) {
        result = sqrt([self popOfProgramStack:stack]);

    } else if ([operation isEqualToString:@"π"]) {
        result = M_PI;
        
    } else  if ([operation isEqualToString:@"+/-"]) {
        result = -[self popOfProgramStack:stack];
        
    }
    return result;
}

///--------------------------------------
#pragma mark - Help methods
///--------------------------------------

// 是否变量
+ (BOOL)isVariable:(id)element {
    
    // 字符串中非操作符的"字母" 为 变量!
    return [element isKindOfClass:[NSString class]]
    && ([element rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]].location != NSNotFound)
    && ![[self operations] objectForKey:element];
}

// 变量入栈
- (void)pushVariable:(NSString *)variable {
    
    // 变量直接存字符
    [self.programStack addObject:variable];
}

// 操作数入栈
- (void)pushOperand:(double)operand {
    
    // 操作数存 NSNumber
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

// 清空末尾元素
- (void)clearLast {
    
    [self.programStack removeLastObject];
}

// 清空模型状态
- (void)clear {
    
    [self.programStack removeAllObjects];
}

#pragma mark - Lazy instantiation

- (NSMutableArray *)programStack {
    
    if (_programStack == nil) {
        _programStack = [NSMutableArray array];
    }
    return _programStack;
}

@end

