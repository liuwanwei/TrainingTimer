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

@class TrainingUnit;

@interface BigLineView : UIView

@property (nonatomic, strong) UILabel * typeLabel;
@property (nonatomic, strong) UILabel * lengthLabel;
@property (nonatomic, strong) UIView * bottomLineView;

@property (nonatomic) NSInteger maxLength;
@property (nonatomic) NSInteger currentLength;

- (instancetype)initWithMaxLength:(TTMaxLength)maxLength;

//- (void)setCenterLabelText:(NSString *)text textColor:(UIColor *)color;
- (void)hideBottomLine;

//- (void)setTypeName:(NSString *)typeName length:(NSInteger)timeLength desc:(NSString *)desc;
- (void)setLength:(NSInteger)length isTime:(BOOL)isTime;
- (void)setType:(NSString *)type;

@end
