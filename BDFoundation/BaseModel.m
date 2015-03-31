//
//  BaseModel.m
//  MallCommunicationLibrary
//
//  Created by maoyu on 14-7-28.
//  Copyright (c) 2014年 yuteng. All rights reserved.
//

#import "BaseModel.h"
#import "AutoCoding.h"

@implementation BaseModel

- (id)initWithUUID{
    if (self = [super init]) {
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        self.iid = CFBridgingRelease(CFUUIDCreateString(NULL, uuid));
        CFRelease(uuid);
        
        self.createDate = [NSDate date];
    }
    
    return self;
}

/*
 * 支持NSCoding协议，将对象打包成格式数据，打包之后，就能使用TMCache一类的库来做本地数据缓存
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    [self setWithCoder:aDecoder];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    for (NSString *key in [self codableProperties])
    {
        id object = [self valueForKey:key];
        if (object) [aCoder encodeObject:object forKey:key];
    }
}

@end
