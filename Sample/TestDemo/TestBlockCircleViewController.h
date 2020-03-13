//
//  TestBlockCircleViewController.h
//  MemoryLeakDetecter
//
//  Created by Max on 2018/4/23.
//  Copyright © 2018年 Max. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestBlockCircleViewController : UIViewController

@property (nonatomic, copy) void(^changeColor)(void);

@end
