//
//  UIButton+JHKit.h
//  JHKit
//
//  Created by muma on 2016/12/10.
//  Copyright © 2016年 weygo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (JHKit)

- (void)setImageWithURL:(nullable NSURL *)url
               forState:(UIControlState)state
       placeholderImage:(nullable UIImage *)placeholder
                options:(JHWebImageOptions)options;

- (void)setBackgroundImageWithURL:(nullable NSURL *)url
                         forState:(UIControlState)state
                 placeholderImage:(nullable UIImage *)placeholder
                          options:(JHWebImageOptions)options;

@end
