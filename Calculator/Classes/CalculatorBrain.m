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

//TODO: 显示运算步骤
+ (NSString *)descriptionOfProgram:(id)program {
    return @"Implement this in Homework #2";
}

//TODO: 带参数的执行方法
+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues {
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

// 入栈
- (void)pushOperand:(double)operand {
    
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

// 重写 Getter 方法, 返回运算对象数组;
- (id)program {
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
