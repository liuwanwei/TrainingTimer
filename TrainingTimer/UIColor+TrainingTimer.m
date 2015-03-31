//
//  UIColor+TrainingTimer.m
//  TrainingTimer
//
//  Created by sungeo on 15/3/21.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import "UIColor+TrainingTimer.h"
#import "BDFoundation.h"
#import <TMCache.h>

static NSString * const kSchemaKey = @"schemaKey";

static TrainingColorSchema sSchema = TrainingColorSchemaOrange;

@implementation UIColor(TrainingTimer)

+ (void)loadSchema{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSNumber * object = (NSNumber *)[[TMDiskCache sharedCache] objectForKey:kSchemaKey];
        if (object) {
            sSchema = (TrainingColorSchema)[object integerValue];
        }
    });
}

+ (void)setSchema:(TrainingColorSchema)schema{
    [[TMDiskCache sharedCache] setObject:@(schema) forKey:kSchemaKey];
}

+ (UIColor *)barBackgroundColor{
    switch (sSchema) {
        case TrainingColorSchemaOrange:
            return RGB(0x77, 0x6B, 0x5E);
        case TrainingColorSchemaBlue:
            return RGB(0x77, 0x6B, 0x5E);
    }
    
}


+ (UIColor *)trainingBackground{
    switch (sSchema) {
        case TrainingColorSchemaOrange:
            return RGB(0xEA, 0x60, 0x5D);
            break;
        case TrainingColorSchemaBlue:
            return RGB(0x25, 0xAE, 0xFB);
    }
}

+ (UIColor *)runningIndicatorColor{
    switch (sSchema) {
        case TrainingColorSchemaOrange:
            return RGB(0x91, 0xB5, 0xE5);
        case TrainingColorSchemaBlue:
            return RGB(0x8C, 0xB6, 0x45);
    }
}

@end
