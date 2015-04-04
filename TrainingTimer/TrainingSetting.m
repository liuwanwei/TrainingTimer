//
//  TrainingSetting.m
//  TrainingTimer
//
//  Created by sungeo on 15/4/4.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import "TrainingSetting.h"
#import <TMCache.h>

static NSString * const kKey = @"key";

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
                sInstance.warmUpTime = @(120);
                sInstance.skippingTime = @(60);
                sInstance.restTime = @(20);
                sInstance.rounds = @(4);
            }
        }
    });
    
    return sInstance;
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
