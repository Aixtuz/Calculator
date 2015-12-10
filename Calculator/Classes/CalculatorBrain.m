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
    
    NSDictionary *dict = @{ @"+" : @"+",
                            @"-" : @"-",
                            @"*" : @"*",
                            @"/" : @"/",
                            @"sin" : @"sin",
                            @"cos" : @"cos",
                            @"π" : @"π"
                            };
    return dict;
}

//TODO: 显示运算步骤
+ (NSString *)descriptionOfProgram:(id)program {
    return @"Implement this in Homework #2";
}

// 带参数的执行方法
+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues {
    
    NSMutableArray *stack;
    // 赋值可变数组, 用于后续出栈计算;
    if ([program isKindOfClass:[NSArray class]]) {
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
    // 赋值可变数组, 用于后续出栈计算;
    if ([program isKindOfClass:[NSArray class]]) {
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
    
    // 遍历 Stack, 判断变量存入 NSSet
    [program enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([CalculatorBrain isVariable:obj]) {
            [variables addObject:obj];
        }
    }];
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

