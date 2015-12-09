//
//  CalculatorViewController.h
//  Calculator
//
//  Created by Aixtuz Kang on 15/12/6.
//  Copyright © 2015年 Aixtuz Kang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalculatorViewController : UIViewController

///  逆波兰式
@property (weak, nonatomic) IBOutlet UILabel *stepDisplay;
///  当前输入
@property (weak, nonatomic) IBOutlet UILabel *display;

@end
