//
//  UIButton+JHKit.m
//  JHKit
//
//  Created by muma on 2016/12/10.
//  Copyright © 2016年 weygo.com. All rights reserved.
//

#import "UIButton+JHKit.h"
#import "UIButton+WebCache.h"

@implementation UIButton (JHKit)

- (void)setImageWithURL:(nullable NSURL *)url
               forState:(UIControlState)state
       placeholderImage:(nullable UIImage *)placeholder
                options:(JHWebImageOptions)options {
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
    [self sd_setImageWithURL:url forState:state placeholderImage:placeholder options:sdOptions];
}

- (void)setBackgroundImageWithURL:(nullable NSURL *)url
                         forState:(UIControlState)state
                 placeholderImage:(nullable UIImage *)placeholder
                          options:(JHWebImageOptions)options {
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
    [self sd_setBackgroundImageWithURL:url forState:state placeholderImage:placeholder options:sdOptions];
}

@end
