//
//  BigLineView.m
//  TrainingTimer
//
//  Created by sungeo on 15/4/1.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import "BigLineView.h"
#import <objc/runtime.h>
#import <Masonry.h>
#import "Utils.h"
#import "TrainingUnit.h"
#import "UIFont+Adapter.h"
#import <XLForm.h>

@implementation BigLineView{
    UIView * _progressView;
}

+ (BOOL)requiresConstraintBasedLayout{
    return YES;
}

- (instancetype)initWithMaxValue:(TTMaxLength)maxLength{
    if (self = [super init]) {
        _maxValue = maxLength;
        [self createSubViews];
        
        UIGestureRecognizer * gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [self addGestureRecognizer:gesture];
    }
    
    return self;
}

- (void)tapped:(UIGestureRecognizer *)recoginizer{
    UIActionSheet * actionSheet = [[UIActionSheet alloc] init];
    actionSheet.title = _typeLabel.text;

    NSEnumerator * enumerator = [_options objectEnumerator];
    XLFormOptionsObject * object;
    while((object = [enumerator nextObject])){
        [actionSheet addButtonWithTitle:object.formDisplayText];
    }
    
    [actionSheet addButtonWithTitle:@"取消"];
    actionSheet.delegate = self;
    [actionSheet showInView:self.superview];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex < _options.count) {
        XLFormOptionsObject * object = _options[buttonIndex];
        _currentValue = [object.formValue integerValue];
        
        __weak __typeof__(self) wself = self;
        [UIView animateWithDuration:1 animations:^{
            CGRect frame = _progressView.frame;
            frame.size.width = ((CGFloat)wself.currentValue / wself.maxValue) * wself.bounds.size.width;
            _progressView.frame = frame;
        }];
    }
}

- (void)createSubViews{
    
    self.backgroundColor = RGB(0xAF, 0xAD, 0xAA);// 背景色
    
    __weak __typeof__(self) superView = self;
    
    // 时间，如：02：00
    _valueLabel = [[UILabel alloc] init];
    _valueLabel.textAlignment = NSTextAlignmentCenter;
    _valueLabel.textColor = [UIColor whiteColor];
    _valueLabel.userInteractionEnabled = NO;
    [self addSubview:_valueLabel];
    [_valueLabel mas_makeConstraints:^(MASConstraintMaker * maker){
        maker.centerX.equalTo(superView.mas_centerX);
        maker.centerY.equalTo(superView.mas_centerY).offset(-5);
        maker.width.equalTo(superView.mas_width);
        maker.height.equalTo(superView.mas_height).dividedBy(3);
        
    }];
    
    // 类型，如：热身
    _typeLabel = [[UILabel alloc] init];
    _typeLabel.textAlignment = NSTextAlignmentCenter;
    _typeLabel.textColor = [UIColor whiteColor];
    _typeLabel.userInteractionEnabled = NO;
    [self addSubview:_typeLabel];
    [_typeLabel mas_makeConstraints:^(MASConstraintMaker * maker){
        const CGFloat verticalGap = 5;
        maker.centerX.equalTo(superView.mas_centerX);
        maker.top.equalTo(_valueLabel.mas_bottom).offset(verticalGap);
        maker.width.equalTo(superView.mas_width);
        maker.bottom.equalTo(superView.mas_bottom).offset(-verticalGap);
    }];
    
    // 底部分隔线
    _bottomLineView = [[UIView alloc] init];
    _bottomLineView.backgroundColor = [UIColor lightTextColor];
    [self addSubview:_bottomLineView];
    [_bottomLineView mas_makeConstraints:^(MASConstraintMaker * maker){
        maker.leading.equalTo(superView.mas_leading);
        maker.bottom.equalTo(superView.mas_bottom);
        maker.width.equalTo(superView.mas_width);
        maker.height.equalTo(@(1));
    }];
    
    // 进度条
    _progressView = [[UIView alloc] initWithFrame:CGRectZero];
    _progressView.backgroundColor = RGB(0xD4, 0xD5, 0xD5);
    [self addSubview:_progressView];
    [self sendSubviewToBack:_progressView];
}

- (void)resetFonts{
    [self setFontAutoFitSizeForLabel:_typeLabel];
    [self setFontAutoFitSizeForLabel:_valueLabel];
}

/**
 *  设置类型，显示在中心点，文字居中
 * 
 *  @param type     类型的描述
 *
 */
- (void)setDescription:(NSString *)type{
    [self setFontAutoFitSizeForLabel:_typeLabel];
    _typeLabel.text = type;
}

- (void)setCurrentValue:(NSInteger)length isTime:(BOOL)isTime{
    _currentValue = length;
    [self setFontAutoFitSizeForLabel:_valueLabel];
    if (isTime) {
        _valueLabel.text = [NSString stringWithFormat:@"%@s", [Utils colonSeperatedTime:length]];
    }else{
        _valueLabel.text = [@(length) stringValue];
    }
    
    [self updateProgressView];
}

- (void)updateProgressView{
    __weak __typeof__(self) superView = self;
    [_progressView mas_remakeConstraints:^(MASConstraintMaker * maker){
        maker.leading.equalTo(superView.mas_leading);
        maker.top.equalTo(superView.mas_top);
        maker.height.equalTo(superView.mas_height);
        maker.right.equalTo(superView.mas_right).multipliedBy((CGFloat)superView.currentValue/_maxValue);
    }];
}

- (void)setFontAutoFitSizeForLabel:(UILabel *)label{
    [label setNeedsLayout];
    [label layoutIfNeeded];
    
    label.font = [UIFont findAdaptiveFontWithName:nil forUILabelSize:label.frame.size withMinimumSize:0];
}


- (void)hideBottomLine{
    _bottomLineView.hidden = YES;
}

@end
