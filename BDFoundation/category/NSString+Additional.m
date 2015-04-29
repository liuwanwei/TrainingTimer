//
//  NSString+Additional.m
//  investigation
//
//  Created by maoyu on 14/12/11.
//  Copyright (c) 2014年 buddysoft. All rights reserved.
//

#import "NSString+Additional.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Additional)

- (NSString *)dataToMD5EncodedString:(NSData *)data {
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5([data bytes], (CC_LONG)[data length], result);
    
    return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
}

- (NSString *)md5EncodedString
{
    NSData * data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [self dataToMD5EncodedString:data];
}

- (CGFloat)getContentHeightWithFont:(UIFont *)font withWidth:(NSInteger)width {
    CGFloat height = 0;
    CGSize maximumLabelSize = CGSizeMake(width, CGFLOAT_MAX);
    
    NSDictionary *attrsDictionary = @{ NSFontAttributeName: font};
    
    CGRect textRect = [self boundingRectWithSize:maximumLabelSize
                                         options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                      attributes:attrsDictionary
                                         context:nil];
    
    height = textRect.size.height;
    
    return height;
}

@end
