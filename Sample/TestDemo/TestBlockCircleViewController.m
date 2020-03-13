//
//  TestBlockCircleViewController.m
//  MemoryLeakDetecter
//
//  Created by Max on 2018/4/23.
//  Copyright © 2018年 Max. All rights reserved.
//

#import "TestBlockCircleViewController.h"

@interface TestBlockCircleViewController ()

@end

@implementation TestBlockCircleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)changeColor:(id)sender
{
    _changeColor();
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
