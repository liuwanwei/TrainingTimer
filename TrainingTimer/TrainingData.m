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

NSString * const TrainingProcessChangedNote = @"trainingProcessChanged";

static NSString * const kRootNode = @"rootNode";

@implementation TrainingData

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
}

- (void)saveTrainingProcess:(TrainingProcess *)process{
    if (! [_trainingProcesses containsObject:process]) {
        [_trainingProcesses addObject:process];
        
        [[TMDiskCache sharedCache] setObject:_trainingProcesses forKey:kRootNode];
        [self postChangedNotification];        
    }
}

- (void)postChangedNotification{
    [[NSNotificationCenter defaultCenter] postNotificationName:TrainingProcessChangedNote object:self];
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
