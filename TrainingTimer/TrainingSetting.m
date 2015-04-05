//
//  TrainingSetting.m
//  TrainingTimer
//
//  Created by sungeo on 15/4/4.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import "TrainingSetting.h"
#import <TMCache.h>

static NSString * const kKey = @"trainingSettingKey";

@implementation TrainingSetting

+ (instancetype)sharedInstance{
    static TrainingSetting * sInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (sInstance == nil) {
            TMDiskCache * cache = [TMDiskCache sharedCache];
            sInstance = (TrainingSetting *)[cache objectForKey:kKey];
            if (sInstance == nil) {
                sInstance = [[TrainingSetting alloc] init];
            }
        }
    });
    
    return sInstance;
}

- (instancetype)init{
    if (self = [super init]) {
        _warmUpTime = @(120);
        _skippingTime = @(60);
        _restTime = @(20);
        _rounds = @(4);
    }
    
    return self;
}

- (void)setWarmUpTime:(NSNumber *)warmUpTime{
    _warmUpTime = warmUpTime;
    [self syncToDisk];
}

- (void)setRestTime:(NSNumber *)restTime{
    _restTime = restTime;
    [self syncToDisk];
}

- (void)setSkippingTime:(NSNumber *)skippingTime{
    _skippingTime = skippingTime;
    [self syncToDisk];
}

- (void)setRounds:(NSNumber *)rounds{
    _rounds = rounds;
    [self syncToDisk];
}

- (void)syncToDisk{
    [[TMDiskCache sharedCache] setObject:self forKey:kKey];
}


@end
