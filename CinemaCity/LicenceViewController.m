//
//  LicenceViewController.m
//  CinemaCity
//
//  Created by Alex Studnicka on 30/03/14.
//  Copyright (c) 2014 Alex Studnicka. All rights reserved.
//

#import "LicenceViewController.h"
#import "TicketsViewController.h"

@implementation LicenceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.view.backgroundColor = UIColor.blackColor;
	
	self.navigationItem.title = NSLocalizedString(@"RESERVATION", nil);
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BACK", nil) style:UIBarButtonItemStyleBordered target:nil action:NULL];
	
	UIImageView *bgLogoImageView = [UIImageView new];
	bgLogoImageView.alpha = 0.2;
	bgLogoImageView.frame = CGRectMake(0, 0, 320, 180);
	bgLogoImageView.center = self.view.center;
	bgLogoImageView.image = [UIImage imageNamed:@"bg_logo.png"];
	bgLogoImageView.contentMode = UIViewContentModeCenter;
	[self.view addSubview:bgLogoImageView];
	[self.view sendSubviewToBack:bgLogoImageView];
	
	_textField.contentInset = UIEdgeInsetsMake(74, 0, 59, 0);
	_textField.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 49, 0);
	
}

- (IBAction)continueAction {
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
	TicketsViewController *ticketsVC = [storyboard instantiateViewControllerWithIdentifier:@"TicketsViewController"];
	ticketsVC.ticketURL = self.ticketURL;
	[self.navigationController pushViewController:ticketsVC animated:YES];
}

@end
