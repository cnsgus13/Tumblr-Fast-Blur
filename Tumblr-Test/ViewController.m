//
//  ViewController.m
//  Tumblr-Test
//
//  Created by yiqin on 3/9/14.
//  Copyright (c) 2014 purdue. All rights reserved.
//

#import "ViewController.h"
#import "TumblrMenuView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)showTumblrMenu:(id)sender {
    TumblrMenuView *menuView = [[TumblrMenuView alloc] init];
    [menuView addMenuItemWithTitle:@"Art" andIcon:[UIImage imageNamed:@"testArt.png"] andSelectedBlock:^{
        NSLog(@"Art selected");
    }];
    [menuView addMenuItemWithTitle:@"Tech" andIcon:[UIImage imageNamed:@"post_type_bubble_photo.png"] andSelectedBlock:^{
        NSLog(@"Tech selected");
    }];
    [menuView addMenuItemWithTitle:@"Finance" andIcon:[UIImage imageNamed:@"post_type_bubble_quote.png"] andSelectedBlock:^{
        NSLog(@"Finance selected");
        
    }];
    [menuView addMenuItemWithTitle:@"Education" andIcon:[UIImage imageNamed:@"post_type_bubble_link.png"] andSelectedBlock:^{
        NSLog(@"Education selected");
        
    }];
    [menuView addMenuItemWithTitle:@"Service" andIcon:[UIImage imageNamed:@"post_type_bubble_chat.png"] andSelectedBlock:^{
        NSLog(@"Service selected");
        
    }];
    [menuView addMenuItemWithTitle:@"More" andIcon:[UIImage imageNamed:@"post_type_bubble_video.png"] andSelectedBlock:^{
        NSLog(@"More selected");
        
    }];

    
    
    [menuView show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
