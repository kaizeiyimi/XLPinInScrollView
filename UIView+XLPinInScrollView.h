//
//  UIView+XLPinInScrollView.h
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

#import <UIKit/UIKit.h>

@interface UIView (XLPinInScrollView)

/// enable pin vertical
@property (nonatomic, assign) BOOL pinVerticalEnabled;
/// enable pin horizontal
@property (nonatomic, assign) BOOL pinHorizontalEnabled;
/// the space relative to the top of scrollview bounds
@property (nonatomic, assign) CGFloat pinMinY;
/// the space relative to the left of scrollview bounds
@property (nonatomic, assign) CGFloat pinMinX;

/// set both the pinVertical and pinHorizontal enabled.
- (void)setPinEnabled:(BOOL)pinEnabled;

@end

