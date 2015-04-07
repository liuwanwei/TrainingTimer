//
//  TrainingRecord.h
//  TrainingTimer
//
//  Created by sungeo on 15/4/4.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDFoundation.h"

@interface TrainingRecord : BaseModel

@property (nonatomic, strong, readonly) NSNumber * rounds;        // 训练几组
@property (nonatomic, strong, readonly) NSNumber * totalTime;     // 训练总时间：秒
@property (nonatomic, strong) NSNumber * numberOfSkipping;        // 跳了多少个

- (instancetype)initWithUnits:(NSArray *)trainingUnits;

- (NSString *)date;

@end
