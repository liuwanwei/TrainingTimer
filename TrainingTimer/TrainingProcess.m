//
//  TrainingProcess.m
//  TrainingTimer
//
//  Created by sungeo on 15/3/21.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import "TrainingProcess.h"
#import "TrainingUnit.h"

@implementation TrainingProcess

- (instancetype)initWithTitle:(NSString *)title{
    if (self = [super initWithUUID]) {
        _title = title;
        _units = [NSMutableArray array];
    }
    
    return self;
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

@end
