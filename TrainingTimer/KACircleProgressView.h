#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface KACircleProgressView : UIView {
    CAShapeLayer *_trackLayer;
    UIBezierPath *_trackPath;
    CAShapeLayer *_progressLayer;
    UIBezierPath *_progressPath;
}

@property (nonatomic, strong) UIColor *trackColor;
@property (nonatomic, strong) UIColor *progressColor;
@property (nonatomic) float progress;//0~1之间的数
@property (nonatomic) float progressWidth;

- (void)setProgress:(float)progress animated:(BOOL)animated;

@end


/* 用法：在viewDidLoad中添加下面代码

 KACircleProgressView *progress = [[KACircleProgressView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
 [self.view addSubview:progress];
 progress.trackColor = [UIColor blackColor];
 progress.progressColor = [UIColor orangeColor];
 progress.progress = .7;
 progress.progressWidth = 10;

*/