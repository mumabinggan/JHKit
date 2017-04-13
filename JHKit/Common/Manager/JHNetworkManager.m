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
            NSError *error = nil;
            JHResponse *response = [[clazz alloc] initWithData:responseObject error:&error];
            if (response.reLogin) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReLoginRequired object:nil];
                return;
            }
            if (!response) {
                NSString *sss = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                NSLog(@"----response = %@---", sss);
                response = [[clazz alloc] initWithDictionary:responseObject error:nil];
                NSLog(@"----response---");
            }
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

//- (void)post:(JHRequest *)request forResponseClass:(Class)clazz progress:(void (^)(NSProgress *))progress success:(void (^)(JHResponse *))success failure:(void (^)(NSError *))failure {
//    
//    [self prepareHttpHeaders:request];
//
//    __weak typeof(self) weakSelf = self;
//    
//    [_url2Tasks setObject:
//    [_sessionManager POST:request.url parameters:request.parameters progress:^(NSProgress * _Nonnull uploadProgress) {
//        if (progress) {
//            progress(uploadProgress);
//        }
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        if (success) {
//            JHResponse *response = [[clazz alloc] initWithData:responseObject error:nil];
//            if (response && request.enableResponseObject) {
//                [response setValue:responseObject forKey:@"responseObject"];
//            }
//            success(response);
//            [weakSelf handleRequestFailure:request];
//        }
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        if (failure) {
//            failure(error);
//        }
//        [weakSelf handleRequestFailure:request];
//    }] forKey:request.url];
//}

- (void)post:(JHRequest *)request forResponseClass:(Class)clazz progress:(void (^)(NSProgress *))progress success:(void (^)(JHResponse *))success failure:(void (^)(NSError *))failure {
    // 初始化Request
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:request.url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:request.timeoutInterval];
    // http method
    [urlRequest setHTTPMethod:@"POST"];
    // http header
    [urlRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSDictionary *parameters = request.parameters;    // http body
    NSMutableString *paraString = [NSMutableString string];
    for (NSString *key in [parameters allKeys]) {
        [paraString appendFormat:@"&%@=%@", key, parameters[key]];
    }
    if (![NSString isNullOrEmpty:paraString]) {
        [paraString deleteCharactersInRange:NSMakeRange(0, 1)]; // 删除多余的&号
    }
    [urlRequest setHTTPBody:[paraString dataUsingEncoding:NSUTF8StringEncoding]];
    
    // 初始化AFManager
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration: [NSURLSessionConfiguration defaultSessionConfiguration]];
    AFJSONResponseSerializer *serializer = [AFJSONResponseSerializer serializer];
    serializer.acceptableContentTypes = [NSSet setWithObjects:
                                         @"text/plain",
                                         @"application/json",
                                         @"text/html", nil];
    manager.responseSerializer = serializer;
    WeakSelf;
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:urlRequest uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            // 请求失败
            NSLog(@"Request failed with reason '%@'", [error localizedDescription]);
        } else {
            // 请求成功
            NSLog(@"Request success with responseObject - /n '%@'", responseObject);
            JHResponse *response = [[clazz alloc] initWithDictionary:responseObject error:nil];
            if (response.reLogin) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReLoginRequired object:nil];
                return;
            }
            if (response && request.enableResponseObject) {
                [response setValue:responseObject forKey:@"responseObject"];
            }
            success(response);
            [weakSelf handleRequestFailure:request];
        }
    }];
    
    [_url2Tasks setObject:dataTask forKey:request.url];
    [dataTask resume];
    
//    
//    [_url2Tasks setObject:
//     [_sessionManager POST:request.url parameters:request.parameters progress:^(NSProgress * _Nonnull uploadProgress) {
//        if (progress) {
//            progress(uploadProgress);
//        }
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        if (success) {
//            JHResponse *response = [[clazz alloc] initWithData:responseObject error:nil];
//            if (response && request.enableResponseObject) {
//                [response setValue:responseObject forKey:@"responseObject"];
//            }
//            success(response);
//            [weakSelf handleRequestFailure:request];
//        }
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        if (failure) {
//            failure(error);
//        }
//        [weakSelf handleRequestFailure:request];
//    }] forKey:request.url];
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
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    
    //[requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    //responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/plain", nil];
    //responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html; charset=UTF-8",@"text/plain", nil];
    
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

-(void)networkingGetMethod:(NSDictionary *)parameters urlName:(NSString *)urlName
{
    return;
    urlName = @"http://delong6688.develop.weygo.com/appservice/catalogSearch/topMenus?sign=15384456e8e84108e338256c3a8a98c8";
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //申明返回的结果是json类型
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //申明请求的数据是json类型
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    //如果报接受类型不一致请替换一致text/html或别的
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/plain", nil];
    [manager GET:urlName parameters:@{} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //
        NSLog(@"----success---%@", responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //failureBlock(error);
        NSLog(@"----fail---");
    }];
    
}

- (void)testPost {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    // 设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 20.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/xml",@"text/html", nil ];
    NSString *url = @"http://delong6688.develop.weygo.com/appservice/pages/content?";
    NSDictionary *params = @{@"menuId":@(19), @"sign":@"943419793cfeef22139a9e64936ace24"};
    // post请求
    [manager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        // 成功，关闭网络指示器
        NSLog(@"-----%@----", responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // 失败，关闭网络指示器
        NSLog(@"-----ERROR---%@", error);
    }];
}

//    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
//    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
//    session.requestSerializer = [AFHTTPRequestSerializer serializer];
//    
//    NSDictionary *params = @{@"menuId":@(19)};
//    
//    [session POST:@"http://delong6688.develop.weygo.com/appservice/pages/content?sign=943419793cfeef22139a9e64936ace24" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        
//        NSLog(@"%@",responseObject);
//        
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        
//        NSLog(@"%@",error);
//        
//    }];

- (void)postWithUrl:(NSString *)url body:(NSData *)body showLoading:(BOOL)show success:(void(^)(NSDictionary *response))success failure:(void(^)(NSError *error))failure
{
    __weak id weakSelf = self;
    NSString *requestUrl = @"http://delong6688.develop.weygo.com/appservice/customer/login?sign=86d7e81d8d79bb54a0626f947de72add";
    // 初始化Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestUrl] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15.0];
    // http method
    [request setHTTPMethod:@"POST"];
    // http header
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSDictionary *parameters = @{@"username":@"mumabinggan@163.com", @"password":@"123456"};    // http body
    NSMutableString *paraString = [NSMutableString string];
    for (NSString *key in [parameters allKeys]) {
        [paraString appendFormat:@"&%@=%@", key, parameters[key]];
    }
    [paraString deleteCharactersInRange:NSMakeRange(0, 1)]; // 删除多余的&号
    [request setHTTPBody:[paraString dataUsingEncoding:NSUTF8StringEncoding]];
    
    // 初始化AFManager
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration: [NSURLSessionConfiguration defaultSessionConfiguration]];
    AFJSONResponseSerializer *serializer = [AFJSONResponseSerializer serializer];
    serializer.acceptableContentTypes = [NSSet setWithObjects:
                                         @"text/plain",
                                         @"application/json",
                                         @"text/html", nil];
    manager.responseSerializer = serializer;
        
//    NSError *serializationError = nil;
//    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:&serializationError];
//    if (serializationError) {
//        if (failure) {
//            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
//                failure(nil, serializationError);
//            });
//        }
//        
//        return nil;
//    }
    
//    __block NSURLSessionDataTask *dataTask = nil;
//    dataTask = [self dataTaskWithRequest:request
//                          uploadProgress:uploadProgress
//                        downloadProgress:downloadProgress
//                       completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
//                           if (error) {
//                               if (failure) {
//                                   failure(dataTask, error);
//                               }
//                           } else {
//                               if (success) {
//                                   success(dataTask, responseObject);
//                               }
//                           }
//                       }];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            // 请求失败
            NSLog(@"Request failed with reason '%@'", [error localizedDescription]);
        } else {
            // 请求成功
            NSLog(@"Request success with responseObject - /n '%@'", responseObject);
        }
    }];
    
//    // 构建请求任务
//    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
//        if (error) {
//            // 请求失败
//            NSLog(@"Request failed with reason '%@'", [error localizedDescription]);
//        } else {
//            // 请求成功
//            NSLog(@"Request success with responseObject - /n '%@'", responseObject);
//        }
//    }];
    // 发起请求
    [dataTask resume];
}

@end

@implementation JHLogin

@end
