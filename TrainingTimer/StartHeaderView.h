//
//  StartHeaderView.h
//  TrainingTimer
//
//  Created by sungeo on 15/4/28.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StartHeaderView : UIView

@property (nonatomic, weak) UIViewController * parentViewController;

@property (nonatomic, strong) UILabel * labelTitle;
@property (nonatomic, strong) UITextView * textViewBrief;
@property (nonatomic, strong) UILabel * labelTotalTime;

@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * brief;
@property (nonatomic, copy) NSString * totalTime;

- (id)initWithViewController:(UIViewController *)vc;

- (void)createSubViews;

- (void)updateTotalTime:(NSString *)totalTime;

@end
