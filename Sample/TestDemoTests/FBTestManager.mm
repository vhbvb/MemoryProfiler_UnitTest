//
//  FBTestCase.m
//  TestDemoTests
//
//  Created by Max on 2018/4/25.
//  Copyright © 2018年 Max. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <FBMemoryLeakDetecter/FBMemoryLeakDetecter.h>
#import <FBMemoryLeakDetecter/FBObjectiveCGraphElement.h>
#import <objc/runtime.h>
#import <objc/message.h>

@interface FBTestManager : NSObject

@property (nonatomic, strong) NSMutableDictionary *retainCycles;

@end

@implementation FBTestManager

+ (instancetype)shareManager
{
    static FBTestManager *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[FBTestManager alloc] init];
    });
    
    return singleton;
}

- (void)detectRetainCyclesWithTest:(XCTestCase *)test
{
    NSSet *retainCycles = [FBMemoryLeakDetecter retainCycles];
    for (NSArray *obj in retainCycles)
    {
        NSMutableArray *elementStrings = [self _descriptionsWithCycleElements:obj];
        NSString *cycleDes = [self _jsonStringWithObject:elementStrings];
        if (cycleDes.length)
        {
            if (self.retainCycles[cycleDes])
            {
                [self.retainCycles[cycleDes] addObject:test.name];
            }
            else
            {
                self.retainCycles[cycleDes] = @[test.name?:@"unknown method name"].mutableCopy;
            }
        }
    }
    
    static NSInteger i = 0;
    i++;
    
    if (i == [test.class testInvocations].count)
    {
        [self generateLogForTest:test];
    }
}

- (NSMutableDictionary *)retainCycles
{
    if (!_retainCycles)
    {
        _retainCycles = [NSMutableDictionary dictionary];
    }
    return _retainCycles;
}

- (NSMutableArray *)_descriptionsWithCycleElements:(NSArray *)elements
{
    NSMutableArray *elementStrings = [NSMutableArray array];
    
    for (FBObjectiveCGraphElement *element in elements)
    {
        NSMutableArray *array = [NSMutableArray array];
        
        if (element.namePath.count)
        {
            [array addObjectsFromArray:element.namePath];
        }
        
        [array addObject:element.classNameOrNull];
        
        [elementStrings addObject:array];
    }
    
    return elementStrings;
}

- (NSString *)_jsonStringWithObject:(id)object
{
    NSError *error = nil;
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
    if (!error)
    {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    else
    {
        NSLog(@"FBMemoryLeakDetecter: Convent to json error!");
        return nil;
    }
}

- (void)generateLogForTest:(XCTestCase *)test
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString *now = [formatter stringFromDate:[NSDate date]];
    
    NSDictionary *logInfo = @{@"date":now,
                          @"test":NSStringFromClass(test.class)?:@"unknow Test",
                          @"retainCycles":self.retainCycles
                          };
    NSString *logStr = [self _jsonStringWithObject:logInfo];
    
    sleep(10);
    printf("%s",[NSString stringWithFormat:@"\n>>retainCycleLeft<<\n%@\n>>retainCycleRight<<",logStr].UTF8String);
    sleep(10);
}
    
@end


static void MLDTearDownIMP(id self, SEL cmd)
{
    [[FBTestManager shareManager] detectRetainCyclesWithTest:self];
    SEL hookTearDown = NSSelectorFromString(@"MLDTTearDown");
    if ([self respondsToSelector:hookTearDown])
    {
        ((void(*)(id,SEL))objc_msgSend)(self,hookTearDown);
    }
}

struct MLDTestMain
{
    MLDTestMain()
    {
        SEL hookTearDown = NSSelectorFromString(@"MLDTTearDown");
        
        if (![XCTestCase instancesRespondToSelector:hookTearDown])
        {
            class_addMethod(XCTestCase.class, hookTearDown, (IMP)MLDTearDownIMP, "v@:");
        }
        
        if ([XCTestCase instancesRespondToSelector:hookTearDown])
        {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                method_exchangeImplementations(
                                               class_getInstanceMethod(XCTestCase.class, @selector(tearDown)),
                                               class_getInstanceMethod(XCTestCase.class, hookTearDown));
            });
        }
    }
};

static MLDTestMain mldMain;
