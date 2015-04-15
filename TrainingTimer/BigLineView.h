//
//  BigLineView.h
//  TrainingTimer
//
//  Created by sungeo on 15/4/1.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    TTMaxWarmUpTime     = 180,
    TTMaxSkippingTime   = 60,
    TTMaxRestTime       = 30,
    TTMaxRound          = 10,
    TTMaxLengthNone,
}TTMaxLength;

@class BigLineView;
@protocol BigLineViewDelegate <NSObject>
@optional
- (void)bigLineView:(BigLineView *)view didChangeWithNewValue:(NSNumber *)theValue;
@end


@class TrainingUnit;

@interface BigLineView : UIView <UIActionSheetDelegate>

@property (nonatomic, strong) UILabel * typeLabel;
@property (nonatomic, strong) UILabel * valueLabel;
@property (nonatomic, strong) UIView * bottomLineView;
@property (nonatomic, strong) NSArray * options;

@property (nonatomic, weak) id<BigLineViewDelegate> delegate;

@property (nonatomic) NSInteger maxValue;
@property (nonatomic) NSInteger currentValue;

- (instancetype)initWithMaxValue:(TTMaxLength)maxLength;

- (void)setDescription:(NSString *)type;
- (void)setCurrentValue:(NSInteger)length isTime:(BOOL)isTime;

- (void)resetContentSize;

- (void)drawStepScale;

- (void)hideBottomLine;

@end
