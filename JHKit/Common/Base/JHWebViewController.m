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
//  TWWebViewController.m
//  TWKit
//
//  Created by Chris on 24/5/2016.
//

#import "JHWebViewController.h"

const float TWWebViewInitialProgressValue = 0.1f;
const float TWWebViewInteractiveProgressValue = 0.5f;
const float TWWebViewFinalProgressValue = 0.9f;

@interface JHWebViewController (WebViewDelegate) <UIWebViewDelegate>

@end

@implementation JHWebViewController
{
    UIWebView *_webView;
    NSURL *_URL;
    
    NSUInteger _loadingCount;
    NSUInteger _maxLoadCount;
    BOOL _interactive;
}

static NSString *completeRPCURLPath = @"/twkitwebviewprogressproxy/complete";

- (id)init {
    self = [super init];
    if (self) {
        _loadingCount = 0;
        _maxLoadCount = 0;
        _showsProgress = YES;
    }
    return self;
}

- (id)initWithURLAddress:(NSString *)address {
    return [self initWithURL:[NSURL URLWithString:address]];
}

- (id)initWithURL:(NSURL *)URL {
    self = [self init];
    if(self) {
        _URL = URL;
    }
    return self;
}

- (NSString *)getUrl {
    return _URL.absoluteString;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _webView.delegate = self;
    _webView.scalesPageToFit = YES;
    [self.view addSubview:_webView];

    _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 2)];
    _progressView.progressTintColor = kRedColor;
    _progressView.hidden = !_showsProgress;
    [self.view addSubview:_progressView];

    if(_URL){
        [_webView loadRequest:[NSURLRequest requestWithURL:_URL]];
    }
}

- (void)setShowsProgress:(BOOL)showsProgress {
    _showsProgress = showsProgress;
    if (_progressView) {
        _progressView.hidden = !showsProgress;
    }
}

- (void)setURLAddress:(NSString *)address {
    if(![NSString isNullOrEmpty:address]){
        [self setURL:[NSURL URLWithString:address]];
    }
}

- (void)setURL:(NSURL *)URL{
    _URL = URL;
    [self reload];
}

- (void)reset {
    _loadingCount = 0;
    _maxLoadCount = 0;
    _interactive = NO;
    [self setProgress:0];
}

- (void)reload {
    [self reset];
    if(_URL){
        [_webView loadRequest:[NSURLRequest requestWithURL:_URL]];
    }
}

- (void)startProgress {
    if (_loadingProgress < TWWebViewInitialProgressValue) {
        [self setProgress:TWWebViewInitialProgressValue];
        [UIView animateWithDuration:0.25 animations:^{
            _progressView.layer.opacity = 1.0f;
        }];
    }
}

- (void)incrementProgress {
    float progress = self.loadingProgress;
    float maxProgress = _interactive ? TWWebViewFinalProgressValue : TWWebViewInteractiveProgressValue;
    float remainPercent = (float)_loadingCount / (float)_maxLoadCount;
    float increment = (maxProgress - progress) * remainPercent;
    progress += increment;
    progress = fmin(progress, maxProgress);
    [self setProgress:progress];
}

- (void)completeProgress {
    [self setProgress:1.0];
    [UIView animateWithDuration:0.25 animations:^{
        _progressView.layer.opacity = 0.0f;
    }];
}

- (void)setProgress:(float)progress {
    if (progress > _loadingProgress || progress == 0) {
        _loadingProgress = progress;
        _progressView.progress = progress;
    }
}

- (void)addCompleteFrame:(UIWebView *)webView {
    NSString *js = @"\
    window.addEventListener('load',function() {\
        var iframe = document.createElement('iframe');\
        iframe.style.display = 'none';\
        iframe.src = '%@://%@%@'; document.body.appendChild(iframe);\
    }, false);";
    NSString *scheme = webView.request.mainDocumentURL.scheme;
    NSString *host = webView.request.mainDocumentURL.host;
    NSString *waitForCompleteJS = [NSString stringWithFormat:js, scheme, host, completeRPCURLPath];
    [webView stringByEvaluatingJavaScriptFromString:waitForCompleteJS];
}

- (UIWebView *)webView {
    return _webView;
}

- (void)pageDidFinishLoad {
    
}

@end


@implementation JHWebViewController (WebViewDelegate)

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([request.URL.path isEqualToString:completeRPCURLPath]) {
        [self completeProgress];
        return NO;
    }
    BOOL ret = YES;
    
    BOOL isFragmentJump = NO;
    if (request.URL.fragment) {
        NSString *nonFragmentURL = [request.URL.absoluteString stringByReplacingOccurrencesOfString:[@"#" stringByAppendingString:request.URL.fragment] withString:@""];
        isFragmentJump = [nonFragmentURL isEqualToString:webView.request.URL.absoluteString];
    }
    
    BOOL isTopLevelNavigation = [request.mainDocumentURL isEqual:request.URL];
    
    BOOL isHTTPOrLocalFile = [request.URL.scheme isEqualToString:@"http"] || [request.URL.scheme isEqualToString:@"https"] || [request.URL.scheme isEqualToString:@"file"];
    if (ret && !isFragmentJump && isHTTPOrLocalFile && isTopLevelNavigation) {
        _URL = request.URL;
        [self reset];
    }
    return ret;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    _loadingCount ++;
    _maxLoadCount = fmax(_maxLoadCount, _loadingCount);
    [self startProgress];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    _loadingCount --;
    [self incrementProgress];
    
    NSString *readyState = [webView stringByEvaluatingJavaScriptFromString:@"document.readyState"];
    
    BOOL interactive = [readyState isEqualToString:@"interactive"];
    if (interactive) {
        _interactive = YES;
        [self addCompleteFrame:webView];
    }
    
    BOOL isNotRedirect = _URL && [_URL isEqual:webView.request.mainDocumentURL];
    BOOL complete = [readyState isEqualToString:@"complete"];
    if (complete && isNotRedirect) {
        [self completeProgress];
    }
    
    if (!self.title) {
        self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    }
    
    [self pageDidFinishLoad];
    
    if (self.pageFinishLoad) {
        self.pageFinishLoad(self);
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    _loadingCount --;
    [self incrementProgress];
    
    NSString *readyState = [webView stringByEvaluatingJavaScriptFromString:@"document.readyState"];
    
    BOOL interactive = [readyState isEqualToString:@"interactive"];
    if (interactive) {
        _interactive = YES;
        [self addCompleteFrame:webView];
    }
    
    BOOL isNotRedirect = _URL && [_URL isEqual:webView.request.mainDocumentURL];
    BOOL complete = [readyState isEqualToString:@"complete"];
    if ((complete && isNotRedirect) || error) {
        [self completeProgress];
    }
}

@end
