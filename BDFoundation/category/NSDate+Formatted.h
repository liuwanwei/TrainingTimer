//
//  NSDate+formatted.h
//  investigation
//
//  Created by sungeo on 14/12/4.
//  Copyright (c) 2014年 buddysoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Formatted)

- (NSString *)mediumChineseString;
- (NSString *)mediumSimpleString;
- (NSString *)simpleDateTime;
- (NSString *)simpleDate;

+ (NSString *)longChineseForNow;
+ (NSDate *)fromStringDate:(NSString *)string withFormat:(NSString *)dateFormat;

@end
