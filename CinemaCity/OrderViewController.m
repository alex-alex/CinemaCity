//
//  OrderViewController.m
//  CinemaCity
//
//  Created by Alex Studnicka on 31/03/14.
//  Copyright (c) 2014 Alex Studnicka. All rights reserved.
//

#import "OrderViewController.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "CinemaCity-Swift.h"

@implementation OrderViewController {
	
	NSURL *_url;
	NSDictionary *_formInfo;
	
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.view.backgroundColor = UIColor.blackColor;
	
	self.navigationItem.title = NSLocalizedString(@"ORDER", nil);
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BACK", nil) style:UIBarButtonItemStyleBordered target:nil action:NULL];
	
	UIImageView *bgLogoImageView = [UIImageView new];
	bgLogoImageView.frame = CGRectMake(0, 138+56, 320, 180);
	bgLogoImageView.image = [UIImage imageNamed:@"bg_logo.png"];
	bgLogoImageView.contentMode = UIViewContentModeCenter;
	[self.view addSubview:bgLogoImageView];
	[self.view sendSubviewToBack:bgLogoImageView];
	
	_scrollView.contentInset = UIEdgeInsetsMake(64, 0, 49, 0);
	_scrollView.scrollIndicatorInsets = _scrollView.contentInset;
	
	[API.sharedInstance selectSeatsWithURL:self.url formInfo:self.formInfo seats:self.seats completionHandler:^(NSURL *url, NSDictionary *formInfo, NSDate *expirationDate, NSURL *captchaURL) {
		_url = url;
		_formInfo = formInfo;
		
		NSLog(@"expirationDate: %@", expirationDate);
		
	} captchaHandler:^(UIImage *captcha) {
		_captchaImageView.image = captcha;
	}];
	
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	if (_nameField.isFirstResponder) {
		[_surnameField becomeFirstResponder];
		return NO;
	}
	
	if (_surnameField.isFirstResponder) {
		[_emailField becomeFirstResponder];
		return NO;
	}
	
	if (_emailField.isFirstResponder) {
		[_phoneField becomeFirstResponder];
		return NO;
	}
	
	if (_phoneField.isFirstResponder) {
		[_captchaField becomeFirstResponder];
		return NO;
	}
	
	if (_captchaField.isFirstResponder) {
		[_captchaField resignFirstResponder];
		return NO;
	}
	
	return YES;
	
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
//	UIScrollView *scrollView =  (UIScrollView *)self.view;
	if ([textField isEqual:_captchaField]) {
		[_scrollView setContentOffset:CGPointMake(0, -_scrollView.contentInset.top+textField.frame.origin.y-(48+53+8)) animated:YES];
	} else {
		[_scrollView setContentOffset:CGPointMake(0, -_scrollView.contentInset.top+textField.frame.origin.y-48) animated:YES];
	}
	
	self.navigationItem.rightBarButtonItem = _doneButton;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
//	UIScrollView *scrollView =  (UIScrollView *)self.view;
	[_scrollView setContentOffset:CGPointMake(0, -_scrollView.contentInset.top) animated:YES];
	
	self.navigationItem.rightBarButtonItem = _continueButton;
}

#pragma mark - Actions

- (IBAction)done {

	if (_nameField.isFirstResponder) {
		[_nameField resignFirstResponder];
		return;
	}
	
	if (_surnameField.isFirstResponder) {
		[_surnameField resignFirstResponder];
		return;
	}
	
	if (_emailField.isFirstResponder) {
		[_emailField resignFirstResponder];
		return;
	}
	
	if (_phoneField.isFirstResponder) {
		[_phoneField resignFirstResponder];
		return;
	}
	
	if (_captchaField.isFirstResponder) {
		[_captchaField resignFirstResponder];
		return;
	}
	
}

- (IBAction)continueAction {

	self.navigationItem.rightBarButtonItem.enabled = NO;
	
	[API.sharedInstance sendOrderWithURL:_url formInfo:_formInfo name:_nameField.text surname:_surnameField.text email:_emailField.text phone:_phoneField.text captcha:_captchaField.text completionHandler:^(NSURL *url, NSDictionary *formInfo) {
	
		self.navigationItem.rightBarButtonItem.enabled = YES;
		
		UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
		RecapitulationViewController *recapitulationVC = [storyboard instantiateViewControllerWithIdentifier:@"RecapitulationViewController"];
//		recapitulationVC.url = _url;
//		recapitulationVC.formInfo = _formInfo;
//		recapitulationVC.seats = _selectedSeats;
		[self.navigationController pushViewController:recapitulationVC animated:YES];
		
	}];
	
}

@end
