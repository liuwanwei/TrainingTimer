//
//  RecordsViewController.m
//  TrainingTimer
//
//  Created by sungeo on 15/4/4.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import "RecordsViewController.h"
#import <Masonry.h>
#import <NSObject+GLPubSub.h>
#import <EXTScope.h>
#import "TrainingData.h"
#import "TrainingRecord.h"
#import "TrainingRecordCell.h"
#import "UIColor+TrainingTimer.h"


@implementation RecordsViewController{
    NSArray * _records;
    
    NSArray * _oneDayRecords;
    NSString * _selectedDateString;
    NSMutableDictionary * _eventsByDate;
    
    JTCalendarMenuView * _calendarMenuView;
    JTCalendarContentView * _calendarContentView;
    JTCalendar * _calendar;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    self.title = @"训练记录";
    
    @weakify(self);
    
    _calendarMenuView = [[JTCalendarMenuView alloc] init];
    _calendarMenuView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_calendarMenuView];
    [_calendarMenuView mas_makeConstraints:^(MASConstraintMaker * maker){
        @strongify(self);
        maker.leading.equalTo(self.view.mas_leading);
        maker.trailing.equalTo(self.view.mas_trailing);
        maker.top.equalTo(self.view.mas_top);
        maker.height.equalTo(@(50));
    }];
    
    _calendarContentView = [[JTCalendarContentView alloc] init];
    _calendarContentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_calendarContentView];
    [_calendarContentView mas_makeConstraints:^(MASConstraintMaker * maker){
        @strongify(self);
        maker.leading.equalTo(self.view.mas_leading);
        maker.trailing.equalTo(self.view.mas_trailing);
        maker.top.equalTo(self->_calendarMenuView.mas_bottom);
        maker.height.equalTo(@(300));
    }];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 80.0f;
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker * maker){
        @strongify(self);
        maker.leading.equalTo(self.view.mas_leading);
        maker.trailing.equalTo(self.view.mas_trailing);
        maker.top.equalTo(self->_calendarContentView.mas_bottom);
        maker.bottom.equalTo(self.view.mas_bottom);
    }];
    UIView * emptyView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableView.tableFooterView = emptyView;
    
    [self subscribe:TrainingRecordsChangedNote handler:^(GLEvent * event){
        @strongify(self);
        [self.tableView reloadData];
    }];
    
    [self customCalendar];
}

- (void)customCalendar{
    _calendar = [JTCalendar new];
    
    // All modifications on calendarAppearance have to be done before setMenuMonthsView and setContentView
    // Or you will have to call reloadAppearance
    {
        _calendar.calendarAppearance.calendar.firstWeekday = 2; // Sunday == 1, Saturday == 7
        _calendar.calendarAppearance.dayCircleRatio = 7. / 10.;
        _calendar.calendarAppearance.dayDotRatio = 1. / 5;
        _calendar.calendarAppearance.dayDotColor = [UIColor mainColor];
        _calendar.calendarAppearance.dayDotColorOtherMonth = [UIColor mainColor];
        _calendar.calendarAppearance.dayCircleColorSelected = [UIColor mainColor];
        _calendar.calendarAppearance.dayCircleColorSelectedOtherMonth = [UIColor mainColor];
        _calendar.calendarAppearance.ratioContentMenu = 1.;
        _calendar.calendarAppearance.focusSelectedDayChangeMode = NO;
        
        // Customize the text for each month
        _calendar.calendarAppearance.monthBlock = ^NSString *(NSDate *date, JTCalendar *jt_calendar){
            NSCalendar *calendar = jt_calendar.calendarAppearance.calendar;
            NSDateComponents *comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:date];
            NSInteger currentMonthIndex = comps.month;
            
            static NSDateFormatter *dateFormatter;
            if(!dateFormatter){
                dateFormatter = [NSDateFormatter new];
                dateFormatter.timeZone = jt_calendar.calendarAppearance.calendar.timeZone;
            }
            
            while(currentMonthIndex <= 0){
                currentMonthIndex += 12;
            }
            
            NSString *monthText = [[dateFormatter standaloneMonthSymbols][currentMonthIndex - 1] capitalizedString];
            
            return [NSString stringWithFormat:@"%zd\n%@", comps.year, monthText];
        };
    }
    
    [_calendar setMenuMonthsView:_calendarMenuView];
    [_calendar setContentView:_calendarContentView];
    [_calendar setDataSource:self];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    _records = [[TrainingData defaultInstance] records];
    
    [self createTrainingEventsFromRecords:_records];
    [_calendar reloadData];
    
    // 默认列表显示所有的记录，当选择一个日期后，再展示那天的训练记录
    _oneDayRecords = _records;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // 在 viewWillAppear 中调用起不到效果，我猜不到原因 TODO:
    [_calendar setCurrentDate:[NSDate date]];
}

#pragma mark - JTCalendar 
- (BOOL)calendarHaveEvent:(JTCalendar *)calendar date:(NSDate *)date
{
    NSString *key = [[self dateFormatter] stringFromDate:date];
    
    if(_eventsByDate[key]){
        NSArray * events = _eventsByDate[key];
        if (events.count > 0) {
            NSLog(@"%@ has events %@", key, @(events.count));
            return YES;
        }
    }
    
    return NO;
}

- (void)calendarDidDateSelected:(JTCalendar *)calendar date:(NSDate *)date{
    NSString *key = [[self dateFormatter] stringFromDate:date];
    NSArray *events = _eventsByDate[key];
    
    _oneDayRecords = events;
    _selectedDateString = key;
    [_tableView reloadData];
    NSLog(@"Date: %@ - %zd events", date, [events count]);
}

//- (BOOL)calendar:(JTCalendar *)calendar canSelectDate:(NSDate *)date{
//    NSString *key = [[self dateFormatter] stringFromDate:date];
//    NSArray *events = _eventsByDate[key];
//    
//    return events.count > 0;
//}

- (void)calendarDidLoadPreviousPage
{
    NSLog(@"Previous page loaded");
}

- (void)calendarDidLoadNextPage
{
    NSLog(@"Next page loaded");
}

- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
    }
    
    return dateFormatter;
}

- (void)createTrainingEventsFromRecords:(NSArray *)records{
    _eventsByDate = [NSMutableDictionary new];
    
    NSEnumerator * enumerator = [records objectEnumerator];
    TrainingRecord * record;
    while(record = [enumerator nextObject]){
        NSDate *trainingDate = record.createDate;
        
        // Use the date as key for eventsByDate
        NSString *key = [[self dateFormatter] stringFromDate:trainingDate];
        
        if(!_eventsByDate[key]){
            _eventsByDate[key] = [NSMutableArray new];
        }
        
        [_eventsByDate[key] addObject:record];
    }
}



#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _oneDayRecords.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (_oneDayRecords && _oneDayRecords == _records) {
        NSString * sectionTitle = [NSString stringWithFormat:@"全部训练（共 %@ 次）", @(_records.count)];
        return sectionTitle;
    }
    
    if (_oneDayRecords.count <= 0) {
        return @"该日没有训练";
    }else{
        NSString * sectionTitle = [NSString stringWithFormat:@"%@（共 %@ 次)", _selectedDateString, @(_oneDayRecords.count)];
        return sectionTitle;
    }
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
    
    TrainingRecord * record = _oneDayRecords[indexPath.row];
    [recordCell setNumberOfSkipping:record.numberOfSkipping.stringValue];
    recordCell.descriptionLabel.text = [record description];
    recordCell.timeLabel.text = [record date];

}

@end
