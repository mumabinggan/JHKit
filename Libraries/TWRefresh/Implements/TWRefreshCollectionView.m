//
//  TWRefreshCollectionView.m
//  TWRefreshDemo
//
//  Created by Chris on 15/6/15.
//  Copyright (c) 2015 EasyBaking. All rights reserved.
//

#import "TWRefreshCollectionView.h"
#import "TWRefreshIndicatorView.h"

@implementation TWRefreshCollectionView
{
    TWRefreshType _refreshType;
}

- (id) initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout refreshType:(TWRefreshType) refreshType {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        _refreshType = refreshType;
        [self prepareRefresh];
    }
    return self;
}

- (void) prepareRefresh {
    //self.contentInset = UIEdgeInsetsMake(0, 0, 49, 0);
    
    if((_refreshType & TWRefreshTypeTop) == TWRefreshTypeTop){
        [self setRefreshHeaderWithIndicatorClass:[TWRefreshIndicatorView class]];
    }
    if((_refreshType & TWRefreshTypeBottom) == TWRefreshTypeBottom){
        [self setRefreshFooterWithIndicatorClass:[TWRefreshIndicatorView class]];
    }
}

- (void) refreshHeader {
    [super refreshHeader];
    if (self.refreshDelegate && [self.refreshDelegate respondsToSelector:@selector(beginRefreshHeader:)]) {
        [self.refreshDelegate beginRefreshHeader:self];
    }
}

- (void) refreshFooter {
    [super refreshFooter];
    if (self.refreshDelegate && [self.refreshDelegate respondsToSelector:@selector(beginRefreshFooter:)]) {
        [self.refreshDelegate beginRefreshFooter:self];
    }
}

@end
