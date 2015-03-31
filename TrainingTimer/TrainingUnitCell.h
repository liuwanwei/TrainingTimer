//
//  TrainingUnitCell.h
//  TrainingTimer
//
//  Created by sungeo on 15/3/21.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TrainingUnit;

@interface TrainingUnitCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView * imageViewState;
@property (nonatomic, weak) IBOutlet UILabel * labelTitle;
@property (nonatomic, weak) IBOutlet UILabel * labelDetailTime;

@property (nonatomic, weak) TrainingUnit * unit;

// 设置对应的训练单元
- (void)setTrainingUnit:(TrainingUnit *)unit;

// 设置是否正在执行该单元
- (void)setRunning:(BOOL)running;

@end
