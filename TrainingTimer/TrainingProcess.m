//
//  TrainingProcess.m
//  TrainingTimer
//
//  Created by sungeo on 15/3/21.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import "TrainingProcess.h"
#import "TrainingUnit.h"
#import "TrainingSetting.h"

@implementation TrainingProcess

- (instancetype)initWithTitle:(NSString *)title{
    if (self = [super initWithUUID]) {
        _title = title;
        _units = [NSMutableArray array];
    }
    
    return self;
}

+ (instancetype)trainingProcessFromSetting{
    if (TrainingDebug) {
        return [[self class] testObject];
    }
    
    TrainingProcess * process = [[TrainingProcess alloc] initWithTitle:@""];
    TrainingSetting * setting = [TrainingSetting sharedInstance];
    
    // 准备时间单元
    TrainingUnit * unit = [TrainingUnit trainingUnitWithType:TrainingUnitTypeWarmUp
                                                    interval:setting.warmUpTime.integerValue];
    [process addUnit:unit];
    
    // 训练时间单元
    NSInteger round = setting.rounds.integerValue;
    for (NSInteger i = 0; i < round; i++) {
        unit = [TrainingUnit trainingUnitWithType:TrainingUnitTypeSkipping
                                         interval:setting.skippingTime.integerValue];
        [process addUnit:unit];
        
        unit = [TrainingUnit trainingUnitWithType:TrainingUnitTypeRest
                                         interval:setting.restTime.integerValue];
        unit.index = @(i);
        [process addUnit:unit];
    }
    
    return process;
}

- (NSString *)description{
    return _title;
}

- (void)addUnit:(TrainingUnit *)unit{
    if (![_units containsObject:unit]) {
        if (_units == nil) {
            _units = [NSMutableArray array];
        }
        
        [_units addObject:unit];
    }
}

- (void)deleteUnit:(TrainingUnit *)unit{
    if ([_units containsObject:unit]) {
        [_units removeObject:unit];
    }
}

BOOL TrainingDebug = NO;

+ (NSArray *)tdataes{
    NSArray * units = @[@{TrainingUnitIndex:@(1),
                          TrainingUnitTypeKey:@(TrainingUnitTypeWarmUp),
                          TrainingUnitTimeLength:@(2)},
                        
                        @{TrainingUnitIndex:@(2),
                          TrainingUnitTypeKey:@(TrainingUnitTypeSkipping),
                          TrainingUnitTimeLength:@(60)},
                        
                        @{TrainingUnitIndex:@(3),
                          TrainingUnitTypeKey:@(TrainingUnitTypeRest),
                          TrainingUnitTimeLength:@(30)},
                        
                        @{TrainingUnitIndex:@(4),
                          TrainingUnitTypeKey:@(TrainingUnitTypeSkipping),
                          TrainingUnitTimeLength:@(2)},
                        
                        @{TrainingUnitIndex:@(5),
                          TrainingUnitTypeKey:@(TrainingUnitTypeRest),
                          TrainingUnitTimeLength:@(2)},
                        @{TrainingUnitIndex:@(4),
                          TrainingUnitTypeKey:@(TrainingUnitTypeSkipping),
                          TrainingUnitTimeLength:@(2)},
                        
                        @{TrainingUnitIndex:@(5),
                          TrainingUnitTypeKey:@(TrainingUnitTypeRest),
                          TrainingUnitTimeLength:@(2)},
                        @{TrainingUnitIndex:@(4),
                          TrainingUnitTypeKey:@(TrainingUnitTypeSkipping),
                          TrainingUnitTimeLength:@(2)},
                        ];
    
    return units;
}


+ (instancetype)testObject{
    TrainingProcess * process = [[TrainingProcess alloc] initWithTitle:@"测试"];
    NSArray * units = [[self class] tdataes];
    
    TrainingUnit * unit;
    NSEnumerator * enumerator = [units objectEnumerator];
    id object;
    while ((object = [enumerator nextObject])) {
        unit = [[TrainingUnit alloc] initWithDictionary:object];
        NSLog(@"%@", unit);
        [process addUnit:unit];
    }
    
    return process;
}


@end
