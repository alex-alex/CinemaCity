//
//  ScheduleCell.h
//  CinemaCity
//
//  Created by Alex Studnicka on 27/03/14.
//  Copyright (c) 2014 Alex Studnicka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TintColorSelectionCell.h"

@interface ScheduleCell : TintColorSelectionCell {
	
	__weak IBOutlet UILabel *_nameLabel;
	__weak IBOutlet UILabel *_ratingLabel;
	__weak IBOutlet UILabel *_typeLabel;
	__weak IBOutlet UILabel *_versionLabel;
	__weak IBOutlet UILabel *_durationLabel;
	
}

- (void)setScheduleDict:(NSDictionary *)scheduleDict today:(BOOL)today;

@end
