//
//  UIImage+RoundCorner.h
//  JHKit
//
//  Created by muma on 16/10/3.
//  Copyright © 2016年 mumuxinxinCompany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JHMacro.h"

@interface UIImage (JHRoundCorner)

+ (UIImage *)imageWithRect:(CGRect)frame
             roundedCorner:(JHRadius)radius
               borderWidth:(CGFloat)borderWidth
               borderColor:(UIColor *)borderColor
           backgroundColor:(UIColor *)backgroundColor;

@end

@interface UIImage (JHTintColor)

- (UIImage *)tintedImageWithColor:(UIColor *)tintColor;

@end

@interface UIImage (JHSize)

- (float)width;

- (float)height;

@end
