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
    
//    NSArray * objects = (NSArray *)[[TMDiskCache sharedCache] objectForKey:kRootNode];
//    if (objects.count != 0) {
//        _trainingProcesses = [objects mutableCopy];
//    }else{
        _trainingProcesses = [[NSMutableArray alloc] init];
        // FIXME: 生成一条默认测试数据
        TrainingProcess * process = [[TrainingProcess alloc] initWithTitle:@"疯狂减脂训练"];
        
        NSArray * units = [self tdataes];

        TrainingUnit * unit;
        NSEnumerator * enumerator = [units objectEnumerator];
        id object;
        while ((object = [enumerator nextObject])) {
            unit = [[TrainingUnit alloc] initWithDictionary:object];
            NSLog(@"%@", unit);
            [process addUnit:unit];
        }

        [self saveTrainingProcess:process];
//    }
    
    // 创建一条测试记录
    TrainingRecord * record = [[TrainingRecord alloc] initWithUnits:process.units];
    [self addRecord:record];
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
        [_rawRecords addObject:aRecord];
        [self publish:TrainingRecordsChangedNote];
    }
}

- (NSArray *)records{
    return [_rawRecords copy];
}

- (NSArray *)dataes{
    NSArray * units = @[@{TrainingUnitIndex:@(1),
                          TrainingUnitTypeKey:@(TrainingUnitTypeWarmUp),
                          TrainingUnitTimeLength:@(120)},
                        
                        @{TrainingUnitIndex:@(2),
                          TrainingUnitTypeKey:@(TrainingUnitTypeSkipping),
                          TrainingUnitTimeLength:@(60)},
                        
                        @{TrainingUnitIndex:@(3),
                          TrainingUnitTypeKey:@(TrainingUnitTypeRest),
                          TrainingUnitTimeLength:@(20)},
                        
                        @{TrainingUnitIndex:@(4),
                          TrainingUnitTypeKey:@(TrainingUnitTypeSkipping),
                          TrainingUnitTimeLength:@(60)},
                        
                        @{TrainingUnitIndex:@(5),
                          TrainingUnitTypeKey:@(TrainingUnitTypeRest),
                          TrainingUnitTimeLength:@(20)},
                        
                        @{TrainingUnitIndex:@(6),
                          TrainingUnitTypeKey:@(TrainingUnitTypeSkipping),
                          TrainingUnitTimeLength:@(60)},
                        
                        @{TrainingUnitIndex:@(7),
                          TrainingUnitTypeKey:@(TrainingUnitTypeRest),
                          TrainingUnitTimeLength:@(20)},
                        
                        @{TrainingUnitIndex:@(8),
                          TrainingUnitTypeKey:@(TrainingUnitTypeSkipping),
                          TrainingUnitTimeLength:@(60)},
                        
                        @{TrainingUnitIndex:@(9),
                          TrainingUnitTypeKey:@(TrainingUnitTypeRest),
                          TrainingUnitTimeLength:@(20)},
                        
                        @{TrainingUnitIndex:@(10),
                          TrainingUnitTypeKey:@(TrainingUnitTypeSkipping),
                          TrainingUnitTimeLength:@(60)},
                        
                        @{TrainingUnitIndex:@(11),
                          TrainingUnitTypeKey:@(TrainingUnitTypeRest),
                          TrainingUnitTimeLength:@(20)},
                        
                        @{TrainingUnitIndex:@(12),
                          TrainingUnitTypeKey:@(TrainingUnitTypeSkipping),
                          TrainingUnitTimeLength:@(60)}];
    
    return units;
}

- (NSArray *)tdataes{
    NSArray * units = @[@{TrainingUnitIndex:@(1),
                          TrainingUnitTypeKey:@(TrainingUnitTypeWarmUp),
                          TrainingUnitTimeLength:@(5)},
                        
                        @{TrainingUnitIndex:@(2),
                          TrainingUnitTypeKey:@(TrainingUnitTypeSkipping),
                          TrainingUnitTimeLength:@(5)},
                        
                        @{TrainingUnitIndex:@(3),
                          TrainingUnitTypeKey:@(TrainingUnitTypeRest),
                          TrainingUnitTimeLength:@(5)},
                        
                        @{TrainingUnitIndex:@(4),
                          TrainingUnitTypeKey:@(TrainingUnitTypeSkipping),
                          TrainingUnitTimeLength:@(5)},
                        
                        @{TrainingUnitIndex:@(5),
                          TrainingUnitTypeKey:@(TrainingUnitTypeRest),
                          TrainingUnitTimeLength:@(5)},
                        
                        @{TrainingUnitIndex:@(6),
                          TrainingUnitTypeKey:@(TrainingUnitTypeSkipping),
                          TrainingUnitTimeLength:@(60)},
                        
                        @{TrainingUnitIndex:@(7),
                          TrainingUnitTypeKey:@(TrainingUnitTypeRest),
                          TrainingUnitTimeLength:@(20)},
                        
                        @{TrainingUnitIndex:@(8),
                          TrainingUnitTypeKey:@(TrainingUnitTypeSkipping),
                          TrainingUnitTimeLength:@(60)},
                        
                        @{TrainingUnitIndex:@(9),
                          TrainingUnitTypeKey:@(TrainingUnitTypeRest),
                          TrainingUnitTimeLength:@(20)},
                        
                        @{TrainingUnitIndex:@(10),
                          TrainingUnitTypeKey:@(TrainingUnitTypeSkipping),
                          TrainingUnitTimeLength:@(60)},
                        
                        @{TrainingUnitIndex:@(11),
                          TrainingUnitTypeKey:@(TrainingUnitTypeRest),
                          TrainingUnitTimeLength:@(20)},
                        
                        @{TrainingUnitIndex:@(12),
                          TrainingUnitTypeKey:@(TrainingUnitTypeSkipping),
                          TrainingUnitTimeLength:@(60)}];
    
    return units;
}


@end
