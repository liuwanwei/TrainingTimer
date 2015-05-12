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
#import <NSObject+GLPubSub.h>
#import "UIColor+TrainingTimer.h"
#import "UIImage+Tint.h"
#import "HeartRateViewController.h"
#import "RecordsViewController.h"
#import "TTConstants.h"
#import "BDFoundation.h"

@implementation StartHeaderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithViewController:(UIViewController *)vc{
    if (self = [super init]) {
        _parentViewController = vc;
        _title = @"HIIT 跳绳训练";
        _brief = @"高强度间歇性训练，用来练习心肺功能，冲击速度，减脂效果明显";
        _totalTime = @"共需 3 分 25 秒";
    }
    
    return self;
}

+ (BOOL)requiresConstraintBasedLayout{
    return YES;
}

- (void)createSubViews{
    
    self.backgroundColor = [UIColor mainColor];
    
    // 居中描述文字
    _textViewBrief = [[UITextView alloc] init];
    [self addSubview:_textViewBrief];
    _textViewBrief.text = _brief;
    _textViewBrief.font = [UIFont systemFontOfSize:17.0];
    _textViewBrief.textAlignment = NSTextAlignmentCenter;
    _textViewBrief.textColor = RGB(239,239,244);
    _textViewBrief.editable = NO;
    _textViewBrief.selectable = NO;
    _textViewBrief.backgroundColor = [UIColor clearColor];
    
    CGFloat fixedWidth = kScreen_Width - 20;
    CGSize newSize = [_textViewBrief sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGFloat newWidth = fmaxf(fixedWidth, newSize.width);
    CGFloat newHeight = newSize.height;
    @weakify(self);
    [_textViewBrief mas_makeConstraints:^(MASConstraintMaker * maker){
        @strongify(self);
        maker.center.equalTo(self);
        maker.width.equalTo(@(newWidth));
        maker.height.equalTo(@(newHeight));
    }];
    
    // 顶部标题——HIIT 训练
    _labelTitle = [[UILabel alloc] init];
    [self addSubview:_labelTitle];
    _labelTitle.text = _title;
    _labelTitle.font = [UIFont systemFontOfSize:18];
    _labelTitle.textColor = [UIColor whiteColor];
    _labelTitle.textAlignment = NSTextAlignmentCenter;
    [_labelTitle mas_makeConstraints:^(MASConstraintMaker * maker){
        @strongify(self);
        maker.centerX.equalTo(self.mas_centerX);
        maker.width.equalTo(self.mas_width);
        maker.top.equalTo(self.mas_top).offset(20);
        maker.bottom.equalTo(_textViewBrief.mas_top);
    }];
    
    // 右侧心形图标按钮
    UIButton * buttonHeart = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:buttonHeart];
    [buttonHeart addTarget:self action:@selector(showHeartRate:) forControlEvents:UIControlEventTouchUpInside];
    UIImage * imageHeart = [UIImage imageNamed:@"heart"];
    imageHeart = [imageHeart imageWithTintColor:[UIColor whiteColor]];
    [buttonHeart setImage:imageHeart forState:UIControlStateNormal];
    buttonHeart.contentMode = UIViewContentModeCenter;
    [buttonHeart mas_makeConstraints:^(MASConstraintMaker * maker){
        @strongify(self);
        maker.trailing.equalTo(self.mas_trailing);
        maker.centerY.equalTo(self->_labelTitle.mas_centerY);
        maker.width.equalTo(@(40));
        maker.height.equalTo(buttonHeart.mas_width);
    }];
    
    // 左侧日历按钮
    UIButton * buttonCalendar = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:buttonCalendar];
    [buttonCalendar addTarget:self action:@selector(showCalendar:) forControlEvents:UIControlEventTouchUpInside];
    UIImage * imageCalendar = [UIImage imageNamed:@"calendar"];
    imageCalendar = [imageCalendar imageWithTintColor:[UIColor whiteColor]];
    [buttonCalendar setImage:imageCalendar forState:UIControlStateNormal];
    buttonCalendar.contentMode = UIViewContentModeCenter;
    [buttonCalendar  mas_makeConstraints:^(MASConstraintMaker * maker){
        @strongify(self);
        maker.leading.equalTo(self.mas_leading);
        maker.centerY.equalTo(self->_labelTitle.mas_centerY);
        maker.width.equalTo(@40);
        maker.height.equalTo(buttonCalendar.mas_width);
    }];
    
    // 底部：整体所需时间
    _labelTotalTime = [[UILabel alloc] init];
    [self addSubview:_labelTotalTime];
    _labelTotalTime.text = _totalTime;
    _labelTotalTime.font = [UIFont systemFontOfSize:20.0];
    _labelTotalTime.textColor = [UIColor whiteColor];
    _labelTotalTime.textAlignment = NSTextAlignmentCenter;
    [_labelTotalTime mas_makeConstraints:^(MASConstraintMaker * maker){
        @strongify(self);
        maker.centerX.equalTo(self.mas_centerX);
        maker.width.equalTo(self.mas_width);
        maker.top.equalTo(_textViewBrief.mas_bottom);
        maker.bottom.equalTo(self.mas_bottom);
    }];
    
//    [self subscribe:TrainingSettingChanged handler:^(GLEvent * event){
//        // TODO: 应该自己计算并赋值
//        _labelTotalTime.text = @"TODO";
//    }];
}

- (void)updateTotalTime:(NSString *)totalTime{
    _labelTotalTime.text = totalTime;
}


- (void)showHeartRate:(id)sender{
    HeartRateViewController * vc = [[HeartRateViewController alloc] init];
    [_parentViewController.navigationController pushViewController:vc animated:YES];
}

- (void)showCalendar:(id)sender{
    RecordsViewController * vc = [[RecordsViewController alloc] init];
    [self.parentViewController.navigationController pushViewController:vc animated:YES];

}

@end
