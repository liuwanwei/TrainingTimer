//
//  TrainingViewController.m
//  TrainingTimer
//
//  Created by sungeo on 15/3/24.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import "TrainingViewController.h"
#import <Masonry.h>
#import <libextobjc/EXTScope.h>
#import "UIColor+TrainingTimer.h"
#import "UIFont+Adapter.h"
#import "UIImage+Tint.h"
#import "TrainingProcess.h"
#import "TrainingUnit.h"
#import "TrainingManager.h"
#import "TrainingRecord.h"
#import "TrainingData.h"
#import "DotView.h"
#import "TrainingSetting.h"
#import <EXTScope.h>
#import <FBShimmeringView.h>

static NSString * const kDefaultTrainingTimeLeft = @"00:00";
static NSString * const kStartTrainingText = @"开始训练";
static NSString * const kStopTrainingText = @"结束训练";

static NSInteger const UIAlertViewStopTraining = 10081;
static NSInteger const UIAlertViewSkippingCount = 10082;

static float const DotViewBottomMargin = 15;


@interface TrainingViewController ()

@end

@implementation TrainingViewController{
    TrainingManager * _trainingManager;
    TrainingUnit * _currentTrainingUnit;
    BOOL _manualStopped;    // 是否手工关闭

    UIButton * _closeButton;
    UIButton * _soundButton;
    UILabel * _timeLabel;
    UIView * _centeredView;
    UIButton * _centeredButton;
    UILabel * _centeredLabel;
    NSMutableArray * _dottedViews;
    UIView * _progressView;
    
    MASConstraint * _progressViewWidthConstraint;
    
    FBShimmeringView * _shimmeringView;
    
    UIDynamicAnimator * _animator;
    
    __weak DotView * _currentDotView;
    __weak UIView * _wSuperView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor mainColor];
    _wSuperView = self.view;
    
    [self createSubViews];
    
    [self startTrainingUnit:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (NSUInteger)supportedInterfaceOrientations{
    if (isPad){
        return UIInterfaceOrientationMaskAll;
    }else{
        return UIInterfaceOrientationPortrait;
    }
}

- (BOOL)prefersStatusBarHidden{
    return  YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private functions
- (void)createSubViews{
    // 关闭按钮
    const float CloseButtonWidth = 50.0f;
    _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _closeButton.contentMode = UIViewContentModeCenter;
    [_wSuperView addSubview:_closeButton];
    [_closeButton mas_makeConstraints:^(MASConstraintMaker * maker){
        maker.leading.equalTo(_wSuperView.mas_leading).offset(0.f);
        maker.top.equalTo(_wSuperView.mas_top).offset(16.0f);
        maker.width.equalTo(@(CloseButtonWidth));
        maker.height.equalTo(_closeButton.mas_width);
    }];
    UIImage * image = [UIImage imageNamed:@"arrow-back"];
    image = [image imageWithTintColor:[UIColor whiteColor]];
    [_closeButton setImage:image forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(dismissView:) forControlEvents:UIControlEventTouchUpInside];
    
    // 声音按钮
    _soundButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:_soundButton];
    @weakify(self);
    [_soundButton mas_makeConstraints:^(MASConstraintMaker * maker){
        @strongify(self);
        maker.trailing.equalTo(self.view.mas_trailing).offset(0.f);
        maker.top.equalTo(self.view.mas_top).offset(16.0f);
        maker.width.equalTo(@(CloseButtonWidth));
        maker.height.equalTo(_soundButton.mas_width);
    }];
    [self updateSoundEffectButton];// "volume" and "mute" image
    [_soundButton addTarget:self action:@selector(soundEffect:) forControlEvents:UIControlEventTouchUpInside];
    
    
    // 中心背景：正圆形
    _centeredView = [[UIView alloc] initWithFrame:CGRectZero];
    _centeredView.backgroundColor = [UIColor whiteColor];
    [_wSuperView addSubview:_centeredView];
    [self remakeConstraintsForCenterView:_centeredView remake:NO];
    [self makeCircleForView:_centeredView];
    
    // 中心进度控制按钮
    _centeredButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _centeredButton.titleLabel.font = [UIFont fontWithName:@"Menlo-Bold" size:30.0f];
    [_centeredButton setTitleColor:[UIColor mainColor] forState:UIControlStateNormal];
    [_centeredButton addTarget:self action:@selector(pauseTraining:) forControlEvents:UIControlEventTouchUpInside];
    [_wSuperView addSubview:_centeredButton];
    [_centeredButton mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.edges.equalTo(_centeredView);
    }];
    [_centeredButton setNeedsLayout];
    [_centeredButton layoutIfNeeded];
    CGSize size = _centeredButton.bounds.size;
    _centeredButton.titleLabel.font = [UIFont adaptiveFontWithHeight:size.height/4];
    
    // 10秒数字倒计时label，充满中心圆
    _centeredLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _centeredLabel.backgroundColor = [UIColor clearColor];
    _centeredLabel.textColor = [UIColor mainColor];
    _centeredLabel.textAlignment = NSTextAlignmentCenter;
    [_wSuperView addSubview:_centeredLabel];
    [_centeredLabel mas_makeConstraints:^(MASConstraintMaker * maker){
        maker.edges.equalTo(_centeredView);
    }];
    size = _centeredView.frame.size;
    UIFont * font = [UIFont findAdaptiveFontWithName:@"DIN Alternate" forUILabelSize:size withMinimumSize:32];
    _centeredLabel.font = font;
    
    // 进度指示器：正方形
    _progressView = [[UIView alloc] initWithFrame:CGRectZero];
    _progressView.backgroundColor = [UIColor darkGrayColor];
    _progressView.alpha = 0.4;
    [_wSuperView addSubview:_progressView];
    [_progressView mas_makeConstraints:^(MASConstraintMaker * maker){
        maker.leading.equalTo(_wSuperView.mas_leading);
        maker.top.equalTo(_wSuperView.mas_top);
        maker.bottom.equalTo(_wSuperView.mas_bottom);
        _progressViewWidthConstraint = maker.width.equalTo(@(CGFLOAT_MIN));
    }];
    [self hideProgressView];
    
    // 剩余时间
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [_wSuperView addSubview:_timeLabel];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker * maker){
        maker.top.equalTo(_wSuperView.mas_top);
        maker.bottom.equalTo(_centeredView.mas_top);
        maker.width.equalTo(_wSuperView.mas_width);
        maker.centerX.equalTo(_wSuperView.mas_centerX);
    }];
    [_timeLabel setNeedsLayout];
    [_timeLabel layoutIfNeeded];
//    [self resetLeftTimeLabelFont];
    _timeLabel.font = [UIFont fontWithName:@"Courier" size:40.];
    _timeLabel.textColor = [UIColor whiteColor];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.text = [Utils colonSeperatedTime:0];

    FBShimmeringView * shimmeringView = [[FBShimmeringView alloc] initWithFrame:CGRectZero];
    shimmeringView.shimmering = NO;
    shimmeringView.shimmeringBeginFadeDuration = 0.1;
    shimmeringView.shimmeringOpacity = 1.0;
    shimmeringView.shimmeringSpeed = 105.f;
    [self.view addSubview:shimmeringView];
    [shimmeringView mas_makeConstraints:^(MASConstraintMaker * maker){
        maker.edges.equalTo(_timeLabel);
    }];
    shimmeringView.contentView = _timeLabel;
    _shimmeringView = shimmeringView;
    
    // 创建单元按钮
    [self createDottedViews];
    
    // 将进度指示界面放到按钮下层，其它界面上层
    [_wSuperView bringSubviewToFront:_progressView];
    [_wSuperView bringSubviewToFront:_centeredView];
    [_wSuperView bringSubviewToFront:_centeredLabel];
    [_wSuperView bringSubviewToFront:_closeButton];
    [_wSuperView bringSubviewToFront:_soundButton];
    [_wSuperView bringSubviewToFront:_centeredButton];
}

- (void)createDottedViews{
    const float HorizontalMargin = 30.0f;
    const float HorizontalInterval = 15.0f;
    
    _dottedViews = [NSMutableArray array];
    
    // 用等宽方法实现均匀放置任意个控件，方法如下：
    // 设置：第一个控件跟父容器左边距为固定值：DottedViewLeftMargin
    // 设置：最后一个控件跟父容器右边距为固定值：DottedViewRightMargin
    // 设置：每个控件跟它左边控件的边距为固定值：DottedViewInterval
    // 设置：每个控件的宽度互相相等
    id object;
    DotView * dotView = nil;
    __block UIView * prevView = nil;
    NSEnumerator * enumerator = [_process.units objectEnumerator];
    while ((object = [enumerator nextObject]) != nil) {
        TrainingUnit * unit = (TrainingUnit *)object;
        if (![unit isTrainingUnit]) {
            continue;
        }
        
        dotView = [[DotView alloc] initWithFrame:CGRectZero];
        dotView.backgroundColor = [UIColor whiteColor];
        [_wSuperView addSubview:dotView];
        [_dottedViews addObject:dotView];
        
        [dotView mas_makeConstraints:^(MASConstraintMaker * maker){
            // 共同位置属性
            maker.height.equalTo(@(36));
            
            dotView.originalBottomOffset = - DotViewBottomMargin;
            dotView.bottomConstraint = maker.bottom.equalTo(_wSuperView.mas_bottom).with.offset( - DotViewBottomMargin);
            
            if (prevView == nil) {
                // 第一个控件
                maker.leading.equalTo(_wSuperView.mas_leading).with.offset(HorizontalMargin);
                
            }else{
                // 中间控件
                maker.width.equalTo(prevView.mas_width);
                maker.leading.equalTo(prevView.mas_right).with.offset(HorizontalInterval);
            }
            
            prevView = dotView;
        }];
    }
    
    // 最后一个控件
    [prevView mas_makeConstraints:^(MASConstraintMaker * maker){
        maker.trailing.equalTo(_wSuperView.mas_trailing).with.offset(- HorizontalMargin);
    }];
    
    // 显示区域改为圆形
    [self resetDotViewLayerMasks];
}

- (void)resetDotViewLayerMasks{
    DotView * dotView;
    NSEnumerator * enumerator = [_dottedViews objectEnumerator];
    while ((dotView = [enumerator nextObject]) != nil) {
        [dotView makeCircle];
        [dotView resetConcentricCircle];
    }
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    [self resetDotViewLayerMasks];
    
//    [self resetLeftTimeLabelFont];
}

/** 将 UIView 变成一个圆形，直径等于长和宽中较小的那个
 *
 *  @param view     目标 view
 */
- (void)makeCircleForView:(UIView *)view{
    [view setNeedsLayout];
    [view layoutIfNeeded];
    
    // 直接生成圆形，使用贝塞尔曲线路径
    CAShapeLayer * shape = [CAShapeLayer layer];
    CGPoint center;
    center.x = view.bounds.size.width/2;
    center.y = view.bounds.size.height/2;
    CGFloat radius = center.x > center.y ? center.y : center.x;
    UIBezierPath * path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0 endAngle:(2*M_PI) clockwise:YES];
    shape.path = path.CGPath;
    view.layer.mask = shape;    // 重点在这里
}


- (void)remakeConstraintsForCenterView:(UIView *)view remake:(BOOL)remake{
    void (^makerBlock)(MASConstraintMaker *) = ^(MASConstraintMaker * maker){
        maker.center.equalTo(_wSuperView);
        
        CGFloat diameter;
        if (_wSuperView.bounds.size.width > _wSuperView.bounds.size.height) {
            diameter = _wSuperView.bounds.size.height;
        }else{
            diameter = _wSuperView.bounds.size.width;
        }
        maker.width.equalTo(@(diameter/2));
        maker.height.equalTo(_centeredView.mas_width);
    };
    
    if (remake) {
        [view mas_remakeConstraints:makerBlock];
    }else{
        [view mas_makeConstraints:makerBlock];
    }
}

- (void)dismissView:(id)sender{
    if(_trainingManager.trainingState == TrainingStateRunning){
        // 结束训练
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"结束训练？"
                                                             message:@""
                                                            delegate:self
                                                   cancelButtonTitle:@"取消"
                                                   otherButtonTitles:@"确定", nil];
        alertView.tag = UIAlertViewStopTraining;
        [alertView show];
    }else{
        [self.navigationController popViewControllerAnimated:YES];        
    }
}

- (void)soundEffect:(id)sender{
    TrainingSetting * ts = [TrainingSetting sharedInstance];
    ts.soundEffect = ! ts.soundEffect;
    [ts syncToDisk];
    [self updateSoundEffectButton];
}

- (void)updateSoundEffectButton{
    TrainingSetting * ts = [TrainingSetting sharedInstance];
    NSString * imageName = ts.soundEffect ? @"volume" : @"mute";
    UIImage * image = [UIImage imageNamed:imageName];
    image = [image imageWithTintColor:[UIColor whiteColor]];
    [_soundButton setImage:image forState:UIControlStateNormal];
}

- (void)stopTraining{
    if (_trainingManager.trainingState == TrainingStateRunning ||
        _trainingManager.trainingState == TrainingStatePaused) {
        [_trainingManager stop];
        _trainingManager = nil;
        
        [self hideProgressView];
    }
}

- (void)startTrainingUnit:(TrainingUnit *)unit{
    _trainingManager = [[TrainingManager alloc] initWithTrainingProcess:_process];
    _trainingManager.delegate = self;
    [_trainingManager startWithUnit:unit];
}

- (void)pauseTraining:(id)sender{
    if (_trainingManager.trainingState == TrainingStateRunning) {
        // 暂停
        [_trainingManager pause];
        [_centeredButton setTitle:nil forState:UIControlStateNormal];
        UIImage * image = [UIImage imageNamed:@"play"];
        image = [image imageWithTintColor:[UIColor mainColor]];
        // 三角形图形重心偏左，所以将总体显示位置向右移动一些
        [_centeredButton setImageEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
        [_centeredButton setImage:image forState:UIControlStateNormal];
    }else{
        // 继续
        [_trainingManager resume];
        [_centeredButton setTitle:[_currentTrainingUnit description] forState:UIControlStateNormal];
        [_centeredButton setImage:nil forState:UIControlStateNormal];
    }
}


#pragma mark - Alert view delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (UIAlertViewStopTraining == alertView.tag && buttonIndex == alertView.firstOtherButtonIndex) {
        _manualStopped = YES;
        [self stopTraining];
        
    }else if(UIAlertViewSkippingCount == alertView.tag){
        TrainingRecord * record = [[TrainingRecord alloc] initWithUnits:_process.units];

        if (alertView.firstOtherButtonIndex == buttonIndex) {
            // 输入跳绳个数处理
            UITextField * textField = [alertView textFieldAtIndex:0];
            record.numberOfSkipping = @(textField.text.integerValue);
        }
        
        [[TrainingData defaultInstance] addRecord:record];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Training manager delegate

- (void)trainingBeginForUnit:(TrainingUnit *)unit{
    NSLog(@"%@开始", unit);
    
    _currentTrainingUnit = unit;
    
    // 记录当前训练单元对应的圆点视图对象
    BOOL found = NO;
    NSInteger index = -1;
    NSEnumerator * enumerator = [_process.units objectEnumerator];
    TrainingUnit * object;
    while ((object = [enumerator nextObject]) != nil) {
        if ([object isTrainingUnit]) {
            index ++;
            
            if (object == unit) {
                found = YES;
                break;
            }
        }
    }
    NSLog(@"%@", @(index));
    if (index != -1 && found) {
        _currentDotView = _dottedViews[index];
        
    }else{
        _currentDotView = nil;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_centeredButton setTitle:[unit description]  forState:UIControlStateNormal];
    });
}

- (void)trainingUnit:(TrainingUnit *)unit unitTimeLeft:(NSNumber *)seconds{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger leftSeconds = [seconds integerValue];
        
        // 更新剩余时间
        _timeLabel.text = [Utils colonSeperatedTime:leftSeconds];
        
        if (leftSeconds < RushTimeStartSeconds) {
            // 最后十秒中间显示倒计时
            [_centeredButton setTitle:nil forState:UIControlStateNormal];
            _centeredLabel.text = [NSString stringWithFormat:@"%@", @(leftSeconds)];
            
            _shimmeringView.shimmering = YES;
        }
        
        [self animationDot];
        [self animationProgressWithLeftSeconds:leftSeconds - 1];
    });
}

- (void)trainingFinishedForUnit:(TrainingUnit *)unit{
    NSLog(@"%@结束", unit);
    _currentTrainingUnit = nil;
    _shimmeringView.shimmering = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideProgressView];
        
        [_currentDotView addConcentricCircle];
        _currentDotView = nil;
        
        _centeredLabel.text = nil;
    });
}

- (void)trainingFinishedForProcess:(TrainingProcess *)process{
    NSLog(@"训练全部结束");
    
    if (_manualStopped) {
        @weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            [self.navigationController popViewControllerAnimated:YES];
        });
        return;
    }else{
        [_centeredButton setTitle:@"完成" forState:UIControlStateNormal];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"这次一共跳了几个？" message:nil delegate:self cancelButtonTitle:@"没记住啦" otherButtonTitles:@"确定", nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        alertView.tag = UIAlertViewSkippingCount;
        UITextField * textField = [alertView textFieldAtIndex:0];
        textField.keyboardType = UIKeyboardTypeNumberPad;
        [alertView show];
    });
    
}

#pragma mark - Animations

- (void)animationProgressWithLeftSeconds:(NSInteger)seconds{
    if (seconds < 0) {
        seconds = 0;
    }

    CGFloat width = _wSuperView.bounds.size.width;
    NSInteger totalSeconds = _currentTrainingUnit.timeLength.integerValue;
    width *= (CGFloat)(totalSeconds - seconds) / totalSeconds;

    // 展示当前时间进度
    void (^animation)() = ^(){
        _progressViewWidthConstraint.sizeOffset(CGSizeMake(width, 0));
        [_progressView setNeedsLayout];
        [_progressView layoutIfNeeded];
    };
    
    [UIView transitionWithView:_progressView
                      duration:1.0
                       options:UIViewAnimationOptionCurveLinear animations:animation
                    completion:nil];
    

}

// 小球在上升时运动无误，下降时却无法完美实现一直加速
- (void)animationDot{
    if (_currentDotView == nil) {
        return;
    }
    
    [_currentDotView.layer removeAllAnimations];
    
    const CGFloat DotJumpHeight = 50.f;
    
    // 下面动态修改 constraint，在iPhone
    void (^moveUp)() = ^{
        _currentDotView.bottomConstraint.offset(_currentDotView.originalBottomOffset - DotJumpHeight);
        [_currentDotView setNeedsUpdateConstraints];
        [_currentDotView layoutIfNeeded];
    };
    
    void (^moveDown)() = ^{
        _currentDotView.bottomConstraint.offset(_currentDotView.originalBottomOffset);
        [_currentDotView setNeedsUpdateConstraints];
        [_currentDotView layoutIfNeeded];
    };
    
    void (^moveUpFinish)(BOOL) = ^(BOOL finished){
        if (finished) {
            [UIView transitionWithView:_wSuperView
                              duration:0.49 
                               options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionAllowAnimatedContent
                            animations:moveDown
                            completion:nil];
        }
    };
    
    [UIView transitionWithView:_wSuperView
                      duration:.5
                       options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionAllowAnimatedContent
                    animations:moveUp
                    completion:moveUpFinish];

}


- (void)resetLeftTimeLabelFont{
    CGSize size;
    size = _timeLabel.frame.size;
    size.height /= 2;
    UIFont * font = [UIFont findAdaptiveFontWithName:@"Courier" forUILabelSize:size withMinimumSize:20];
    _timeLabel.font = font;
}

- (void)hideProgressView{
//    UIView * superView = _progressView.superview;
//    CGFloat height = superView.bounds.size.height;
//    _progressView.frame = CGRectMake(0, 0, 0, height);
    _progressViewWidthConstraint.sizeOffset(CGSizeMake(CGFLOAT_MIN, 0));
}

@end
