//
//  ReservationInputViewController.h
//  CinemaCity
//
//  Created by Alex Studnicka on 29/03/14.
//  Copyright (c) 2014 Alex Studnicka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReservationInputViewController : UITableViewController

@property (nonatomic, strong) NSString *cinemaID;
@property (nonatomic, strong) NSString *venueTypeID;
@property (nonatomic, strong) NSString *featureCode;
@property (nonatomic, strong) NSURL *detailURL;
@property (nonatomic, strong) NSDate *date;

@end
