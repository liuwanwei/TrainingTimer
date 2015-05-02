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
    _numberOfSkippingLabel.textAlignment = NSTextAlignmentLeft;
    _numberOfSkippingLabel.font = [UIFont systemFontOfSize:20.];
    [self.contentView addSubview:_numberOfSkippingLabel];
    @weakify(self);
    [_numberOfSkippingLabel mas_makeConstraints:^(MASConstraintMaker * maker){
        @strongify(self);
        maker.centerY.equalTo(self.contentView.mas_centerY);
        maker.leading.equalTo(self.contentView.mas_left).offset(16.0);
        maker.width.equalTo(@(140.0));
    }];
    
    _descriptionLabel = [[UILabel alloc] init];
    _descriptionLabel.font = [UIFont systemFontOfSize:18.0];
    [self.contentView addSubview:_descriptionLabel];
    [_descriptionLabel mas_makeConstraints:^(MASConstraintMaker * maker){
        @strongify(self);
        maker.leading.equalTo(_numberOfSkippingLabel.mas_right).offset(8.0);
        maker.centerY.equalTo(self.contentView.mas_centerY);
        maker.width.equalTo(@(200));
        maker.height.equalTo(self.contentView.mas_height).dividedBy(2.0);
    }];
    
    _timeLabel = [[UILabel alloc] init];
    [self.contentView addSubview:_timeLabel];
    _timeLabel.textAlignment = NSTextAlignmentRight;
    _timeLabel.textColor = [UIColor lightGrayColor];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker * maker){
        @strongify(self);
        maker.leading.equalTo(_descriptionLabel.mas_right);
        maker.trailing.equalTo(self.contentView.mas_right).offset(-16);
        maker.centerY.equalTo(self.contentView.mas_centerY);
        maker.height.equalTo(self->_descriptionLabel.mas_height);
    }];
}

- (void)setNumberOfSkipping:(NSString *)numberString{
    if (numberString.length == 0) {
        _numberOfSkippingLabel.text = @"未计数";
    }else{
        _numberOfSkippingLabel.text = [NSString stringWithFormat:@"跳绳 %@ 次", numberString];
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
