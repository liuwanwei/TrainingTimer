//
//  StartViewController.m
//  TrainingTimer
//
//  Created by sungeo on 15/3/31.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import "StartViewController.h"
#import "TrainingUnit.h"
#import "UIColor+TrainingTimer.h"
#import "UIFont+Adapter.h"
#import "StartLineView.h"
#import <objc/runtime.h>
#import <Masonry.h>
#import "TrainingProcess.h"
#import "TrainingViewController.h"
#import "RecordsViewController.h"
#import "TrainingSetting.h"
#import <XLForm.h>
#import <FBShimmeringView.h>
#import <GLPubSub/NSObject+GLPubSub.h>
#import <libextobjc/EXTScope.h>
#import "StartHeaderView.h"
#import "StartPanelView.h"
#import "BDFoundation.h"

typedef enum{
    BigLineViewWarmUp = 1,
    BigLineViewSkipping,
    BigLineViewRest,
    BigLineViewRound,
}BigLineViewTag;

@implementation StartViewController{
    StartHeaderView * _headerView;
    StartLineView * _warmUpView;
    StartLineView * _skippingView;
    StartLineView * _restView;
    StartLineView * _roundView;
    NSMutableArray * _bigLines;
    StartPanelView * _startPanel;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self initializeSubViews];
    [self initializeBarButtonItem];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    self.title = @"HIIT跳绳训练";
    
    self.navigationController.navigationBarHidden = YES;
//    
//    @weakify(self);
//    // TODO: 能收到这个消息，但这是个 will 消息，收到时还没有旋转，所以代码不起作用
//    [self subscribe:UIApplicationWillChangeStatusBarOrientationNotification handler:^(GLEvent * event){
//        @strongify(self);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self resetLineViewDimention];
//            [self updateStartButtonFont];
//        });
//    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    static dispatch_once_t onceToken;
    @weakify(self);
    dispatch_once(&onceToken, ^{
        // TODO: 这段初始化代码应该放到更合适的地方
        @strongify(self);
        
        TrainingSetting * setting = [TrainingSetting sharedInstance];
        [_warmUpView setDescription:@"热身时间"];
        [_warmUpView setValueUnit:@"秒"];
        [_warmUpView setCurrentValue:setting.warmUpTime.integerValue isTime:YES];
        
        [_skippingView setDescription:@"训练时间"];
        [_skippingView setValueUnit:@"秒"];
        [_skippingView setCurrentValue:setting.skippingTime.integerValue isTime:YES];
        
        [_restView setDescription:@"休息时间"];
        [_restView setValueUnit:@"秒"];
        [_restView setCurrentValue:setting.restTime.integerValue isTime:YES];
        
        [_roundView setDescription:@"重复几组"];
        [_roundView setValueUnit:@"组"];
        [_roundView setCurrentValue:setting.rounds.integerValue isTime:NO];
        
        [_startPanel updateStartButtonFont];
        
        [self updateTotalTime];
    });
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations{
    if (isPad){
        return UIInterfaceOrientationMaskAll;
    }else{
        return UIInterfaceOrientationPortraitUpsideDown;
    }
}

- (void)resetLineViewDimention{
    StartLineView * view;
    NSEnumerator * enumerator = [_bigLines objectEnumerator];
    while ((view = [enumerator nextObject])) {
        [view resetContentSize];
    }
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    [self resetLineViewDimention];
    [_startPanel updateStartButtonFont];
    
    [self.view layoutSubviews];
}

- (void)initializeSubViews{
    _bigLines = [NSMutableArray array];
    __weak UIView * wSuperView = self.view;
    
    @weakify(self);
    
    // 头部：训练描述
    _headerView = [[StartHeaderView alloc] initWithViewController:self];
    [self.view addSubview:_headerView];
    [_headerView createSubViews];
    [_headerView mas_makeConstraints:^(MASConstraintMaker * maker){
        @strongify(self);
        maker.leading.equalTo(self.view.mas_leading);
        maker.top.equalTo(self.view.mas_top);
        maker.width.equalTo(self.view.mas_width);
        maker.height.equalTo(self.view.mas_height).dividedBy(3.58);
    }];
    
    // 热身
    _warmUpView = [[StartLineView alloc] initWithMaxValue:TTMaxWarmUpTime];
    _warmUpView.tag = BigLineViewWarmUp;
    _warmUpView.parentViewController = self;
    _warmUpView.options = @[[XLFormOptionsObject formOptionsObjectWithValue:@(60) displayText:@"60 秒"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(120) displayText:@"120 秒"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(180) displayText:@"180 秒"]];
    [self.view addSubview:_warmUpView];
    [_warmUpView mas_makeConstraints:^(MASConstraintMaker * maker){
        @strongify(self);
        maker.top.equalTo(self->_headerView.mas_bottom);
        maker.leading.equalTo(wSuperView.mas_leading);
        maker.width.equalTo(wSuperView.mas_width);
    }];
    [_bigLines addObject:_warmUpView];
    
    // 跳绳时间
    _skippingView = [[StartLineView alloc] initWithMaxValue:TTMaxSkippingTime];
    _skippingView.tag = BigLineViewSkipping;
    _skippingView.parentViewController = self;
    _skippingView.options = nil;
    [self.view addSubview:_skippingView];
    [_skippingView mas_makeConstraints:^(MASConstraintMaker * maker){
        maker.top.equalTo(_warmUpView.mas_bottom);
        maker.leading.equalTo(wSuperView.mas_leading);
        maker.width.equalTo(wSuperView.mas_width);
        maker.height.equalTo(_warmUpView.mas_height);
    }];
    [_bigLines addObject:_skippingView];
    
    // 休息时间
    _restView = [[StartLineView alloc] initWithMaxValue:TTMaxRestTime];
    _restView.tag = BigLineViewRest;
    _restView.parentViewController = self;
    _restView.options = @[[XLFormOptionsObject formOptionsObjectWithValue:@(10) displayText:@"10 秒"],
                          [XLFormOptionsObject formOptionsObjectWithValue:@(20) displayText:@"20 秒"],
                          [XLFormOptionsObject formOptionsObjectWithValue:@(30) displayText:@"30 秒"]];
    [self.view addSubview:_restView];
    [_restView mas_makeConstraints:^(MASConstraintMaker * maker){
        maker.top.equalTo(_skippingView.mas_bottom);
        maker.leading.equalTo(wSuperView.mas_leading);
        maker.width.equalTo(wSuperView.mas_width);
        maker.height.equalTo(_skippingView.mas_height);
    }];
    [_bigLines addObject:_restView];
    
    // 练习几轮
    _roundView = [[StartLineView alloc] initWithMaxValue:TTMaxRound];
    _roundView.tag = BigLineViewRound;
    _roundView.parentViewController = self;
    _roundView.options = @[[XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"3 组"],
                           [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"4 组"],
                           [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"5 组"],
                           [XLFormOptionsObject formOptionsObjectWithValue:@(6) displayText:@"6 组"],
                           [XLFormOptionsObject formOptionsObjectWithValue:@(7) displayText:@"7 组"],
                           [XLFormOptionsObject formOptionsObjectWithValue:@(8) displayText:@"8 组"],
                           [XLFormOptionsObject formOptionsObjectWithValue:@(9) displayText:@"9 组"],
                           [XLFormOptionsObject formOptionsObjectWithValue:@(10) displayText:@"10 组"]];
    [self.view addSubview:_roundView];
    [_roundView mas_makeConstraints:^(MASConstraintMaker * maker){
        maker.top.equalTo(_restView.mas_bottom);
        maker.leading.equalTo(wSuperView.mas_leading);
        maker.width.equalTo(wSuperView.mas_width);
        maker.height.equalTo(_restView.mas_height);
    }];
    [_bigLines addObject:_roundView];
     [_roundView hideBottomLine];
    
    _startPanel = [[StartPanelView alloc] init];
    [self.view addSubview:_startPanel];
    [_startPanel createSubViews];
    [_startPanel mas_makeConstraints:^(MASConstraintMaker * maker){
        maker.top.equalTo(_roundView.mas_bottom);
        maker.leading.equalTo(wSuperView.mas_leading);
        maker.width.equalTo(wSuperView.mas_width);
        maker.height.equalTo(@60);
        maker.bottom.equalTo(wSuperView.mas_bottom);
    }];
    [_startPanel addStartButtonTarget:self selector:@selector(startTraining:)];
    [_startPanel addCalendarButtonTarget:self selector:@selector(showRecords:)];
    
    // 处理每个子View的delegate事件
    for (StartLineView * view in _bigLines) {
        view.delegate = self;
    }
}

- (void)startTraining:(id)sender{
    TrainingProcess * process = [TrainingProcess trainingProcessFromSetting];
    
    TrainingViewController * trainingVc = [[TrainingViewController alloc] init];
    trainingVc.process = process;
    [self.navigationController pushViewController:trainingVc animated:YES];
    
}


- (void)initializeBarButtonItem{
    UIBarButtonItem * item;
    
    item = [[UIBarButtonItem alloc] initWithTitle:@"记录" style:UIBarButtonItemStylePlain target:self action:@selector(showRecords:)];
    self.navigationItem.leftBarButtonItem = item;
    
    // 隐藏默认栈返回按钮中的文字
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
}


- (void)showRecords:(id)sender{
    RecordsViewController * vc = [[RecordsViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Big line value changed
- (void)bigLineView:(StartLineView *)view didChangeWithNewValue:(NSNumber *)theValue{
    TrainingSetting * setting = [TrainingSetting sharedInstance];
    switch (view.tag) {
        case BigLineViewWarmUp:
            setting.warmUpTime = theValue;
            break;
        case BigLineViewSkipping:
            setting.skippingTime = theValue;
            break;
        case BigLineViewRest:
            setting.restTime = theValue;
            break;
        case BigLineViewRound:
            setting.rounds = theValue;
    }
    
    [setting syncToDisk];
    
    [self updateTotalTime];
}

- (void)updateTotalTime{
    TrainingSetting * setting = [TrainingSetting sharedInstance];
    
    NSInteger seconds = 0;
    seconds += [setting.warmUpTime integerValue];
    for (NSInteger i = 0; i < setting.rounds.integerValue; i++) {
        seconds += setting.skippingTime.integerValue;
        seconds += setting.restTime.integerValue;
    }
    
    NSInteger minutes = seconds / 60;
    seconds %= 60;
    NSString * totalTime = [NSString stringWithFormat:@"共需 %@ 分 %@ 秒", @(minutes), @(seconds)];
    
    [_headerView updateTotalTime:totalTime];
}


@end
