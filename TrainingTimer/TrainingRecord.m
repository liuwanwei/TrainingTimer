//
//  TrainingRecord.m
//  TrainingTimer
//
//  Created by sungeo on 15/4/4.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import "TrainingRecord.h"
#import "TrainingUnit.h"
#import <DateTools.h>

@implementation TrainingRecord

- (instancetype)initWithUnits:(NSArray *)trainingUnits{
    if (self = [super initWithUUID]) {
        NSEnumerator * enumerator = [trainingUnits objectEnumerator];
        TrainingUnit * unit;
        NSInteger seconds = 0;
        NSInteger rounds = 0;
        while ((unit = [enumerator nextObject])) {
            seconds += unit.timeLength.integerValue;
            
            if ([unit isTrainingUnit]) {
                rounds ++;
            }
        }
        
        _totalTime = @(seconds);
        _rounds = @(rounds);
    }
    
    return self;
}

- (NSString *)date{
    return [self.createDate timeAgoSinceNow];
}

- (NSString *)description{
    // 如：完成三组训练，共耗时15分钟
    NSString * desc = [NSString stringWithFormat:@"%@组训练，耗时 ", _rounds];
    NSInteger minutes = _totalTime.integerValue / 60;
    NSInteger seconds = _totalTime.integerValue % 60;
    if (minutes > 0) {
        desc = [desc stringByAppendingFormat:@"%02zd分", minutes];
    }
    
    if (seconds > 0) {
        desc = [desc stringByAppendingFormat:@"%02zd秒", seconds];
    }
    
//    if (_numberOfSkipping.integerValue > 0) {
//        desc = [desc stringByAppendingFormat:@"%@次", _numberOfSkipping];
//    }
    
    return desc;
}

@end
