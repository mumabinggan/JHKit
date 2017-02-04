//
//  JHXMLParserManager.m
//  JHKit
//
//  Created by muma on 2017/2/1.
//  Copyright © 2017年 weygo.com. All rights reserved.
//

#import "JHXMLParserManager.h"

@interface JHXMLParserManager ()
{
    JHXMLParserCompletion _completion;
    NSString *_xmlString;
    BOOL _parserError;
}
@end

@interface JHXMLParserManager (XMLParser) <NSXMLParserDelegate>

@end

@implementation JHXMLParserManager

static JHXMLParserManager *_sharedInstance = nil;

+ (JHXMLParserManager *)sharedXMLParserManager {
    @synchronized([JHXMLParserManager class]) {
        if (!_sharedInstance) {
            _sharedInstance = [[self alloc] init];
        }
        return _sharedInstance;
    }
    return nil;
}

- (void)parser:(id)object completion:(JHXMLParserCompletion)completion {
    _completion = completion;
    [object setDelegate:self];
    [object parse];
}

- (void)reset {
    _xmlString = nil;
    _completion = nil;
    _parserError = NO;
}

@end

@implementation JHXMLParserManager (XMLParser)

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    _xmlString = string;
    NSLog(@"---foundCharacters---%@", string);
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock {
    NSString *afterParserString =  [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
    if ([NSString isNullOrEmpty:afterParserString]) {
        _completion(nil, [[NSError alloc] init]);
    }
    else {
        _completion(afterParserString, nil);
    }
    DLog(@"---str---=%@", afterParserString);
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    if (_completion) {
        if (_parserError) {
            _completion(nil, [[NSError alloc] init]);
        }
        else {
            _completion(_xmlString, nil);
        }
    }
    [self reset];
}

- (void)paser:parserErrorOccured {
    _parserError = YES;
    if (_completion) {
        _completion(nil, [[NSError alloc] init]);
    }
}

@end
