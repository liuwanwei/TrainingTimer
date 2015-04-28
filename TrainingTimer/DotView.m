//
//  DotView.m
//  TrainingTimer
//
//  Created by sungeo on 15/4/11.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import "DotView.h"
#import "UIColor+TrainingTimer.h"
#import "UIImage+Tint.h"

@implementation DotView{
    CAShapeLayer * _finishedCircleLayer;
    CALayer * _checkmarkLayer;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)makeCircle{
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    // 直接生成圆形，使用贝塞尔曲线路径
    CAShapeLayer * shape = [CAShapeLayer layer];
    CGPoint center;
    center.x = self.bounds.size.width/2;
    center.y = self.bounds.size.height/2;
    CGFloat radius = center.x > center.y ? center.y : center.x;
    UIBezierPath * path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0 endAngle:(2*M_PI) clockwise:YES];
    shape.path = path.CGPath;
    self.layer.mask = shape;    // 重点在这里
}


/** 向中心添加一个同心圆，代表训练单元完成
 *
 *
 */
- (void)addConcentricCircle{
    CAShapeLayer * circleShape = [CAShapeLayer layer];
    circleShape.fillColor = [[UIColor mainColor] CGColor];
    CGPoint center;
    center.x = self.bounds.size.width/2;
    center.y = self.bounds.size.height/2;
    CGFloat radius = center.x > center.y ? center.y : center.x;
    CGFloat cic_radius = radius - 4;
    UIBezierPath * path = [UIBezierPath bezierPathWithArcCenter:center radius:cic_radius startAngle:0 endAngle:(2*M_PI) clockwise:YES];
    circleShape.path = path.CGPath;
    [self.layer addSublayer:circleShape];
    
    _finishedCircleLayer = circleShape;

    UIImage * image = [UIImage imageNamed:@"check_mark"];
    image = [image imageWithTintColor:[UIColor whiteColor]];
    UIImageView * imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(center.x - radius/2, center.y - radius/2, radius, radius);
    [self.layer addSublayer:imageView.layer];
    
    _checkmarkLayer = imageView.layer;
}

/** 重绘完成状态同心圆，一般用在屏幕旋转后
 *
 */
- (void)resetConcentricCircle{
    if (_finishedCircleLayer) {
        [_finishedCircleLayer removeFromSuperlayer];
        [_checkmarkLayer removeFromSuperlayer];
        [self addConcentricCircle];
    }
}

@end
