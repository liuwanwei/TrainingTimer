//
//  BigLineView.h
//  TrainingTimer
//
//  Created by sungeo on 15/4/1.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlurMenu.h"

typedef enum{
    TTMaxWarmUpTime     = 180,
    TTMaxSkippingTime   = 60,
    TTMaxRestTime       = 30,
    TTMaxRound          = 10,
    TTMaxLengthNone,
}TTMaxLength;

@class StartLineView;
@protocol BigLineViewDelegate <NSObject>
@optional
- (void)bigLineView:(StartLineView *)view didChangeWithNewValue:(NSNumber *)theValue;
@end


@class TrainingUnit;

@interface StartLineView : UIView <BlurMenuDelegate>

@property (nonatomic, strong) UILabel * typeLabel;
@property (nonatomic, strong) UILabel * valueLabel;
@property (nonatomic, strong) UIView * bottomLineView;
@property (nonatomic, strong) NSArray * options;
@property (nonatomic, copy) NSString * valueUnit;

@property (nonatomic, weak) UIViewController * parentViewController;

@property (nonatomic, weak) id<BigLineViewDelegate> delegate;

@property (nonatomic) NSInteger maxValue;
@property (nonatomic) NSInteger currentValue;

- (instancetype)initWithMaxValue:(TTMaxLength)maxLength;

- (void)setDescription:(NSString *)type;
- (void)setCurrentValue:(NSInteger)length isTime:(BOOL)isTime;

- (void)resetContentSize;

- (void)redrawScaleSplitter;

- (void)hideBottomLine;

@end
