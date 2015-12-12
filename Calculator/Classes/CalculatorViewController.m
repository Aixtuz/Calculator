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

///  首位标识
@property (nonatomic, assign) BOOL userIsInTheMiddleOfTypingANumber;
///  数据模型
@property (nonatomic, strong) CalculatorBrain *brain;
///  参数集合
@property (nonatomic, strong) NSDictionary *variableValues;

@end


@implementation CalculatorViewController

///--------------------------------------
#pragma mark - life cycle
///--------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

///--------------------------------------
#pragma mark - setup & configuration
///--------------------------------------

- (CalculatorBrain *)brain {
    
    if (_brain == nil) {
        _brain = [[CalculatorBrain alloc] init];
    }
    return _brain;
}

///--------------------------------------
#pragma mark - event response
///--------------------------------------

// 监听操作数点击
- (IBAction)digitPressed:(UIButton *)sender {
    
    // 接收操作数
    NSString *digit = sender.currentTitle;

    if (!self.userIsInTheMiddleOfTypingANumber) {
        
        // 首位非 0, 结束首位状态;
        if (![digit isEqualToString:@"0"]) {
            self.userIsInTheMiddleOfTypingANumber = YES;
        }
        
        // 首位 "." 需要拼接, 非 "." 直接显示;
        [self displayUpdateWithStr:digit isAppend:[digit isEqualToString:@"."]];
        
    } else if ([digit isEqualToString:@"."] && [self.display.text containsString:@"."]) {
        
        // 非首位状态, 重复小数点忽略;
        return;
        
    } else {
        
        // 非首位其他, 直接拼接;
        [self displayUpdateWithStr:digit isAppend:YES];
    }
}

// 监听操作符点击
- (IBAction)operationPressed:(UIButton *)sender {
    
    // 接收操作符
    NSString *operation = sender.currentTitle;
    
    // 非首位输入状态
    if (self.userIsInTheMiddleOfTypingANumber) {
        
        if ([operation isEqualToString:@"+/-"]) {
            
            // +/- 操作符, 仅换号;
            double temp = [self.display.text doubleValue];
            temp = - temp;
            self.display.text = [NSString stringWithFormat:@"%g", temp];
            
        } else {
            
            // 其他操作符, Enter + 执行操作;
            [self enterPressed];
            [self performOperation:operation];
        }
        
    } else {
        
        // 首位状态, 不区分操作符, 均执行操作;
        [self performOperation:operation];
    }
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
    
    // step 显示步骤
    [self stepDisplayUpdate];
}

// 监听变量点击
- (IBAction)variablePressed:(UIButton *)sender {
    
    if (self.userIsInTheMiddleOfTypingANumber) {
        
        // 之前输入中, 先 Enter;
        [self enterPressed];
    }
    
    // 变量直接显示, 并 Enter;
    [self displayUpdateWithStr:sender.currentTitle isAppend:NO];
    [self enterPressed];
    
    // Label 显示变量
    [self variableUpdate];
}

// 监听测试点击
- (IBAction)testPressed:(UIButton *)sender {
    
    if ([sender.currentTitle isEqualToString:@"T+"]) {
        self.variableValues = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithInt:100], @"x",
                               [NSNumber numberWithInt:200], @"y",
                               [NSNumber numberWithInt:300], @"a",
                               [NSNumber numberWithInt:400], @"b",
                               nil];
        
    } else if ([sender.currentTitle isEqualToString:@"T-"]) {
        self.variableValues = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithInt:-100], @"x",
                               [NSNumber numberWithInt:-200], @"y",
                               [NSNumber numberWithInt:-300], @"a",
                               [NSNumber numberWithInt:-400], @"b",
                               nil];
        
    } else if ([sender.currentTitle isEqualToString:@"nil"]) {
        self.variableValues = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNull null], @"x",
                               [NSNull null], @"y",
                               [NSNull null], @"a",
                               [NSNull null], @"b",
                               nil];
    }
    
    // 重新执行运算
    double result = [CalculatorBrain runProgram:self.brain.program usingVariableValues:self.variableValues];
    
    // 刷新显示
    [self stepDisplayUpdate];
    [self displayUpdateWithStr:[NSString stringWithFormat:@"%g", result] isAppend:NO];
    [self variableUpdate];
}

// 监听回退操作
- (IBAction)backspace {
    
    // 计算长度减 1
    NSUInteger index = self.display.text.length - 1;
    
    if (index > 0) {
        
        // 非个位回退 = 长度减 1
        self.display.text = [self.display.text substringToIndex:index];
        
    } else {
        
        // 个位回退归 0, 重置首位状态;
        self.display.text = @"0";
        self.userIsInTheMiddleOfTypingANumber = NO;
    }
    
    // 0 再退
    if ([self.display.text isEqualToString:@"0"]) {
        
        // 取出栈顶, 重新运算;
        [self.brain clearLast];
        double result = [CalculatorBrain runProgram:self.brain.program usingVariableValues:self.variableValues];
        
        // 刷新显示(结果+步骤)
        [self displayUpdateWithStr:[NSString stringWithFormat:@"%g", result] isAppend:NO];
        [self stepDisplayUpdate];
    }
}

// 监听清除键点击
- (IBAction)clear {
    
    // 重置显示、存储、状态
    self.display.text = @"0";
    self.stepDisplay.text = @"";
    self.variableDisplay.text = @"";
    self.variableValues = nil;
    self.userIsInTheMiddleOfTypingANumber = NO;
    
    // 模型的 Clear 方法
    [self.brain clear];
}

///--------------------------------------
#pragma mark - update views
///--------------------------------------

// 更新步骤显示
- (void)stepDisplayUpdate {
    
    self.stepDisplay.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
}

// 更新结果显示
- (void)displayUpdateWithStr:(NSString *)str isAppend:(BOOL)isAppend {
    
    if (isAppend) {
        
        // 非首位拼接
        self.display.text = [self.display.text stringByAppendingString:str];
        
    } else if ([str isEqualToString:@"."]) {
        
        // 首位小数点直接赋值
        self.display.text = @"0.";
        
    } else {
        
        // 首位其他直接赋值
        self.display.text = str;
    }
}

// 更新变量显示
- (void)variableUpdate {
    
    // 默认显示空
    NSString *variablesDisplay = @"";
    
    // 取得变量集合
    NSSet *variables = [CalculatorBrain variablesUsedInProgram:self.brain.program];
    
    // 遍历全部变量
    for (NSString *variable in variables) {
        
        // 取出对应值
        NSNumber *value = [self.variableValues objectForKey:variable];
        
        // 当前变量无值时, 显示 0;
        if (!value || [value isKindOfClass:[NSNull class]]) {
            value = [NSNumber numberWithInt:0];
        }
        
        // 更新显示
        variablesDisplay = [variablesDisplay stringByAppendingFormat:@"%@ = %@ ", variable, value];
    }
    
    // 显示变量
    self.variableDisplay.text = variablesDisplay;
}

///--------------------------------------
#pragma mark - helper/private methods
///--------------------------------------

// 执行操作
- (void)performOperation:(NSString *)operation {
    
    // 执行操作, 返回结果
    double result = [self.brain performOperation:operation withVariables:self.variableValues];

    // 结果字符串
    NSString *resultStr = [NSString stringWithFormat:@"%g", result];
    
    // display 显示结果
    [self displayUpdateWithStr:resultStr isAppend:NO];
    
    // step 显示步骤;
    [self stepDisplayUpdate];
}

@end
