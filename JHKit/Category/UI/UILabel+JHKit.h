//
//  UILabel+JHKit.h
//  JHKit
//
//  Created by muma on 2017/3/17.
//  Copyright © 2017年 weygo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (JHKit)

- (void)setPartString:(NSString *)str  attributes:(NSDictionary *)attrs;

- (void)addPrefixString:(NSString *)str  attributes:(NSDictionary *)attrs;

- (void)addSuffixString:(NSString *)str  attributes:(NSDictionary *)attrs;

@end
