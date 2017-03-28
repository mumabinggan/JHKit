//
//  JHNetworkManager.h
//  JHKit
//
//  Created by muma on 2016/10/16.
//  Copyright © 2016年 mumuxinxinCompany. All rights reserved.
//

#import "JHObject.h"

@class JHRequest, JHResponse;

@interface JHLogin : JHObject

@property (nonatomic, assign) long long code;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *sessionId;

@end

@interface JHNetworkManager : NSObject

+ (JHNetworkManager *)sharedManager;

- (void)get:(JHRequest *)request forResponseClass:(Class)clazz
    success:(void (^)(JHResponse *response))success
    failure:(void (^)(NSError *error))failure;

- (void)post:(JHRequest *)request forResponseClass:(Class)clazz
     success:(void (^)(JHResponse *response))success
     failure:(void (^)(NSError *error))failure;

- (void)get:(JHRequest *)request forResponseClass:(Class)clazz
   progress:(void (^)(NSProgress *downloadProgress))progress
    success:(void (^)(JHResponse *response))success
    failure:(void (^)(NSError *error))failure;

- (void)post:(JHRequest *)request forResponseClass:(Class)clazz
    progress:(void (^)(NSProgress *uploadProgress))progress
     success:(void (^)(JHResponse *response))success
     failure:(void (^)(NSError *error))failure;

- (void)post:(JHRequest *)request forResponseClass:(Class)clazz
    progress:(void (^)(NSProgress *uploadProgress))progress
       parts:(NSArray *)parts
     success:(void (^)(JHResponse *response))success
     failure:(void (^)(NSError *error))failure;

- (void)abort:(NSString *)url;

- (void)sss;

- (void)postSoap:(JHSoapRequest *)request forResponseClass:(Class)clazz
         success:(void (^)(JHResponse *))success
         failure:(void (^)(NSError *))failure;

- (void)postSoap:(JHSoapRequest *)request forResponseClass:(Class)clazz
        progress:(void (^)(NSProgress *))progress
         success:(void (^)(JHResponse *))success
         failure:(void (^)(NSError *))failure;

-(void)networkingGetMethod:(NSDictionary *)parameters urlName:(NSString *)urlName;

- (void)testPost;

@end
