//
//  NSString+Additional.h
//  investigation
//
//  Created by maoyu on 14/12/11.
//  Copyright (c) 2014年 buddysoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Additional)

// md5加密
- (NSString *)md5EncodedString;

// 根据限制的字体、宽度获取文字需要的高度
- (CGFloat)getContentHeightWithFont:(UIFont *)font withWidth:(NSInteger)width;

@end
