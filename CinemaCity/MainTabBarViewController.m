//
//  MainTabBarViewController.m
//  CinemaCity
//
//  Created by Alex Studnicka on 27/03/14.
//  Copyright (c) 2014 Alex Studnicka. All rights reserved.
//

#import "MainTabBarViewController.h"

@implementation MainTabBarViewController

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self.viewControllers[0] setTabBarItem:[self tabBarItemWithTitle:NSLocalizedString(@"MOVIES", nil) icon:[FAKFontAwesome videoCameraIconWithSize:25]]];
	[self.viewControllers[1] setTabBarItem:[self tabBarItemWithTitle:NSLocalizedString(@"SCHEDULE", nil) icon:[FAKFontAwesome listAltIconWithSize:25]]];
	[self.viewControllers[2] setTabBarItem:[self tabBarItemWithTitle:NSLocalizedString(@"CLUB", nil) icon:[FAKFontAwesome userIconWithSize:25]]];
//	[self.viewControllers[3] setTabBarItem:[self tabBarItemWithTitle:NSLocalizedString(@"MORE", nil) icon:[FAKFontAwesome ellipsisHIconWithSize:25]]];
	
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark -

- (UITabBarItem *)tabBarItemWithTitle:(NSString *)title icon:(FAKIcon *)icon {
	[icon addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:0.8 alpha:1]];
	UIImage *image1 = [[icon imageWithSize:CGSizeMake(25, 25)] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
	[icon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
	UIImage *image2 = [[icon imageWithSize:CGSizeMake(25, 25)] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
	return [[UITabBarItem alloc] initWithTitle:title image:image1 selectedImage:image2];
}

@end
