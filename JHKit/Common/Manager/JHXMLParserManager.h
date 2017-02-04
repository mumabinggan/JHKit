//
//  JHXMLParserManager.h
//  JHKit
//
//  Created by muma on 2017/2/1.
//  Copyright © 2017年 weygo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^JHXMLParserCompletion)(id result, NSError *error);

@interface JHXMLParserManager : NSObject

+ (JHXMLParserManager *)sharedXMLParserManager;

- (void)parser:(id)object completion:(JHXMLParserCompletion)completion;

@end
