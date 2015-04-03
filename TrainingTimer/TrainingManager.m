//
//  TrainingManager.m
//  TrainingTimer
//
//  Created by sungeo on 15/3/21.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import "TrainingManager.h"
#import "TrainingProcess.h"
#import "TrainingUnit.h"
#import "TrainingVoiceManager.h"

const NSInteger RushTimeStartSeconds = 10;

@implementation TrainingManager{
    NSTimer * _trainingTimer;
    NSInteger _unitIndex;
    NSTimeInterval _unitSecondsLeft;
    
    TrainingVoiceManager * _voiceSpeaker;
    
    __weak TrainingUnit * _currentUnit;
}

- (instancetype)initWithTrainingProcess:(TrainingProcess *)process{
    if (self = [super init]) {
        _process = process;
        _trainingState = TrainingStateStopped;
        _voiceSpeaker = [[TrainingVoiceManager alloc] initWithLanguage:TrainingVocieChinese];
    }
    
    return self;
}

- (BOOL)startWithUnit:(TrainingUnit *)unit{
    if (_process == nil) {
        NSLog(@"训练对象不存在");
        return NO;
    }
    
    if (_process.units.count <= 0) {
        NSLog(@"训练内容为空");
        return  NO;
    }
    
    if (unit != nil) {
        NSUInteger index = [_process.units indexOfObject:unit];
        if (NSNotFound == index) {
            NSLog(@"训练单元错误");
            return NO;
        }
    
        // 从某个健身单元开始
        _unitIndex = index - 1;
        
    }else{
        _unitIndex = -1;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(trainingBeginForProcess:)]) {
        [_delegate performSelector:@selector(trainingBeginForProcess:) withObject:_process];
    }
    
    [self nextTrainingUnit];
    _trainingState = TrainingStateRunning;
    
    // 禁止自动待机和屏幕变暗
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    return YES;
}

- (void)stop{
    [_trainingTimer invalidate];
    
    if (_delegate && [_delegate respondsToSelector:@selector(trainingFinishedForProcess:)]) {
        [_delegate performSelector:@selector(trainingFinishedForProcess:) withObject:_process];
    }
    
    [_voiceSpeaker stop];
    [_voiceSpeaker speech:@"训练全部结束"];
    
    // 恢复自动待机
    const NSTimeInterval WaitTimeBeforeEnableIdleTime = 5;
    [NSTimer scheduledTimerWithTimeInterval:WaitTimeBeforeEnableIdleTime
                                     target:self
                                   selector:@selector(enableSystemIdleTime:)
                                   userInfo:nil
                                    repeats:NO];
};

- (void)enableSystemIdleTime:(NSTimer *)timer{
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)pause{
    _trainingState = TrainingStatePaused;
};

- (void)resume{
    _trainingState = TrainingStateRunning;
}

- (void)nextTrainingUnit{
    [_trainingTimer invalidate];
    
    if (_unitIndex >= (NSInteger)(_process.units.count - 1)) {
        // 训练结束：所有训练单元都已完成
        [self stop];
        return;
    }
    
    // 进入下一个训练单元
    _unitIndex ++;
    _currentUnit = _process.units[_unitIndex];
    if (_unitIndex == _process.units.count - 1 &&
        (_currentUnit.type.integerValue == TrainingUnitTypeRest)) {
        // 最后一个单元是休息的话，直接结束
        [self stop];
        return;
    }

    
    _unitSecondsLeft = [_currentUnit.timeLength integerValue];
    _trainingTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(trainingTimeUpdated:) userInfo:nil repeats:YES];
    
    // 训练单元开始
    if (_delegate && [_delegate respondsToSelector:@selector(trainingBeginForUnit:)]) {
        [_delegate performSelector:@selector(trainingBeginForUnit:) withObject:_currentUnit];
    }
    
    [_voiceSpeaker speech:[NSString stringWithFormat:@"%@ 单元 开始 共 %@",
                           [_currentUnit description],
                           [Utils readableTimeFromSeconds:[_currentUnit.timeLength integerValue]]]];
}

- (void)trainingTimeUpdated:(NSTimer *)timer{
    if (_trainingState != TrainingStateRunning) {
        NSLog(@"训练暂停中");
        return;
    }
    
    _unitSecondsLeft --;
    if (_unitSecondsLeft < 0) {
        // 训练单元结束
        [timer invalidate];
        if (_delegate && [_delegate respondsToSelector:@selector(trainingFinishedForUnit:)]) {
            [_delegate performSelector:@selector(trainingFinishedForUnit:) withObject:_currentUnit];
        }
        
        __weak TrainingManager * wself = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [wself nextTrainingUnit];
        });
        
    }else{
        if (_unitSecondsLeft <= RushTimeStartSeconds) {
            [_voiceSpeaker speech:[@(_unitSecondsLeft) stringValue] withRate:TrainingVoiceRateFast];
        }

        // 训练单元时间更新
        if (_delegate && [_delegate respondsToSelector:@selector(trainingUnit:unitTimeLeft:)]) {
            [_delegate performSelector:@selector(trainingUnit:unitTimeLeft:) withObject:_currentUnit withObject:@(_unitSecondsLeft)];
        }
    }
}

@end
