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
#import <Colours.h>

static NSString * const kSchemaKey = @"schemaKey";

static TrainingColorSchema sSchema = TrainingColorSchemaBlue;

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
    return [[self class] mainColor];
//    return RGB(0xD4, 0xD5, 0xD5);
}

+ (UIColor *)mainColor{
    switch (sSchema) {
        case TrainingColorSchemaOrange:
            return RGB(0xEB, 0x6E, 0x12);
        case TrainingColorSchemaPink:
            return RGB(0xEA, 0x60, 0x5D);
        case TrainingColorSchemaBlue:
            // From Colours Pod: https://github.com/bennyguitar/Colours
            return [UIColor skyBlueColor];
    }
}

@end
