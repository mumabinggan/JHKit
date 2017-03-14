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
        [self initData];
        [self loadSubviews];
    }
    return self;
}

- (void)initData {

}

- (void)loadSubviews {
    //_contentView = [[JHView alloc] initWithFrame:self.frame];
}

- (void)showWithData:(JHObject *)data {
    //_data = data;
}

- (void)showWithArray:(NSArray *)array {

}

+ (CGFloat)heightWithData:(JHObject *)data {
    return 0.0f;
}

+ (CGFloat)heightWithArray:(NSArray *)data {
    return 0.0f;
}

@end
