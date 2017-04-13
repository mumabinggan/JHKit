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
    return _code == 1;
}

- (BOOL)reLogin {
    return _code == -1;
}

@end
