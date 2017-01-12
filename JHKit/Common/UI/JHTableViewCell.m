//
//  JHTableViewCell.m
//  JHKit
//
//  Created by muma on 2016/10/16.
//  Copyright © 2016年 mumuxinxinCompany. All rights reserved.
//

#import "JHTableViewCell.h"

@implementation JHTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self loadSubviews];
    }
    return self;
}

- (void)loadSubviews {
    //_contentView = [[JHView alloc] initWithFrame:self.frame];
}

- (void)showWithData:(JHObject *)data {
    _data = data;
}

@end
