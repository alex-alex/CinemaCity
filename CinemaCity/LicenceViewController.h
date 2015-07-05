//
//  LicenceViewController.h
//  CinemaCity
//
//  Created by Alex Studnicka on 30/03/14.
//  Copyright (c) 2014 Alex Studnicka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LicenceViewController : UIViewController {
	
	__weak IBOutlet UITextView *_textField;
	
}

@property (nonatomic, strong) NSURL *ticketURL;

- (IBAction)continueAction;

@end
