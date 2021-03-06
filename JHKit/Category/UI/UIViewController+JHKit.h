//
//  UIViewController+JHKit.h
//  JHKit
//
//  Created by muma on 2016/10/20.
//  Copyright © 2016年 mumuxinxinCompany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JHAlert.h"

@class JHRequest;
@class JHResponse;
@class JHSoapRequest;

@interface UIViewController (JHAssistants)

- (void) showWarningMessage:(NSString *)warningMessage;

- (void) showWarningMessageWithDisplayDelay:(NSString *)warningMessage;

- (void) showWarningMessage:(NSString *)warningMessage autoDisplayAfter:(double)displayDelay;

- (void) showWarningMessage:(NSString *)warningMessage onCompletion:(void (^)())completion;

- (void) showWarningMessage:(NSString *)warningMessage autoCloseAfter:(NSInteger)secondsDelay;

- (void) showWarningMessage:(NSString *)warningMessage autoCloseAfter:(double)secondsDelay onCompletion:(void (^)())completion;

- (void) showWarningMessage:(NSString *)warningMessage autoDisplayAfter:(double)displaySecondsDelay autoCloseAfter:(double)secondsDelay onCompletion:(void (^)())completion;

// Alert Actions
- (void)showAlertMessage:(NSString *)message;

- (void)showAlertMessage:(NSString *)message withTitle:(NSString *)title;

- (void)showAlertMessage:(NSString *)message onCompletion:(JHAlertControllerAlertCompletionBlock)completion;

- (void)showAlertMessage:(NSString *)message withTitle:(NSString *)title onCompletion:(JHAlertControllerAlertCompletionBlock)completion;

- (void)showConfirmMessage:(NSString *)message withTitle:(NSString *)title onCompletion:(JHAlertControllerAlertCompletionBlock)completion;

- (void)showConfirmMessage:(NSString *)message withTitle:(NSString *)title
         cancelButtonTitle:(NSString *)cancelButtonTitle
             okButtonTitle:(NSString *)okButtonTitle
              onCompletion:(JHAlertControllerAlertCompletionBlock)completion;

// Action Sheet Actions
- (void)showActionSheetOnCompletion:(JHAlertControllerActionSheetCompletionBlock)completion
                          withTitle:(NSString *)title
                            message:(NSString *)message
                  cancelButtonTitle:(NSString *)cancelButtonTitle
             destructiveButtonTitle:(NSString *)destructiveButtonTitle
                  otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

- (void)showActionSheetOnCompletion:(JHAlertControllerActionSheetCompletionBlock)completion
                          withTitle:(NSString *)title
                            message:(NSString *)message
                  cancelButtonTitle:(NSString *)cancelButtonTitle
             destructiveButtonTitle:(NSString *)destructiveButtonTitle
           otherButtonTitlesInArray:(NSArray *)otherButtonTitles;

// Loading View With Message
- (void)showLoadingViewWithMessage:(NSString *)loadingMessage;

- (void)showLoadingViewWithMessage:(NSString *)loadingMessage inView:(UIView *)view;

- (void)removeLoadingView;

// Retry View With Message
- (void)showRetryViewWithMessage:(NSString *)retryMessage;

- (void)showRetryViewWithMessage:(NSString *)retryMessage inView:(UIView *)view;

- (void)removeRetryView;

- (void)stopRefreshing:(UIScrollView *)scrollView refresh:(BOOL)refresh pulling:(BOOL)pulling;

@end

@interface UIViewController (JHNetwork)

- (void)get:(JHRequest *)request forResponseClass:(Class)clazz
    success:(void (^)(JHResponse *response))success
    failure:(void (^)(NSError *error))failure;

- (void)get:(JHRequest *)request forResponseClass:(Class)clazz
   progress:(void (^)(NSProgress *downloadProgress))progress
    success:(void (^)(JHResponse *response))success
    failure:(void (^)(NSError *error))failure;

- (void)post:(JHRequest *)request forResponseClass:(Class)clazz
     success:(void (^)(JHResponse *response))success
     failure:(void (^)(NSError *error))failure;

- (void)post:(JHRequest *)request forResponseClass:(Class)clazz
    progress:(void (^)(NSProgress *uploadProgress))progress
     success:(void (^)(JHResponse *response))success
     failure:(void (^)(NSError *error))failure;

@end

@interface UIViewController (JHSoapNetwork)

- (void)postSoap:(JHSoapRequest *)request forResponseClass:(Class)clazz
         success:(void (^)(JHResponse *))success
         failure:(void (^)(NSError *))failure;

@end
