//
//  TrainingViewController.h
//  TrainingTimer
//
//  Created by sungeo on 15/3/24.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrainingManager.h"

@class TrainingProcess;

@interface TrainingViewController : UIViewController<TrainingManagerDeleage, UIAlertViewDelegate>

@property (nonatomic, strong) TrainingProcess * process;

@end
