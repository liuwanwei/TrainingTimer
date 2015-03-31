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
    TrainingColorSchemaOrange
    
}TrainingColorSchema;

@interface UIColor(TrainingTimer)

+ (void)loadSchema;
+ (void)setSchema:(TrainingColorSchema)schema;

+ (UIColor *)barBackgroundColor;        // 导航栏背景色
+ (UIColor *)runningIndicatorColor;     // 进度指示条背景色
+ (UIColor *)trainingBackground;        // 训练界面背景色

@end
