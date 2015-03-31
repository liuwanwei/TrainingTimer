//
//  BaseResponseCore.h
//  MallCommunicationLibrary
//
//  Created by maoyu on 14-7-29.
//  Copyright (c) 2014年 yuteng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseResponseCore : NSObject

@property (nonatomic) NSInteger code;
@property (nonatomic, copy) NSString * msg;

@end
