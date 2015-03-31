//
//  ViewController.h
//  TrainingTimer
//
//  Created by sungeo on 15/3/21.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrainingManager.h"

@class TrainingProcess;

@interface ViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, TrainingManagerDeleage, UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UIView * viewHeader;
@property (nonatomic, weak) IBOutlet UILabel * labelLeftTime;
@property (nonatomic, weak) IBOutlet UITableView * tableView;
@property (nonatomic, weak) IBOutlet UIButton * buttonTraining;

@property (nonatomic, strong) TrainingProcess * process;

@end

