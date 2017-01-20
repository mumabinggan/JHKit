//
//  JHCacheManager.m
//  JHKit
//
//  Created by muma on 2017/1/20.
//  Copyright © 2017年 weygo.com. All rights reserved.
//

#import "JHCacheManager.h"
#import "SDImageCache.h"

static JHCacheManager *_sharedInstance = nil;

@implementation JHCacheManager

+ (JHCacheManager *)sharedCacheManager {
    @synchronized([JHCacheManager class]) {
        if(!_sharedInstance)
            _sharedInstance = [[self alloc] init];
        return _sharedInstance;
    }
    return nil;
}

+ (id)alloc {
    @synchronized([JHCacheManager class]) {
        NSAssert(_sharedInstance == nil, @"Attempted to allocate a second instance of a singleton.");
        _sharedInstance = [super alloc];
        return _sharedInstance;
    }
    return nil;
}

- (void)clearCache:(void (^)())completion {
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:completion];
    [[SDImageCache sharedImageCache] clearMemory];//可有可
}

@end
