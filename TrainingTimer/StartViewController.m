//
//  StartViewController.m
//  TrainingTimer
//
//  Created by sungeo on 15/3/31.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import "StartViewController.h"
#import "TrainingUnit.h"
#import "HeartRateViewController.h"
#import "UIColor+TrainingTimer.h"
#import "UIFont+Adapter.h"
#import "BigLineView.h"
#import <objc/runtime.h>
#import <Masonry.h>
#import "TrainingProcess.h"
#import "TrainingViewController.h"
#import "RecordsViewController.h"
#import "TrainingSetting.h"
#import <XLForm.h>
//#import "KACircleProgressView.h"
#import <FBShimmeringView.h>
#import <GLPubSub/NSObject+GLPubSub.h>
#import <libextobjc/EXTScope.h>

typedef enum{
    BigLineViewWarmUp = 1,
    BigLineViewSkipping,
    BigLineViewRest,
    BigLineViewRound,
}BigLineViewTag;

@implementation StartViewController{
    BigLineView * _warmUpView;
    BigLineView * _skippingView;
    BigLineView * _restView;
    BigLineView * _roundView;
    NSMutableArray * _bigLines;
    UIButton * _startButton;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self initializeSubViews];
    [self initializeBarButtonItem];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    self.title = @"HIIT跳绳训练";
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

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // TODO: 这段初始化代码应该放到更合适的地方
        TrainingSetting * setting = [TrainingSetting sharedInstance];
        [_warmUpView setDescription:@"热身"];
        [_warmUpView setCurrentValue:setting.warmUpTime.integerValue isTime:YES];
        
        [_skippingView setDescription:@"跳绳"];
        [_skippingView setCurrentValue:setting.skippingTime.integerValue isTime:YES];
        
        [_restView setDescription:@"休息"];
        [_restView setCurrentValue:setting.restTime.integerValue isTime:YES];
        
        [_roundView setDescription:@"组"];
        [_roundView setCurrentValue:setting.rounds.integerValue isTime:NO];
        
        [self updateStartButtonFont];
        [_startButton setTitle:@"GO!" forState:UIControlStateNormal];
        [_startButton addTarget:self action:@selector(startTraining:) forControlEvents:UIControlEventTouchUpInside];
    });
}

- (void)resetLineViewDimention{
    BigLineView * view;
    NSEnumerator * enumerator = [_bigLines objectEnumerator];
    while ((view = [enumerator nextObject])) {
        [view resetContentSize];
    }
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    [self resetLineViewDimention];
    [self updateStartButtonFont];
}

- (void)initializeSubViews{
    _bigLines = [NSMutableArray array];
    __weak UIView * wSuperView = self.view;
    
    // 热身
    _warmUpView = [[BigLineView alloc] initWithMaxValue:TTMaxWarmUpTime];
    _warmUpView.tag = BigLineViewWarmUp;
    _warmUpView.options = @[[XLFormOptionsObject formOptionsObjectWithValue:@(60) displayText:@"1分钟"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(120) displayText:@"2分钟"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(180) displayText:@"3分钟"]];
    [self.view addSubview:_warmUpView];
    [_warmUpView mas_makeConstraints:^(MASConstraintMaker * maker){
        maker.top.equalTo(wSuperView.mas_top);
        maker.leading.equalTo(wSuperView.mas_leading);
        maker.width.equalTo(wSuperView.mas_width);
    }];
    [_bigLines addObject:_warmUpView];
    
    // 跳绳时间
    _skippingView = [[BigLineView alloc] initWithMaxValue:TTMaxSkippingTime];
    _skippingView.tag = BigLineViewSkipping;
    [self.view addSubview:_skippingView];
    [_skippingView mas_makeConstraints:^(MASConstraintMaker * maker){
        maker.top.equalTo(_warmUpView.mas_bottom);
        maker.leading.equalTo(wSuperView.mas_leading);
        maker.width.equalTo(wSuperView.mas_width);
        maker.height.equalTo(_warmUpView.mas_height);
    }];
    [_bigLines addObject:_skippingView];
    
    // 休息时间
    _restView = [[BigLineView alloc] initWithMaxValue:TTMaxRestTime];
    _restView.tag = BigLineViewRest;
    _restView.options = @[[XLFormOptionsObject formOptionsObjectWithValue:@(10) displayText:@"10秒"],
                          [XLFormOptionsObject formOptionsObjectWithValue:@(20) displayText:@"20秒"],
                          [XLFormOptionsObject formOptionsObjectWithValue:@(30) displayText:@"30秒"]];
    [self.view addSubview:_restView];
    [_restView mas_makeConstraints:^(MASConstraintMaker * maker){
        maker.top.equalTo(_skippingView.mas_bottom);
        maker.leading.equalTo(wSuperView.mas_leading);
        maker.width.equalTo(wSuperView.mas_width);
        maker.height.equalTo(_skippingView.mas_height);
    }];
    [_bigLines addObject:_restView];
    
    // 练习几轮
    _roundView = [[BigLineView alloc] initWithMaxValue:TTMaxRound];
    _roundView.tag = BigLineViewRound;
    _roundView.options = @[[XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"3组"],
                           [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"4组"],
                           [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"5组"],
                           [XLFormOptionsObject formOptionsObjectWithValue:@(6) displayText:@"6组"],
                           [XLFormOptionsObject formOptionsObjectWithValue:@(7) displayText:@"7组"],
                           [XLFormOptionsObject formOptionsObjectWithValue:@(8) displayText:@"8组"],
                           [XLFormOptionsObject formOptionsObjectWithValue:@(9) displayText:@"9组"],
                           [XLFormOptionsObject formOptionsObjectWithValue:@(10) displayText:@"10组"]];
    [self.view addSubview:_roundView];
    [_roundView mas_makeConstraints:^(MASConstraintMaker * maker){
        maker.top.equalTo(_restView.mas_bottom);
        maker.leading.equalTo(wSuperView.mas_leading);
        maker.width.equalTo(wSuperView.mas_width);
        maker.height.equalTo(_restView.mas_height);
    }];
    [_bigLines addObject:_roundView];
    [_roundView hideBottomLine];
    
    _startButton = [[UIButton alloc] init];
    [self.view addSubview:_startButton];
    [_startButton mas_makeConstraints:^(MASConstraintMaker * maker){
        maker.top.equalTo(_roundView.mas_bottom);
        maker.leading.equalTo(wSuperView.mas_leading);
        maker.width.equalTo(wSuperView.mas_width);
        maker.height.equalTo(_roundView.mas_height);
        maker.bottom.equalTo(wSuperView.mas_bottom);
    }];
    _startButton.backgroundColor = [UIColor mainColor];
    
    // 处理每个子View的delegate事件
    for (BigLineView * view in _bigLines) {
        view.delegate = self;
    }
}

- (void)updateStartButtonFont{
    CGSize size = _startButton.bounds.size;
    size.height /= 2;
    _startButton.titleLabel.font = [UIFont findAdaptiveFontWithName:nil forUILabelSize:size withMinimumSize:0];
}

- (void)startTraining:(id)sender{
//    TrainingProcess * process = [TrainingProcess trainingProcessFromSetting];
    TrainingProcess * process = [TrainingProcess testObject];
    
    TrainingViewController * trainingVc = [[TrainingViewController alloc] init];
    trainingVc.process = process;
    [self.navigationController pushViewController:trainingVc animated:YES];

}

- (void)initializeBarButtonItem{
    UIBarButtonItem * item;
    
    item = [[UIBarButtonItem alloc] initWithTitle:@"记录" style:UIBarButtonItemStylePlain target:self action:@selector(showRecords:)];
    self.navigationItem.leftBarButtonItem = item;
    
    item = [[UIBarButtonItem alloc] initWithTitle:@"心率" style:UIBarButtonItemStylePlain target:self action:@selector(showHeartRateSetting:)];
    self.navigationItem.rightBarButtonItem = item;
    
    // 隐藏默认栈返回按钮中的文字
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
}

- (void)showRecords:(id)sender{
    RecordsViewController * vc = [[RecordsViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showHeartRateSetting:(id)sender{
    HeartRateViewController * vc = [[HeartRateViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Big line value changed
- (void)bigLineView:(BigLineView *)view didChangeWithNewValue:(NSNumber *)theValue{
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
}


@end
