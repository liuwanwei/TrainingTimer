//
//  RecordsViewController.m
//  TrainingTimer
//
//  Created by sungeo on 15/4/4.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import "RecordsViewController.h"
#import <Masonry.h>
#import <GLPubSub/NSObject+GLPubSub.h>
#import "TrainingData.h"
#import "TrainingRecord.h"
#import "TrainingRecordCell.h"

@implementation RecordsViewController{
    NSArray * _records;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.title = @"训练记录";
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 80.0f;
    [self.view addSubview:_tableView];
    __weak __typeof__(self) wself = self;
    [_tableView mas_makeConstraints:^(MASConstraintMaker * maker){
        maker.edges.equalTo(wself.view);
    }];
    
    [self subscribe:TrainingRecordsChangedNote handler:^(GLEvent * event){
        [wself.tableView reloadData];
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    _records = [[TrainingData defaultInstance] records];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _records.count;
}

#pragma mark - Table view delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * sIdentifier = @"RecordCell";
    TrainingRecordCell * cell = [tableView dequeueReusableCellWithIdentifier:sIdentifier];
    if (!cell) {
        cell = [[TrainingRecordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sIdentifier];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TrainingRecordCell * recordCell = (TrainingRecordCell *)cell;
    
    TrainingRecord * record = _records[indexPath.row];
    [recordCell setNumberOfSkipping:record.numberOfSkipping.stringValue];
    recordCell.descriptionLabel.text = [record description];
    recordCell.timeLabel.text = [record date];

}

@end
