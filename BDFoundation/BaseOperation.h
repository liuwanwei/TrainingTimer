//
//  BaseOperation.h
//  tang
//
//  Created by maoyu on 13-12-18.
//  Copyright (c) 2013年 diandi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseResponse.h"
#import "ASINetworkQueue.h"
#import "ASIFormDataRequest.h"

typedef enum{
    BDOperationERROR = -1,    
    BDOperationSuccess = 0,
}BDOperationState;

typedef enum{
    RequestTypeInvalid = -1,
    RequestTypeGet = 0,
    RequestTypePost = 1,
}RequestType;

@class BaseOperation;

@protocol OperationDelegate <NSObject>

@optional
- (void)didSucceed:(BaseOperation *)operation;
- (void)didFail:(BaseOperation *)operation;

@end

@protocol OperationDataSource <NSObject>

@required
- (RequestType)requestType;             // 请求类型
- (NSDictionary *)requestParam;         // 请求参数
- (NSString *)requestPath;              // url路径
- (Class)responseClassType;             // 反馈包解析类原型。
@end


@interface BaseOperation : NSObject

@property (nonatomic) NSTimeInterval requestTimeoutSeconds;

@property (nonatomic, weak) id <OperationDelegate> delegate;

// POST请求需要发送认证信息时设置为YES
@property (nonatomic) BOOL needUserAuthInfo;
@property (nonatomic, strong) BaseResponse * response;
@property (nonatomic, copy) void (^completion)(BaseResponse * resp);

// 启动请求
- (BOOL)startRequest:(id<OperationDelegate>)delegate;
- (BOOL)startRequestWithCompletion:(void (^)(BaseResponse *))completion;

- (NSURL *)makeGetApiUrl:(NSString *)subUrl withParams:(NSDictionary *)params;

@end
