//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Aixtuz Kang on 15/12/6.
//  Copyright © 2015年 Aixtuz Kang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

///  运算步骤
@property (nonatomic, readonly) id program;

// 显示运算步骤
+ (NSString *)descriptionOfProgram:(id)program;

// 带参数字典的执行方法
+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;

// 以传入的数组执行运算
+ (double)runProgram:(id)program;


// 入栈
- (void)pushOperand:(double)operand;

// 执行运算
- (double)performOperation:(NSString *)operation;

// 清空状态
- (void)clear;

@end
