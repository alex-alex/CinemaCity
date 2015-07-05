//
//  ReservationTypeViewController.m
//  CinemaCity
//
//  Created by Alex Studnicka on 29/03/14.
//  Copyright (c) 2014 Alex Studnicka. All rights reserved.
//

#import "ReservationTypeViewController.h"
#import "LicenceViewController.h"

@implementation ReservationTypeViewController {
	NSString *_ticketURL;
}

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
	
	[_reservationButton setTitle:NSLocalizedString(@"RESERVATION", nil) forState:UIControlStateNormal];
	[_purchaseButton setTitle:NSLocalizedString(@"PURCHASE", nil) forState:UIControlStateNormal];
	
}

#pragma mark - Actions

- (IBAction)reservation {
	_ticketURL = [self.URLtemplate[@"ticketUrls"] firstObject][@"ticketUrl"];
	
	[self continueAciton];
}

- (IBAction)purchase {
	_ticketURL = [self.URLtemplate[@"ticketUrls"] lastObject][@"ticketUrl"];
	
	[self continueAciton];
}

#pragma mark - UIAlertViewDelegate

- (IBAction)continueAciton {
	
	_ticketURL = [_ticketURL stringByReplacingOccurrencesOfString:@"$PrsntCode$" withString:self.presentationCode];
	
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
	LicenceViewController *licenceVC = [storyboard instantiateViewControllerWithIdentifier:@"LicenceViewController"];
	licenceVC.ticketURL = [NSURL URLWithString:_ticketURL];
	[self.navigationController pushViewController:licenceVC animated:YES];
	
}

@end
