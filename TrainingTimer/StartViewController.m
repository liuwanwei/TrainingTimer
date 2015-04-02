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

@implementation StartViewController{
    BigLineView * _warmUpView;
    BigLineView * _skippingView;
    BigLineView * _restView;
    BigLineView * _roundView;
    UIButton * _startButton;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self initializeSubViews];
    [self initializeBarButtonItem];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    self.title = @"HIIT跳绳训练";
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)initializeSubViews{
    __weak UIView * wSuperView = self.view;
    TrainingUnit * unit;
    
    // 热身
    unit = [[TrainingUnit alloc] initWithDictionary:@{TrainingUnitTypeKey:@(TrainingUnitTypeWarmUp),
                                                      TrainingUnitTimeLength:@(120)}];
    _warmUpView = [[BigLineView alloc] initWithMaxLength:TTMaxWarmUpTime];
    [self.view addSubview:_warmUpView];
    [_warmUpView mas_makeConstraints:^(MASConstraintMaker * maker){
        maker.top.equalTo(wSuperView.mas_top);
        maker.leading.equalTo(wSuperView.mas_leading);
        maker.width.equalTo(wSuperView.mas_width);
    }];
    
    // 跳绳时间
    unit = [[TrainingUnit alloc] initWithDictionary:@{TrainingUnitTypeKey:@(TrainingUnitTypeSkipping),
                                                      TrainingUnitTimeLength:@(60)}];
    _skippingView = [[BigLineView alloc] initWithMaxLength:TTMaxSkippingTime];
    [self.view addSubview:_skippingView];
    [_skippingView mas_makeConstraints:^(MASConstraintMaker * maker){
        maker.top.equalTo(_warmUpView.mas_bottom);
        maker.leading.equalTo(wSuperView.mas_leading);
        maker.width.equalTo(wSuperView.mas_width);
        maker.height.equalTo(_warmUpView.mas_height);
    }];
    
    // 休息时间
    unit = [[TrainingUnit alloc] initWithDictionary:@{TrainingUnitTypeKey:@(TrainingUnitTypeRest),
                                                      TrainingUnitTimeLength:@(20)}];
    _restView = [[BigLineView alloc] initWithMaxLength:TTMaxRestTime];
    [self.view addSubview:_restView];
    [_restView mas_makeConstraints:^(MASConstraintMaker * maker){
        maker.top.equalTo(_skippingView.mas_bottom);
        maker.leading.equalTo(wSuperView.mas_leading);
        maker.width.equalTo(wSuperView.mas_width);
        maker.height.equalTo(_skippingView.mas_height);
    }];
    
    // 练习几轮
    _roundView = [[BigLineView alloc] initWithMaxLength:TTMaxRound];
    [self.view addSubview:_roundView];
    [_roundView mas_makeConstraints:^(MASConstraintMaker * maker){
        maker.top.equalTo(_restView.mas_bottom);
        maker.leading.equalTo(wSuperView.mas_leading);
        maker.width.equalTo(wSuperView.mas_width);
        maker.height.equalTo(_restView.mas_height);
    }];
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
    _startButton.backgroundColor = RGB(0xEB, 0x6E, 0x12);
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    [_warmUpView setType:@"热身"];
    [_warmUpView setLength:120 isTime:YES];
    
    [_skippingView setType:@"跳绳"];
    [_skippingView setLength:60 isTime:YES];
    
    [_restView setType:@"休息"];
    [_restView setLength:20 isTime:YES];
    
    [_roundView setType:@"组"];
    [_roundView setLength:4 isTime:NO];
    
    CGSize size = _startButton.bounds.size;
    size.height /= 3;
    _startButton.titleLabel.font = [UIFont findAdaptiveFontWithName:nil forUILabelSize:size withMinimumSize:0];
    [_startButton setTitle:@"GO!" forState:UIControlStateNormal];
    [_startButton addTarget:self action:@selector(startTraining:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)startTraining:(id)sender{
    TrainingProcess * process = [[TrainingProcess alloc] initWithTitle:@""];
    
    // 准备时间单元
    TrainingUnit * unit = [TrainingUnit trainingUnitWithType:TrainingUnitTypeWarmUp interval:_warmUpView.currentLength];
    [process addUnit:unit];
    
    // 训练时间单元
    NSInteger round = _roundView.currentLength;
    for (NSInteger i = 0; i < round; i++) {
        unit = [TrainingUnit trainingUnitWithType:TrainingUnitTypeSkipping interval:_skippingView.currentLength];
        [process addUnit:unit];
        
        unit = [TrainingUnit trainingUnitWithType:TrainingUnitTypeRest interval:_restView.currentLength];
        unit.index = @(i);
        [process addUnit:unit];
    }
    
    TrainingViewController * trainingVc = [[TrainingViewController alloc] init];
    trainingVc.process = process;
    [self.navigationController pushViewController:trainingVc animated:YES];

}

- (void)initializeBarButtonItem{
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithTitle:@"心率" style:UIBarButtonItemStylePlain target:self action:@selector(showHeartRateSetting:)];
    self.navigationItem.rightBarButtonItem = item;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
}

- (void)showHeartRateSetting:(id)sender{
    HeartRateViewController * vc = [[HeartRateViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
