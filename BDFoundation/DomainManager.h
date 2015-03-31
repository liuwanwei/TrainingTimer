//
//  DomainManager.h
//  investigation
//
//  Created by sungeo on 14/12/30.
//  Copyright (c) 2014年 buddysoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DomainManager : NSObject

+ (DomainManager *)defaultInstance;

- (NSArray *)domains;

- (void)addDomain:(NSString *)domain official:(BOOL)official;

- (void)setCurrentDomain:(NSString*)domain;
- (NSString *)currentDomain;
- (NSString *)officialDomain;

@end
