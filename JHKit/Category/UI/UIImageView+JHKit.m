//
//  UIImageView+JHWebImage.m
//  JHKit
//
//  Created by muma on 16/10/6.
//  Copyright © 2016年 mumuxinxinCompany. All rights reserved.
//

#import "UIImageView+JHKit.h"
#import "SDWebImageManager.h"

@implementation UIImageView (JHWebImage)

- (void)setImageWithURL:(nullable NSURL *)url
       placeholderImage:(nullable UIImage *)placeholder
                options:(JHWebImageOptions)options {
    [self setImageWithURL:url placeholderImage:placeholder options:options completed:nil];
}

- (void)setImageWithURL:(nullable NSURL *)url
       placeholderImage:(nullable UIImage *)placeholder
                options:(JHWebImageOptions)options
              completed:(nullable JHWebImageDownloadCompletionBlock)completedBlock {
    [self setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)setImageWithURL:(nullable NSURL *)url
       placeholderImage:(nullable UIImage *)placeholder
                options:(JHWebImageOptions)options
               progress:(nullable JHWebImageDownloadProgressBlock)progressBlock
              completed:(nullable JHWebImageDownloadCompletionBlock)completedBlock {
    //set options
    SDWebImageOptions sdOptions = 0;
    if (options & JHWebImageOptionsRetryFailed) {
        sdOptions |= SDWebImageRetryFailed;
    }
    else if (options & JHWebImageOptionsLowPriority) {
        sdOptions |= SDWebImageLowPriority;
    }
    else if (options & JHWebImageOptionsCacheMemoryOnly) {
        sdOptions |= SDWebImageCacheMemoryOnly;
    }
    else if (options & JHWebImageOptionsProgressiveDownload) {
        sdOptions |= SDWebImageProgressiveDownload;
    }
    else if (options & JHWebImageOptionsRefreshCached) {
        sdOptions |= SDWebImageRefreshCached;
    }
    
    //set progress
    SDWebImageDownloaderProgressBlock sdProgressBlock = nil;
    if (progressBlock) {
        sdProgressBlock = ^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            progressBlock(receivedSize, expectedSize, targetURL);
        };
    }
    
    //set completion
    SDExternalCompletionBlock sdCompletionBlock = nil;
    if (completedBlock) {
        sdCompletionBlock = ^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            JHImageCacheType imageCacheType = JHImageCacheTypeNone;
            if (cacheType == SDImageCacheTypeDisk) {
                imageCacheType = JHImageCacheTypeDisk;
            }
            else if (cacheType == SDImageCacheTypeMemory) {
                imageCacheType = JHImageCacheTypeMemory;
            }
            completedBlock(image, error, imageCacheType, imageURL);
        };
    }
    
    [self sd_setImageWithURL:url placeholderImage:placeholder options:sdOptions progress:sdProgressBlock completed:sdCompletionBlock];
}

@end
