//
//  ScheduleCell.m
//  CinemaCity
//
//  Created by Alex Studnicka on 27/03/14.
//  Copyright (c) 2014 Alex Studnicka. All rights reserved.
//

#import "ScheduleCell.h"

@implementation ScheduleCell

#pragma mark - Setter

- (void)setScheduleDict:(NSDictionary *)scheduleDict today:(BOOL)today {
	
	_nameLabel.text = scheduleDict[@"name"];
	_ratingLabel.text = scheduleDict[@"rating"];
	_typeLabel.text = scheduleDict[@"type"];
	_versionLabel.text = scheduleDict[@"version"];
	_durationLabel.text = [NSString stringWithFormat:@"%@ min", [scheduleDict[@"duration"] stringValue]];
	
	NSArray *presentations = scheduleDict[@"presentations"];
	for (int i = 0; i < 12; i++) {
		id presentation;
		if (i < presentations.count) presentation = presentations[i];
		UILabel *label = (UILabel *)[self viewWithTag:10+i];
		if ([presentation isKindOfClass:NSString.class]) {
			
			label.text = presentation;
			
			if (today) {
				
				NSDate *date1 = [API.sharedInstance.timeFormatter dateFromString:[API.sharedInstance.timeFormatter stringFromDate:NSDate.date]];
				NSDate *date2 = [API.sharedInstance.timeFormatter dateFromString:presentation];
				
				NSComparisonResult result = [date1 compare:date2];
				if (result == NSOrderedDescending) {
					label.textColor = [UIColor grayColor];
				} else {
					label.textColor = [UIColor whiteColor];
				}
				
			} else {
				label.textColor = [UIColor whiteColor];
			}

			
		} else {
			label.text = @"~~";
			label.textColor = [UIColor grayColor];
		}
	}
	
	
}

@end
