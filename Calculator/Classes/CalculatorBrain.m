//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Aixtuz Kang on 15/12/6.
//  Copyright © 2015年 Aixtuz Kang. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain ()

///  运算对象数组
@property (nonatomic, strong) NSMutableArray *operandStack;

@end

@implementation CalculatorBrain

// 正序压入数组元素
- (void)pushOperand:(double)operand {
    
    [self.operandStack addObject:[NSNumber numberWithDouble:operand]];
}

// 逆序弹出数组元素
- (double)popOperand {
    
    NSNumber *operandObject = [self.operandStack lastObject];
    
    // 取出则删除
    if (operandObject) {
        [self.operandStack removeLastObject];
    }
    return [operandObject doubleValue];
}

// 执行运算
- (double)performOperation:(NSString *)operation {
    
    double result = 0;
    
    if ([operation isEqualToString:@"+"]) {
        result = [self popOperand] + [self popOperand];
        
    } else if ([operation isEqualToString:@"*"]) {
        result = [self popOperand] * [self popOperand];
        
    } else if ([operation isEqualToString:@"-"]) {
        double subtrahend = [self popOperand];
        result = [self popOperand] - subtrahend;
        
    } else if ([operation isEqualToString:@"/"]) {
        double divisor = [self popOperand];
        result = [self popOperand] / divisor;
    }
    // 结果压入数组, 待后续运算;
    [self pushOperand:result];
    return result;
}

#pragma mark - lazy instantiation

- (NSMutableArray *)operandStack {
    
    if (_operandStack == nil) {
        _operandStack = [NSMutableArray array];
    }
    return _operandStack;
}

@end
