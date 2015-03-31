//
//  TrainingUnitCell.m
//  TrainingTimer
//
//  Created by sungeo on 15/3/21.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import "TrainingUnitCell.h"
#import "TrainingUnit.h"
#import "Utils.h"
#import "UIColor+TrainingTimer.h"

@implementation TrainingUnitCell

- (void)awakeFromNib {
    // Initialization code
    _imageViewState.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setTrainingUnit:(TrainingUnit *)unit{
    _unit = unit;
    self.labelTitle.text = [unit description];
    self.labelDetailTime.text = [Utils readableTimeFromSeconds:[unit.timeLength integerValue]];
}

- (void)setRunning:(BOOL)running{
    _imageViewState.hidden = !running;
    self.backgroundColor = running ? RGB(0xF7, 0xF7, 0xF7) : [UIColor whiteColor];
}

@end
