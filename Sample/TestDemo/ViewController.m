//
//  ViewController.m
//  MemoryLeakDetecter
//
//  Created by Max on 2018/4/23.
//  Copyright © 2018年 Max. All rights reserved.
//

#import "ViewController.h"
#import "TestTimerViewController.h"
#import "TestRetainCircleViewController.h"
#import <FBMemoryLeakDetecter/FBMemoryLeakDetecter.h>
#import "TestBlockCircleViewController.h"

@interface ViewController ()
{
    TestRetainCircleViewController * _vc;
    TestBlockCircleViewController *_vc2;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)timer:(id)sender
{
    [self presentViewController:[TestTimerViewController new] animated:YES completion:nil];
}

- (IBAction)delegate:(id)sender
{
    _vc = [TestRetainCircleViewController new];
    _vc.delegate = self;

    [self presentViewController:_vc animated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
   NSLog(@"%@",[FBMemoryLeakDetecter retainCycles]);
}

- (void)didFindRetainCycles:(NSSet *)retainCycles
{
    NSLog(@"%@",retainCycles);
}

- (IBAction)block:(id)sender
{
    _vc2  = [TestBlockCircleViewController new];
    _vc2.changeColor = ^{
        self.view.backgroundColor = [UIColor redColor];
    };
    
    [self presentViewController:_vc2 animated:YES completion:nil];
}

- (void)test
{
    [self timer:nil];
}

@end
