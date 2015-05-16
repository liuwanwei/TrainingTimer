//
//  BaseOperation.m
//
//  Created by maoyu on 13-12-18.
//  Copyright (c) 2013年 diandi. All rights reserved.
//

#import "BaseOperation.h"
#import "JDJsonDecoder.h"
#import "DomainManager.h"

const CGFloat BDRequestTimeout = 15.0f;     // 请求超时时间，单位秒

#define kRequestMetaData              @"request_tag"
// 要上传的文件数据在本地NSDictionary中的key
#define kUploadFilename               @"upload_file_name"
// 上传文件在POST协议中的key
#define kUploadFileFieldName          @"upload_file_field_name"
// 默认使用的上传文件名字（who cares？）
#define kRandomJPEGFilename(a)        [NSString stringWithFormat:@"%@_filename.jpeg",a]


static NSMutableArray * sOperations = nil;

@interface BaseOperation() {
    ASIHTTPRequest * _request;
}

@end

@implementation BaseOperation

- (id)init{
    if (self = [super init]) {
        self.requestTimeoutSeconds = BDRequestTimeout;
        self.needUserAuthInfo = YES;
    }
    
    return self;
}

- (BOOL)startRequest:(id <OperationDelegate>) delegate
{    
    _request = [self createRequest];
    [_request setTimeOutSeconds:self.requestTimeoutSeconds];
    
    self.delegate = delegate;
    
    ASINetworkQueue * networkQueue;
    networkQueue = [[ASINetworkQueue alloc] init];
    networkQueue.shouldCancelAllRequestsOnFailure = NO;
    networkQueue.maxConcurrentOperationCount = 1;
    networkQueue.delegate = self;
    [networkQueue setRequestDidFinishSelector:@selector(requestDidFinish:)];
    [networkQueue setRequestDidFailSelector:@selector(requestDidFail:)];
    
    [networkQueue addOperation:_request];
    [networkQueue go];
    
    [self addOperation:self];
    
    return true;
}

- (BOOL)startRequest:(id<OperationDelegate>)delegate withCompletion:(void (^)(BaseResponse * resp))completion{
    self.completion = completion;
    return [self startRequest:delegate];
}

- (BOOL)startRequestWithCompletion:(void (^)(BaseResponse *))completion{
    self.completion = completion;
    return [self startRequest:nil];
}

- (NSString *)rootUrl{
    return [NSString stringWithFormat:@"%@index.php?r=", [[DomainManager defaultInstance] currentDomain]];
}

- (NSString *)MakeUrlWithRelativePath:(NSString *)relativePath{
    return [NSString stringWithFormat:@"%@%@", [self rootUrl], relativePath];
}

- (NSString *)makeUrlWithRelativePath:(NSString *)relativePath param:(NSString *)param{
    if (param.length == 0) {
        return [NSString stringWithFormat:@"%@%@",[self rootUrl],relativePath];
    }else{
        return [NSString stringWithFormat:@"%@%@&req=%@",[self rootUrl],relativePath,param];
    }
}

#pragma mark - Create Get/Post Request

- (ASIHTTPRequest *)createPostRequestWithParam:(NSDictionary *)params withUrl:(NSURL *)url {
    ASIFormDataRequest * request = [ASIFormDataRequest requestWithURL:url];
    
    // 某些Post请求需要填充认证消息到HTTP HEADER
    if (self.needUserAuthInfo) {
        // TODO: 做成DataSource形势让派生类提供认证信息
//        [self addUserAuthInfo:request];
    }
    
    // 处理文件数据
    NSString * filePath = [params objectForKey:kUploadFilename];
    NSString * postField = [params objectForKey:kUploadFileFieldName];
    if (filePath != nil && postField != nil) {
        [request setFile:filePath forKey:postField];
    }
    
    // 处理其他参数（除了文件数据之外）
    NSMutableDictionary * leftParams = [NSMutableDictionary dictionaryWithDictionary:params];
    [leftParams removeObjectForKey:kUploadFileFieldName];
    
    //处理图片
    for (NSString * key in leftParams.allKeys) {
        id object = [leftParams objectForKey:key];
        if ([object isKindOfClass:[UIImage class]]) {
            UIImage * image = (UIImage *)object;
            NSData * data = UIImageJPEGRepresentation(image,0.5);
            [request setData:data withFileName:kRandomJPEGFilename(key) andContentType:nil forKey:key];
        }else {
            [request setPostValue:[leftParams objectForKey:key] forKey:key];
        }
    }
    
    NSString * subUrl = nil;
    if ([self respondsToSelector:@selector(requestPath)]) {
        subUrl = [self performSelector:@selector(requestPath)];
    }
    
    if (subUrl.length != 0) {
        [request setUserInfo:[NSDictionary dictionaryWithObject:subUrl forKey:kRequestMetaData]];
    }
    
    return request;
    
}

- (ASIHTTPRequest *)createGetRequestWithParam:(NSDictionary *)params{
    NSString * subUrl = nil;
    if ([self respondsToSelector:@selector(requestPath)]) {
        subUrl = [self performSelector:@selector(requestPath)];
    }
    
    ASIHTTPRequest * request = nil;
    if (subUrl.length != 0) {
        NSURL * url = [self makeGetApiUrl:subUrl withParams:params];
        NSLog(@"GET %@", url);
        request = [ASIHTTPRequest requestWithURL:url];
        [request setUserInfo:[NSDictionary dictionaryWithObject:subUrl forKey:kRequestMetaData]];
    }
    
    return request;
}

- (ASIHTTPRequest *)createPostRequestWithParam:(NSDictionary *)params{
    NSString * subUrl = nil;
    if ([self respondsToSelector:@selector(requestPath)]) {
        subUrl = [self performSelector:@selector(requestPath)];
    }else{
        return nil;
    }
    
    NSURL * url = [self makePostApiUrl:subUrl];
    NSLog(@"BDFoundation POST %@", url);
    
    return [self createPostRequestWithParam:params withUrl:url];
}

// 根据参数和子URL生成GET请求时用到的最终API URL。
- (NSURL *)makeGetApiUrl:(NSString *)subUrl withParams:(NSDictionary *)params{
    if (! [NSJSONSerialization isValidJSONObject:params]) {
        NSLog(@"BDFoundation: Params is not like json object");
        return nil;
    }
    
    NSString * paramString = nil;
    if (params != nil) {
        NSError * error;
        NSData * data = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
        paramString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        // OBJ-C的urlencode。Json出现在HTTP URL中时，需要编码成URL格式。
        paramString = (NSString *)
        CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                  (CFStringRef)paramString,
                                                                  NULL,
                                                                  NULL,
                                                                  kCFStringEncodingUTF8));
    }
    
    NSString * apiUrl = [self makeUrlWithRelativePath:subUrl param:paramString];
    return [NSURL URLWithString:apiUrl];
}

- (NSURL *)makePostApiUrl:(NSString *)subUrl {
    return [NSURL URLWithString:[self MakeUrlWithRelativePath:subUrl]];
}

#pragma mark - AsiNetWorkQueue delegate

- (void)requestDidFinish:(ASIHTTPRequest *)request {
    NSString * requestMetaData = [request.userInfo objectForKey:kRequestMetaData];
    NSData * responseData = [request responseData];
    
    NSString * subUrl = nil;
    if ([self respondsToSelector:@selector(requestPath)]) {
        subUrl = [self performSelector:@selector(requestPath)];
    }
    
    if ([requestMetaData isEqualToString:subUrl]) {
        Class prototype = nil;
        if ([self respondsToSelector:@selector(responseClassType)]) {
            
            // 获取反馈包class原型（prototype），反馈包必须继承自BaseResponse才能自动解析
            prototype = [self performSelector:@selector(responseClassType)];
            
            if ([prototype isSubclassOfClass:[BaseResponse class]]) {
                
                // 自动解析反馈数据为responseClassType
                NSError * error = nil;
                self.response = [JDJsonDecoder objectForClass:prototype withData:responseData options:0 error:&error];
                
                if (nil == self.response || BDOperationSuccess != self.response.head.code) {
                    // 反馈包包头不对，也作为错误的一种来处理
                    [self requestDidFail:request];
                    
                }else {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(didSucceed:)]) {
                        [self.delegate didSucceed:self];
                    }
                }
                
                // block回调处理，在delegate后添加的新的反馈包处理方式
                if (self.completion) {
                    self.completion(self.response);
                }
                
            }else{
                NSLog(@"反馈包原型错误");
            }
        }else{
            NSLog(@"ResponseClass未定义");
        }
    }
    
    // 执行到此行之前不能存在return，否则永远无法回收缓存，造成内存泄露
    [self removeOperation:self];
}

- (void)requestDidFail:(ASIHTTPRequest *)request {
    if ((nil == self.response)) {
        self.response = [[BaseResponse alloc] init];
        self.response.head = [[BaseResponseCore alloc] init];
        self.response.head.code = -1;
        self.response.head.msg = [NSString stringWithFormat:@"请检查网络连接"];
    }
    
    NSLog(@"error: code=%d msg=%@", (int)self.response.head.code, self.response.head.msg);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFail:)]) {
        [self.delegate didFail:self];
    }
    
    if (self.completion) {
        self.completion(self.response);
    }
    
    // 执行到此行之前不能存在return，否则永远无法回收缓存，造成内存泄露
    [self removeOperation:self];
}


- (ASIHTTPRequest *)createRequest {
    RequestType type = RequestTypeInvalid;
    if ([self respondsToSelector:@selector(requestType)]) {
        type = (RequestType)[self performSelector:@selector(requestType)];
    }
    
    if (type != RequestTypeInvalid) {
        NSDictionary * param = nil;
        if ([self respondsToSelector:@selector(requestParam)]) {
            param = [self performSelector:@selector(requestParam)];
        }
        
        if (type == RequestTypeGet) {
            return [self createGetRequestWithParam:param];
        }else if(type == RequestTypePost){
            return [self createPostRequestWithParam:param];
        }
    }
    
    return nil;
}

- (void)dealloc {
    [_request clearDelegatesAndCancel];
}

#pragma mark - 维护Operation Objects缓存
- (void)addOperation:(BaseOperation *)operation{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (sOperations == nil) {
            sOperations = [NSMutableArray array];
        }
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (operation != nil) {
            if (![sOperations containsObject:operation]) {
                [sOperations addObject:operation];
            }
        }
        
        const int MaxUnrecollected = 5;
        if (sOperations.count > MaxUnrecollected) {
            NSLog(@"BaseOperation缓存大于%d，请检查问题", MaxUnrecollected);
        }
    });
}

- (void)removeOperation:(BaseOperation *)operation{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (operation != nil) {
            if ([sOperations containsObject:operation]) {
                [sOperations removeObject:operation];
            }
        }
    });
}

@end
