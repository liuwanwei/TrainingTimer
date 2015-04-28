//
//  StartPanelView.h
//  TrainingTimer
//
//  Created by sungeo on 15/4/28.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StartPanelView : UIView

- (void)createSubViews;

- (void)addStartButtonTarget:(id)target selector:(SEL)selector;
- (void)addCalendarButtonTarget:(id)target selector:(SEL)selector;

- (void)updateStartButtonFont;

@end
