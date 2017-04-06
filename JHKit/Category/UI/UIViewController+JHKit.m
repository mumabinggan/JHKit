//
//  UIViewController+JHKit.m
//  JHKit
//
//  Created by muma on 2016/10/20.
//  Copyright © 2016年 mumuxinxinCompany. All rights reserved.
//

#import "UIViewController+JHKit.h"
#import <objc/runtime.h>
#import "JHNetworkManager.h"
#import "JHRequest.h"
#import "JHResponse.h"

static CGFloat WARNING_MESSAGE_DELAY = 2.0f;
static CGFloat WARNING_MESSAGE_DISPLAY_DELAY = 0.2f;

static NSString *LoadingViewKey = nil;

static NSString *RetryViewKey = nil;

@implementation UIViewController (UIAssistants)

- (JHView *)warningView {
    return objc_getAssociatedObject(self, @"TWWarningView");
}

- (void)setWarningView:(JHView *)warningView {
    if (warningView) {
        objc_setAssociatedObject(self, @"TWWarningView", warningView, OBJC_ASSOCIATION_RETAIN);
    }
    else {
        //objc_removeAssociatedObjects(self);
        objc_setAssociatedObject(self, @"TWWarningView", nil, OBJC_ASSOCIATION_RETAIN);
    }
}

- (void) showWarningMessage:(NSString *)warningMessage{
    [self showWarningMessage:warningMessage autoCloseAfter:WARNING_MESSAGE_DELAY];
}

- (void) showWarningMessageWithDisplayDelay:(NSString *)warningMessage{
    [self showWarningMessage:warningMessage autoDisplayAfter:WARNING_MESSAGE_DISPLAY_DELAY autoCloseAfter:WARNING_MESSAGE_DELAY onCompletion:nil];
}

- (void) showWarningMessage:(NSString *)warningMessage autoDisplayAfter:(double)displayDelay{
    [self showWarningMessage:warningMessage autoDisplayAfter:displayDelay autoCloseAfter:WARNING_MESSAGE_DELAY onCompletion:nil];
}

- (void) showWarningMessage:(NSString *)warningMessage onCompletion:(void (^)())completion {
    [self showWarningMessage:warningMessage autoCloseAfter:WARNING_MESSAGE_DELAY onCompletion:completion];
}

- (void) showWarningMessage:(NSString *)warningMessage autoCloseAfter:(NSInteger)secondsDelay {
    [self showWarningMessage:warningMessage autoCloseAfter:secondsDelay onCompletion:nil];
}

- (void) showWarningMessage:(NSString *)warningMessage autoCloseAfter:(double)secondsDelay onCompletion:(void (^)())completion{
    [self showWarningMessage:warningMessage autoDisplayAfter:0 autoCloseAfter:secondsDelay onCompletion:completion];
}

- (void) showWarningMessage:(NSString *)warningMessage autoDisplayAfter:(double)displaySecondsDelay autoCloseAfter:(double)secondsDelay onCompletion:(void (^)())completion{
    if([NSString isNullOrEmpty:warningMessage]){
        return;
    }
    JHView *_warningView = [self warningView];
    if (_warningView == nil) {
        _warningView = [self createWarningView:warningMessage];
        _warningView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin;
        if (completion) {
            objc_setAssociatedObject(_warningView, @"warningViewCompletionBlock", completion, OBJC_ASSOCIATION_COPY);
        }
        [self setWarningView:_warningView];
        [self.view addSubview:_warningView];
    }
    else{
        JHLabel *label = (JHLabel*)[_warningView viewWithTag:1000];
        [label setText:warningMessage];
    }
    if (displaySecondsDelay > 0.01){
        _warningView.hidden = YES;
        [self performSelector:@selector(displayWarningView:) withObject:_warningView afterDelay:displaySecondsDelay];
    }
    
    if(secondsDelay<=0){
        secondsDelay = WARNING_MESSAGE_DELAY;
    } else {
        secondsDelay += displaySecondsDelay;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideWarningView:) object:_warningView];
    [self performSelector:@selector(hideWarningView:) withObject:_warningView afterDelay:secondsDelay];
}

- (JHView *)createWarningView:(NSString *)warningMessage {
    JHLabel *warningLabel = [[JHLabel alloc]initWithFrame:CGRectMake(16, 10, kDeviceWidth-16*2, 50)];
    warningLabel.text = warningMessage;
    warningLabel.textColor = kRGB(225, 225, 225);
    warningLabel.font = kAppFont(14);
    warningLabel.tag = 1000;
    warningLabel.textAlignment = NSTextAlignmentCenter;
    warningLabel.numberOfLines = 0;
    [warningLabel sizeToFit];
    if (warningLabel.frame.size.width<self.view.frame.size.width/2) {
        CGRect r = warningLabel.frame;
        r.size.width = MAX(self.view.frame.size.width/3, r.size.width);
        warningLabel.frame = r;
    }
    
    JHView *_warningView = [[JHView alloc]initWithFrame:CGRectMake((self.view.frame.size.width-warningLabel.frame.size.width-16*2)/2, (self.view.frame.size.height-warningLabel.frame.size.height-20)/2+64/2, warningLabel.frame.size.width+16*2, warningLabel.frame.size.height+20) radius:0.0f];
    
    _warningView.radius = (int)_warningView.frame.size.height/2;
    [_warningView addSubview:warningLabel];
    warningLabel=nil;
    _warningView.backgroundColor = kRGBA(45, 45, 45, 0.85);
    return _warningView;
}

- (void)displayWarningView:(JHView*)warningView{
    warningView.hidden = NO;
}

- (void)hideWarningView:(JHView *)warningView{
    [UIView animateWithDuration:0.25 animations:^{
        warningView.layer.opacity = 0.0f;
    } completion:^(BOOL finished) {
        [warningView removeFromSuperview];
        void (^completionBlock)() = objc_getAssociatedObject(warningView, @"warningViewCompletionBlock");
        if (completionBlock) {
            completionBlock();
        }
        [self setWarningView:nil];
    }];
}

// Alert Actions
- (void)showAlertMessage:(NSString *)message {
    [self showAlertMessage:message withTitle:nil];
}

- (void)showAlertMessage:(NSString *)message withTitle:(NSString *)title {
    [self showAlertMessage:message withTitle:title onCompletion:nil];
}

- (void)showAlertMessage:(NSString *)message onCompletion:(JHAlertControllerAlertCompletionBlock)completion {
    [self showAlertMessage:message withTitle:nil onCompletion:completion];
}

- (void)showAlertMessage:(NSString *)message
               withTitle:(NSString *)title
            onCompletion:(JHAlertControllerAlertCompletionBlock)completion {
    [self showConfirmMessage:message withTitle:title cancelButtonTitle:kStr(@"Close") okButtonTitle:nil onCompletion:completion];
}

- (void)showConfirmMessage:(NSString *)message withTitle:(NSString *)title
              onCompletion:(JHAlertControllerAlertCompletionBlock)completion {
    [self showConfirmMessage:message withTitle:title cancelButtonTitle:kStr(@"Cancel") okButtonTitle:kStr(@"Ok") onCompletion:completion];
}

- (void)showConfirmMessage:(NSString *)message withTitle:(NSString *)title
         cancelButtonTitle:(NSString *)cancelButtonTitle
             okButtonTitle:(NSString *)okButtonTitle
              onCompletion:(JHAlertControllerAlertCompletionBlock)completion {
    [[JHAlert sharedAlert] showConfirmMessageInViewController:self
                                                      message:message
                                                    withTitle:title
                                            cancelButtonTitle:cancelButtonTitle
                                                okButtonTitle:okButtonTitle
                                                 onCompletion:completion];
}

// Action Sheet Actions
- (void)showActionSheetOnCompletion:(JHAlertControllerActionSheetCompletionBlock)completion
                          withTitle:(NSString *)title
                            message:(NSString *)message
                  cancelButtonTitle:(NSString *)cancelButtonTitle
             destructiveButtonTitle:(NSString *)destructiveButtonTitle
                  otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION {
    
    [[JHAlert sharedAlert] showActionSheetInViewController:self
                                                completion:completion
                                                 withTitle:title
                                                   message:message
                                         cancelButtonTitle:cancelButtonTitle
                                    destructiveButtonTitle:destructiveButtonTitle
                                         otherButtonTitles:otherButtonTitles, nil];
}

- (void) showActionSheetOnCompletion:(JHAlertControllerActionSheetCompletionBlock)completion
                           withTitle:(NSString *)title
                             message:(NSString *)message
                   cancelButtonTitle:(NSString *)cancelButtonTitle
              destructiveButtonTitle:(NSString *)destructiveButtonTitle
            otherButtonTitlesInArray:(NSArray *)otherButtonTitles {
    
    [[JHAlert sharedAlert] showActionSheetInViewController:self
                                                completion:completion
                                                 withTitle:title
                                                   message:message
                                         cancelButtonTitle:cancelButtonTitle
                                    destructiveButtonTitle:destructiveButtonTitle
                                  otherButtonTitlesInArray:otherButtonTitles];
}

- (void)setRetryView:(UIView *)retryView {
    if (retryView) {
        objc_setAssociatedObject(self, &RetryViewKey, retryView, OBJC_ASSOCIATION_RETAIN);
    }
    else {
        objc_setAssociatedObject(self, &RetryViewKey, nil, OBJC_ASSOCIATION_RETAIN);
    }
}

- (UIView *)retryView {
    return objc_getAssociatedObject(self, &RetryViewKey);
}

// Loading View With Message
- (void)showLoadingViewWithMessage:(NSString *)loadingMessage {
    [self showLoadingViewWithMessage:loadingMessage inView:self.view];
}

- (void)showLoadingViewWithMessage:(NSString *)loadingMessage inView:(UIView *)view {
    [[JHAlert sharedAlert] showLoadingViewWithMessage:loadingMessage inView:view];
}

- (void)removeLoadingView {
    [[JHAlert sharedAlert] removeLoadingView];
}

// Retry View With Message
- (void)showRetryViewWithMessage:(NSString *)retryMessage {
    [self showRetryViewWithMessage:retryMessage inView:self.view];
}

- (void)showRetryViewWithMessage:(NSString *)retryMessage inView:(UIView *)view {
    
}

- (void)removeRetryView {
    
}

- (void)stopRefreshing:(UIScrollView *)scrollView refresh:(BOOL)refresh pulling:(BOOL)pulling {
    if (pulling) {
        if (refresh) {
            [scrollView stopHeaderRefreshing];
        }
        else {
            [scrollView stopFooterRefreshing];
        }
    } else {
        [self removeLoadingView];
    }
}

@end

@implementation UIViewController (Network)

- (void)get:(JHRequest *)request forResponseClass:(Class)clazz success:(void (^)(JHResponse *))success failure:(void (^)(NSError *))failure {
    [self get:request forResponseClass:clazz progress:nil success:success failure:failure];
}

- (void)post:(JHRequest *)request forResponseClass:(Class)clazz success:(void (^)(JHResponse *))success failure:(void (^)(NSError *))failure {
    [self post:request forResponseClass:clazz progress:nil success:success failure:failure];
}

- (void)get:(JHRequest *)request forResponseClass:(Class)clazz progress:(void (^)(NSProgress *))progress success:(void (^)(JHResponse *))success failure:(void (^)(NSError *))failure {
    if (request.showsLoadingView) {
        [self showsLoadingViewWithRequest:request];
    }
    __weak JHRequest *weakRequest = request;
    WeakSelf;
    [[JHNetworkManager sharedManager] get:request forResponseClass:clazz progress:^(NSProgress *downloadProgress) {
        if (progress) {
            progress(downloadProgress);
        }
    } success:^(JHResponse *response) {
        if (weakRequest.showsLoadingView) {
            [weakSelf removeLoadingView];
        }
        if (success != nil) {
            success(response);
        }
    } failure:^(NSError *error) {
        if (weakRequest.showsLoadingView) {
            [weakSelf removeLoadingView];
        }
        if (failure != nil) {
            failure(error);
        }
    }];
}

- (void)post:(JHRequest *)request forResponseClass:(Class)clazz progress:(void (^)(NSProgress *))progress success:(void (^)(JHResponse *))success failure:(void (^)(NSError *))failure {
    if (request.showsLoadingView) {
        [self showsLoadingViewWithRequest:request];
    }
    __weak JHRequest *weakRequest = request;
    __weak id weakSelf = self;
    [[JHNetworkManager sharedManager] post:request forResponseClass:clazz progress:^(NSProgress *uploadProgress) {
        if (progress) {
            progress(uploadProgress);
        }
    } success:^(JHResponse *response) {
        if (weakRequest.showsLoadingView) {
            [weakSelf removeLoadingView];
        }
        if (success != nil) {
            success(response);
        }
    } failure:^(NSError *error) {
        if (weakRequest.showsLoadingView) {
            [weakSelf removeLoadingView];
        }
        if (weakRequest.showsRetryView) {
            [weakSelf showsRetryViewWithRequest:weakRequest];
        }
        if (failure != nil) {
            failure(error);
        }
    }];
}

- (void)showsLoadingViewWithRequest:(JHRequest *)request {
    [self showLoadingViewWithMessage:request.loadingMessage];
}

- (void)showsRetryViewWithRequest:(JHRequest *)request {
    [self showRetryViewWithMessage:request.retryMessage];
}

@end

@implementation UIViewController (SOAPNetwork)

- (void)postSoap:(JHSoapRequest *)request forResponseClass:(Class)clazz success:(void (^)(JHResponse *))success failure:(void (^)(NSError *))failure {
    [self postSoap:request forResponseClass:clazz progress:nil success:success failure:failure];
}

- (void)postSoap:(JHSoapRequest *)request forResponseClass:(Class)clazz progress:(void (^)(NSProgress *))progress success:(void (^)(JHResponse *))success failure:(void (^)(NSError *))failure {
    if (request.showsLoadingView) {
        [self showsLoadingViewWithSoapRequest:request];
    }
    __weak JHSoapRequest *weakRequest = request;
    __weak id weakSelf = self;
    [[JHNetworkManager sharedManager] postSoap:request forResponseClass:clazz progress:^(NSProgress *uploadProgress) {
        if (progress) {
            progress(uploadProgress);
        }
    } success:^(JHResponse *response) {
        if (weakRequest.showsLoadingView) {
            [weakSelf removeLoadingView];
        }
        if (success != nil) {
            success(response);
        }
    } failure:^(NSError *error) {
        if (weakRequest.showsLoadingView) {
            [weakSelf removeLoadingView];
        }
        if (weakRequest.showsRetryView) {
            [weakSelf showsRetryViewWithSoapRequest:weakRequest];
        }
        if (failure != nil) {
            failure(error);
        }
    }];
}

- (void)showsLoadingViewWithSoapRequest:(JHSoapRequest *)request {
    [self showLoadingViewWithMessage:request.loadingMessage];
}

- (void)showsRetryViewWithSoapRequest:(JHSoapRequest *)request {
    [self showRetryViewWithMessage:request.retryMessage];
}

@end
