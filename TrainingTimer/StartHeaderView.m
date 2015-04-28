//
//  StartHeaderView.m
//  TrainingTimer
//
//  Created by sungeo on 15/4/28.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import "StartHeaderView.h"
#import <Masonry.h>
#import <EXTScope.h>
#import "UIColor+TrainingTimer.h"
#import "BDFoundation.h"

@implementation StartHeaderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (BOOL)requiresConstraintBasedLayout{
    return YES;
}

- (void)createSubViews{
    
    self.backgroundColor = [UIColor mainColor];
    
    _textViewBrief = [[UITextView alloc] init];
    [self addSubview:_textViewBrief];
    _textViewBrief.font = [UIFont systemFontOfSize:24.0];
    _textViewBrief.textAlignment = NSTextAlignmentCenter;
    _textViewBrief.textColor = RGB(239,239,244);
    _textViewBrief.backgroundColor = [UIColor clearColor];
    @weakify(self);
    [_textViewBrief mas_makeConstraints:^(MASConstraintMaker * maker){
        @strongify(self);
        maker.center.equalTo(self);
        maker.width.equalTo(self.mas_width).dividedBy(2.0);
        maker.height.equalTo(self.mas_height).dividedBy(4.0);
    }];
    
    _labelTitle = [[UILabel alloc] init];
    [self addSubview:_labelTitle];
    _labelTitle.font = [UIFont systemFontOfSize:44.0];
    _labelTitle.textColor = [UIColor whiteColor];
    _labelTitle.textAlignment = NSTextAlignmentCenter;
    [_labelTitle mas_makeConstraints:^(MASConstraintMaker * maker){
        @strongify(self);
        maker.centerX.equalTo(self.mas_centerX);
        maker.width.equalTo(self.mas_width);
        maker.top.greaterThanOrEqualTo(self.mas_top).offset(25);
        maker.bottom.lessThanOrEqualTo(_textViewBrief.mas_top);
    }];
    
    _labelTotalTime = [[UILabel alloc] init];
    [self addSubview:_labelTotalTime];
    _labelTotalTime.font = [UIFont systemFontOfSize:34.0];
    _labelTotalTime.textColor = [UIColor whiteColor];
    _labelTotalTime.textAlignment = NSTextAlignmentCenter;
    [_labelTotalTime mas_makeConstraints:^(MASConstraintMaker * maker){
        @strongify(self);
        maker.centerX.equalTo(self.mas_centerX);
        maker.width.equalTo(self.mas_width);
        maker.top.greaterThanOrEqualTo(_textViewBrief.mas_bottom);
        maker.bottom.lessThanOrEqualTo(self.mas_bottom).offset(-25);
    }];
    
}


@end
