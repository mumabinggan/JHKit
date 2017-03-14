//
//  UIView+Frame.m
//  JHKit
//
//  Created by muma on 16/9/30.
//  Copyright © 2016年 mumuxinxinCompany. All rights reserved.
//

#import "UIView+JHKit.h"
#import "JHMacro.h"
#import <objc/runtime.h>
#import "JHBadgeView.h"

@implementation UIView (Frame)

- (CGFloat)x {
    return self.frame.origin.x;
}

- (void)setX:(CGFloat)newX {
    CGRect frame = self.frame;
    frame.origin.x = newX;
    self.frame = frame;
}

- (CGFloat)y {
    return self.frame.origin.y;
}

- (void)setY:(CGFloat)newY {
    CGRect frame = self.frame;
    frame.origin.y = newY;
    self.frame = frame;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)newWidth {
    CGRect frame = self.frame;
    frame.size.width = newWidth;
    self.frame = frame;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)newHeight {
    CGRect frame = self.frame;
    frame.size.height = newHeight;
    self.frame = frame;
}

- (CGFloat)maxY {
    return self.y + self.height;
}

- (void)setMaxY:(CGFloat)maxY {
    [self setY:maxY - self.height];
}

- (CGFloat)maxX {
    return self.x + self.width;
}

- (void)setMaxX:(CGFloat)maxX {
    [self setX:maxX - self.width];
}

- (CGFloat)midX {
    return self.x + self.width / 2;
}

- (void)setMidX:(CGFloat)midX {
    CGRect frame = self.frame;
    frame.origin.x = midX - self.width / 2;
    self.frame = frame;
}

- (CGFloat)midY {
    return self.y + self.height / 2;
}

- (void)setMidY:(CGFloat)midY {
    CGRect frame = self.frame;
    frame.origin.y = midY - self.height / 2;
    self.frame = frame;
}

- (CGPoint)origin {
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin {
    CGRect r = self.frame;
    r.origin = origin;
    self.frame = r;
}

- (CGSize)size {
    return self.frame.size;
}

- (void)setSize:(CGSize)size {
    CGRect r = self.frame;
    r.size = size;
    self.frame = r;
}

@end

@implementation UIView (Corner)

- (void)addCorner:(JHRadius)radius
      borderWidth:(CGFloat)borderWidth
      borderColor:(UIColor *)borderColor
  backgroundColor:(UIColor *)backgroundColor {
    UIImage *image = [UIImage imageWithRect:self.frame roundedCorner:radius borderWidth:borderWidth borderColor:borderColor backgroundColor:backgroundColor];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [self insertSubview:imageView atIndex:0];
}

@end

@implementation UIView (GestureRecognizer)

- (void)addSingleTapGestureRecognizerWithTarget:(id)target action:(SEL)action {
    UITapGestureRecognizer *singleTapRecognizer;
    singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    singleTapRecognizer.numberOfTapsRequired = 1;
    [self addGestureRecognizer:singleTapRecognizer];
}

@end

@implementation UIView (Gradient)

- (void)addGradientColor:(UIColor *)color {
    CAGradientLayer *layer = [CAGradientLayer layer];
    layer.startPoint = CGPointMake(0, 0);//（0，0）表示从左上角开始变化。默认值是(0.5,0.0)表示从x轴为中间，y为顶端的开始变化
    layer.endPoint = CGPointMake(1, 0);//（1，1）表示到右下角变化结束。默认值是(0.5,1.0)  表示从x轴为中间，y为低端的结束变化
    layer.colors = [NSArray arrayWithObjects:(id)kHRGBA(0xFFFFFF, 0.1).CGColor, (id)kHRGBA(0xFFFFFF, 1).CGColor, nil];
    //layer.locations = @[@0.0f, @1.0f];//渐变颜色的区间分布，locations的数组长度和color一致，这个值一般不用管它，默认是nil，会平均分布
    layer.frame = self.layer.bounds;
    [self.layer addSublayer:layer];
}

@end

@implementation UIView (Badge)

- (UIView *)badgeView {
    return objc_getAssociatedObject(self, @selector(badgeView));
}

- (void)setBadgeView:(UIView *)badgeView {
    objc_setAssociatedObject(self, @selector(badgeView), badgeView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)addBadge {
    if (!self.badgeView) {
        JHBadgeView *badgeView = [[JHBadgeView alloc] initWithFrame:CGRectMake(0, 0, 18, 18) radius:9.0];
        badgeView.backgroundColor = kHRGB(0x5677FC);
        badgeView.layer.borderWidth = 2.0f;
        badgeView.layer.borderColor = kWhiteColor.CGColor;
        badgeView.layer.cornerRadius = badgeView.radius;
        badgeView.x = self.width/3;
        badgeView.y = - self.height/5;
        [self addSubview:badgeView];
        [badgeView show:NO];
        self.badgeView = badgeView;
    }
}

- (void)showBadge:(BOOL)show text:(NSString *)text {
    JHBadgeView *badgeView = (JHBadgeView *)self.badgeView;
    [badgeView show:show badgeText:text];
}

@end
