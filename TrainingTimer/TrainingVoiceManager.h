//
//  TrainingVoiceManager.h
//  TrainingTimer
//
//  Created by sungeo on 15/3/22.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import <Foundation/Foundation.h>

// 语言类型：中文、英语
extern NSString * const TrainingVocieChinese;
extern NSString * const TrainingVoiceEnglish;

// 语速：快、中、慢
extern float const TrainingVoiceRateFast;
extern float const TrainingVoiceRateMedium;
extern float const TrainingVoiceRateSlow;

@interface TrainingVoiceManager : NSObject

// http://www.cnblogs.com/qingche/p/3502816.html
// 语音播报当前进展

- (instancetype)initWithLanguage:(NSString *)language;

- (void)speech:(NSString *)text;
- (void)speech:(NSString *)text withRate:(float)rate;

- (void)stop;

@end
