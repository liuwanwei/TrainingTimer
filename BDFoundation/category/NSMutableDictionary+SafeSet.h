//
//  NSMutableDictionary+SafeSet.h
//  investigation
//
//  Created by sungeo on 14/12/23.
//  Copyright (c) 2014年 buddysoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary(SafeSet)

- (void)safeSetObject:(id)object forKey:(NSString *)key;

@end
