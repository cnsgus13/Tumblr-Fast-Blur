//
//  TumblrMenuView.m
//  TumblrMenu
//
//  Created by yiqin on 3/9/14.
//  Copyright (c) 2014 purdue. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^TumblrMenuViewSelectedBlock)(void);


@interface TumblrMenuView : UIView<UIGestureRecognizerDelegate>
@property (nonatomic, readonly)UIImageView *backgroundImgView;
- (void)addMenuItemWithTitle:(NSString*)title andIcon:(UIImage*)icon andSelectedBlock:(TumblrMenuViewSelectedBlock)block;
- (void)show;
@end
