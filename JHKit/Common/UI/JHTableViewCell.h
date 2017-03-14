//
//  JHTableViewCell.h
//  JHKit
//
//  Created by muma on 2016/10/16.
//  Copyright © 2016年 mumuxinxinCompany. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JHObject;

@interface JHTableViewCell : UITableViewCell
{
    //JHObject    *_data;
    JHView      *_contentView;
}

- (void)loadSubviews;

- (void)showWithData:(JHObject *)data;

- (void)showWithArray:(NSArray *)array;

+ (CGFloat)heightWithData:(JHObject *)data;

+ (CGFloat)heightWithArray:(NSArray *)data;

@end
