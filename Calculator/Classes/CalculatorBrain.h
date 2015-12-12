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
// 执行带参数的运算步骤
+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;
// 执行运算步骤
+ (double)runProgram:(id)program;
// 返回运算所用变量集合
+ (NSSet *)variablesUsedInProgram:(id)program;
// 是否变量
+ (BOOL)isVariable:(id)element;

// 变量入栈
- (void)pushVariable:(NSString *)variable;
// 操作数入栈
- (void)pushOperand:(double)operand;
// 带参执行操作
- (double)performOperation:(NSString *)operation withVariables:(NSDictionary *)variableValues;
// 清空末尾元素
- (void)clearLast;
// 清空模型状态
- (void)clear;

@end
