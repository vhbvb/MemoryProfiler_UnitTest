//
//  TestTimerViewController.m
//  MemoryLeakDetecter
//
//  Created by Max on 2018/4/23.
//  Copyright © 2018年 Max. All rights reserved.
//

#import "TestTimerViewController.h"

@interface TestTimerViewController ()
{
    NSInteger i;
    NSTimer *_timer;
}
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation TestTimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //坑爹
//   _timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
//        self.label.text = [NSString stringWithFormat:@"%zd",i++];
//    }];
    
//    i = 0;
  _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(test) userInfo:nil repeats:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc
{
    NSLog(@"----------%s---------",__func__);
}

- (void)test
{
    self.label.text = [NSString stringWithFormat:@"%zd",i++];
}


@end
