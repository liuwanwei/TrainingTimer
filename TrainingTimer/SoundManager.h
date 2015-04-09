//
//  SoundManager.h
//  Basketballer
//
//  Created by lixiaoyu on 12-8-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface SoundManager : NSObject

@property (nonatomic, readwrite) CFURLRef soundFileURLRef;
@property (nonatomic, readonly) SystemSoundID soundFileObject;

+ (instancetype)defaultManager;

- (void)playSoundWithFileName:(NSString *)fileName;
- (void)stop;

@end
