//
//  TrainingManager.h
//  TrainingTimer
//
//  Created by sungeo on 15/3/21.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    TrainingStateStopped,
    TrainingStateRunning,
    TrainingStatePaused,
}TrainingState;


@class TrainingProcess;
@class TrainingUnit;

@protocol TrainingManagerDeleage <NSObject>

// 训练总体开始
- (void)trainingBeginForProcess:(TrainingProcess *)process;
// 训练单元开始
- (void)trainingBeginForUnit:(TrainingUnit *)unit;
// 训练单元剩余多少秒
- (void)trainingUnit:(TrainingUnit *)unit unitTimeLeft:(NSNumber *)seconds;
// 训练单元结束
- (void)trainingFinishedForUnit:(TrainingUnit *)unit;
// 训练总体结束
- (void)trainingFinishedForProcess:(TrainingProcess *)process;

@end

@interface TrainingManager : NSObject

@property (nonatomic, weak) TrainingProcess * process;
@property (nonatomic) TrainingState trainingState;
@property (nonatomic, weak) id<TrainingManagerDeleage> delegate;

- (instancetype)initWithTrainingProcess:(TrainingProcess *)process;

- (BOOL)startWithUnit:(TrainingUnit *)unit;
- (void)pause;
- (void)resume;
- (void)stop;

@end

extern const NSInteger RushTimeStartSeconds;
