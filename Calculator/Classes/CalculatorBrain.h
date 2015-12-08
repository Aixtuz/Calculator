//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Aixtuz Kang on 15/12/6.
//  Copyright © 2015年 Aixtuz Kang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

///  正负标记
@property (nonatomic, assign) BOOL isNegative;

// 正序压入数组元素
- (void)pushOperand:(double)operand;

// 逆序弹出数组元素
- (double)popOperand;

// 执行运算
- (double)performOperation:(NSString *)operation;

// 清空状态
- (void)clear;

@end
