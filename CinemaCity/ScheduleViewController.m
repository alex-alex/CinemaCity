//
//  ScheduleViewController.m
//  CinemaCity
//
//  Created by Alex Studnicka on 27/03/14.
//  Copyright (c) 2014 Alex Studnicka. All rights reserved.
//

#import "ScheduleViewController.h"
#import "TFHpple.h"
#import "ScheduleCell.h"
#import "ReservationInputViewController.h"

@implementation ScheduleViewController {
	
	UIRefreshControl *_refreshControl;
	
	NSDate *_selectedDate;
	BOOL _today;
	NSDateFormatter *_dateFormatter;
	RMDateSelectionViewController *_dateSelectionVC;
	
	NSInteger _selectedCinema;
	RMPickerViewController *_pickerVC;
	
	NSArray *_schedule;
	
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.tableView.backgroundColor = UIColor.blackColor;
	
//	self.navigationItem.title = NSLocalizedString(@"SCHEDULE", nil);
	
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
	
	// --------------------
	
	_selectedDate = [NSDate date];
	_today = YES;
	
	_dateFormatter = [NSDateFormatter new];
	_dateFormatter.dateStyle = NSDateFormatterMediumStyle;
	self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"TODAY", nil);

	RMAction *selectAction = [RMAction actionWithTitle:NSLocalizedString(@"SELECT", nil) style:RMActionStyleDone andHandler:^(RMActionController *controller) {
		_selectedDate = ((RMDateSelectionViewController *)controller).datePicker.date;
		
		NSDateComponents *date1 = [NSCalendar.currentCalendar components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:_selectedDate];
		NSDateComponents *date2 = [NSCalendar.currentCalendar components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:NSDate.date];
		_today = (date1.day == date2.day && date1.month == date2.month && date1.year == date2.year && date1.era == date2.era);
		
		self.navigationItem.leftBarButtonItem.title = _today ? NSLocalizedString(@"TODAY", nil) : [_dateFormatter stringFromDate:_selectedDate];;
		
		[self.tableView setContentOffset:CGPointMake(0, -_refreshControl.frame.size.height) animated:YES];
		[self refresh];
	}];
	
	RMAction *cancelAction = [RMAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:RMActionStyleCancel andHandler:nil];
	
	_dateSelectionVC = [RMDateSelectionViewController actionControllerWithStyle:RMActionControllerStyleDefault selectAction:selectAction andCancelAction:cancelAction];
	
	RMAction *nowAction = [RMAction actionWithTitle:NSLocalizedString(@"TODAY", nil) style:RMActionStyleAdditional andHandler:^(RMActionController *controller) {
		((UIDatePicker *)controller.contentView).date = [NSDate date];
	}];
	nowAction.dismissesActionController = NO;
	
	[_dateSelectionVC addAction:nowAction];
	
	// --------------------
	
	_selectedCinema = 0;
	self.navigationItem.rightBarButtonItem.title = [self pickerView:_pickerVC.picker titleForRow:_selectedCinema forComponent:0];
	
	RMAction *selectAction2 = [RMAction actionWithTitle:NSLocalizedString(@"SELECT", nil) style:RMActionStyleDone andHandler:^(RMActionController *controller) {
		UIPickerView *picker = ((RMPickerViewController *)controller).picker;
		_selectedCinema = [picker selectedRowInComponent:0];
		
		self.navigationItem.rightBarButtonItem.title = [self pickerView:_pickerVC.picker titleForRow:_selectedCinema forComponent:0];
		
		[self.tableView setContentOffset:CGPointMake(0, -_refreshControl.frame.size.height) animated:YES];
		[self refresh];
	}];
	
	RMAction *cancelAction2 = [RMAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:RMActionStyleCancel andHandler:nil];
	
	_pickerVC = [RMPickerViewController actionControllerWithStyle:RMActionControllerStyleDefault selectAction:selectAction2 andCancelAction:cancelAction2];
	_pickerVC.picker.delegate = self;
	_pickerVC.picker.dataSource = self;
	
	// --------------------
	
	self.tableView.alwaysBounceVertical = YES;
	[self.tableView setContentOffset:CGPointMake(0, -_refreshControl.frame.size.height) animated:YES];
	[self refresh];
	
}

#pragma mark - Refresh

- (void)refresh {
	
	[_refreshControl beginRefreshing];
	
	NSArray *cinemaIDComps = [[self pickerView:_pickerVC.picker titleForRow:_selectedCinema forComponent:1] componentsSeparatedByString:@"|"];
	NSString *cinemaID = cinemaIDComps.firstObject;
	NSString *venueTypeID = (cinemaIDComps.count > 1) ? cinemaIDComps[1] : @"0";
	
	[API.sharedInstance getScheduleForCinema:cinemaID venueTypeID:venueTypeID date:_selectedDate completionHandler:^(NSArray *schedule) {
		_schedule = schedule;
		[self.tableView reloadData];
		[_refreshControl endRefreshing];
	}];
	
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return _schedule.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	ScheduleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ScheduleCell" forIndexPath:indexPath];
	[cell setScheduleDict:_schedule[indexPath.row] today:_today];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSArray *cinemaIDComps = [[self pickerView:_pickerVC.picker titleForRow:_selectedCinema forComponent:1] componentsSeparatedByString:@"|"];
	NSString *cinemaID = cinemaIDComps.firstObject;
	NSString *venueTypeID = (cinemaIDComps.count > 1) ? cinemaIDComps[1] : @"0";
	
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
	ReservationInputViewController *reservationInputVC = [storyboard instantiateViewControllerWithIdentifier:@"ReservationInputViewController"];
	reservationInputVC.cinemaID = cinemaID;
	reservationInputVC.venueTypeID = venueTypeID;
	reservationInputVC.featureCode = _schedule[indexPath.row][@"code"];
	reservationInputVC.detailURL = _schedule[indexPath.row][@"detailURL"];
	reservationInputVC.date = _selectedDate;
	[self.navigationController pushViewController:reservationInputVC animated:YES];
	
}

#pragma mark - UIPickerViewDataSource & UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return 15;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	
	if (component == 0) {
		
		switch (row) {
			case 0:
				return @"Flora";
			case 1:
				return @"Flora (IMAX)";
			case 2:
				return @"Galaxie";
			case 3:
				return @"Letňany";
			case 4:
				return @"Nový Smíchov";
			case 5:
				return @"Nový Smíchov (4DX)";
			case 6:
				return @"Slovanský dům";
			case 7:
				return @"Zličín";
			case 8:
				return @"Olympia";
			case 9:
				return @"Velký Špalíček";
			case 10:
				return @"Liberec";
			case 11:
				return @"Ostrava";
			case 12:
				return @"Pardubice";
			case 13:
				return @"Plzeň";
			case 14:
				return @"Ústí nad Labem";
			default:
				return @"";
		}
		
	} else if (component == 1) {
		
		switch (row) {
			case 0:
				return @"1010105|0";
			case 1:
				return @"1010105|2";
			case 2:
				return @"1010113";
			case 3:
				return @"1010110";
			case 4:
				return @"1010101|0";
			case 5:
				return @"1010101|5";
			case 6:
				return @"1010111";
			case 7:
				return @"1010104";
			case 8:
				return @"1010103";
			case 9:
				return @"1010107";
			case 10:
				return @"1010102";
			case 11:
				return @"1010114";
			case 12:
				return @"1010108";
			case 13:
				return @"1010106";
			case 14:
				return @"1010109";
			default:
				return @"";
		}
		
	}
	
	return @"";
	
}

#pragma mark - Actions

- (IBAction)changeDate {
	[self.tabBarController presentViewController:_dateSelectionVC animated:YES completion:nil];
	_dateSelectionVC.datePicker.date = _selectedDate;
	_dateSelectionVC.datePicker.minimumDate = NSDate.date;
	_dateSelectionVC.datePicker.datePickerMode = UIDatePickerModeDate;
}

- (IBAction)changeCinema {
	[self.tabBarController presentViewController:_pickerVC animated:YES completion:nil];
	[_pickerVC.picker selectRow:_selectedCinema inComponent:0 animated:NO];
}

@end
