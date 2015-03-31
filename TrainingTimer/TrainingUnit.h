//
//  TrainingTime.h
//  TrainingTimer
//
//  Created by sungeo on 15/3/21.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDFoundation.h"

extern NSString * const TrainingUnitTypeKey;
extern NSString * const TrainingUnitTimeLength;
extern NSString * const TrainingUnitIndex;

typedef enum {
    TrainingUnitTypePreprae = 0,      // 准备
    TrainingUnitTypeJump,     // 跳绳训练
    TrainingUnitTypeRest,             // 休息
    
}TrainingUnitTypeEnum;

@interface TrainingUnit : BaseModel

@property (nonatomic, strong) NSNumber * type;                    // 类型：TTTrainingType
@property (nonatomic, strong) NSNumber * timeLength;              // 持续时间：NSInteger
@property (nonatomic, strong) NSNumber * index;                   // 序号：NSInteger，序号越小，越排在前面
@property (nonatomic, copy) NSString * title;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (BOOL)isTrainingUnit;

+ (TrainingUnit *)trainingUnitWithType:(TrainingUnitTypeEnum)type interval:(NSInteger)interval;

+ (NSString *)descriptionForType:(TrainingUnitTypeEnum)type;

@end
