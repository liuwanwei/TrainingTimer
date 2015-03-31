//
//  DomainManager.m
//  investigation
//
//  Created by sungeo on 14/12/30.
//  Copyright (c) 2014年 buddysoft. All rights reserved.
//

#import "DomainManager.h"

#define kDomain     @"HostnameIndex"

@interface DomainManager()
@property (nonatomic, strong) NSMutableArray * availableDomains;
@property (nonatomic) int currentDomainIndex;
@property (nonatomic) NSInteger officialDomainIndex;

@end

@implementation DomainManager

+ (DomainManager *)defaultInstance{
    static DomainManager * sDefault = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (sDefault == nil) {
            sDefault = [[DomainManager alloc] init];
        }
    });
    
    return sDefault;
}

- (id)init{
    if (self = [super init]) {
        self.availableDomains = [NSMutableArray array];
        self.currentDomainIndex = -1;
        [self loadConfig];
    }
    
    return self;
}

- (void)loadConfig{
    // 从磁盘加载主机序号
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    int index = [[ud objectForKey:kDomain] intValue];
    self.currentDomainIndex = index;
}

- (NSArray *)domains{
    return [NSArray arrayWithArray:self.availableDomains];
}

// 添加一个域名
- (void)addDomain:(NSString *)domain official:(BOOL)official{
    if ([self.availableDomains containsObject:domain]) {
        return;
    }else{
        [self.availableDomains addObject:domain];
        if (official) {
            self.officialDomainIndex = [self.availableDomains indexOfObject:domain];
            [self setCurrentDomain:domain];
        }
    }
}

// 设置当前使用域名
- (void)setCurrentDomain:(NSString *)domain{
    NSUInteger index = [self.availableDomains indexOfObject:domain];
    if (index != NSNotFound) {
        self.currentDomainIndex = (int)index;
        
        // 保存到磁盘中
        NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:[NSNumber numberWithInt:self.currentDomainIndex] forKey:kDomain];
    }
}

- (NSString *)currentDomain{
    return self.availableDomains[self.currentDomainIndex];
}

- (NSString *)officialDomain{
    return self.availableDomains[self.officialDomainIndex];
}

@end
