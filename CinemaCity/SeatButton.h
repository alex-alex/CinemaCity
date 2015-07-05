//
//  SeatButton.h
//  CinemaCity
//
//  Created by Alex Studnicka on 29/03/14.
//  Copyright (c) 2014 Alex Studnicka. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UIControlStateChoosed 1 << 16

@interface SeatButton : UIButton

@property (nonatomic) int status;
@property (nonatomic, strong) NSIndexPath *place;

@end
