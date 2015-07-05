//
//  OrderViewController.h
//  CinemaCity
//
//  Created by Alex Studnicka on 31/03/14.
//  Copyright (c) 2014 Alex Studnicka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderViewController : UIViewController <UITextFieldDelegate> {
	
	__weak IBOutlet UIScrollView *_scrollView;
	
	__weak IBOutlet UITextField *_nameField;
	__weak IBOutlet UITextField *_surnameField;
	__weak IBOutlet UITextField *_emailField;
	__weak IBOutlet UITextField *_phoneField;
	__weak IBOutlet UITextField *_captchaField;
	
	__weak IBOutlet UIImageView *_captchaImageView;
	
	IBOutlet UIBarButtonItem *_continueButton;
	IBOutlet UIBarButtonItem *_doneButton;
	
}

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSDictionary *formInfo;
@property (nonatomic, strong) NSArray *seats;

@end
