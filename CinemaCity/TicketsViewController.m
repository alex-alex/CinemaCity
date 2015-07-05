//
//  TicketsViewController.m
//  CinemaCity
//
//  Created by Alex Studnicka on 30/03/14.
//  Copyright (c) 2014 Alex Studnicka. All rights reserved.
//

#import "TicketsViewController.h"
#import "SeatChooserViewController.h"

@implementation TicketsViewController {
	
	UIRefreshControl *_refreshControl;
	
	NSURL *_url;
	NSDictionary *_formInfo;
	NSArray *_prices;
	NSMutableDictionary *_tickets;
	
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.tableView.backgroundColor = UIColor.blackColor;
	
	self.navigationItem.title = NSLocalizedString(@"TICKETS", nil);
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BACK", nil) style:UIBarButtonItemStyleBordered target:nil action:NULL];
	self.navigationItem.rightBarButtonItem.enabled = NO;
	
	UIImageView *bgLogoImageView = [UIImageView new];
	bgLogoImageView.frame = CGRectMake(0, 138, 320, 180);
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
	
	self.navigationItem.rightBarButtonItem.enabled = NO;
	[_refreshControl beginRefreshing];
	
	[API.sharedInstance loadSelectTicketsFormWithURL:self.ticketURL completionHandler:^(NSURL *url, NSDictionary *formInfo, NSArray *prices) {
		_url = url;
		_formInfo = formInfo;
		_prices = prices;
		_tickets = [NSMutableDictionary dictionaryWithCapacity:_prices.count];
		
		for (NSDictionary *price in prices) {
			_tickets[price[@"nameID"]] = @(0);
		}
		
		[self.tableView reloadData];
		[_refreshControl endRefreshing];
	}];
	
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _prices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	TicketCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TicketCell" forIndexPath:indexPath];
	
	cell.delegate = self;
	
	NSDictionary *priceDict = _prices[indexPath.row];
	[cell setPriceDict:priceDict quantity:[_tickets[priceDict[@"nameID"]] intValue]];
	
	return cell;
}

#pragma mark - TicketCellDelegate

- (void)ticketCell:(TicketCell *)cell didChangeQuantity:(int)quantity forPriceID:(NSString *)priceID {
	_tickets[priceID] = @(quantity);
	
	int total = 0;
	for (NSNumber *quantity in _tickets.allValues) total += quantity.intValue;
	self.navigationItem.rightBarButtonItem.enabled = NSLocationInRange(total, NSMakeRange(1, 10));
}

#pragma mark - Actions

- (IBAction)continueAction {
	
	NSMutableDictionary *selectedTickets = [NSMutableDictionary dictionaryWithCapacity:_tickets.count];
	[_tickets enumerateKeysAndObjectsUsingBlock:^(NSString *priceID, NSNumber *quantity, BOOL *stop) {
		selectedTickets[priceID] = [quantity stringValue];
	}];
	
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
	SeatChooserViewController *seatChooserVC = [storyboard instantiateViewControllerWithIdentifier:@"SeatChooserViewController"];
	seatChooserVC.url = _url;
	seatChooserVC.formInfo = _formInfo;
	seatChooserVC.tickets = selectedTickets;
	[self.navigationController pushViewController:seatChooserVC animated:YES];
	
}

@end
