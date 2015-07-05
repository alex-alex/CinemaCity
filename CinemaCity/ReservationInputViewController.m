//
//  ReservationInputViewController.m
//  CinemaCity
//
//  Created by Alex Studnicka on 29/03/14.
//  Copyright (c) 2014 Alex Studnicka. All rights reserved.
//

#import "ReservationInputViewController.h"
//#import "ReservationTypeViewController.h"
#import "LicenceViewController.h"

@implementation ReservationInputViewController {
	
	UIRefreshControl *_refreshControl;
	
	BOOL _today;
	Presentations *_presentations;
	
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
	NSDateComponents *date1 = [NSCalendar.currentCalendar components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self.date];
	NSDateComponents *date2 = [NSCalendar.currentCalendar components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:NSDate.date];
	_today = (date1.day == date2.day && date1.month == date2.month && date1.year == date2.year && date1.era == date2.era);
	
	self.tableView.backgroundColor = UIColor.blackColor;
	
	self.navigationItem.title = NSLocalizedString(@"RESERVATION", nil);
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BACK", nil) style:UIBarButtonItemStyleBordered target:nil action:NULL];
	
	UIImageView *bgLogoImageView = [UIImageView new];
	bgLogoImageView.alpha = 0.2;
	bgLogoImageView.frame = CGRectMake(0, 0, 320, 180);
	bgLogoImageView.center = self.view.center;
	bgLogoImageView.image = [UIImage imageNamed:@"bg_logo.png"];
	bgLogoImageView.contentMode = UIViewContentModeCenter;
	self.tableView.backgroundView = bgLogoImageView;
	
	_refreshControl = [UIRefreshControl new];
	_refreshControl.tintColor = AppDelegate.instance.window.tintColor;
	[_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
	[self.tableView addSubview:_refreshControl];
	
	self.tableView.alwaysBounceVertical = YES;
	[self.tableView setContentOffset:CGPointMake(0, -_refreshControl.frame.size.height) animated:YES];
	[self refresh];
	
}

#pragma mark - Refresh

- (void)refresh {
	
	[_refreshControl beginRefreshing];

	[API.sharedInstance getPresentationsForURL:self.detailURL completionHandler:^(Presentations *presentations) {
		_presentations = presentations;
//		NSLog(@"presentations: %@", presentations);
		[self.tableView reloadData];
		[_refreshControl endRefreshing];
	}];
	
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return _presentations ? 2 : 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
//		case 0:
//			return NSLocalizedString(@"INFO", nil);
		case 1:
			return NSLocalizedString(@"PRESENTATION_TIMES", nil);
		default:
			return nil;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 3;
		case 1:
			return [_presentations presentationTypeNamesAtSite:self.cinemaID date:self.date].count;
		default:
			return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0: {
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InfoCell" forIndexPath:indexPath];
			
			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = [_presentations movieNameForSite:self.cinemaID];
					break;
				case 1:
					cell.textLabel.text = [_presentations siteNameForSiteCode:self.cinemaID];
					break;
				case 2:
					cell.textLabel.text = [API.sharedInstance.humanDateFormatter stringFromDate:self.date];
					break;
				default:
					cell.textLabel.text = @"";
					break;
			}
			
			return cell;
		}
		case 1: {
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PresentationCell" forIndexPath:indexPath];
			
			NSDictionary *presentation = [_presentations presentationsAtSite:self.cinemaID date:self.date][indexPath.row];
			cell.textLabel.text = presentation[@"name"];
			
			if (_today) {
				
				NSDate *date1 = [API.sharedInstance.timeFormatter dateFromString:[API.sharedInstance.timeFormatter stringFromDate:NSDate.date]];
				NSDate *date2 = [API.sharedInstance.timeFormatter dateFromString:presentation[@"time"]];
				
				NSComparisonResult result = [date1 compare:date2];
				if (result == NSOrderedDescending) {
					cell.accessoryType = UITableViewCellAccessoryNone;
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					cell.detailTextLabel.textColor = [UIColor darkGrayColor];
					
					NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:presentation[@"time"] attributes:@{NSStrikethroughStyleAttributeName: @(NSUnderlineStyleSingle)}];
					cell.detailTextLabel.attributedText = titleString;
				} else {
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					cell.selectionStyle = UITableViewCellSelectionStyleDefault;
					cell.detailTextLabel.textColor = [UIColor lightGrayColor];
					cell.detailTextLabel.text = presentation[@"time"];
				}
				
			} else {
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.selectionStyle = UITableViewCellSelectionStyleDefault;
				cell.detailTextLabel.textColor = [UIColor lightGrayColor];
				cell.detailTextLabel.text = presentation[@"time"];
			}
			
			return cell;
		}
		default:
			return nil;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 1) {
		
		NSDictionary *presentation = [_presentations presentationsAtSite:self.cinemaID date:self.date][indexPath.row];

		BOOL valid = YES;
		if (_today) {
			NSDate *date1 = [API.sharedInstance.timeFormatter dateFromString:[API.sharedInstance.timeFormatter stringFromDate:NSDate.date]];
			NSDate *date2 = [API.sharedInstance.timeFormatter dateFromString:presentation[@"time"]];
			NSComparisonResult result = [date1 compare:date2];
			if (result == NSOrderedDescending) {
				valid = NO;
			}
		}
		
		if (valid) {
//			UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//			ReservationTypeViewController *reservationTypeVC = [storyboard instantiateViewControllerWithIdentifier:@"ReservationTypeViewController"];
//			reservationTypeVC.URLtemplate = [_presentations templateForSite:self.cinemaID];
//			reservationTypeVC.presentationCode = presentation[@"code"];
//			[self.navigationController pushViewController:reservationTypeVC animated:YES];
			
			NSDictionary *URLtemplate = [_presentations templateForSite:self.cinemaID];
			NSString *_ticketURL = [URLtemplate[@"ticketUrls"] firstObject][@"ticketUrl"];		// reservation
//			NSString *_ticketURL = [URLtemplate[@"ticketUrls"] lastObject][@"ticketUrl"];		// purchase
			_ticketURL = [_ticketURL stringByReplacingOccurrencesOfString:@"$PrsntCode$" withString:presentation[@"code"]];
			UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
			LicenceViewController *licenceVC = [storyboard instantiateViewControllerWithIdentifier:@"LicenceViewController"];
			licenceVC.ticketURL = [NSURL URLWithString:_ticketURL];
			[self.navigationController pushViewController:licenceVC animated:YES];
			
		}
		
	}
}

@end
