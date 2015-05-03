//
//  TrainingSetting.h
//  TrainingTimer
//
//  Created by sungeo on 15/4/4.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import "BaseModel.h"

@interface TrainingSetting : BaseModel

@property (nonatomic, strong) NSNumber * warmUpTime;
@property (nonatomic, strong) NSNumber * skippingTime;
@property (nonatomic, strong) NSNumber * restTime;
@property (nonatomic, strong) NSNumber * rounds;

@property (nonatomic) BOOL soundEffect;

+ (instancetype)sharedInstance;

- (void)syncToDisk;

@end
