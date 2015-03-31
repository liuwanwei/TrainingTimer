//
//  TrainingVoiceManager.m
//  TrainingTimer
//
//  Created by sungeo on 15/3/22.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import "TrainingVoiceManager.h"
#import <AVFoundation/AVFoundation.h>

NSString * const TrainingVocieChinese = @"zh_CN";
NSString * const TrainingVoiceEnglish = @"en-US";

float const TrainingVoiceRateFast = 0.5;
float const TrainingVoiceRateMedium = 0.3;
float const TrainingVoiceRateSlow = 0.1;

@implementation TrainingVoiceManager{
    NSString * _language;
    AVSpeechSynthesizer * _synthesizer;
    AVSpeechSynthesisVoice * _synthesizerVoice;
}

- (instancetype)initWithLanguage:(NSString *)language{
    if (self = [super init]) {
        _language = language;
        if ([self isValidLanguage:language]) {
            _synthesizerVoice = [AVSpeechSynthesisVoice voiceWithLanguage:_language];
            _synthesizer = [[AVSpeechSynthesizer alloc] init];
        }
    }
    
    return self;
}

- (BOOL)isValidLanguage:(NSString *)language{
    if ([_language isEqualToString:TrainingVocieChinese] || [_language isEqualToString:TrainingVoiceEnglish]) {
        return YES;
    }else{
        NSLog(@"错误的语言");
        return NO;
    }
}

- (void)speech:(NSString *)text{
    [self speech:text withRate:TrainingVoiceRateSlow];
}

- (void)speech:(NSString *)text withRate:(float)rate{
    if (! _synthesizer) {
        NSLog(@"未初始化合成器");
        return;
    }
    AVSpeechUtterance * utterance = [AVSpeechUtterance speechUtteranceWithString:text];
    utterance.voice = _synthesizerVoice;
    utterance.rate = rate; // 语速
    [_synthesizer speakUtterance:utterance];

}

- (void)stop{
    if (! _synthesizer) {
        return;
    }
    
    [_synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
}

@end
