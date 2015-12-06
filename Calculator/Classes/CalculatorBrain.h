//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Aixtuz Kang on 15/12/6.
//  Copyright © 2015年 Aixtuz Kang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

///  数值
@property (nonatomic, assign) double operand;

// 正序压入数组元素
- (void)pushOperand:(double)operand;

// 执行运算
- (double)performOperation:(NSString *)operation;

@end
