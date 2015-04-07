//
//  DataCenter.m
//  TrainingTimer
//
//  Created by sungeo on 15/3/21.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import "TrainingData.h"
#import "TrainingUnit.h"
#import "TrainingProcess.h"
#import <TMCache.h>
#import <GLPubSub/NSObject+GLPubSub.h>

NSString * const TrainingProcessChangedNote = @"trainingProcessChanged";
NSString * const TrainingRecordsChangedNote = @"trainingRecordsChanged";

static NSString * const kRootNode = @"rootNode";
static NSString * const kRecordsNode = @"recordsNode";

@implementation TrainingData{
    NSMutableArray * _rawRecords;
}

+ (instancetype)defaultInstance{
    static TrainingData * sInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (sInstance == nil) {
            sInstance = [[TrainingData alloc] init];
        }
    });
    
    return sInstance;
}

- (void)loadDataes{
    // 加载历史记录
    TMDiskCache * diskCache = [TMDiskCache sharedCache];
    NSArray * objects = (NSArray *)[diskCache objectForKey:kRecordsNode];
    if (objects) {
        _rawRecords = [objects mutableCopy];
    }else{
        _rawRecords = [NSMutableArray array];
    }
    
    _rawRecords = [[_rawRecords sortedArrayUsingComparator:^(id obj1, id obj2){
        TrainingRecord * record1 = (TrainingRecord *)obj1;
        TrainingRecord * record2 = (TrainingRecord *)obj2;
        
        NSComparisonResult result = [record1.createDate compare:record2.createDate];
        if (result == NSOrderedAscending) {
            return NSOrderedDescending;
        }else if(result == NSOrderedDescending){
            return NSOrderedAscending;
        }else{
            return result;
        }
    }] mutableCopy];
}

- (void)saveTrainingProcess:(TrainingProcess *)process{
    if (! [_trainingProcesses containsObject:process]) {
        [_trainingProcesses addObject:process];
        
        [[TMDiskCache sharedCache] setObject:_trainingProcesses forKey:kRootNode];
        [self publish:TrainingProcessChangedNote];
    }
}

- (void)addRecord:(TrainingRecord *)aRecord{
    if (aRecord) {
        [_rawRecords insertObject:aRecord atIndex:0];
        [[TMDiskCache sharedCache] setObject:_rawRecords forKey:kRecordsNode];
        [self publish:TrainingRecordsChangedNote];
    }
}

- (NSArray *)records{
    return [_rawRecords copy];
}

@end
