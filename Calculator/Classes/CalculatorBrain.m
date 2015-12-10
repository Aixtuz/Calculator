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

// 获取操作符信息集合
+ (NSDictionary *)operations {
    
    // 定义元数
    NSNumber *zero = [NSNumber numberWithInt:0];
    NSNumber *one = [NSNumber numberWithInt:1];
    NSNumber *two = [NSNumber numberWithInt:2];
    
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    
    // 零元操作符
    // Hints: 建议使用 dictionaryWithObjectsAndKeys 方法
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

// 显示运算步骤
+ (NSString *)descriptionOfProgram:(id)program {
    
    NSMutableArray *stack;
    
    // 确认已存在才赋值, 复制避免改动 stack 属性存储的内容;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self descriptionOfTopOfStack:stack];
}

// 出栈后的判断
+ (NSString *)descriptionOfTopOfStack:(NSMutableArray *)stack {
    
    // 用于显示纤手操作数和打印结果
    NSString *first, *second, *stepStr;
    
    // 取出栈顶元素
    id element = [stack lastObject];
    if (element) {
        // 成功取出, 则删除
        [stack removeLastObject];
        
        // 判断是否为操作符, 若是取出操作符对应 元数,格式 信息
        NSDictionary *operation = [[self operations] objectForKey:element];
        
        // 成功取出则为操作符
        if (operation) {
            
            // 元数(需要操作符前面几位操作数参与计算)
            int variableCount = [[operation objectForKey:@"variableCount"] intValue];
            // 打印格式
            NSString *format = [operation objectForKey:@"printFormat"];
            
            // 根据元数, 决定需出栈几位操作数参与运算
            switch (variableCount) {
                case 0:
                    stepStr = format;
                    break;
                    
                case 1:
                    first = [self descriptionOfTopOfStack:stack];
                    if ([first isEqualToString:@""]) {
                        first = @"0";
                    }
                    stepStr = [NSString stringWithFormat:format, first];
                    break;
                    
                case 2:
                    second = [self descriptionOfTopOfStack:stack];
                    if ([second isEqualToString:@""]) {
                        second = @"0";
                    }
                    first = [self descriptionOfTopOfStack:stack];
                    if ([first isEqualToString:@""]) {
                        first = @"0";
                    }
                    stepStr = [NSString stringWithFormat:format, first, second];
                    break;
                    
                default:
                    break;
            }
            
        } else {
            // operations 取出的字典中无此 key, 则非操作符, 直接打印
            stepStr = [element description];
        }
    }
    return stepStr;
}


// 带参数的执行方法
+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues {
    
    NSMutableArray *stack;
    
    // 确认已存在才复制, 避免改动 stack 属性存储的内容;
    if ([program isKindOfClass:[NSArray class]]) {
        // 赋值可变数组, 用于后续出栈计算;
        stack = [program mutableCopy];
    }
    
    // 遍历 Stack
    for (int i = 0; i < stack.count; i++) {
        
        // 取出遍历的元素
        id element = [stack objectAtIndex:i];
        
        // 非操作符的字符串 为 变量
        if ([CalculatorBrain isVariable:element]) {
            
            // 取出变量对应值(可能为空)
            id value = [variableValues objectForKey:element];
            
            if (value) {
                // 有值则替换对应值
                [stack replaceObjectAtIndex:i withObject:value];
                
            } else {
                // 无值则替换 0
                [stack replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:0]];
            }
        }
        
        // 元素是变量, 则替换
        if ([variableValues objectForKey:element]) {
            //
            [stack replaceObjectAtIndex:i withObject:[variableValues objectForKey:element]];
            
        } else {
            [stack replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:0]];
        }
    }
    return 0;
}

// 执行操作
- (double)performOperation:(NSString *)operation {
    // 入栈
    [self.programStack addObject:operation];
    // 计算
    return [[self class] runProgram:self.program];
}

// 以传入的数组执行操作
+ (double)runProgram:(id)program {
    
    NSMutableArray *stack;
    
    // 确认已存在才复制, 避免改动 stack 属性存储的内容;
    if ([program isKindOfClass:[NSArray class]]) {
        // 赋值可变数组, 用于后续出栈计算;
        stack = [program mutableCopy];
    }
    return [self popOfProgramStack:stack];
}

// 出栈运算;
+ (double)popOfProgramStack:(NSMutableArray *)stack {
    
    double result = 0;
    
    // 取出数组末位元素
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    // 操作数, 直接返回
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        result = [topOfStack doubleValue];
        
    } else if ([topOfStack isKindOfClass:[NSString class]]) {
        // 操作符, 执行计算
        result = [self calculateOperation:topOfStack withStack:stack];
    }
    return result;
}

// 从出栈操作中抽取判别操作符的步骤
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

// 返回运算所用变量集合
+ (NSSet *)variablesUsedInProgram:(id)program {
    
    NSMutableSet *variables;
    
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

// 是否变量
+ (BOOL)isVariable:(id)element {
    // 字符串中非操作符的字母 为 变量
    return [element isKindOfClass:[NSString class]]
    && ([element rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]].location != NSNotFound)
    && ![[self operations] objectForKey:element];
}

// 变量入栈
- (void)pushVariable:(NSString *)variable {
    // 变量直接存字符
    [self.programStack addObject:variable];
}

// 入栈
- (void)pushOperand:(double)operand {
    // 操作数存 NSNumber
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

// 重写 Getter 方法
- (id)program {
    // 取出数组
    return [self.programStack copy];
}

// 清空状态
- (void)clear {
    [self.programStack removeAllObjects];
}

#pragma mark - lazy instantiation

- (NSMutableArray *)programStack {
    
    if (_programStack == nil) {
        _programStack = [NSMutableArray array];
    }
    return _programStack;
}

@end

