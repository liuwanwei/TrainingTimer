//
//  NSDate+formatted.m
//  investigation
//
//  Created by sungeo on 14/12/4.
//  Copyright (c) 2014年 buddysoft. All rights reserved.
//

#import "NSDate+Formatted.h"

@implementation NSDate (Formatted)

+ (NSString *)longChineseForNow{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM月dd日HH点mm分"];
    
    return [formatter stringFromDate:[NSDate date]];
}

- (NSString *)mediumChineseString{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM月dd日HH:mm"];
    return [formatter stringFromDate:self];
}

- (NSString *)mediumSimpleString{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd HH:mm"];
    return [formatter stringFromDate:self];
}

- (NSString *)simpleDateTime{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [formatter stringFromDate:self];
}

- (NSString *)simpleDate {
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return [formatter stringFromDate:self];
}

+ (NSDate *)fromStringDate:(NSString *)string withFormat:(NSString *)dateFormat{
    NSDateFormatter * format = [[NSDateFormatter alloc] init];
    format.dateFormat = dateFormat;
    return [format dateFromString:string];
}

@end
