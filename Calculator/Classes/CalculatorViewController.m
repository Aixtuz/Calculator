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
        // 首位输入".", 补全 0 前缀;
        self.display.text = @"0.";
        
        // 首位新输入, 需恢复正数标记, 除首输 0 外, 还需结束首输状态(下同);
        self.userIsInTheMiddleOfTypingANumber = YES;
        self.brain.isNegative = NO;
            
    } else if ([digit isEqualToString:@"0"]) {
        // 首位输入"0", 赋值 0;
        self.display.text = @"0";
        self.brain.isNegative = NO;
            
    } else {
        // 首位输入其他数字, 直接赋值;
        self.display.text = digit;
        self.userIsInTheMiddleOfTypingANumber = YES;
        self.brain.isNegative = NO;
    }
}

// 监听运算符点击
- (IBAction)operationPressed:(UIButton *)sender {
    
    // 接收操作符
    NSString *operation = sender.currentTitle;
    
    if ([operation isEqualToString:@"π"]) {
        
        // 每次点击 π 操作符, 重置正负标记;
        self.brain.isNegative = NO;
        
        // π 操作符, 先将之前当前显示压入数组;
        if (![self.display.text isEqualToString:@"0"] && ![self.display.text hasSuffix:@"π"]) {
            [self enterPressed];
        }
        
        // 再将 π 操作符自身, 显示并压入;
        self.display.text = @"π";
        [self enterPressed];
        
    } else if ([operation isEqualToString:@"C"]) {
        // C 操作符, 执行 Clear 方法;
        [self clear];
        
    } else if ([operation isEqualToString:@"←"]) {
        // 回退符, 执行 backspace 方法;
        [self backspace];
    
    } else {
        
        // 其他操作符: 自动将当前显示数值存入数组, 用于后续运算;
        if (self.userIsInTheMiddleOfTypingANumber || [self.display.text isEqualToString:@"0"]) {
            [self enterPressed];
        }
        
        // 拼接显示逆波兰式
        [self rpnWithStr:operation];
        
        // 执行运算, 显示结果;
        double result = [self.brain performOperation:operation];
        self.display.text = [NSString stringWithFormat:@"%g", result];
        
        // 计算相关的操作符, 加上等号
        [self addEqualsSign];
    }
}

// 监听换号键点击
- (IBAction)negativePressed:(UIButton *)sender {
    
    // 接收操作符
    NSString *operation = sender.currentTitle;
    
    // 点击立即切换标记
    self.brain.isNegative = !self.brain.isNegative;
    
    NSInteger rpnLength = self.rpnLabel.text.length;
    NSInteger numLength = self.display.text.length;
    
    // 非首位直接换号
    if (self.userIsInTheMiddleOfTypingANumber) {
        
        // 负数标记
        if (self.brain.isNegative) {
            // 正数加负号
            self.display.text = [NSString stringWithFormat:@"-%@", self.display.text];
            
        } else {
            // 负数删负号
            self.display.text = [self.display.text substringFromIndex:1];
        }
        
    } else if ([self.display.text hasSuffix:@"π"]) {
        
        // 首位 π 操作符状态
        if (self.brain.isNegative) {
            // 正数加负号
            self.display.text = [NSString stringWithFormat:@"-%@", self.display.text];
            self.rpnLabel.text = [self.rpnLabel.text substringToIndex:(rpnLength - 2)];
            
        } else {
            // 负数删负号
            self.display.text = [self.display.text substringFromIndex:1];
            self.rpnLabel.text = [self.rpnLabel.text substringToIndex:(rpnLength - 5)];
        }
        // π 操作符直接压入;
        [self enterPressed];
        
    } else {
        
        // 首位状态且非 π;
        if (self.brain.isNegative) {
            // 正数加负号
            self.display.text = [NSString stringWithFormat:@"-%@", self.display.text];
            self.rpnLabel.text = [self.rpnLabel.text substringToIndex:(rpnLength - numLength -1)];
            
        } else {
            // 负数删负号
            self.display.text = [self.display.text substringFromIndex:1];
            self.rpnLabel.text = [self.rpnLabel.text substringToIndex:(rpnLength - numLength - 3)];
        }
        
        // 执行运算, 显示结果;
        double result = [self.brain performOperation:operation];
        self.display.text = [NSString stringWithFormat:@"%g", result];
        
        // 取出当前显示
        NSString *operandStr = self.display.text;
        
        // 若为负数, 添加括号
        if (self.brain.isNegative) {
            operandStr = [NSString stringWithFormat:@"(%@)",operandStr];
        }
        
        // 拼接显示逆波兰式
        [self rpnWithStr:operandStr];
    }
}


// 监听确认符点击
- (IBAction)enterPressed {
    
    // 取出当前显示
    NSString *operandStr = self.display.text;
    
    // π 操作符, 存入 π 值, 显示 π 字符;
    if ([operandStr hasSuffix:@"π"]) {
        
        if (self.brain.isNegative) {
            [self.brain pushOperand:-M_PI];
            
        } else {
            [self.brain pushOperand:M_PI];
        }
        
        // 若为负数, 添加括号
        if (self.brain.isNegative) {
            operandStr = [NSString stringWithFormat:@"(%@)",operandStr];
        }

    } else {
        // 其他操作数, 存入数组, 用于后续运算;
        [self.brain pushOperand:[operandStr doubleValue]];
        
        // 若为负数, 添加括号
        if (self.brain.isNegative) {
            operandStr = [NSString stringWithFormat:@"(%@)",operandStr];
        }
        
        if (self.userIsInTheMiddleOfTypingANumber) {
            // 恢复正数标记
            self.brain.isNegative = NO;
        }
    }
    
    // 重置首位标识
    self.userIsInTheMiddleOfTypingANumber = NO;
    
    // 拼接显示逆波兰式
    [self rpnWithStr:operandStr];

}

// 添加等号
- (void)addEqualsSign {
    self.rpnLabel.text = [self.rpnLabel.text stringByAppendingString:@"="];
}

// 拼接显示逆波兰式
- (void)rpnWithStr:(NSString *)str {
    
    // 拼接不包含最后的等号
    if ([self.rpnLabel.text hasSuffix:@"="]) {
        NSUInteger rpnIndex = self.rpnLabel.text.length;
        self.rpnLabel.text = [self.rpnLabel.text substringToIndex:(rpnIndex - 1)];
    }
    // 拼接显示
    NSString *enterStr = [NSString stringWithFormat:@"%@ ", str];
    self.rpnLabel.text = [self.rpnLabel.text stringByAppendingString:enterStr];
}

// 回退操作
- (void)backspace {

    NSUInteger index = self.display.text.length - 1;
    if (index > 0) {
        // 回退 = 长度减 1
        self.display.text = [self.display.text substringToIndex:index];
        
    } else {
        // π 回退, 需删除之前的 π 值和显示
        if ([self.display.text isEqualToString:@"π"]) {
            // 删除数组元素
            [self.brain popOperand];
            // 删除 rpnLabel 显示 (rpnLabel 比 display 多显示个空格);
            NSUInteger rpnIndex = self.rpnLabel.text.length - 2;
            self.rpnLabel.text = [self.rpnLabel.text substringToIndex:rpnIndex];
        }
        // 个位再回退归 0
        self.display.text = @"0";
    }
}

// 清空状态
- (void)clear {
    
    self.display.text = @"0";
    self.rpnLabel.text = @"";
    self.userIsInTheMiddleOfTypingANumber = NO;
    
    // 模型的 Clear 方法
    [self.brain clear];
}


#pragma mark - lazy instantiation

- (CalculatorBrain *)brain {
    
    if (_brain == nil) {
        _brain = [[CalculatorBrain alloc] init];
    }
    return _brain;
}

@end

