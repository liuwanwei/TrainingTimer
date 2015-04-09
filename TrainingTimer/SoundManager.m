//
//  SoundManager.m
//  Basketballer
//
//  Created by maoyu on 12-8-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SoundManager.h"
#import <AVFoundation/AVFoundation.h>

static SoundManager * sSoundManager;
#define kSystemSoundID 1013

@interface SoundManager() {
    AVAudioPlayer * _audioPlayer;
}
@end


@implementation SoundManager : NSObject
@synthesize soundFileObject = _soundFileObject;
@synthesize soundFileURLRef = _soundFileURLRef;

+ (instancetype)defaultManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (nil == sSoundManager) {
            sSoundManager = [[SoundManager alloc] init];
        }
    });

    return sSoundManager;
}

- (id)init{
    if (self = [super init]) {        
    }
    
    return self;
}

- (void)playSoundWithFileName:(NSString *)fileName {
    [self stop];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource: fileName
                                           withExtension: @"mp3"];
    NSError  *error;  
    _audioPlayer  = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];  
    _audioPlayer.numberOfLoops  = 0;  
    if  (_audioPlayer == nil)  
        NSLog(@"播放失败");  
    else  
        [_audioPlayer  play];  
}

- (void)stop{
    if (_audioPlayer) {
        [_audioPlayer stop];
        _audioPlayer = nil;
    }
}

@end
