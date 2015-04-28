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
#import <FBShimmeringView.h>
#import "UIColor+TrainingTimer.h"
#import <NSObject+GLPubSub.h>

@implementation BigLineView{
    UIView * _progressView;
    UIImageView * _imageViewArrow;
    UILabel * _LabelValueUnit;
    BOOL _isTime;
    
    BlurMenu * _menu;
    
    NSMutableArray * _scaleLayers; // 刻度 layer 对象缓存
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

- (void)drawRect:(CGRect)rect{
    [self redrawScaleSplitter];
}

#pragma mark - Blue menu delegate
- (void)selectedItemAtIndex:(NSInteger)index{
    XLFormOptionsObject * object = (XLFormOptionsObject *)_options[index];
    _currentValue =  [object.formValue integerValue];
    
    [self updateProgressView];
    
    // 通知更新
    if (_delegate && [_delegate respondsToSelector:@selector(bigLineView:didChangeWithNewValue:)]) {
        [_delegate performSelector:@selector(bigLineView:didChangeWithNewValue:) withObject:self withObject:@(_currentValue)];
    }
    
    [_menu hide];
}

- (void)showTappedMenu{
    NSMutableArray * mutableArray = [@[] mutableCopy];
    NSEnumerator * enumerator = [_options objectEnumerator];
    XLFormOptionsObject * option;
    while ((option = [enumerator nextObject])) {
        [mutableArray addObject:option.displayText];
    }
    
    NSArray * items = mutableArray;
    
    _menu = [[BlurMenu alloc] initWithItems:items parentView:self.parentViewController.view delegate:self];
    
    [_menu show];
}

// 点击屏幕修改刻度操作处理函数
- (void)tapped:(UITapGestureRecognizer *)recoginizer{
    BOOL test = YES;
    if (test) {
        return [self showTappedMenu];
    }
    
    if (recoginizer.state == UIGestureRecognizerStateEnded) {
        CGPoint location = [recoginizer locationInView:self];
    
        const CGFloat ViewWidth = self.bounds.size.width;
        const NSInteger OptionsCount = _options.count;
        if (OptionsCount <= 0) {
            return;
        }
        
        XLFormOptionsObject * object;
        NSInteger position = 0;
        
        // 最大适配算法，寻找小于点击位置的最大刻度
//        for (NSInteger i = OptionsCount - 1; i >= 0; i--) {
//            object = _options[i];
//
//            CGFloat bringe = ([object.formValue floatValue] / _maxValue) * ViewWidth;
//            if (bringe < location.x) {
//                position = i + 1;
//                break;
//            }
//        }
        
        // 最小适配算法：寻找大于点击位置的最小刻度
        for (NSInteger i = 0; i < OptionsCount; i++) {
            object = _options[i];
            
            CGFloat bringe = ([object.formValue floatValue] / _maxValue) * ViewWidth;
            if (bringe >= location.x) {
                position = i;
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
    [UIView animateWithDuration:.5 animations:^{
        @strongify(self);
        CGRect frame = _progressView.frame;
        frame.size.width = ((CGFloat)self.currentValue / self.maxValue) * self.bounds.size.width;
        _progressView.frame = frame;
    }];
    
    [self updateCurrentValueView];
}

- (void)createSubViews{
    self.backgroundColor = [UIColor lineFgColor];// 背景色
    
    @weakify(self);
    
    // 右侧箭头
    _imageViewArrow = [[UIImageView alloc] init];
    [self addSubview:_imageViewArrow];
    [_imageViewArrow setImage:[UIImage imageNamed:@"arrow_right"]];
    _imageViewArrow.alpha = 0.4;
    [_imageViewArrow mas_makeConstraints:^(MASConstraintMaker * maker){
        @strongify(self);
        maker.trailing.equalTo(self.mas_trailing).offset(-16);
        maker.centerY.equalTo(self.mas_centerY);
        maker.width.equalTo(@56);
        maker.height.equalTo(_imageViewArrow.mas_width);
    }];
    
    // 单位名称
    _LabelValueUnit = [[UILabel alloc] init];
    [self addSubview:_LabelValueUnit];
    _LabelValueUnit.alpha = 0.6;
    _LabelValueUnit.textColor = [UIColor blackColor];
    _LabelValueUnit.font = [UIFont systemFontOfSize:34.0];
    [_LabelValueUnit mas_makeConstraints:^(MASConstraintMaker * maker){
        @strongify(self);
        maker.centerY.equalTo(self.mas_centerY);
        maker.trailing.equalTo(self->_imageViewArrow.mas_leading);
        maker.height.equalTo(self->_imageViewArrow.mas_height);
        maker.width.equalTo(@48);
    }];
    
    // 时间，如：02：00
    _valueLabel = [[UILabel alloc] init];
    _valueLabel.textAlignment = NSTextAlignmentCenter;
    _valueLabel.textColor = [UIColor mainColor];
    _valueLabel.userInteractionEnabled = NO;
//    UIFont * font = [UIFont fontWithName:@"Lao Sangam MN" size:34.0];
    UIFont * font = [UIFont fontWithName:@"DIN Alternate" size:34.0];
    _valueLabel.font = font;
    [self addSubview:_valueLabel];
    [_valueLabel mas_makeConstraints:^(MASConstraintMaker * maker){
        @strongify(self);
//        maker.centerX.equalTo(self.mas_centerX);
        maker.centerY.equalTo(self.mas_centerY);
        maker.trailing.equalTo(self->_LabelValueUnit.mas_leading);
        maker.width.equalTo(self.mas_width).dividedBy(4.0);
        maker.height.equalTo(self.mas_height).dividedBy(2);
        
    }];
    
    // 类型，如：热身
    _typeLabel = [[UILabel alloc] init];
    _typeLabel.textAlignment = NSTextAlignmentLeft;
    _typeLabel.textColor = [UIColor whiteColor];
    _typeLabel.userInteractionEnabled = NO;
    [self addSubview:_typeLabel];
    [_typeLabel mas_makeConstraints:^(MASConstraintMaker * maker){
        @strongify(self);
//        const CGFloat verticalGap = 5;
//        maker.centerX.equalTo(self.mas_centerX);
//        maker.top.equalTo(_valueLabel.mas_bottom).offset(verticalGap);
//        maker.width.equalTo(self.mas_width);
//        maker.bottom.equalTo(self.mas_bottom).offset(-verticalGap);
        maker.leading.equalTo(@16);
        maker.centerY.equalTo(self.mas_centerY);
        maker.height.equalTo(self.mas_height).dividedBy(3.0);
        maker.trailing.equalTo(_valueLabel.mas_leading);
    }];
    
    
    // 底部长分隔线
    _bottomLineView = [[UIView alloc] init];
    _bottomLineView.backgroundColor = [UIColor lightTextColor];
    [self addSubview:_bottomLineView];
    [_bottomLineView mas_makeConstraints:^(MASConstraintMaker * maker){
        @strongify(self);
        maker.leading.equalTo(self.mas_leading).offset(8.0);
        maker.bottom.equalTo(self.mas_bottom);
        maker.width.equalTo(self.mas_width);
        maker.height.equalTo(@(1));
    }];
    
    // 进度条
    _progressView = [[UIView alloc] initWithFrame:CGRectZero];
    _progressView.backgroundColor = [UIColor lineFgColor];
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

- (void)resetContentSize{
    [self setFontAutoFitSizeForLabel:_typeLabel];
    [self setFontAutoFitSizeForLabel:_valueLabel];
    
    [self redrawScaleSplitter];
}

- (void)setValueUnit:(NSString *)valueUnit{
    _valueUnit = valueUnit;
    
    _LabelValueUnit.text = _valueUnit;
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
    [self updateCurrentValueView];
    
//    @weakify(self);
//    [_progressView mas_remakeConstraints:^(MASConstraintMaker * maker){
//        @strongify(self);
//        maker.leading.equalTo(self.mas_leading);
//        maker.top.equalTo(self.mas_top);
//        maker.height.equalTo(self.mas_height);
//        CGFloat ratio = (CGFloat)_currentValue/_maxValue;
//        maker.right.equalTo(self.mas_right).multipliedBy(ratio);
//    }];

}

- (void)updateCurrentValueView{
    if (_isTime) {
        _valueLabel.text = [NSString stringWithFormat:@"%zd", _currentValue];
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

// 重绘刻度
- (void)redrawScaleSplitter{
    BOOL test = YES;
    if (test) {
        return;
    }
    
    for (CAShapeLayer * layer in _scaleLayers) {
        [layer removeFromSuperlayer];
    }
    
    NSLog(@"重绘");
    _scaleLayers = [NSMutableArray array];
    
    XLFormOptionsObject * option;
    NSEnumerator * enumerator = [_options objectEnumerator];
    while ((option = [enumerator nextObject])) {
//        const CGFloat ScaleStrokeHeight = 5.0;
//        const CGFloat ScaleStrokeWidth = 2.0;
        
        // 通过刻度值计算刻度位置
        NSInteger value = [option.formValue integerValue];
        CGFloat posX = ((CGFloat)value / _maxValue) * self.bounds.size.width;
        CGFloat posY = self.bounds.size.height;

        // 画刻度线
//        UIBezierPath * path = [UIBezierPath bezierPath];
//        [path moveToPoint:CGPointMake(posX, posY - ScaleStrokeHeight)];
//        [path addLineToPoint:CGPointMake(posX, posY)];
        UIBezierPath * path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(posX, posY) radius:3 startAngle:0 endAngle:(2*M_PI) clockwise:YES];
        
        CAShapeLayer * shapeLayer = [CAShapeLayer layer];
        NSAssert(shapeLayer != nil, @"shape layer can't be nil");
        shapeLayer.anchorPoint = CGPointMake(0.f, 0.f); // TODO: 写一篇笔记来记录这个特性！！
        shapeLayer.path = [path CGPath];
//        shapeLayer.strokeColor = [[UIColor mainColor] CGColor];
//        shapeLayer.lineWidth = ScaleStrokeWidth;
        shapeLayer.fillColor = [[UIColor whiteColor] CGColor];
       
        [self.layer addSublayer:shapeLayer];
        
        [_scaleLayers addObject:shapeLayer];
    }
    
}

@end
