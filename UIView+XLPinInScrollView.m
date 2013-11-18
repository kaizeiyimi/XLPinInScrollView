//
//  UIView+XLPinInScrollView.m
//  studyLayout
//
//  Created by kaizei on 13-11-17.

//  The MIT License (MIT)

//  Copyright (c) 2013 kaizei

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "UIView+XLPinInScrollView.h"

#import <objc/runtime.h>

@interface UIView ()

@property (nonatomic, assign) BOOL isObserving;

@end

@implementation UIView (XLPinInScrollView)

static char * const kinitialOriginKey = "XLkinitialOriginKey";

static char * const kPinVerticalEnabledKey = "XLkPinVerticalEnabledKey";
static char * const kPinHorizontalEnabledKey = "XLkPinHorizontalEnabledKey";
static char * const kPinMinYKey = "XLkPinMinYKey";
static char * const kPinMinXKey = "XLkPinMinXKey";

static char * const kIsObservingKey = "XLkIsObservingKey";

+ (void)load
{
    Method method = class_getInstanceMethod([UIView class], @selector(willMoveToSuperview:));
    IMP originalImp = method_getImplementation(method);
    
    IMP newImp = imp_implementationWithBlock(^(id _self, UIView *superview) {
        if (!superview) {
            [_self stopObservingScrollView:[_self superview]];
        }
        if (superview && (superview != [_self superview])) {
            [_self stopObservingScrollView:[_self superview]];
            [_self changeObservingStateIfNeededForSuperview:superview];
        }
        originalImp(_self, @selector(willMoveToSuperview:));
    });
    method_setImplementation(method, newImp);
}

- (void)startObservingScrollView:(UIScrollView *)scrollView
{
    if (!scrollView || ![scrollView isKindOfClass:[UIScrollView class]] || self.isObserving) {
        return;
    }
    
    [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    self.isObserving = YES;
    objc_setAssociatedObject(self, kinitialOriginKey, [NSValue valueWithCGPoint:self.frame.origin], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)stopObservingScrollView:(UIView *)scrollView
{
    if (!scrollView || ![scrollView isKindOfClass:[UIScrollView class]] || !self.isObserving) {
        return;
    }
    
    [scrollView removeObserver:self forKeyPath:@"contentOffset"];
    self.isObserving = NO;
}

- (void)changeObservingStateIfNeededForSuperview:(UIView *)superview
{
    if (![superview isKindOfClass:[UIScrollView class]]) {
        return;
    }
    
    if ((self.pinVerticalEnabled || self.pinHorizontalEnabled)) {
        [self startObservingScrollView:(UIScrollView *)superview];
    }
    if ((!self.pinHorizontalEnabled && !self.pinVerticalEnabled)) {
        [self stopObservingScrollView:(UIScrollView *)superview];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint contentOffset;
        [change[NSKeyValueChangeNewKey]getValue:&contentOffset];
        CGPoint initialOrigin;
        [objc_getAssociatedObject(self, kinitialOriginKey) getValue:&initialOrigin];
        if (self.pinVerticalEnabled) {
            CGRect frame = self.frame;
            if (contentOffset.y + self.pinMinY > initialOrigin.y) {
                frame.origin.y = contentOffset.y + self.pinMinY;
            } else {
                frame.origin.y = initialOrigin.y;
            }
            self.frame = frame;
        }
        if (self.pinHorizontalEnabled) {
            CGRect frame = self.frame;
            if (contentOffset.x + self.pinMinX > initialOrigin.x) {
                frame.origin.x = contentOffset.x;
            } else {
                frame.origin.x = initialOrigin.x;
            }
            self.frame = frame;
        }
    }
}

#pragma mark setters and getters
- (void)setPinEnabled:(BOOL)pinEnabled
{
    [self setPinVerticalEnabled:pinEnabled];
    [self setPinHorizontalEnabled:pinEnabled];
}

- (void)setPinVerticalEnabled:(BOOL)pinVerticalEnabled
{
    objc_setAssociatedObject(self, kPinVerticalEnabledKey, @(pinVerticalEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self changeObservingStateIfNeededForSuperview:self.superview];
}

- (BOOL)pinVerticalEnabled
{
    NSNumber *enabled = objc_getAssociatedObject(self, kPinVerticalEnabledKey);
    return [enabled boolValue];
}

- (void)setPinHorizontalEnabled:(BOOL)pinHorizontalEnabled
{
    objc_setAssociatedObject(self, kPinHorizontalEnabledKey, @(pinHorizontalEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self changeObservingStateIfNeededForSuperview:self.superview];
}

- (BOOL)pinHorizontalEnabled
{
    NSNumber *enabled = objc_getAssociatedObject(self, kPinHorizontalEnabledKey);
    return [enabled boolValue];
}

- (void)setPinMinY:(CGFloat)minY
{
    objc_setAssociatedObject(self, kPinMinYKey, @(minY), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)pinMinY
{
    NSNumber *minY = objc_getAssociatedObject(self, kPinMinYKey);
    return [minY floatValue];
}

- (void)setPinMinX:(CGFloat)minX
{
    objc_setAssociatedObject(self, kPinMinXKey, @(minX), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)pinMinX
{
    NSNumber *minX = objc_getAssociatedObject(self, kPinMinXKey);
    return [minX floatValue];
}

- (BOOL)isObserving
{
    BOOL isObserving = [objc_getAssociatedObject(self, kIsObservingKey) boolValue];
    return isObserving;
}

- (void)setIsObserving:(BOOL)isObserving
{
    if (isObserving != [self isObserving]) {
        objc_setAssociatedObject(self, kIsObservingKey, @(isObserving), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

@end
