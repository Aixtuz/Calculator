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
    //FIXME: 检查数字键点击
    NSLog(@"user touched: %@", digit);
    
    // 非首位输入
    if (self.userIsInTheMiddleOfTypingANumber) {
        // 重复".", 则忽略
        if ([digit isEqualToString:@"."] && [self.display.text containsString:@"."]) {
            return;
            
        } else {
            // 非重复".", 则拼接显示;
            self.display.text = [self.display.text stringByAppendingString:digit];
        }
        
    } else if ([digit isEqualToString:@"."]) {
        // 首位输入".", 补全 0 前缀, 变更首位标识;
        self.display.text = @"0.";
        self.userIsInTheMiddleOfTypingANumber = YES;
        
    } else if ([digit isEqualToString:@"0"]) {
        // 首位输入"0", 赋值 0, 但不变更首位标识;
        self.display.text = @"0";
        
    } else {
        // 首位输入其他, 直接赋值, 变更首位标识;
        self.display.text = digit;
        self.userIsInTheMiddleOfTypingANumber = YES;
    }
}

// 监听运算符点击
- (IBAction)operationPressed:(UIButton *)sender {
    
    //FIXME: 检查操作符点击
    NSLog(@"user touched: %@", sender.currentTitle);
    
    // 数字输入中, 点击操作符, 自动将当前显示数值存入数组, 用于后续运算;
    if (self.userIsInTheMiddleOfTypingANumber) {
        [self enterPressed];
    }
    
    // 接收操作符
    NSString *operation = sender.currentTitle;
    
    // π 操作符, 则显示并压入
    if ([operation isEqualToString:@"π"]) {
        self.display.text = [NSString stringWithFormat:@"%f", M_PI];
        [self enterPressed];
        
    } else {
        // 其他操作符, 则执行运算, 显示结果;
        double result = [self.brain performOperation:operation];
        self.display.text = [NSString stringWithFormat:@"%g", result];
    }
}

// 监听确认符点击
- (IBAction)enterPressed {
    
    //FIXME: 检查 Enter 执行
    NSLog(@"user touched: Enter");
    
    // 当前显示数值存入数组, 用于后续运算;
    [self.brain pushOperand:[self.display.text doubleValue]];
    
    //!!!: 连续点击 Enter 实现当前操作数重复存入, 故不可归 0;
    // Enter 后显示归 0, 可视化确认点击操作, 并简化后续 0或. 开头输入的判断
    // self.display.text = @"0";
    
    // 重置首位标识
    self.userIsInTheMiddleOfTypingANumber = NO;
}


#pragma mark - lazy instantiation

- (CalculatorBrain *)brain {
    if (_brain == nil) {
        _brain = [[CalculatorBrain alloc] init];
    }
    return _brain;
}

@end
