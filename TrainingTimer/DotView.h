//
//  DotView.h
//  TrainingTimer
//
//  Created by sungeo on 15/4/11.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry.h>

@interface DotView : UIView

@property (nonatomic, strong) MASConstraint * bottomConstraint;
@property (nonatomic) CGFloat originalBottomOffset;

- (void)makeCircle;

- (void)addConcentricCircle;
- (void)resetConcentricCircle;

@end
