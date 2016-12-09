//
//  UIImageView+JHWebImage.h
//  JHKit
//
//  Created by muma on 16/10/6.
//  Copyright © 2016年 mumuxinxinCompany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

typedef NS_ENUM(NSInteger, JHWebImageOptions) {
    //if download error, try again
    JHWebImageOptionsRetryFailed = 1 << 0,
    
    //when scrollView is scroll, delay download
    JHWebImageOptionsLowPriority = 1 << 0,
    
    //cache memory only
    JHWebImageOptionsCacheMemoryOnly = 1 << 0,
    
    //progressive download
    JHWebImageOptionsProgressiveDownload = 1 << 0,
    
    //cache disk, NSURLCache will deal
    JHWebImageOptionsRefreshCached = 1 << 0,
};

typedef NS_ENUM(NSInteger, JHImageCacheType) {
    JHImageCacheTypeNone,
    JHImageCacheTypeDisk,
    JHImageCacheTypeMemory,
};

//download progress block
typedef void (^JHWebImageDownloadProgressBlock) (NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL);

//download completion block
typedef void (^JHWebImageDownloadCompletionBlock)(UIImage * _Nullable image, NSError * _Nullable error, JHImageCacheType cacheType, NSURL * _Nullable imageURL);

@interface UIImageView (JHWebImage)

- (void)setImageWithURL:(nullable NSURL *)url
       placeholderImage:(nullable UIImage *)placeholder
                options:(JHWebImageOptions)options;

- (void)setImageWithURL:(nullable NSURL *)url
       placeholderImage:(nullable UIImage *)placeholder
                options:(JHWebImageOptions)options
              completed:(nullable JHWebImageDownloadCompletionBlock)completedBlock;

- (void)setImageWithURL:(nullable NSURL *)url
       placeholderImage:(nullable UIImage *)placeholder
                options:(JHWebImageOptions)options
               progress:(nullable JHWebImageDownloadProgressBlock)progressBlock
              completed:(nullable JHWebImageDownloadCompletionBlock)completedBlock;
@end
