//
//  TrainingTime.m
//  TrainingTimer
//
//  Created by sungeo on 15/3/21.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import "TrainingUnit.h"

NSString * const TrainingUnitTypeKey    = @"trainingUnitType";
NSString * const TrainingUnitTimeLength = @"trainingUnitTimeLength";
NSString * const TrainingUnitIndex      = @"trainingUnitTimeIndex";

@implementation TrainingUnit

- (instancetype)initWithDictionary:(NSDictionary *)dictionary{
    if (self = [super init]) {
        _type = dictionary[TrainingUnitTypeKey];
        _index = dictionary[TrainingUnitIndex];
        _timeLength = dictionary[TrainingUnitTimeLength];
    }
    
    return self;
}

- (BOOL)isTrainingUnit{
    TrainingUnitTypeEnum type = (TrainingUnitTypeEnum)[_type integerValue];
    if (type == TrainingUnitTypeSkipping) {
        return YES;
    }else{
        return NO;
    }
}

- (NSString *)description{
    TrainingUnitTypeEnum type = (TrainingUnitTypeEnum)[_type integerValue];
    return [[self class] descriptionForType:type];
}

+ (TrainingUnit *)trainingUnitWithType:(TrainingUnitTypeEnum)type interval:(NSInteger)interval{
    TrainingUnit * unit = [[TrainingUnit alloc] init];
    unit.type = @(type);
    unit.timeLength = @(interval);
    
    return unit;
}

+ (NSString *)descriptionForType:(TrainingUnitTypeEnum)type{
    switch (type) {
        case TrainingUnitTypeWarmUp:
            return @"热身期";
        case TrainingUnitTypeSkipping:
            return @"跳绳训练";
        case TrainingUnitTypeRest:
            return @"休息期";
    }
}

@end
