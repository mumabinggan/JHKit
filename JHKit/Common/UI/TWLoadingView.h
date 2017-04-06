//
//  TWLoadingView.h
//  EasyBaking
//
//  Created by Chris on 1/21/15.
//  Copyright (c) 2015 iEasyNote. All rights reserved.
//

#import "JHPopoverView.h"

@interface TWLoadingView : JHPopoverView

@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) JHImageView *gifImageView;

- (void) stopLoading;

@end
