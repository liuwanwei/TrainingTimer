//
//  RecordsViewController.h
//  TrainingTimer
//
//  Created by sungeo on 15/4/4.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JTCalendar.h>

@interface RecordsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, JTCalendarDataSource>

@property (nonatomic, strong, readonly) UITableView * tableView;

@end
