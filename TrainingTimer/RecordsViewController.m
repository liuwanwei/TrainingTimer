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

@implementation RecordsViewController{
    NSArray * _records;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.title = @"训练记录";
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
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
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:sIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:sIdentifier];
    }
    
    TrainingRecord * record = _records[indexPath.row];
    cell.textLabel.text = [record description];
    cell.detailTextLabel.text = [record date];
    
    return cell;
}

@end
