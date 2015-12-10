//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Aixtuz Kang on 15/12/6.
//  Copyright © 2015年 Aixtuz Kang. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorViewController ()

///  首位数字标识
@property (nonatomic, assign) BOOL userIsInTheMiddleOfTypingANumber;
///  数据模型
@property (nonatomic, strong) CalculatorBrain *brain;

@end

@implementation CalculatorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// 监听数字点击
- (IBAction)digitPressed:(UIButton *)sender {
    
    // 接收数值符
    NSString *digit = sender.currentTitle;
    
    // 非首位状态, 重复小数点忽略;
    if (self.userIsInTheMiddleOfTypingANumber && [digit isEqualToString:@"."] && [self.display.text containsString:@"."]) {
        return;
    }
    
    if (!self.userIsInTheMiddleOfTypingANumber) {
        // 首位 "." 需要拼接
        [self displayUpdateWithStr:digit isAppend:[digit isEqualToString:@"."]];
        
        // 首位 非 0, 结束首位状态;
        self.userIsInTheMiddleOfTypingANumber = ![digit isEqualToString:@"0"];
        
    } else {
        // 其他情况, 根据是否首位, 更新 display 显示;
        [self displayUpdateWithStr:digit isAppend:self.userIsInTheMiddleOfTypingANumber];
    }
}

// 监听运算符点击
- (IBAction)operationPressed:(UIButton *)sender {
    
    // 接收操作符
    NSString *operation = sender.currentTitle;
    
    // 非首位输入状态
    if (self.userIsInTheMiddleOfTypingANumber) {
        
        // +/- 操作符, 仅换号;
        if ([operation isEqualToString:@"+/-"]) {
            
            double temp = [self.display.text doubleValue];
            temp = - temp;
            self.display.text = [NSString stringWithFormat:@"%g", temp];
            
        } else {
            // 其他操作符,  执行 Enter + 运算;
            [self enterPressed];
            [self performOperation:operation];
            
        }
    } else {
        // 首位状态, 不区分操作符, 均开始运算;
        [self performOperation:operation];
    }
}

// 执行操作
- (void)performOperation:(NSString *)operation {
    
    // 执行操作, 返回结果
    double result = [self.brain performOperation:operation];
    // 结果字符串
    NSString *resultStr = [NSString stringWithFormat:@"%g", result];
    
    // display 显示结果
    [self displayUpdateWithStr:resultStr isAppend:NO];
    
    // 不再考虑操作符元数, 交给模型判断, 直接刷新结果;
    [self stepDisplayUpdate];
}

// 监听确认符点击
- (IBAction)enterPressed {
    
    // 取出当前显示
    NSString *operandStr = self.display.text;
   
    if ([CalculatorBrain isVariable:operandStr]) {
        // 变量直接入栈
        [self.brain pushVariable:operandStr];
        
    } else {
        // 非变量, 以浮点入栈;
        [self.brain pushOperand:[operandStr doubleValue]];
    }
    
    // 重置首位标识
    self.userIsInTheMiddleOfTypingANumber = NO;
    
    // stepDisplay 拼接显示
    [self stepDisplayUpdate];
}

- (IBAction)variablePressed:(UIButton *)sender {
    // 变量直接显示
    [self displayUpdateWithStr:sender.currentTitle isAppend:NO];
    [self enterPressed];
}

// 回退操作
- (IBAction)backspace {
    
    // 计算长度减 1
    NSUInteger index = self.display.text.length - 1;
    
    // 非个位
    if (index > 0) {
        // 回退 = 长度减 1
        self.display.text = [self.display.text substringToIndex:index];
        
    } else {
        
        // 个位回退归 0
        self.display.text = @"0";
        // 重置首位状态
        self.userIsInTheMiddleOfTypingANumber = NO;
    }
}

// 清空状态
- (IBAction)clear {
    
    // 重置显示和首位状态
    self.display.text = @"0";
    self.stepDisplay.text = @"";
    self.userIsInTheMiddleOfTypingANumber = NO;
    
    // 模型的 Clear 方法
    [self.brain clear];
}

// step 拼接显示
- (void)stepDisplayUpdate {
    self.stepDisplay.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
}

// display 更新显示
- (void)displayUpdateWithStr:(NSString *)str isAppend:(BOOL)isAppend {
    
    if (isAppend) {
        // 非首位拼接
        self.display.text = [self.display.text stringByAppendingString:str];
        
    } else if ([str isEqualToString:@"."]) {
        // 首位小数点
        self.display.text = @"0.";
        
    } else {
        // 首位赋值
        self.display.text = str;
    }
}


#pragma mark - lazy instantiation

- (CalculatorBrain *)brain {
    
    if (_brain == nil) {
        _brain = [[CalculatorBrain alloc] init];
    }
    return _brain;
}

@end

