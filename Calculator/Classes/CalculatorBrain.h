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

// 返回运算所用变量集合
+ (NSSet *)variablesUsedInProgram:(id)program;

// 是否变量
+ (BOOL)isVariable:(id)element;

// 变量入栈
- (void)pushVariable:(NSString *)variable;

// 入栈
- (void)pushOperand:(double)operand;

// 执行运算
- (double)performOperation:(NSString *)operation withVariables:(NSDictionary *)variableValues;

// 清空末尾元素
- (void)clearLast;

// 清空状态
- (void)clear;

@end
