//
//  DotView.m
//  TrainingTimer
//
//  Created by sungeo on 15/4/11.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import "DotView.h"

@implementation DotView{
//    CAShapeLayer * _circleLayer;
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


@end
