//
//  FBLeakTrackManager.m
//  MemoryLeakDetecter
//
//  Created by Max on 2018/4/23.
//  Copyright © 2018年 Max. All rights reserved.
//

#import "FBMemoryLeakDetecter.h"
#import "FBAllocationTracker.h"
#import "FBRetainCycleDetector.h"

struct MLDMain
{
    MLDMain()
    {
        [FBAssociationManager hook];
        [[FBAllocationTrackerManager sharedManager] startTrackingAllocations];
        [[FBAllocationTrackerManager sharedManager] enableGenerations];
    }
};

static MLDMain mldMain;

@implementation FBMemoryLeakDetecter

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

@end
