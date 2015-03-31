//
//  ViewController.m
//  TrainingTimer
//
//  Created by sungeo on 15/3/21.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import "ViewController.h"
#import "BDFoundation.h"
#import "TrainingUnit.h"
#import "TrainingProcess.h"
#import "TrainingUnitCell.h"
#import "TrainingData.h"
#import "TrainingManager.h"
#import "UIColor+TrainingTimer.h"
#import "TrainingViewController.h"
#import "TrainingUnitViewController.h"

static NSString * const kDefaultTrainingTimeLeft = @"00:00";
static NSString * const kStartTrainingText = @"开始训练";
static NSString * const kStopTrainingText = @"结束训练";

static NSInteger const UIAlertViewStopTraining = 10081;

static CGFloat const ProgressBarHeight = 15.0f;

@interface ViewController ()

@end

@implementation ViewController{
    TrainingManager * _trainingManager;
    TrainingUnit * _currentTrainingUnit;
    
    UIView * _progressView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Utils hideExtraCellsForTableView:_tableView];

    // 初始化起停按钮
    [_buttonTraining setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_buttonTraining setBackgroundColor:[UIColor trainingBackground]];
    [_buttonTraining setTitle:kStartTrainingText forState:UIControlStateNormal];
    // 圆角化起停按钮
    [_buttonTraining setNeedsLayout];
    [_buttonTraining layoutIfNeeded];
    _buttonTraining.layer.cornerRadius = self.buttonTraining.bounds.size.height / 2;
    
    self.title = _process.title;

    [self showFirstTrainingUnitTimeLength];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private functions
- (void)addUnit:(id)sender{
    TrainingUnitViewController * vc = [[TrainingUnitViewController alloc] initWithTrainingUnit:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showFirstTrainingUnitTimeLength{
    if (_process.units.count > 0) {
        TrainingUnit * firstUnit = _process.units[0];
        _labelLeftTime.text = [Utils colonSeperatedTime:[firstUnit.timeLength integerValue]];
    }else{
        _labelLeftTime.text = kDefaultTrainingTimeLeft;
    }
}

- (void)hideProgressView{
    _progressView.frame = CGRectMake(0, 0, 0, ProgressBarHeight);
}

#pragma mark - Touched action
- (IBAction)trainingPressed:(id)sender{
    static BOOL UseTrainingView = YES;
    if (UseTrainingView) {
        TrainingViewController * trainingView = [[TrainingViewController alloc] init];
        trainingView.process = _process;
        [self.navigationController pushViewController:trainingView animated:YES];
        return;
    }
    
    if (_trainingManager == nil){
        // 开始训练
        [self startTrainingUnit:nil];
        
    }else if(_trainingManager.trainingState == TrainingStateRunning){
        // 结束训练
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"结束训练？"
                                                             message:@""
                                                            delegate:self
                                                   cancelButtonTitle:@"取消"
                                                   otherButtonTitles:@"确定", nil];
        alertView.tag = UIAlertViewStopTraining;
        [alertView show];
    }
    
}

- (void)stopTraining{
    if (_trainingManager.trainingState == TrainingStateRunning ||
        _trainingManager.trainingState == TrainingStatePaused) {
        [_trainingManager stop];
        _trainingManager = nil;
        
        [self hideProgressView];
        [self showFirstTrainingUnitTimeLength];
    }
}

- (void)startTrainingUnit:(TrainingUnit *)unit{
    _trainingManager = [[TrainingManager alloc] initWithTrainingProcess:_process];
    _trainingManager.delegate = self;
    [_trainingManager startWithUnit:unit];
}

#pragma mark - Training manager delegate
- (void)trainingBeginForProcess:(TrainingProcess *)process{
    NSLog(@"%@开始", process);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_buttonTraining setTitle:kStopTrainingText forState:UIControlStateNormal];
    });
}

- (void)trainingBeginForUnit:(TrainingUnit *)unit{
    NSLog(@"%@开始", unit);
    
    _currentTrainingUnit = unit;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        TrainingUnitCell * cell = [self trainingCellForUnit:unit];
        [cell setRunning:YES];
        
        [_progressView.layer removeAllAnimations];
        
        // 展示当前进度，用动画实现，有过度效果，显得平滑
        [UIView animateWithDuration:[_currentTrainingUnit.timeLength floatValue] animations:^{
            _progressView.frame = CGRectMake(0, 0, _viewHeader.bounds.size.width, ProgressBarHeight);
        }];
    });
}

- (void)trainingUnit:(TrainingUnit *)unit unitTimeLeft:(NSNumber *)seconds{
    dispatch_async(dispatch_get_main_queue(), ^{
        _labelLeftTime.text = [Utils colonSeperatedTime:[seconds integerValue]];
    });
}

- (void)trainingFinishedForUnit:(TrainingUnit *)unit{
    NSLog(@"%@结束", unit);
    _currentTrainingUnit = nil;
    TrainingUnitCell * cell = [self trainingCellForUnit:unit];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [cell setRunning:NO];
        [self hideProgressView];
    });
}

- (void)trainingFinishedForProcess:(TrainingProcess *)process{
    NSLog(@"训练全部结束");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showFirstTrainingUnitTimeLength];
        [_buttonTraining setTitle:kStartTrainingText forState:UIControlStateNormal];
        
        TrainingUnitCell * cell = [self trainingCellForUnit:_currentTrainingUnit];
        [cell setRunning:NO];
    });
    
}

- (TrainingUnitCell *)trainingCellForUnit:(TrainingUnit *)unit{
    NSUInteger row = [_process.units indexOfObject:unit];
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    TrainingUnitCell * cell = (TrainingUnitCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    return cell;
}

#pragma mark - Table view date source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.process.units.count;
}

#pragma mark - Table view delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * sIdentifier = @"TrainingUnitCell";
    TrainingUnitCell * cell = [tableView dequeueReusableCellWithIdentifier:sIdentifier];
    
    TrainingUnit * unit = self.process.units[indexPath.row];
    [cell setTrainingUnit:unit];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TrainingUnitCell * cell = (TrainingUnitCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    TrainingUnitViewController * vc = [[TrainingUnitViewController alloc] initWithTrainingUnit:cell.unit];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)startTrainingForUnitWithIndexPath:(NSIndexPath *)indexPath{
    if (_trainingManager.trainingState == TrainingStateRunning) {
        [[[UIAlertView alloc] initWithTitle:@"训练中" message:@"要想从该单元开始训练，请先结束当前训练任务" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil] show];
        return;
    }
    
    TrainingUnitCell * cell = (TrainingUnitCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [self startTrainingUnit:cell.unit];
}

@end
