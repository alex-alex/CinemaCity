//
//  SeatButton.m
//  CinemaCity
//
//  Created by Alex Studnicka on 29/03/14.
//  Copyright (c) 2014 Alex Studnicka. All rights reserved.
//

#import "SeatButton.h"

@implementation SeatButton {
	BOOL _choosed;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		[self setImage:[Utilities imageWithColor:UIColor.greenColor size:CGSizeMake(100, 100)] forState:UIControlStateNormal];
		[self setImage:[Utilities imageWithColor:UIColor.orangeColor size:CGSizeMake(100, 100)] forState:UIControlStateChoosed];
		[self setImage:[Utilities imageWithColor:UIColor.grayColor size:CGSizeMake(100, 100)] forState:UIControlStateDisabled];
    }
    return self;
}

- (void)setStatus:(int)status {
	_status = status;

	switch (status) {
		case 1:
			self.enabled = YES;
			_choosed = NO;
			break;
		case 3:
			self.enabled = YES;
			_choosed = YES;
			break;
		case 2:
		default:
			self.enabled = NO;
			self.selected = NO;
			break;
	}
	
	[self setNeedsLayout];
	[self setNeedsDisplay];
}

- (UIControlState)state {
	if (_choosed) {
		return super.state|UIControlStateChoosed;
	} else {
		return super.state;
	}
}

@end

