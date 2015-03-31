//
//  UIImageView+Additional.h
//  MallLibrary
//
//  Created by maoyu on 14-7-31.
//  Copyright (c) 2014年 yunteng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Additional)

// 添加单击事件
- (void)addAction:(SEL)action target:(id)target;

// 添加外边框线
- (void)addBorderWithWidth:(NSInteger)width withColor:(UIColor *)color;

// 显示圆形图像
- (void)makeCircle;
- (void)makeCircleWithBorderColor:(UIColor *)color;

// 显示倒圆角
- (void)makeCornorRadius:(CGFloat)radius;

// 异步下载远程图片
//- (void)downloadImage:(NSString *)path withPlaceholderImage:(NSString *)placehoderImage;

// 同上，修改名字
//- (void)showImage:(NSString *)url withPlaceHolder:(NSString *)bundleImageName;
//- (void)showImage:(NSString *)url withPlaceHolderImage:(UIImage *)placeHolder;

@end
