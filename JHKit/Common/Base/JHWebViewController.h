//
//  Copyright 2016 Chris.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//
//  TWWebViewController.h
//  TWKit
//
//  Created by Chris on 24/5/2016.
//

#import "JHViewController.h"

@interface JHWebViewController : JHViewController

- (id)initWithURLAddress:(NSString *)address;

- (id)initWithURL:(NSURL *)URL;

- (void)setURLAddress:(NSString *)address;

- (void)setURL:(NSURL *)URL;

- (void)reload;

@property (nonatomic, assign) BOOL showsProgress;

@property (nonatomic, strong, readonly) UIProgressView *progressView;

@property (nonatomic, assign, readonly) float loadingProgress;

@property (nonatomic, strong, readonly) UIWebView *webView;

@property (nonatomic, copy) void (^pageFinishLoad)(JHWebViewController *controller);

@end
