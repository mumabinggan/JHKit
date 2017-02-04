//
//  JHNetworkManager.m
//  JHKit
//
//  Created by muma on 2016/10/16.
//  Copyright © 2016年 mumuxinxinCompany. All rights reserved.
//

#import "JHNetworkManager.h"
#import "JHRequest.h"
#import "JHResponse.h"
#import "NSString+JHKit.h"
#import "UIKit+AFNetworking.h"
#import "GDataXMLNode.h"
#import "JHXMLParserManager.h"

@interface JHNetworkManager ()

@end

@implementation JHNetworkManager
{
    NSMutableDictionary *_url2Tasks;
    AFHTTPSessionManager *_sessionManager;
}

static JHNetworkManager *_sharedInstance = nil;

+ (JHNetworkManager *)sharedManager {
    @synchronized([JHNetworkManager class]) {
        if (!_sharedInstance) {
            _sharedInstance = [[self alloc] init];
        }
        if (_sharedInstance) {
            [_sharedInstance prepareNetworkManager];
        }
        return _sharedInstance;
    }
    return nil;
}

+ (id)alloc {
    @synchronized([JHNetworkManager class]) {
        NSAssert(_sharedInstance == nil, @"Attempted to allocate a second instance of a singleton.");
        _sharedInstance = [super alloc];
        return _sharedInstance;
    }
    return nil;
}

- (void)prepareNetworkManager {
    if (!_sessionManager) {
        _sessionManager = [AFHTTPSessionManager manager];
    }
    if (!_url2Tasks) {
        _url2Tasks = [NSMutableDictionary dictionary];
    }
}

- (void)get:(JHRequest *)request forResponseClass:(Class)clazz success:(void (^)(JHResponse *))success failure:(void (^)(NSError *))failure {
    [self get:request forResponseClass:clazz progress:nil success:success failure:failure];
}

- (void)post:(JHRequest *)request forResponseClass:(Class)clazz success:(void (^)(JHResponse *))success failure:(void (^)(NSError *))failure {
    [self post:request forResponseClass:clazz progress:nil success:success failure:failure];
}

- (void)get:(JHRequest *)request forResponseClass:(Class)clazz progress:(void (^)(NSProgress *))progress success:(void (^)(JHResponse *))success failure:(void (^)(NSError *))failure {
    
    [self prepareHttpHeaders:request];
    
    __weak typeof(self) weakSelf = self;
    
    [_url2Tasks setObject:
     [_sessionManager GET:request.url parameters:request.parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progress) {
            progress(downloadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            JHResponse *response = [[clazz alloc] initWithDictionary:responseObject];
            if (response && request.enableResponseObject) {
                [response setValue:responseObject forKey:@"responseObject"];
            }
            success(response);
            [weakSelf handleRequestSuccess:request];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
        [weakSelf handleRequestFailure:request];
    }] forKey:request.url];
}

- (void)handleRequestSuccess:(JHRequest *)request {
    [_url2Tasks removeObjectForKey:request.url];
}

- (void)handleRequestFailure:(JHRequest *)request {
    [_url2Tasks removeObjectForKey:request.url];
}

- (void)post:(JHRequest *)request forResponseClass:(Class)clazz progress:(void (^)(NSProgress *))progress success:(void (^)(JHResponse *))success failure:(void (^)(NSError *))failure {
    
    [self prepareHttpHeaders:request];
    
    __weak typeof(self) weakSelf = self;
    
    [_url2Tasks setObject:
    [_sessionManager POST:request.url parameters:request.parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            JHResponse *response = [[clazz alloc] initWithDictionary:responseObject];
            if (response && request.enableResponseObject) {
                [response setValue:responseObject forKey:@"responseObject"];
            }
            success(response);
            [weakSelf handleRequestFailure:request];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
        [weakSelf handleRequestFailure:request];
    }] forKey:request.url];
}

- (void)post:(JHRequest *)request forResponseClass:(Class)clazz progress:(void (^)(NSProgress *))progress parts:(NSArray *)parts success:(void (^)(JHResponse *))success failure:(void (^)(NSError *))failure {
    
    [self prepareHttpHeaders:request];
    
    __weak typeof(self) weakSelf = self;
    
    [_url2Tasks setObject:
     [_sessionManager POST:request.url parameters:request.parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [weakSelf prepareFormData:formData parts:parts];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            JHResponse *response = [[clazz alloc] initWithDictionary:responseObject];
            if (response && request.enableResponseObject) {
                [response setValue:responseObject forKey:@"responseObject"];
            }
            success(response);
            [weakSelf handleRequestFailure:request];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
        [weakSelf handleRequestFailure:request];
    }] forKey:request.url];
}

- (void)prepareFormData:(id<AFMultipartFormData>  _Nonnull)formData parts:(NSArray *)parts {
    for (id p in parts) {
        if ([p isKindOfClass:[JHRequestFileURLPart class]]) {
            JHRequestFileURLPart *part = (JHRequestFileURLPart *)p;
            if (part.url && ![NSString isNullOrEmpty:part.name]) {
                if (![NSString isNullOrEmpty:part.fileName] && ![NSString isNullOrEmpty:part.mimeType]) {
                    [formData appendPartWithFileURL:part.url name:part.name fileName:part.fileName mimeType:part.mimeType error:nil];
                }
                else {
                    [formData appendPartWithFileURL:part.url name:part.name error:nil];
                }
            }
        }
        else if ([p isKindOfClass:[JHRequestFileDataPart class]]) {
            JHRequestFileDataPart *part = (JHRequestFileDataPart *)p;
            if (part.data && ![NSString isNullOrEmpty:part.name] && ![NSString isNullOrEmpty:part.fileName] && ![NSString isNullOrEmpty:part.mimeType]) {
                [formData appendPartWithFileData:part.data name:part.name fileName:part.fileName mimeType:part.mimeType];
            }
        }
        else if ([p isKindOfClass:[JHRequestFormDataPart class]]) {
            JHRequestFormDataPart *part = (JHRequestFormDataPart *)p;
            if (part.data && ![NSString isNullOrEmpty:part.name]) {
                [formData appendPartWithFormData:part.data name:part.name];
            }
        }
        else if ([p isKindOfClass:[JHRequestInputStreamPart class]]) {
            JHRequestInputStreamPart *part = (JHRequestInputStreamPart *)p;
            if (part.stream && ![NSString isNullOrEmpty:part.name] && ![NSString isNullOrEmpty:part.fileName] && ![NSString isNullOrEmpty:part.mimeType]) {
                [formData appendPartWithInputStream:part.stream name:part.name fileName:part.fileName length:part.length mimeType:part.mimeType];
            }
        }
        else if ([p isKindOfClass:[JHRequestHeaderPart class]]) {
            JHRequestHeaderPart *part = (JHRequestHeaderPart *)p;
            if (part.body) {
                [formData appendPartWithHeaders:part.headrs body:part.body];
            }
        }
    }
}

- (void)prepareHttpHeaders:(JHRequest *)request {
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    
    [requestSerializer setTimeoutInterval:[request timeoutInterval]];
    
    NSDictionary *headers = [request headers];
    if (headers) {
        for (NSInteger i = 0, n = headers.allKeys.count; i < n; ++ i) {
            NSString *key = [headers.allKeys objectAtIndex:i];
            [requestSerializer setValue:[headers objectForKey:key] forHTTPHeaderField:key];
        }
    }
    
    if (request.acceptContentTypes) {
        [responseSerializer setAcceptableContentTypes:request.acceptContentTypes];
    }
    
    _sessionManager.requestSerializer = requestSerializer;
    _sessionManager.responseSerializer = responseSerializer;
}

- (void)abort:(NSString *)url {
    NSURLSessionDataTask *task = [_url2Tasks objectForKey:url];
    if (task) {
        [task cancel];
        [_url2Tasks removeObjectForKey:url];
    }
}

- (void)postSoap:(JHSoapRequest *)request forResponseClass:(Class)clazz success:(void (^)(JHResponse *))success failure:(void (^)(NSError *))failure {
    [self postSoap:request forResponseClass:clazz progress:nil success:success failure:failure];
}

- (void)postSoap:(JHSoapRequest *)request forResponseClass:(Class)clazz progress:(void (^)(NSProgress *))progress success:(void (^)(JHResponse *))success failure:(void (^)(NSError *))failure {
    
    NSMutableString *soapBodyMString = [NSMutableString string];
    [soapBodyMString appendString:[NSString stringWithFormat:@"<ns1:%@ env:encodingStyle=\"http://www.w3.org/2003/05/soap-encoding\">\n", request.funcName]];
    for (int num = 0; num < request.parameterValueArray.count; ++num) {
        id value = request.parameterValueArray[num];
        if ([value isKindOfClass:[NSNull class]]) {
            continue;
        }
        NSString *key = request.parameterKeyArray[num];
        NSString *keyType = request.parameterTypeArray[num];
        [soapBodyMString appendString:[NSString stringWithFormat:@"<%@ xsi:type=\"xsd:%@\">%@</%@>\n", key, keyType, value, key]];
    }
    [soapBodyMString appendString:[NSString stringWithFormat:@"</ns1:%@>\n", request.funcName]];
    
    NSString *soapMessage = [NSString stringWithFormat:
                             @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
                             "<env:Envelope xmlns:env=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:ns1=\"urn:Magento\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:enc=\"http://www.w3.org/2003/05/soap-encoding\">\n"
                             "<env:Body>\n"
                             "%@"
                             "</env:Body>\n"
                             "</env:Envelope>\n", soapBodyMString];
    NSURL *url = [NSURL URLWithString:request.url];
    //AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //设置请求头
    [_sessionManager.requestSerializer setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    _sessionManager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    // 设置HTTPBody
    [_sessionManager.requestSerializer setQueryStringSerializationWithBlock:^NSString *(NSURLRequest *request, NSDictionary *parameters, NSError *__autoreleasing *error) {
        return soapMessage;
    }];
    
    __weak typeof(self) weakSelf = self;
    [_url2Tasks setObject:
    [_sessionManager POST:url.absoluteString parameters:soapMessage progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progress) {
            progress(downloadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"---%@----", responseObject);
        [[JHXMLParserManager sharedXMLParserManager] parser:responseObject completion:^(id result, NSError *error) {
            if (success) {
                JHResponse *response = [[clazz alloc] initWithJSON:result];
                success(response);
                DLog(@"----response--- = %@", response);
                [weakSelf handleSoapRequestFailure:request];
            }
        }];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
        [weakSelf handleSoapRequestFailure:request];
    }] forKey:[NSString stringWithFormat:@"%@_%@_%@", request.url, request.funcName, request.pathName]];
}

- (void)handleSoapRequestFailure:(JHSoapRequest *)request {
    [_url2Tasks removeObjectForKey:request.url];
}

- (void)sss {
//    //封装soap请求消息
//    NSString *soapMessage = [NSString stringWithFormat:
//                             @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
//                             "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
//                             "<soap:Body>\n"
//                             "<login xmlns=\"http://weygo3.cloudhy.com/index.php/api/soap/index/\">\n"
//                             "<hoursOffset>%@</hoursOffset>\n"
//                             "<hoursOffset1>%@</hoursOffset1>\n"
//                             "</login>\n"
//                             "</soap:Body>\n"
//                             "</soap:Envelope>\n"
//                             ,@"weygo", @"weygo1988"];
    
    NSString *soapMessage = [NSString stringWithFormat:
                             @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
                             "<env:Envelope xmlns:env=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:ns1=\"urn:Magento\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:enc=\"http://www.w3.org/2003/05/soap-encoding\">\n"
                             "<env:Body>\n"
//                                  "<ns1:call env:encodingStyle=\"http://www.w3.org/2003/05/soap-encoding\">\n"
//                                  "<sessionId xsi:type=\"xsd:string\">0cf2a7717b68d1995fb6d057115395cc</sessionId>\n"
//                                  "<resourcePath xsi:type=\"xsd:string\">catalog_category.categoryPage</resourcePath>\n"
//                                  "</ns1:call>\n"
                                                          "<ns1:login env:encodingStyle=\"http://www.w3.org/2003/05/soap-encoding\">\n"
                             "<username xsi:type=\"xsd:string\">weygo</username>\n"
                             "<apiKey xsi:type=\"xsd:string\">weygo1988</apiKey>\n"
                             "</ns1:login>\n"
                             "</env:Body>\n"
                             "</env:Envelope>\n"];
    
    ///请求发送到的路径
    NSURL *url = [NSURL URLWithString:@"http://weygo3.cloudhy.com/api/soap/index?wsdl"];
    
    url = [NSURL URLWithString:@"http://weygo3.cloudhy.com/index.php/api/soap/index"];
    //设置请求头
    [_sessionManager.requestSerializer setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    //[finalRequest addValue:@"http://weygo3.cloudhy.com" forHTTPHeaderField:@"HOST"];
    //[manager.requestSerializer setValue:@"http://weygo3.cloudhy.com" forHTTPHeaderField:@"HOST"];
    _sessionManager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    //manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    // 设置HTTPBody
    [_sessionManager.requestSerializer setQueryStringSerializationWithBlock:^NSString *(NSURLRequest *request, NSDictionary *parameters, NSError *__autoreleasing *error) {
        return soapMessage;
    }];
    
    [_sessionManager POST:url.absoluteString parameters:soapMessage progress:^(NSProgress * _Nonnull downloadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //responseObject = @"<rpc:result>loginReturn</rpc:result><loginReturn xsi:type=\"xsd:string\">{\"code\":1,\"message\":\"Login Successfully\",\"sessionId\":\"66570874eb46ab48f22796d376f1b71d\"}</loginReturn>";
        NSLog(@"-----%@",responseObject);
        [[JHXMLParserManager sharedXMLParserManager] parser:responseObject completion:^(id result, NSError *error) {

        }];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"Error: %@", error);
    }];
}

- (void)handleParserJson:(id)result class:(Class)clazz{
    
}

@end

@implementation JHLogin

@end
