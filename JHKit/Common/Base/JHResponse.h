//
//  JHResponse.h
//  JHKit
//
//  Created by muma on 16/10/7.
//  Copyright © 2016年 mumuxinxinCompany. All rights reserved.
//

#import "JHObject.h"

@interface JHResponse : JHObject

//@property (nonatomic, strong) NSString *code;
@property (nonatomic, assign) NSInteger code;

@property (nonatomic, strong) NSString *message;

@property (nonatomic, assign, readonly) BOOL success;

@property (nonatomic, strong, readonly) id responseObject;

@end
