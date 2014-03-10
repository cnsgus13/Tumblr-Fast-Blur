//
//  TumblrMenuView.m
//  TumblrMenu
//
//  Created by yiqin on 3/9/14.
//  Copyright (c) 2014 purdue. All rights reserved.
//
//  Includes three layers (from button to top).
//
//      1. BackgroundView with blur effect
//         Take a screenshot first. Then call blur effect function.
//         The algorithm is "vImage":
//         - is simply a part of the native iOS Acceleration Framework.
//         - written in pure C language with set of functions and data types.
//         - gives more flexibility to control the pixel matrix manipulation process.
//         - processes huge resolution images quickly.
//
//      2. Glass view
//         Provides transparency color to make the blur effect even more real.
//
//      3. Tumblr Menu View
//


#import <UIKit/UIKit.h>
typedef void (^TumblrMenuViewSelectedBlock)(void);


@interface TumblrMenuView : UIView<UIGestureRecognizerDelegate>

@property (nonatomic, readonly)UIImageView *backgroundImgView;
@property (nonatomic, strong) UIView *glassView;


- (void)addMenuItemWithTitle:(NSString*)title andIcon:(UIImage*)icon andSelectedBlock:(TumblrMenuViewSelectedBlock)block;

- (void)show;

@end
