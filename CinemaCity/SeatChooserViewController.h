//
//  SeatChooserViewController.h
//  CinemaCity
//
//  Created by Alex Studnicka on 29/03/14.
//  Copyright (c) 2014 Alex Studnicka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SeatChooserViewController : UIViewController <UIScrollViewDelegate> {
	__weak IBOutlet UIScrollView *_scrollView;
}

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSDictionary *formInfo;
@property (nonatomic, strong) NSDictionary *tickets;

- (IBAction)continueAction;

@end
