//
//  MovieDetailViewController.m
//  CinemaCity
//
//  Created by Alex Studnicka on 27/03/14.
//  Copyright (c) 2014 Alex Studnicka. All rights reserved.
//

#import "MovieDetailViewController.h"
#import "TFHpple.h"
#import "MovieDetailPosterCell.h"

@implementation MovieDetailViewController {
	
	UIRefreshControl *_refreshControl;
	
	NSDictionary *_info;
	
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
	self.tableView.backgroundColor = UIColor.blackColor;
	
	self.navigationItem.title = NSLocalizedString(@"MOVIE_DETAIL", nil);
	
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

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	NSLog(@"viewWillAppear");
	
	[UIApplication.sharedApplication setStatusBarHidden:NO withAnimation:(animated ? UIStatusBarAnimationSlide : UIStatusBarAnimationNone)];
}

- (BOOL)prefersStatusBarHidden {
	return NO;
}

#pragma mark - Refresh

- (void)refresh {
	
	[_refreshControl beginRefreshing];
	
	[API.sharedInstance getDetailOfMovieWithFeatureCode:self.featureCode completionHandler:^(NSDictionary *movieDetail) {
		_info = movieDetail;
		[self.tableView reloadData];
		[_refreshControl endRefreshing];
	}];
	
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (_info) {
		switch (section) {
			case 0:
				return 1;
			case 1:
				return 10;
			default:
				return 0;
		}
	}
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 1 && indexPath.row == 9) {
		CGRect boundingRect = [_info[@"synopsis"] boundingRectWithSize:CGSizeMake(290, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]} context:nil];
		return boundingRect.size.height+10;
	}
	return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	
	if (_info && indexPath.section == 0 && indexPath.row == 0) {
		[(MovieDetailPosterCell *)cell setInfoDict:_info];
	}
	
	if (_info && indexPath.section == 1) {
		switch (indexPath.row) {
			case 0:
				cell.detailTextLabel.text = _info[@"name"];
				break;
			case 1:
				cell.detailTextLabel.text = _info[@"genere"];
				break;
			case 2:
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ min", [_info[@"duration"] stringValue]];
				break;
			case 3:
				cell.detailTextLabel.text = _info[@"version"];
				break;
			case 4:
				cell.detailTextLabel.text = _info[@"premiere"];
				break;
			case 5:
				cell.detailTextLabel.text = _info[@"rating"];
				break;
			case 6:
				cell.detailTextLabel.text = _info[@"director"];
				break;
			case 7:
				cell.detailTextLabel.text = _info[@"actors"];
				break;
			case 8:
				cell.detailTextLabel.text = _info[@"origin"];
				break;
			case 9:
				cell.textLabel.text = _info[@"synopsis"];
				break;
		}
	}
	
	return cell;
}

@end
