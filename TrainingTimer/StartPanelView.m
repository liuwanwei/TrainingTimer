//
//  StartPanelView.m
//  TrainingTimer
//
//  Created by sungeo on 15/4/28.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import "StartPanelView.h"
#import <EXTScope.h>
#import <Masonry.h>
#import <NSObject+GLPubSub.h>
#import "UIColor+TrainingTimer.h"
#import "UIFont+Adapter.h"
#import "TrainingProcess.h"
#import "TrainingViewController.h"


@implementation StartPanelView{
    UIButton * _startButton;
    UIButton * _calendarButton;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)createSubViews{
    self.backgroundColor = RGB(229, 234, 242);
//    [UIColor lineFgColor];
    
    @weakify(self);
    
    UIButton * buttonStart = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:buttonStart];
    [buttonStart mas_makeConstraints:^(MASConstraintMaker * maker){
        @strongify(self);
        maker.center.equalTo(self);
        maker.height.equalTo(self.mas_height).dividedBy(2.0);
        maker.width.equalTo(self.mas_width).dividedBy(1.5);
    }];
    
    UIColor * color = RGB(0, 122, 255);
    [buttonStart setTitle:@"开始训练" forState:UIControlStateNormal];
    [buttonStart setTitleColor:color forState:UIControlStateNormal];
    buttonStart.titleLabel.font = [UIFont systemFontOfSize:30.0];
    
    _startButton = buttonStart;
    
    _calendarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview: _calendarButton];
    [_calendarButton mas_makeConstraints:^(MASConstraintMaker * maker){
        @strongify(self);
        maker.centerY.equalTo(self.mas_centerY);
        maker.leading.greaterThanOrEqualTo(self.mas_leading).offset(32);
//        maker.trailing.lessThanOrEqualTo(self->_startButton.mas_leading).offset(-8);
        maker.width.equalTo(@(36));
        maker.height.equalTo(_calendarButton.mas_width);
    }];
    
    [_calendarButton setImage:[UIImage imageNamed:@"calendar"] forState:UIControlStateNormal];
}

- (void)addStartButtonTarget:(id)target selector:(SEL)selector{
    [_startButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}

- (void)addCalendarButtonTarget:(id)target selector:(SEL)selector{
    [_calendarButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}

- (void)updateStartButtonFont{
    return;
//    CGSize size = _startButton.bounds.size;
//    size.height /= 2;
//    _startButton.titleLabel.font = [UIFont findAdaptiveFontWithName:nil forUILabelSize:size withMinimumSize:0];
}


@end
