//
//  UIImageView+Additional.m
//  MallLibrary
//
//  Created by maoyu on 14-7-31.
//  Copyright (c) 2014年 yunteng. All rights reserved.
//

#import "UIImageView+Additional.h"
//#import "UIImageView+WebCache.h"

@implementation UIImageView (Additional)

- (void)addAction:(SEL)action target:(id)target {
    UITapGestureRecognizer * singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    [singleTap setNumberOfTapsRequired:1];
    [self setUserInteractionEnabled:YES];
    [self addGestureRecognizer:singleTap];
}

- (void)addBorderWithWidth:(NSInteger)width withColor:(UIColor *)color {
    CALayer * layer = [self layer];
    layer.borderColor = [color CGColor];
    layer.borderWidth = width;
}

- (void)makeCircle {
    self.layer.cornerRadius = self.frame.size.width / 2;
    self.layer.masksToBounds = YES;
}

- (void)makeCircleWithBorderColor:(UIColor *)color{
    [self makeCircle];
    [self addBorderWithWidth:3 withColor:color];
}

- (void)makeCornorRadius:(CGFloat)radius{
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = YES;
}

//- (void)downloadImage:(NSString *)path withPlaceholderImage:(NSString *)placehoderImage {
//    if (nil == path) {
//        path = @"";
//    }
//    NSURL * url = [NSURL URLWithString:path];
//    
//    [self sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:placehoderImage]];
//}
//
//- (void)showImage:(NSString *)url withPlaceHolder:(NSString *)bundleImageName{
//    return [self downloadImage:url withPlaceholderImage:bundleImageName];
//}
//
//- (void)showImage:(NSString *)url withPlaceHolderImage:(UIImage *)placeHolder{
//    if (url) {
//        [self sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:placeHolder];
//    }
//}

@end
