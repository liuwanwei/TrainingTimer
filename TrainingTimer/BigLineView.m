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

@implementation BigLineView{
    UIView * _progressView;
}

- (instancetype)initWithMaxLength:(TTMaxLength)maxLength{
    if (self = [super init]) {
        _maxLength = maxLength;
        [self createSubViews];
    }
    
    return self;
}

- (void)createSubViews{
    
    self.backgroundColor = RGB(0xAF, 0xAD, 0xAA);// 背景色
    
    __weak __typeof__(self) superView = self;
    
    // 时间信息
    _lengthLabel = [[UILabel alloc] init];
    _lengthLabel.textAlignment = NSTextAlignmentCenter;
    _lengthLabel.textColor = [UIColor whiteColor];
    [self addSubview:_lengthLabel];
    [_lengthLabel mas_makeConstraints:^(MASConstraintMaker * maker){
        maker.centerX.equalTo(superView.mas_centerX);
        maker.centerY.equalTo(superView.mas_centerY).offset(-5);
        maker.width.equalTo(superView.mas_width);
        maker.height.equalTo(superView.mas_height).dividedBy(3);
        
    }];
    
    // 类型信息
    _typeLabel = [[UILabel alloc] init];
    _typeLabel.textAlignment = NSTextAlignmentCenter;
    _typeLabel.textColor = [UIColor whiteColor];
    [self addSubview:_typeLabel];
    [_typeLabel mas_makeConstraints:^(MASConstraintMaker * maker){
        maker.centerX.equalTo(superView.mas_centerX);
        maker.top.equalTo(_lengthLabel.mas_bottom).offset(3);
        maker.width.equalTo(superView.mas_width);
        maker.height.equalTo(superView.mas_height).dividedBy(5);
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

/**
 *  设置正中间文字和颜色。
 *  
 *  文字区域默认并未生成，调用此函数时会自动创建，文字区域大小为总高度的1/3，宽度为总宽度的1/2。
 *  
 *  文字的字体动态计算出来，占满高度。
 *
 *  @param text     文字内容。
 *  @param color    文字颜色，传入nil时，使用白色文字。
 *
 *  @return void
 */
//- (void)setCenterLabelText:(NSString *)text textColor:(UIColor *)color{
//    _centerLabel.textColor = color ? color : [UIColor whiteColor];
//    _centerLabel.text = text;
//}

//- (void)setTypeName:(NSString *)typeName length:(NSInteger)timeLength desc:(NSString *)desc{
//    _currentLength = timeLength;
//    
//    _lengthLabel.text = [NSString stringWithFormat:@"%@%@", [Utils colonSeperatedTime:timeLength], desc];
//    
//    _typeLabel.text = typeName;
//}

- (void)setType:(NSString *)type{
    [self setFontAutoFitSizeForLabel:_typeLabel];
    _typeLabel.text = type;
}

- (void)setLength:(NSInteger)length isTime:(BOOL)isTime{
    _currentLength = length;
    [self setFontAutoFitSizeForLabel:_lengthLabel];
    if (isTime) {
        _lengthLabel.text = [NSString stringWithFormat:@"%@s", [Utils colonSeperatedTime:length]];
    }else{
        _lengthLabel.text = [@(length) stringValue];
    }
    
    __weak __typeof__(self) superView = self;
    [_progressView mas_makeConstraints:^(MASConstraintMaker * maker){
        maker.leading.equalTo(superView.mas_leading);
        maker.top.equalTo(superView.mas_top);
        maker.height.equalTo(superView.mas_height);
        maker.right.equalTo(superView.mas_right).multipliedBy((CGFloat)length/_maxLength);
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
