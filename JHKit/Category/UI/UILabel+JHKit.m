//
//  UILabel+JHKit.m
//  JHKit
//
//  Created by muma on 2017/3/17.
//  Copyright © 2017年 weygo.com. All rights reserved.
//

#import "UILabel+JHKit.h"
#import "NSString+JHKit.h"

@implementation UILabel (JHKit)

- (void)setPartString:(NSString *)str  attributes:(NSDictionary *)attrs{
    
    //NSRange range = [self.text rangeOfString:str];
    NSMutableAttributedString *attributedString =[[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    if (attributedString == nil) {
        attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
    }
    
    NSArray* rangeArray = [self.text rangesArrayOfString:str];
    for (NSValue* value in rangeArray) {
        NSRange range = value.rangeValue;
        [attributedString setAttributes:attrs range:range];
    }
    
    self.attributedText = attributedString;
}


- (void)addPrefixString:(NSString *)str  attributes:(NSDictionary *)attrs{
    
    self.text  = [NSString stringWithFormat:@"%@%@",str,self.text];
    [self setPartString:str attributes:attrs];
}

- (void)addSuffixString:(NSString *)str  attributes:(NSDictionary *)attrs{
    
    self.text  = [NSString stringWithFormat:@"%@%@",self.text,str];
    [self setPartString:str attributes:attrs];
}

@end
