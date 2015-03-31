//
//  BaseModel.h
//  MallCommunicationLibrary
//
//  Created by maoyu on 14-7-28.
//  Copyright (c) 2014年 yuteng. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kId                 @"id"
#define kName               @"name"
#define kIndex              @"index"
#define kTitle              @"title"
#define kStatus             @"status"
#define kCreateTime         @"createTime"
#define kAnswerOptions      @"answerOptions"

@interface BaseModel : NSObject <NSCoding>

@property (nonatomic, copy) NSString * id;          // id , deprecated, use iid instead
@property (nonatomic, copy) NSString * iid;         // 索引id，index id的简写，为避免跟id关键字冲突，使用iid代替id

@property (nonatomic, copy) NSString * createTime;  // 用于通信协议中
@property (nonatomic, strong) NSDate * createDate;  // 不用在通信协议中，仅仅排序时使用

@property (nonatomic, weak) id parentObject;

- (id)initWithUUID;

@end
