//
//  HistoryViewController.m
//  CinemaCity
//
//  Created by Alex Studnicka on 31/03/14.
//  Copyright (c) 2014 Alex Studnicka. All rights reserved.
//

#import "HistoryViewController.h"
#import "HistoryCell.h"

@implementation HistoryViewController {
	
	UIRefreshControl *_refreshControl;
	
	NSArray *_history;
	
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.tableView.backgroundColor = UIColor.blackColor;
	
	self.navigationItem.title = NSLocalizedString(@"HISTORY", nil);
	
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
	
	[API.sharedInstance loadHistoryWithCompletionHandler:^(NSArray *history) {
		_history = [[history reverseObjectEnumerator] allObjects];
		
		[self.tableView reloadData];
		[_refreshControl endRefreshing];
	}];
	
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _history.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryCell" forIndexPath:indexPath];
	cell.historyDict = _history[indexPath.row];
	return cell;
}

@end
