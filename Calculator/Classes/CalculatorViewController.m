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
    
    // 输入小数点
    if ([digit isEqualToString:@"."]) {
        // 非首位输入状态, 重复小数点忽略;
        if (self.userIsInTheMiddleOfTypingANumber && [self.display.text containsString:@"."]) {
            return;
        }
    }
    
    // 输入非小数点
    if (self.userIsInTheMiddleOfTypingANumber) {
        // 非首位输入状态, 直接拼接
        [self displayAppendStr:digit];
        
    } else {
        // 结束首输状态
        if (![digit isEqualToString:@"0"]) {
            self.userIsInTheMiddleOfTypingANumber = YES;
        }
        // 首位输入, 直接显示;
        [self displayStr:digit];
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
    
    // 显示结果
    [self displayStr:resultStr];
    
    // setpdisplay 拼接操作符
    [self stepAppendStr:operation];
    
    // 非 π, 拼接 = 号和结果;
    if (![operation isEqualToString:@"π"]) {
        // stepdisplay 拼接 = 号
        [self stepAppendStr:@"="];
        // stepDisplay 拼接 结果
        [self stepAppendStr:resultStr];
    }
}

// 监听确认符点击
- (IBAction)enterPressed {
    
    // 取出当前显示
    NSString *operandStr = self.display.text;
   
    // 当前显示以浮点入栈
    [self.brain pushOperand:[operandStr doubleValue]];
    
    // 重置首位标识
    self.userIsInTheMiddleOfTypingANumber = NO;
    
    // stepDisplay 拼接显示
    [self stepAppendStr:operandStr];
    [self stepAppendStr:@" "];

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
- (void)stepAppendStr:(NSString *)str {
    self.stepDisplay.text = [self.stepDisplay.text stringByAppendingString:str];
}

// display 直接显示
- (void)displayStr:(NSString *)str {
    self.display.text = str;
}

// display 拼接显示
- (void)displayAppendStr:(NSString *)str {
    self.display.text = [self.display.text stringByAppendingString:str];
}


#pragma mark - lazy instantiation

- (CalculatorBrain *)brain {
    
    if (_brain == nil) {
        _brain = [[CalculatorBrain alloc] init];
    }
    return _brain;
}

@end

