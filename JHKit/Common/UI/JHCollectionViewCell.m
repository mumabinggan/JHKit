//
//  JHCollectionViewCell.m
//  JHKit
//
//  Created by muma on 2016/10/16.
//  Copyright © 2016年 mumuxinxinCompany. All rights reserved.
//

#import "JHCollectionViewCell.h"

@implementation JHCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self loadSubviews];
    }
    return self;
}

- (void)loadSubviews {
    
}

- (void)showWithData:(JHObject *)data {
    _data = data;
}

@end
