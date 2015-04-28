//
//  UIColor+TrainingTimer.h
//  TrainingTimer
//
//  Created by sungeo on 15/3/21.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    TrainingColorSchemaBlue,
    TrainingColorSchemaOrange,
    TrainingColorSchemaPink,
    
}TrainingColorSchema;

@interface UIColor(TrainingTimer)

+ (void)loadSchema;
+ (void)setSchema:(TrainingColorSchema)schema;

+ (UIColor *)barBackgroundColor;        // 导航栏背景色

+ (UIColor *)mainColor;                 // 背景色

+ (UIColor *)lineFgColor;
+ (UIColor *)lineBgColor;

@end
