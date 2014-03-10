//
//  TumblrMenuView.m
//  TumblrMenu
//
//  Created by yiqin on 3/9/14.
//  Copyright (c) 2014 purdue. All rights reserved.
//

#import "TumblrMenuView.h"

#import <Accelerate/Accelerate.h>


#define TumblrMenuViewTag 1999
#define TumblrMenuViewImageHeight 90
#define TumblrMenuViewTitleHeight 20
#define TumblrMenuViewVerticalPadding 10
#define TumblrMenuViewHorizontalMargin 10
#define TumblrMenuViewRriseAnimationID @"TumblrMenuViewRriseAnimationID"
#define TumblrMenuViewDismissAnimationID @"TumblrMenuViewDismissAnimationID"
#define TumblrMenuViewAnimationTime 0.36
#define TumblrMenuViewAnimationInterval (TumblrMenuViewAnimationTime / 5)

#define TumblrBlue [UIColor colorWithRed:45/255.0f green:68/255.0f blue:94/255.0f alpha:1.0]

@interface TumblrMenuItemButton : UIControl
- (id)initWithTitle:(NSString*)title andIcon:(UIImage*)icon andSelectedBlock:(TumblrMenuViewSelectedBlock)block;
@property(nonatomic,copy)TumblrMenuViewSelectedBlock selectedBlock;
@end

@implementation TumblrMenuItemButton
{
    UIImageView *iconView_;
    UILabel *titleLabel_;
}
- (id)initWithTitle:(NSString*)title andIcon:(UIImage*)icon andSelectedBlock:(TumblrMenuViewSelectedBlock)block
{
    self = [super init];
    if (self) {
        iconView_ = [UIImageView new];
        iconView_.image = icon;
        titleLabel_ = [UILabel new];
        titleLabel_.textAlignment = NSTextAlignmentCenter;
        titleLabel_.backgroundColor = [UIColor clearColor];
        titleLabel_.textColor = [UIColor whiteColor];
        titleLabel_.text = title;
        _selectedBlock = block;
        [self addSubview:iconView_];
        [self addSubview:titleLabel_];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    iconView_.frame = CGRectMake(0, 0, TumblrMenuViewImageHeight, TumblrMenuViewImageHeight);
    titleLabel_.frame = CGRectMake(0, TumblrMenuViewImageHeight, TumblrMenuViewImageHeight, TumblrMenuViewTitleHeight);
}


@end

@implementation TumblrMenuView
{
    UIImageView *backgroundView_;
    NSMutableArray *buttons_;
}
@synthesize backgroundImgView = backgroundView_;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
        ges.delegate = self;
        [self addGestureRecognizer:ges];
        self.backgroundColor = [UIColor clearColor];
        backgroundView_ = [[UIImageView alloc] initWithFrame:self.bounds];
        
        // backgroundView_.backgroundColor = TumblrBlue;
        
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        UIView *topView = window.rootViewController.view;
        UIImage *screenShot = [self captureView:topView];
        UIImage *blurredImage = [self applyBlurOnImage: screenShot withRadius: 0.75];
        
        backgroundView_.backgroundColor = [UIColor colorWithPatternImage:blurredImage];
        
        backgroundView_.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:backgroundView_];
        buttons_ = [[NSMutableArray alloc] initWithCapacity:6];
        
    }
    return self;
}

// Take a screen shot
- (UIImage*)captureView:(UIView *)yourView {
    CGRect rect = [[UIScreen mainScreen] bounds];
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [yourView.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

// Blur effect
- (UIImage *)applyBlurOnImage: (UIImage *)imageToBlur
                   withRadius:(CGFloat)blurRadius {
    if ((blurRadius < 0.0f) || (blurRadius > 1.0f)) {
        blurRadius = 0.5f;
    }
    
    int boxSize = (int)(blurRadius * 100);
    boxSize -= (boxSize % 2) + 1;
    
    CGImageRef rawImage = imageToBlur.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(rawImage);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(rawImage);
    inBuffer.height = CGImageGetHeight(rawImage);
    inBuffer.rowBytes = CGImageGetBytesPerRow(rawImage);
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(rawImage) * CGImageGetHeight(rawImage));
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(rawImage);
    outBuffer.height = CGImageGetHeight(rawImage);
    outBuffer.rowBytes = CGImageGetBytesPerRow(rawImage);
    
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL,
                                       0, 0, boxSize, boxSize, NULL,
                                       kvImageEdgeExtend);
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             CGImageGetBitmapInfo(imageToBlur.CGImage));
    
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    CFRelease(inBitmapData);
    CGImageRelease(imageRef);
    
    return returnImage;
}


- (void)addMenuItemWithTitle:(NSString*)title andIcon:(UIImage*)icon andSelectedBlock:(TumblrMenuViewSelectedBlock)block
{
    TumblrMenuItemButton *button = [[TumblrMenuItemButton alloc] initWithTitle:title andIcon:icon andSelectedBlock:block];
    
    [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    
    [buttons_ addObject:button];
}

- (CGRect)frameForButtonAtIndex:(NSUInteger)index
{
    NSUInteger columnCount = 3;
    NSUInteger columnIndex =  index % columnCount;

    NSUInteger rowCount = buttons_.count / columnCount + (buttons_.count%columnCount>0?1:0);
    NSUInteger rowIndex = index / columnCount;

    CGFloat itemHeight = (TumblrMenuViewImageHeight + TumblrMenuViewTitleHeight) * rowCount + (rowCount > 1?(rowCount - 1) * TumblrMenuViewHorizontalMargin:0);
    CGFloat offsetY = (self.bounds.size.height - itemHeight) / 2.0;
    CGFloat verticalPadding = (self.bounds.size.width - TumblrMenuViewHorizontalMargin * 2 - TumblrMenuViewImageHeight * 3) / 2.0;
    
    CGFloat offsetX = TumblrMenuViewHorizontalMargin;
    offsetX += (TumblrMenuViewImageHeight+ verticalPadding) * columnIndex;
    
    offsetY += (TumblrMenuViewImageHeight + TumblrMenuViewTitleHeight + TumblrMenuViewVerticalPadding) * rowIndex;

    
    return CGRectMake(offsetX, offsetY, TumblrMenuViewImageHeight, (TumblrMenuViewImageHeight+TumblrMenuViewTitleHeight));

}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    for (NSUInteger i = 0; i < buttons_.count; i++) {
        TumblrMenuItemButton *button = buttons_[i];
        button.frame = [self frameForButtonAtIndex:i];
    }
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer.view isKindOfClass:[TumblrMenuItemButton class]]) {
        return NO;
    }
    
    CGPoint location = [gestureRecognizer locationInView:self];
    for (UIView* subview in buttons_) {
        if (CGRectContainsPoint(subview.frame, location)) {
            return NO;
        }
    }
    
    return YES;
}

- (void)dismiss:(id)sender
{
    [self dropAnimation];
    double delayInSeconds = TumblrMenuViewAnimationTime  + TumblrMenuViewAnimationInterval * (buttons_.count + 1);
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self removeFromSuperview];
    });
}


- (void)buttonTapped:(TumblrMenuItemButton*)btn
{
    [self dismiss:nil];
    double delayInSeconds = TumblrMenuViewAnimationTime  + TumblrMenuViewAnimationInterval * (buttons_.count + 1);
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        btn.selectedBlock();

    });
}


- (void)riseAnimation
{
    NSUInteger columnCount = 3;
    NSUInteger rowCount = buttons_.count / columnCount + (buttons_.count%columnCount>0?1:0);


    for (NSUInteger index = 0; index < buttons_.count; index++) {
        TumblrMenuItemButton *button = buttons_[index];
        button.layer.opacity = 0;
        CGRect frame = [self frameForButtonAtIndex:index];
        NSUInteger rowIndex = index / columnCount;
        NSUInteger columnIndex = index % columnCount;
        CGPoint fromPosition = CGPointMake(frame.origin.x + TumblrMenuViewImageHeight / 2.0,frame.origin.y +  (rowCount - rowIndex + 2)*200 + (TumblrMenuViewImageHeight + TumblrMenuViewTitleHeight) / 2.0);
        
        CGPoint toPosition = CGPointMake(frame.origin.x + TumblrMenuViewImageHeight / 2.0,frame.origin.y + (TumblrMenuViewImageHeight + TumblrMenuViewTitleHeight) / 2.0);
        
        double delayInSeconds = rowIndex * columnCount * TumblrMenuViewAnimationInterval;
        if (!columnIndex) {
            delayInSeconds += TumblrMenuViewAnimationInterval;
        }
        else if(columnIndex == 2) {
            delayInSeconds += TumblrMenuViewAnimationInterval * 2;
        }

        CABasicAnimation *positionAnimation;
        
        positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:fromPosition];
        positionAnimation.toValue = [NSValue valueWithCGPoint:toPosition];
        positionAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.45f :1.2f :0.75f :1.0f];
        positionAnimation.duration = TumblrMenuViewAnimationTime;
        positionAnimation.beginTime = [button.layer convertTime:CACurrentMediaTime() fromLayer:nil] + delayInSeconds;
        [positionAnimation setValue:[NSNumber numberWithUnsignedInteger:index] forKey:TumblrMenuViewRriseAnimationID];
        positionAnimation.delegate = self;
        
        [button.layer addAnimation:positionAnimation forKey:@"riseAnimation"];


        
    }
}

- (void)dropAnimation
{
    NSUInteger columnCount = 3;
    for (NSUInteger index = 0; index < buttons_.count; index++) {
        TumblrMenuItemButton *button = buttons_[index];
        CGRect frame = [self frameForButtonAtIndex:index];
        NSUInteger rowIndex = index / columnCount;
        NSUInteger columnIndex = index % columnCount;

        CGPoint toPosition = CGPointMake(frame.origin.x + TumblrMenuViewImageHeight / 2.0,frame.origin.y -  (rowIndex + 2)*200 + (TumblrMenuViewImageHeight + TumblrMenuViewTitleHeight) / 2.0);
        
        CGPoint fromPosition = CGPointMake(frame.origin.x + TumblrMenuViewImageHeight / 2.0,frame.origin.y + (TumblrMenuViewImageHeight + TumblrMenuViewTitleHeight) / 2.0);
        
        double delayInSeconds = rowIndex * columnCount * TumblrMenuViewAnimationInterval;
        if (!columnIndex) {
            delayInSeconds += TumblrMenuViewAnimationInterval;
        }
        else if(columnIndex == 2) {
            delayInSeconds += TumblrMenuViewAnimationInterval * 2;
        }
        CABasicAnimation *positionAnimation;
        
        positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:fromPosition];
        positionAnimation.toValue = [NSValue valueWithCGPoint:toPosition];
        positionAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.3 :0.5f :1.0f :1.0f];
        positionAnimation.duration = TumblrMenuViewAnimationTime;
        positionAnimation.beginTime = [button.layer convertTime:CACurrentMediaTime() fromLayer:nil] + delayInSeconds;
        [positionAnimation setValue:[NSNumber numberWithUnsignedInteger:index] forKey:TumblrMenuViewDismissAnimationID];
        positionAnimation.delegate = self;
        
        [button.layer addAnimation:positionAnimation forKey:@"riseAnimation"];
        
        
        
    }

}

- (void)animationDidStart:(CAAnimation *)anim
{
    NSUInteger columnCount = 3;
    if([anim valueForKey:TumblrMenuViewRriseAnimationID]) {
        NSUInteger index = [[anim valueForKey:TumblrMenuViewRriseAnimationID] unsignedIntegerValue];
        UIView *view = buttons_[index];
        CGRect frame = [self frameForButtonAtIndex:index];
        CGPoint toPosition = CGPointMake(frame.origin.x + TumblrMenuViewImageHeight / 2.0,frame.origin.y + (TumblrMenuViewImageHeight + TumblrMenuViewTitleHeight) / 2.0);
        CGFloat toAlpha = 1.0;
        
        view.layer.position = toPosition;
        view.layer.opacity = toAlpha;
        
    }
    else if([anim valueForKey:TumblrMenuViewDismissAnimationID]) {
        NSUInteger index = [[anim valueForKey:TumblrMenuViewDismissAnimationID] unsignedIntegerValue];
        NSUInteger rowIndex = index / columnCount;

        UIView *view = buttons_[index];
        CGRect frame = [self frameForButtonAtIndex:index];
        CGPoint toPosition = CGPointMake(frame.origin.x + TumblrMenuViewImageHeight / 2.0,frame.origin.y -  (rowIndex + 2)*200 + (TumblrMenuViewImageHeight + TumblrMenuViewTitleHeight) / 2.0);
        
        view.layer.position = toPosition;
    }
}


- (void)show
{
    
    UIViewController *appRootViewController;
    UIWindow *window;
    
    window = [UIApplication sharedApplication].keyWindow;
   
        
    appRootViewController = window.rootViewController;
    
 
    
    UIViewController *topViewController = appRootViewController;
    while (topViewController.presentedViewController != nil)
    {
        topViewController = topViewController.presentedViewController;
    }
    
    if ([topViewController.view viewWithTag:TumblrMenuViewTag]) {
        [[topViewController.view viewWithTag:TumblrMenuViewTag] removeFromSuperview];
    }
    
    self.frame = topViewController.view.bounds;
    [topViewController.view addSubview:self];
    
    [self riseAnimation];
}


@end
