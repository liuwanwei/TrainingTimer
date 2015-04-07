//
//  TrainingRecordCell.h
//  TrainingTimer
//
//  Created by sungeo on 15/4/7.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrainingRecordCell : UITableViewCell

@property (nonatomic, strong) UIImageView * numberOfSkippingImageView; // 用不到，保留备查
@property (nonatomic, strong) UILabel * numberOfSkippingLabel;
@property (nonatomic, strong) UILabel * descriptionLabel;
@property (nonatomic, strong) UILabel * timeLabel;

- (void)setNumberOfSkipping:(NSString *)numberString;

- (void)showNumberOfSkipping:(NSNumber *)numberOfSkipping;

@end
