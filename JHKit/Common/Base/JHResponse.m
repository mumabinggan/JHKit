//
//  JHResponse.m
//  JHKit
//
//  Created by muma on 16/10/7.
//  Copyright © 2016年 mumuxinxinCompany. All rights reserved.
//

#import "JHResponse.h"

@implementation JHResponse

- (BOOL)success {
    if (![NSString isNullOrEmpty:_code]) {
        return _code.intValue == 1;
    }
    return NO;
}

@end
