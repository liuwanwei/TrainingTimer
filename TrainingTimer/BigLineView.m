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
#import <libextobjc/EXTScope.h>
#import <XLForm.h>

@implementation BigLineView{
    UIView * _progressView;
    BOOL _isTime;
}

+ (BOOL)requiresConstraintBasedLayout{
    return YES;
}

- (instancetype)initWithMaxValue:(TTMaxLength)maxLength{
    if (self = [super init]) {
        _maxValue = maxLength;
        [self createSubViews];
        
        UITapGestureRecognizer * gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        gesture.numberOfTapsRequired = 1;
        gesture.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:gesture];
    }
    
    return self;
}

- (void)tapped:(UITapGestureRecognizer *)recoginizer{
//    [self showWithUIActionSheet];
    if (recoginizer.state == UIGestureRecognizerStateEnded) {
        CGPoint location = [recoginizer locationInView:self];
    
        const CGFloat ViewWidth = self.bounds.size.width;
        const NSInteger OptionsCount = _options.count;
        if (OptionsCount <= 0) {
            return;
        }
        
        XLFormOptionsObject * object;
        NSInteger position = 0;
        for (NSInteger i = OptionsCount - 1; i >= 0; i--) {
            object = _options[i];
            CGFloat barrier = ([object.formValue floatValue] / _maxValue) * ViewWidth;
            if (barrier < location.x) {
                position = i + 1;
                break;
            }
        }
        
        // 防止越界
        position = position >= OptionsCount ? position - 1 : position;
        
        _currentValue = [[_options[position] formValue] floatValue];
        [self updateProgressView];
        
        // 通知更新
        if (_delegate && [_delegate respondsToSelector:@selector(bigLineView:didChangeWithNewValue:)]) {
            [_delegate performSelector:@selector(bigLineView:didChangeWithNewValue:) withObject:self withObject:@(_currentValue)];
        }
    }
}

- (void)updateProgressView{
    @weakify(self);
    [UIView animateWithDuration:1 animations:^{
        @strongify(self);
        CGRect frame = _progressView.frame;
        frame.size.width = ((CGFloat)self.currentValue / self.maxValue) * self.bounds.size.width;
        _progressView.frame = frame;
    }];
    
    [self updateCurrentValue];
}

#pragma mark - UIAction sheet style selection handler
- (void)showWithUIActionSheet{
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
        
        [self updateProgressView];
    }
}

- (void)createSubViews{
    
    self.backgroundColor = RGB(0xAF, 0xAD, 0xAA);// 背景色
    
    @weakify(self);
    
    // 时间，如：02：00
    _valueLabel = [[UILabel alloc] init];
    _valueLabel.textAlignment = NSTextAlignmentCenter;
    _valueLabel.textColor = [UIColor whiteColor];
    _valueLabel.userInteractionEnabled = NO;
    [self addSubview:_valueLabel];
    [_valueLabel mas_makeConstraints:^(MASConstraintMaker * maker){
        @strongify(self);
        maker.centerX.equalTo(self.mas_centerX);
        maker.centerY.equalTo(self.mas_centerY).offset(-5);
        maker.width.equalTo(self.mas_width);
        maker.height.equalTo(self.mas_height).dividedBy(3);
        
    }];
    
    // 类型，如：热身
    _typeLabel = [[UILabel alloc] init];
    _typeLabel.textAlignment = NSTextAlignmentCenter;
    _typeLabel.textColor = [UIColor whiteColor];
    _typeLabel.userInteractionEnabled = NO;
    [self addSubview:_typeLabel];
    [_typeLabel mas_makeConstraints:^(MASConstraintMaker * maker){
        @strongify(self);
        const CGFloat verticalGap = 5;
        maker.centerX.equalTo(self.mas_centerX);
        maker.top.equalTo(_valueLabel.mas_bottom).offset(verticalGap);
        maker.width.equalTo(self.mas_width);
        maker.bottom.equalTo(self.mas_bottom).offset(-verticalGap);
    }];
    
    // 底部分隔线
    _bottomLineView = [[UIView alloc] init];
    _bottomLineView.backgroundColor = [UIColor lightTextColor];
    [self addSubview:_bottomLineView];
    [_bottomLineView mas_makeConstraints:^(MASConstraintMaker * maker){
        @strongify(self);
        maker.leading.equalTo(self.mas_leading);
        maker.bottom.equalTo(self.mas_bottom);
        maker.width.equalTo(self.mas_width);
        maker.height.equalTo(@(1));
    }];
    
    // 进度条
    _progressView = [[UIView alloc] initWithFrame:CGRectZero];
    _progressView.backgroundColor = RGB(0xD4, 0xD5, 0xD5);
    [self addSubview:_progressView];
    [_progressView mas_makeConstraints:^(MASConstraintMaker * maker){
        @strongify(self);
        maker.left.equalTo(self.mas_leading);
        maker.top.equalTo(self.mas_top);
        maker.height.equalTo(self.mas_height);
        maker.right.equalTo(@(0.1));
    }];

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
    _isTime = isTime;
    
    [self setFontAutoFitSizeForLabel:_valueLabel];
    [self updateCurrentValue];
    
    @weakify(self);
    [_progressView mas_remakeConstraints:^(MASConstraintMaker * maker){
        @strongify(self);
        maker.leading.equalTo(self.mas_leading);
        maker.top.equalTo(self.mas_top);
        maker.height.equalTo(self.mas_height);
        CGFloat ratio = (CGFloat)_currentValue/_maxValue;
        maker.right.equalTo(self.mas_right).multipliedBy(ratio);
    }];

}

- (void)updateCurrentValue{
    if (_isTime) {
        _valueLabel.text = [NSString stringWithFormat:@"%@s", [Utils colonSeperatedTime:_currentValue]];
    }else{
        _valueLabel.text = [@(_currentValue) stringValue];
    }
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
