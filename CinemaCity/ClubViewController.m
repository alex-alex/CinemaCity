//
//  ClubViewController.m
//  CinemaCity
//
//  Created by Alex Studnicka on 31/03/14.
//  Copyright (c) 2014 Alex Studnicka. All rights reserved.
//

#import "ClubViewController.h"
#import "HistoryViewController.h"

@implementation ClubViewController {
	
	UIRefreshControl *_refreshControl;
	
	FieldCell *usernameCell, *passwordCell;
	NSString *username, *password;
	
	BOOL _loggingIn;
	BOOL _loggedIn;
	NSDictionary *_userInfo;
	
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.tableView.backgroundColor = UIColor.blackColor;
	
	self.navigationItem.title = NSLocalizedString(@"CLUB", nil);
	
	UIImageView *bgLogoImageView = [UIImageView new];
	bgLogoImageView.frame = CGRectMake(0, 138, 320, 180);
	bgLogoImageView.image = [UIImage imageNamed:@"bg_logo.png"];
	bgLogoImageView.contentMode = UIViewContentModeCenter;
	self.tableView.backgroundView = bgLogoImageView;
	
	_refreshControl = [UIRefreshControl new];
	_refreshControl.tintColor = AppDelegate.instance.window.tintColor;
	
	_loggedIn = NO;
	
	self.tableView.alwaysBounceVertical = YES;
	
}

#pragma mark - Login

- (void)login {
	
	[usernameCell resignFirstResponder];
	[passwordCell resignFirstResponder];
	
	if (username.length <= 0 || password.length <= 0) return;
	
	_loggingIn = YES;
	[self.tableView reloadData];
	
	[self.tableView setContentOffset:CGPointMake(0, -_refreshControl.frame.size.height) animated:YES];
	[self.tableView addSubview:_refreshControl];
	[_refreshControl beginRefreshing];
	
	[API.sharedInstance loginUser:username password:password completionHandler:^(NSDictionary *userInfo) {
		
		_loggingIn = NO;
//		NSLog(@"userInfo: %@", userInfo);
		
		if ([userInfo[@"success"] boolValue]) {
			_userInfo = userInfo[@"user"];
			_loggedIn = YES;
			
		} else {
			_userInfo = nil;
			_loggedIn = NO;
			
			NSString *errorStr = userInfo[@"text"] ? userInfo[@"text"] : NSLocalizedString(@"UNKNOWN_ERROR_OCCURRED", nil);
			
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[errorStr stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
			[alertView show];
		}
		
		[self.tableView reloadData];
		[_refreshControl endRefreshing];
		[_refreshControl removeFromSuperview];
	}];
	
}

- (void)logout {
	
	_loggingIn = YES;
	[self.tableView reloadData];
	
	[self.tableView setContentOffset:CGPointMake(0, -_refreshControl.frame.size.height) animated:YES];
	[self.tableView addSubview:_refreshControl];
	[_refreshControl beginRefreshing];
	
	[API.sharedInstance logoutUserWithCompletionHandler:^(BOOL success) {
		_userInfo = nil;
		_loggedIn = NO;
		_loggingIn = NO;
		
		[self.tableView reloadData];
		[_refreshControl endRefreshing];
		[_refreshControl removeFromSuperview];
	}];
	
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (_loggingIn) {
		return 0;
	} else if (_loggedIn) {
		return _userInfo ? 2 : 0;
	} else {
		return 2;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (_loggedIn) {
		if (section == 0) {
			return 1;
		} else if (section == 1) {
			return 2;
		} else {
			return 0;
		}
	} else {
		if (section == 0) {
			return 2;
		} else if (section == 1) {
			return 1;
		} else {
			return 0;
		}
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (_loggedIn) {

		if (indexPath.section == 0 && indexPath.row == 0) {
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
			cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", _userInfo[@"FirstName"], _userInfo[@"LastName"]];
			cell.detailTextLabel.text = _userInfo[@"UserName"];
			return cell;
		} else if (indexPath.section == 1) {
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActionCell" forIndexPath:indexPath];
			
			switch (indexPath.row) {
//				case 0:
//					cell.textLabel.text = NSLocalizedString(@"CHANGE_OF_PERSONAL_DATA", nil);
//					break;
				case 0:
					cell.textLabel.text = NSLocalizedString(@"SHOW_HISTORY", nil);
					break;
				case 1:
					cell.textLabel.text = NSLocalizedString(@"LOGOUT", nil);
					break;
				default:
					cell.textLabel.text = @"";
					break;
			}
			
			return cell;
		} else {
			return nil;
		}
		
	} else {
		
		if (indexPath.section == 0) {
			FieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FieldCell" forIndexPath:indexPath];
			cell.delegate = self;
			
			switch (indexPath.row) {
				case 0:
					cell.fieldCellType = FieldCellTypeUsername;
					usernameCell = cell;
					break;
				case 1:
					cell.fieldCellType = FieldCellTypePassword;
					passwordCell = cell;
					break;
				default:
					cell.fieldCellType = FieldCellTypeOther;
					break;
			}
			
			return cell;
		} else if (indexPath.section == 1 && indexPath.row == 0) {
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActionCell" forIndexPath:indexPath];
			cell.textLabel.text = NSLocalizedString(@"LOGIN", nil);
			return cell;
		} else {
			return nil;
		}
		

	}
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (_loggedIn) {
		if (indexPath.section == 1) {
			switch (indexPath.row) {
//				case 0: {
////					UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
////					HistoryViewController *historyVC = [storyboard instantiateViewControllerWithIdentifier:@"HistoryViewController"];
////					[self.navigationController pushViewController:historyVC animated:YES];
//					break;
//				}
				case 0: {
					UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
					HistoryViewController *historyVC = [storyboard instantiateViewControllerWithIdentifier:@"HistoryViewController"];
					[self.navigationController pushViewController:historyVC animated:YES];
					break;
				}
				case 1:
					[self logout];
					[tableView deselectRowAtIndexPath:indexPath animated:YES];
					break;
			}
		}
	} else {
		if (indexPath.section == 1) {
			[self login];
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
		}
	}
}

#pragma mark - FieldCellDelegate

- (void)textDidChangeInFieldCell:(FieldCell *)cell {
	if (cell.fieldCellType == FieldCellTypeUsername) {
		username = cell.value;
	} else if (cell.fieldCellType == FieldCellTypePassword) {
		password = cell.value;
	}
}

- (void)didReturnInFieldCell:(FieldCell *)cell {
	if (cell.fieldCellType == FieldCellTypeUsername) {
		[passwordCell becomeFirstResponder];
	} else if (cell.fieldCellType == FieldCellTypePassword) {
		[self login];
	}
}

@end
