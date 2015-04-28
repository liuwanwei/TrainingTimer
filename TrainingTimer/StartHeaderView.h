//
//  StartHeaderView.h
//  TrainingTimer
//
//  Created by sungeo on 15/4/28.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StartHeaderView : UIView

@property (nonatomic, strong) UILabel * labelTitle;
@property (nonatomic, strong) UITextView * textViewBrief;
@property (nonatomic, strong) UILabel * labelTotalTime;

- (void)createSubViews;

- (void)updateTotalTime:(NSString *)totalTime;

@end
