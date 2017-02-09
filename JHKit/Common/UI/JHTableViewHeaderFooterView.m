//
//  JHTableViewHeaderFooterView.m
//  JHKit
//
//  Created by muma on 2017/2/8.
//  Copyright © 2017年 weygo.com. All rights reserved.
//

#import "JHTableViewHeaderFooterView.h"

@implementation JHTableViewHeaderFooterView

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self loadSubviews];
    }
    return self;
}

- (void)showWithData:(JHObject *)data {

}

@end
