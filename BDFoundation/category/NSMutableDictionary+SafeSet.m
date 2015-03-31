//
//  NSMutableDictionary+SafeSet.m
//  investigation
//
//  Created by sungeo on 14/12/23.
//  Copyright (c) 2014年 buddysoft. All rights reserved.
//

#import "NSMutableDictionary+SafeSet.h"

@implementation NSMutableDictionary(SafeSet)

- (void)safeSetObject:(id)object forKey:(NSString *)key{
    if (key.length == 0 || object == nil) {
        NSLog(@"安全问题: %@ %@", key, object);
        return;
    }else{
        [self setObject:object forKey:key];
    }
}

@end
