目录
--
[toc]

一、Instument
---
**不满足需求**： 虽然支持指令，但是需要开发者尽可能的模拟足够多的场景，手动参与，过于繁琐。
再者由于intrument的指令对象是 .app文件，无法通过xcode的UITest去跑顺便分析。此路不通~~~

二、FBMemoryProfile
---

#### 简介

**github**: https://github.com/facebook/FBMemoryProfiler

实时收集和监测对象的内存占用情况的组件

#### 组成部分
- **FBMemoryProfile**：依赖下面2个组件的应用内可视化监测器组件。
- **FBAllocationTracker**：检测内存中存在的NSObject对象的情况, 提供便利一个类所有属性的接口
- **FBRetainCycleDetector**：通过runtime便利属性寻找存在的循环引用

#### FBAllocationTracker 介绍

- **初始化**

```objc
 // hook NSObject的alloc和delloc
 [[FBAllocationTrackerManager sharedManager] startTrackingAllocations];
 // 开始监测
 [[FBAllocationTrackerManager sharedManager] enableGenerations];
```
- **获取内存中存活的所有类和对象**

```objc
NSArray <FBAllocationTrackerSummary *>*currentAllocationSummary = [[FBAllocationTrackerManager sharedManager] currentAllocationSummary];
```

- **Generations简介**

通过 

```
[[FBAllocationTrackerManager sharedManager] markGeneration]
```
来创建 Generation ，创建后 之后创建的对象都会有这个Generation 持有。


```
- (void)someFunction {
  // Enable generations (if not already enabled in main.m)
  [[FBAllocationTrackerManager sharedManager] enableGenerations];
 
  // Object a will be kept in generation with index 0
  NSObject *a = [NSObject new];
  
  // We are marking new generation
  [[FBAllocationTrackerManager sharedManager] markGeneration];
  
  // Objects b and c will be kept in second generation at index 1
  NSObject *b = [NSObject new];
  NSObject *c = [NSObject new];
  
  [[FBAllocationTrackerManager sharedManager] markGeneration];
  
  // Object d will be kept in third generation at index 2
  NSObject *d = [NSObject new];
}

NSArray *instances =[[FBAllocationTrackerManager sharedManager] instancesForClass:[NSObject class]
                                                                     inGeneration:1];
```

这样就可以区分和分析不同场景创建的对象。

#### FBRetainCycleDetector 介绍

**初始化**

对象通过 OBJC_ASSOCIATION_RETAIN_NONATOMIC 方式创建都会可能产生 引用循环，所以需要跟踪此类对象的创建，初始化代码如下

```
#import <FBRetainCycleDetector/FBAssociationManager.h>

int main(int argc, char * argv[]) {
  @autoreleasepool {
    [FBAssociationManager hook];
    return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
  }
}
```


**快速使用：**

```objc
#import <FBRetainCycleDetector/FBRetainCycleDetector.h>

FBRetainCycleDetector *detector = [FBRetainCycleDetector new];
[detector addCandidate:myObject];
NSSet *retainCycles = [detector findRetainCycles];
//NSSet *retainCycles = [detector findRetainCyclesWithMaxCycleLength:100];
NSLog(@"%@", retainCycles);
```

**过滤：**

过滤掉存在的循环引用组合。

```
NSArray<FBGraphEdgeFilterBlock> *FBGetStandardGraphEdgeFilters() {
#if _INTERNAL_RCD_ENABLED
  static Class heldActionClass;
  static Class transitionContextClass;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    heldActionClass = NSClassFromString(@"UIHeldAction");
    transitionContextClass = NSClassFromString(@"_UIViewControllerOneToOneTransitionContext");
  });

  return @[FBFilterBlockWithObjectIvarRelation([UIView class], @"_subviewCache"),
           FBFilterBlockWithObjectIvarRelation(heldActionClass, @"m_target"),
           FBFilterBlockWithObjectToManyIvarsRelation([UITouch class],
                                                      [NSSet setWithArray:@[@"_view",
                                                                            @"_gestureRecognizers",
                                                                            @"_window",
                                                                            @"_warpedIntoView"]]),
           FBFilterBlockWithObjectToManyIvarsRelation(transitionContextClass,
                                                      [NSSet setWithArray:@[@"_toViewController",
                                                                            @"_fromViewController"]])];
#else
  return nil;
#endif // _INTERNAL_RCD_ENABLED
}

```

使用过滤数组：

```objc
// Configuration object can describe filters as well as some options
FBObjectGraphConfiguration *configuration =
[[FBObjectGraphConfiguration alloc] initWithFilterBlocks:filters
                                     shouldInspectTimers:YES];
FBRetainCycleDetector *detector = [[FBRetainCycleDetector alloc] initWithConfiguration:configuration];
[detector addCandidate:myObject];
NSSet *retainCycles = [detector findRetainCycles];
```


*注意：*

- scheduledTimerWithTimeInterval: repeats: block: 这个方法类无法过滤，以为这个是“_NSTimerBlockTarget”类而不是“__NSCFTimer”类；facebook可能未更新，，，这个iOS10才出来的
- 必须对象持有NSTimer，才会有内存泄漏，否则无反应；

三：封装 FBAllocationTracker和FBRetainCycleDetector
--

#### 说明：

FBMemoryProfiler 其实就是 FBAllocationTracker和FBRetainCycleDetector的封装的可视化组件，内嵌于app。如果我们需要实现自动化捕捉内存泄漏，那么FBMemoryProfiler不适用。只需要简单使用 内存检测 和 循环引用捕捉 2个框架即可。

#### 主要代码示例

```
+ (NSSet *)retainCycles
{
    NSArray <FBAllocationTrackerSummary *>*currentAllocationSummary = [[FBAllocationTrackerManager sharedManager] currentAllocationSummary];
    
    NSSet *cycles = [NSSet set];
    
    for (FBAllocationTrackerSummary *summary in currentAllocationSummary)
    {
        Class aCls = NSClassFromString(summary.className);
        NSArray *objects = [[FBAllocationTrackerManager sharedManager] instancesOfClasses:@[aCls]];
        
        FBObjectGraphConfiguration *configuration = [[FBObjectGraphConfiguration alloc] initWithFilterBlocks:FBGetStandardGraphEdgeFilters() shouldInspectTimers:YES];
        FBRetainCycleDetector *detector = [[FBRetainCycleDetector alloc] initWithConfiguration:configuration];
        
        for (id object in objects) {
            [detector addCandidate:object];
        }
        
        NSSet<NSArray<FBObjectiveCGraphElement *> *> *retainCycles = [detector findRetainCyclesWithMaxCycleLength:10];
        
        cycles = [cycles setByAddingObjectsFromSet:retainCycles];
    }
    
    return cycles;
}
```

#### 实现不嵌入代码主要的事项

**主Framework包**：
- 初始化用钩子进行自动初始化，ps：在struct的构造方法里勾取系统的 UIApplication的setAppdelegate：方法。
- 测试工程需要添加 Other link flag : -all_load

**单元测试Target**:
- 由于不能嵌入代码，所以无法用集成，用钩子勾取 XTTestCase的tearDown方法。监测每一个单元测试的结束。
- [XTTestCase testInvocations]可以获取到该单元测试里面的所有单元测试，统计个数即可知道所有单元测试结束。
- XCTActivity 协议里面的 name为当前执行单元测试方法的名称。

#### Jenkins部署的实现思路

具体参考jenkins
- xcode集成上述 封装好的 frameswork，执行单元测试即可
- 获取 Jenkins该job的log文件，截取我们想要的 日志文本
- html 展示。
