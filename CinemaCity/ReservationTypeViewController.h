//
//  ReservationTypeViewController.h
//  CinemaCity
//
//  Created by Alex Studnicka on 29/03/14.
//  Copyright (c) 2014 Alex Studnicka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReservationTypeViewController : UIViewController {
	
	__weak IBOutlet UIButton *_reservationButton;
	__weak IBOutlet UIButton *_purchaseButton;
	
}

@property (nonatomic, strong) NSDictionary *URLtemplate;
@property (nonatomic, strong) NSString *presentationCode;

- (IBAction)reservation;
- (IBAction)purchase;

@end
