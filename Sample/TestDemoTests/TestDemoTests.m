//
//  TestDemoTests.m
//  TestDemoTests
//
//  Created by Max on 2018/4/25.
//  Copyright © 2018年 Max. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ViewController.h"

@interface TestDemoTests : XCTestCase

@end

@implementation TestDemoTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    
    NSLog(@"-------------");
}

- (void)testVC
{
    ViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    [vc test];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
