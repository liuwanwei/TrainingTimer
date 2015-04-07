//
//  TrainingRecordCell.m
//  TrainingTimer
//
//  Created by sungeo on 15/4/7.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import "TrainingRecordCell.h"
#import "UIFont+Adapter.h"
#import "UIColor+TrainingTimer.h"
#import <Masonry.h>
#import <libextobjc/EXTScope.h>

@implementation TrainingRecordCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self createSubView];
    }
    
    return self;
}

+ (BOOL)requiresConstraintBasedLayout{
    return YES;
}

- (void)createSubView{
    _numberOfSkippingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _numberOfSkippingLabel.textColor = [UIColor mainColor];
    _numberOfSkippingLabel.textAlignment = NSTextAlignmentCenter;
    _numberOfSkippingLabel.font = [UIFont systemFontOfSize:30.];
    [self.contentView addSubview:_numberOfSkippingLabel];
    @weakify(self);
    [_numberOfSkippingLabel mas_makeConstraints:^(MASConstraintMaker * maker){
        @strongify(self);
        maker.centerY.equalTo(self.contentView.mas_centerY);
        maker.leading.equalTo(self.contentView.mas_left).offset(10.0);
        maker.top.equalTo(self.contentView.mas_top);
        maker.width.equalTo(_numberOfSkippingLabel.mas_height);
    }];
    
    _descriptionLabel = [[UILabel alloc] init];
    _descriptionLabel.font = [UIFont boldSystemFontOfSize:18.0];
    [self.contentView addSubview:_descriptionLabel];
    [_descriptionLabel mas_makeConstraints:^(MASConstraintMaker * maker){
        @strongify(self);
        maker.leading.equalTo(_numberOfSkippingLabel.mas_right).offset(5.0);
        maker.centerY.equalTo(self.contentView.mas_centerY).offset(-10.0);
        maker.trailing.equalTo(self.contentView.mas_right);
        maker.height.equalTo(self.contentView.mas_height).dividedBy(2.0);
    }];
    
    _timeLabel = [[UILabel alloc] init];
    [self.contentView addSubview:_timeLabel];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker * maker){
        @strongify(self);
        maker.leading.equalTo(_descriptionLabel.mas_left);
        maker.trailing.equalTo(self.contentView.mas_right);
        maker.top.equalTo(_descriptionLabel.mas_bottom);
        maker.bottom.equalTo(self.contentView.mas_bottom);
    }];
}

- (void)setNumberOfSkipping:(NSString *)numberString{
    if (numberString.length == 0) {
        _numberOfSkippingLabel.text = @"无";
    }else{
        _numberOfSkippingLabel.text = numberString;        
    }
}

//- (void)showNumberOfSkippingString:(NSString *)string{
//    [self.contentView setNeedsLayout];
//    [self.contentView layoutIfNeeded];
//    CGSize size = _numberOfSkippingLabel.bounds.size;
//
//    UIFont * font = [UIFont adaptiveFontForString:string withWidth:size.width];
//    _numberOfSkippingLabel.font = font;
//    _numberOfSkippingLabel.text = string;
//}


// 下面是将NSString的文字转换成UIImage对象的代码，保留备查
- (void)showNumberOfSkipping:(NSNumber *)numberOfSkipping{
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    NSString * string = [numberOfSkipping stringValue];
    CGSize size = _numberOfSkippingImageView.bounds.size;
    
    UIFont * font = [UIFont adaptiveFontForString:string withWidth:size.width];
    
    NSDictionary * attributes = @{NSFontAttributeName: font,
                                  NSForegroundColorAttributeName: [UIColor mainColor],
                                  NSBackgroundColorAttributeName: [UIColor clearColor]};
    
    self.numberOfSkippingImageView.image = [self imageFromString:string
                                      attributes:attributes size:size];
}

- (UIImage *)imageFromString:(NSString *)string attributes:(NSDictionary *)attributes size:(CGSize)size{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [string drawInRect:CGRectMake(0, 0, size.width, size.height) withAttributes:attributes];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
