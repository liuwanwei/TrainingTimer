//
//  TrainingViewController.m
//  TrainingTimer
//
//  Created by sungeo on 15/3/24.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import "TrainingViewController.h"
#import <Masonry.h>
#import "UIColor+TrainingTimer.h"
#import "UIFont+Adapter.h"
#import "UIImage+Tint.h"
#import "TrainingProcess.h"
#import "TrainingUnit.h"
#import "TrainingManager.h"

static NSString * const kDefaultTrainingTimeLeft = @"00:00";
static NSString * const kStartTrainingText = @"开始训练";
static NSString * const kStopTrainingText = @"结束训练";

static NSInteger const UIAlertViewStopTraining = 10081;


@interface TrainingViewController ()

@end

@implementation TrainingViewController{
    TrainingManager * _trainingManager;
    TrainingUnit * _currentTrainingUnit;

    UIButton * _closeButton;
    UILabel * _timeLabel;
    UIView * _centeredView;
    UIButton * _centeredButton;
    UILabel * _centeredLabel;
    NSMutableArray * _dottedViews;
    UIView * _progressView;
    UIView * _bottomPlatformView;
    
    UIDynamicAnimator * _animator;
    
    __weak UIView * _currentDottedView;
    __weak UIView * _wSuperView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor trainingBackground];
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

- (BOOL)isPortraitForOrientation:(UIInterfaceOrientation)orientation{
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown) {
        return YES;
    }else{
        return NO;
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
    const float CloseButtonWidth = 60.0f;
    _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_wSuperView addSubview:_closeButton];
    [_closeButton mas_makeConstraints:^(MASConstraintMaker * maker){
        maker.leading.equalTo(_wSuperView.mas_leading);
        maker.top.equalTo(_wSuperView.mas_top);
        maker.width.equalTo(@(CloseButtonWidth));
        maker.height.equalTo(_closeButton.mas_width);
    }];
    
    [_closeButton setTitle:@"结束" forState:UIControlStateNormal];
    [_closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(dismissView:) forControlEvents:UIControlEventTouchUpInside];
    
    // 进度背景：正圆形
    _centeredView = [[UIView alloc] initWithFrame:CGRectZero];
    _centeredView.backgroundColor = [UIColor whiteColor];
    [_wSuperView addSubview:_centeredView];
    [self remakeConstraintsForCenterView:_centeredView remake:NO];
    [self makeCircleForView:_centeredView];
    
    // 进度控制按钮
    _centeredButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _centeredButton.titleLabel.font = [UIFont fontWithName:@"Menlo-Bold" size:30.0f];
    [_centeredButton setTitleColor:[UIColor trainingBackground] forState:UIControlStateNormal];
    [_centeredButton addTarget:self action:@selector(pauseTraining:) forControlEvents:UIControlEventTouchUpInside];
    [_wSuperView addSubview:_centeredButton];
    [_centeredButton mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.edges.equalTo(_centeredView);
    }];
    
    // 数字倒计时label，充满中心圆
    _centeredLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _centeredLabel.backgroundColor = [UIColor clearColor];
    _centeredLabel.textColor = [UIColor trainingBackground];
    _centeredLabel.textAlignment = NSTextAlignmentCenter;
    [_wSuperView addSubview:_centeredLabel];
    [_centeredLabel mas_makeConstraints:^(MASConstraintMaker * maker){
        maker.edges.equalTo(_centeredView);
    }];
    CGSize size = _centeredView.frame.size;
    UIFont * font = [UIFont findAdaptiveFontWithName:@"Times New Roman" forUILabelSize:size withMinimumSize:32];
    _centeredLabel.font = font;
    
    // 进度指示器：正方形
    _progressView = [[UIView alloc] initWithFrame:CGRectZero];
    _progressView.backgroundColor = [UIColor darkGrayColor];
    _progressView.alpha = 0.4;
    [_wSuperView addSubview:_progressView];
    [self hideProgressView];
    
    // 剩余时间
    const float TimeLabelWidth = 120.0f;
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _timeLabel.font = [UIFont systemFontOfSize:30.0f];
    [_wSuperView addSubview:_timeLabel];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker * maker){
        maker.top.equalTo(_wSuperView.mas_top);
        maker.bottom.equalTo(_centeredView.mas_top);
        maker.width.equalTo(@(TimeLabelWidth));
        maker.centerX.equalTo(_wSuperView.mas_centerX);
    }];
    _timeLabel.textColor = [UIColor whiteColor];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.text = @"00:00";

    
    // 创建单元按钮
    [self createDottedViews];
    
    // 将进度指示界面放到按钮下层，其它界面上层
    [_wSuperView bringSubviewToFront:_progressView];
    [_wSuperView bringSubviewToFront:_closeButton];
    [_wSuperView bringSubviewToFront:_centeredButton];
}

- (void)createDottedViews{
    const float DottedViewLeftMargin = 50.0f;
    const float DottedViewRightMargin = DottedViewLeftMargin;
    const float DottedViewBottomMargin = 25.0f;
    const float DottedViewInterval = 5.0f;
    const float DottedViewHeight = 25.0f;
    
    _dottedViews = [NSMutableArray array];
    
    NSEnumerator * enumerator = [_process.units objectEnumerator];
    
    // 用等宽方法实现均匀放置任意个控件，方法如下：
    // 设置：第一个控件跟父容器左边距为固定值：DottedViewLeftMargin
    // 设置：最后一个控件跟父容器右边距为固定值：DottedViewRightMargin
    // 设置：每个控件跟它左边控件的边距为固定值：DottedViewInterval
    // 设置：每个控件的宽度互相相等
    id object;
    UIView * dottedView = nil;
    __block UIView * prevView = nil;
    while ((object = [enumerator nextObject]) != nil) {
        TrainingUnit * unit = (TrainingUnit *)object;
        if (![unit isTrainingUnit]) {
            continue;
        }
        
        dottedView = [[UIView alloc] initWithFrame:CGRectZero];
        
        [_wSuperView addSubview:dottedView];
        [_dottedViews addObject:dottedView];
        [dottedView mas_makeConstraints:^(MASConstraintMaker * maker){
            // 共同位置属性
            maker.bottom.equalTo(_wSuperView.mas_bottom).with.offset(- DottedViewBottomMargin);
            maker.height.equalTo(@(DottedViewHeight));
            
            if (prevView == nil) {
                // 第一个控件
                maker.leading.equalTo(_wSuperView.mas_leading).with.offset(DottedViewLeftMargin);
                
            }else{
                // 中间控件
                maker.width.equalTo(prevView.mas_width);
                maker.leading.equalTo(prevView.mas_right).with.offset(DottedViewInterval);
            }
            
            prevView = dottedView;
        }];
        
        dottedView.backgroundColor = [UIColor whiteColor];
    }
    
    // 最后一个控件
    [prevView mas_makeConstraints:^(MASConstraintMaker * maker){
        maker.trailing.equalTo(_wSuperView.mas_trailing).with.offset(- DottedViewRightMargin);
    }];
    
    // 显示区域改为圆形
    enumerator = [_dottedViews objectEnumerator];
    while ((object = [enumerator nextObject]) != nil) {
        [self makeCircleForView:(UIView *)object];
    }
    
    // 底部弹跳平台
    _bottomPlatformView = [[UIView alloc] initWithFrame:CGRectZero];
    [_wSuperView addSubview:_bottomPlatformView];
    _bottomPlatformView.backgroundColor = [UIColor clearColor];
    [_bottomPlatformView mas_makeConstraints:^(MASConstraintMaker * maker){
        maker.leading.equalTo(_wSuperView.mas_leading);
        maker.top.equalTo(prevView.mas_bottom);
        maker.width.equalTo(_wSuperView.mas_width);
        maker.bottom.equalTo(_wSuperView.mas_bottom);
    }];
}

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
    view.layer.mask = shape;
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
        [_trainingManager pause];
        [_centeredButton setTitle:nil forState:UIControlStateNormal];
        UIImage * image = [UIImage imageNamed:@"play2"];
        image = [image imageWithTintColor:[UIColor barBackgroundColor]];// TODO: vv王巍的代码没起到效果
        [_centeredButton setImageEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
        [_centeredButton setImage:image forState:UIControlStateNormal];
    }else{
        [_trainingManager resume];
        [_centeredButton setTitle:[_currentTrainingUnit description] forState:UIControlStateNormal];
        [_centeredButton setImage:nil forState:UIControlStateNormal];
    }
}


#pragma mark - Alert view delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (UIAlertViewStopTraining == alertView.tag && buttonIndex == alertView.firstOtherButtonIndex) {
        [self stopTraining];
    }
}

#pragma mark - Training manager delegate
- (void)trainingBeginForProcess:(TrainingProcess *)process{
    NSLog(@"%@开始", process);
}

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
        _currentDottedView = _dottedViews[index];
    }else{
        _currentDottedView = nil;
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
        }
        
        [self animationDot];
        [self animationProgressWithLeftSeconds:leftSeconds-1];
    });
}

// 使用UIDynamic库的小球弹起实现方法，不再使用
// 小球会逐渐下落，但并不会落到地面。另外，小球在运动中会颤抖，无解。
- (void)beginJumpWithDot:(UIView *)dottedView{
    if (_animator != nil) {
        [_animator removeAllBehaviors];
    }

    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:_wSuperView];
    
    CGRect frame = dottedView.frame;
    frame.origin.y -= 100;
    dottedView.frame = frame;
    
    // 添加重力
    UIGravityBehavior * gravity = [[UIGravityBehavior alloc] initWithItems:@[dottedView]];
    
    // 添加碰撞
    UICollisionBehavior * collision = [[UICollisionBehavior alloc] initWithItems:@[dottedView]];
    collision.translatesReferenceBoundsIntoBoundary = YES;
    
    // 物体属性行为
    UIDynamicItemBehavior * item = [[UIDynamicItemBehavior alloc] initWithItems:@[dottedView]];
    item.elasticity = 1.0;  // 弹力系数，0~1，1最弹
    item.allowsRotation = NO;
    
    [_animator addBehavior:gravity];
    [_animator addBehavior:collision];
    [_animator addBehavior:item];
}

- (void)animationProgressWithLeftSeconds:(NSInteger)seconds{
    if (seconds < 0) {
        seconds = 0;
    }
    
    // 展示当前时间进度
    void (^animation)() = ^(){
        CGFloat width = _wSuperView.bounds.size.width;
        NSInteger totalSeconds = _currentTrainingUnit.timeLength.integerValue;
        width *= (CGFloat)(totalSeconds - seconds) / totalSeconds;
        CGRect newFrame = _progressView.frame;
        newFrame.size.width = width;
        _progressView.frame = newFrame;
    };
    
    [UIView transitionWithView:_progressView
                      duration:1.0
                       options:UIViewAnimationOptionCurveLinear animations:animation
                    completion:nil];
    

}

// 小球在上升时运动无误，下降时却无法完美实现一直加速
- (void)animationDot{
    if (_currentDottedView == nil) {
        return;
    }
    
    const CGFloat DotJumpHeight = 50.f;
    void (^moveUp)() = ^{
        CGRect newRect = _currentDottedView.frame;
        newRect.origin.y += DotJumpHeight;
        _currentDottedView.frame = newRect;
    };
    
    void (^moveDown)() = ^{
        CGRect newRect = _currentDottedView.frame;
        newRect.origin.y -= DotJumpHeight;
        _currentDottedView.frame = newRect;
    };
    
    void (^moveDownFinish)(BOOL) = ^(BOOL finished){
        if (finished) {
            // TODO: 播放滴答声
        }
    };
    
    void (^moveUpFinish)(BOOL) = ^(BOOL finished){
        if (finished) {
            [UIView transitionWithView:_currentDottedView
                              duration:0.49 
                               options:UIViewAnimationOptionCurveEaseOut
                            animations:moveDown
                            completion:moveDownFinish];
        }
    };
    
    [_currentDottedView.layer removeAllAnimations];
    
    [UIView transitionWithView:_currentDottedView
                      duration:0.5
                       options:UIViewAnimationOptionCurveEaseOut
                    animations:moveUp
                    completion:moveUpFinish];

}

- (void)trainingFinishedForUnit:(TrainingUnit *)unit{
    NSLog(@"%@结束", unit);
    _currentTrainingUnit = nil;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideProgressView];
        
        _currentDottedView.backgroundColor = [UIColor lightGrayColor];
        _currentDottedView = nil;
        
        _centeredLabel.text = nil;
    });
}

- (void)trainingFinishedForProcess:(TrainingProcess *)process{
    NSLog(@"训练全部结束");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissView:nil];
    });
    
}

- (void)hideProgressView{
    UIView * superView = _progressView.superview;
    CGFloat height = superView.bounds.size.height;
    _progressView.frame = CGRectMake(0, 0, 0, height);
}

- (void)fullFillProgressView{
    UIView * superView = _progressView.superview;
    _progressView.frame = CGRectMake(0, 0, superView.bounds.size.width, superView.bounds.size.height);
}

@end
