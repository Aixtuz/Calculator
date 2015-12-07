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
    
    // 点击数字按钮
    NSString *digit = sender.currentTitle;
    //FIXME: 检查数字键点击
    NSLog(@"user touched: %@", digit);
    
    // 判断是否首位输入
    if (self.userIsInTheMiddleOfTypingANumber) {
        
        // 判断是否重复小数点
        if ([sender.currentTitle isEqualToString:@"."] && [self.display.text containsString:@"."]) {
            // 重复小数点, 忽略;
            return;
            
        } else {
            // 非重复小数点, 拼接显示;
            self.display.text = [self.display.text stringByAppendingString:digit];
        }
        
    } else if ([sender.currentTitle isEqualToString:@"."]) {
        // 首位输入小数点, 拼接 0 前缀, 变更标识;
        self.display.text = [self.display.text stringByAppendingString:digit];
        self.userIsInTheMiddleOfTypingANumber = YES;
        
    } else if ([sender.currentTitle isEqualToString:@"0"]) {
        // 首位输入 0, 忽略;
        return;
        
    } else {
        // 首位输入其他, 直接赋值, 变更标识;
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
    // 执行运算
    double result = [self.brain performOperation:operation];
    // 显示结果
    self.display.text = [NSString stringWithFormat:@"%g", result];
}

// 监听确认符点击
- (IBAction)enterPressed {
    
    //FIXME: 检查确认符点击
    NSLog(@"user touched: Enter");
    
    // 当前显示数值存入数组, 用于后续运算;
    [self.brain pushOperand:[self.display.text doubleValue]];
    
    // Enter 后显示归 0, 可视化确认点击操作, 并简化后续 0或. 开头输入的判断
    self.display.text = @"0";
    
    // 下次数字输入为首位
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
