//
//  SeatChooserViewController.m
//  CinemaCity
//
//  Created by Alex Studnicka on 29/03/14.
//  Copyright (c) 2014 Alex Studnicka. All rights reserved.
//

#import "SeatChooserViewController.h"
#import "SeatButton.h"
#import "OrderViewController.h"

@implementation SeatChooserViewController {
	
	UIView *_contentView;
	
	NSURL *_url;
	NSDictionary *_formInfo;
	int _total;
	NSMutableArray *_selectedSeats;
	
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.view.backgroundColor = UIColor.blackColor;
	
	self.navigationItem.title = NSLocalizedString(@"CHOOSE_SEATS", nil);
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BACK", nil) style:UIBarButtonItemStyleBordered target:nil action:NULL];
	self.navigationItem.rightBarButtonItem.enabled = NO;
	
	UIImageView *bgLogoImageView = [UIImageView new];
	bgLogoImageView.alpha = 0.2;
	bgLogoImageView.frame = CGRectMake(0, 0, 320, 180);
	bgLogoImageView.center = self.view.center;
	bgLogoImageView.image = [UIImage imageNamed:@"bg_logo.png"];
	bgLogoImageView.contentMode = UIViewContentModeCenter;
	[self.view addSubview:bgLogoImageView];
	[self.view sendSubviewToBack:bgLogoImageView];
	
//	_scrollView.contentInset = UIEdgeInsetsMake(64, 0, 49, 0);
//	_scrollView.scrollIndicatorInsets = _scrollView.contentInset;
	
	_contentView = [UIView new];
//	_contentView.backgroundColor = [UIColor blackColor];
//	_contentView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1.0];
	[_scrollView addSubview:_contentView];
	
	[API.sharedInstance loadSelectTicketsWithURL:self.url formInfo:self.formInfo tickets:self.tickets completionHandler:^(NSURL *url, NSDictionary *formInfo, NSArray *seats, CGSize seatSize) {
		
		_url = url;
		_formInfo = formInfo;
		
		_total = 0;
		for (NSString *quantity in self.tickets.allValues) _total += quantity.intValue;
		
		_selectedSeats = [NSMutableArray arrayWithCapacity:_total];
		self.navigationItem.rightBarButtonItem.enabled = NO;
		
		CGFloat minX = CGFLOAT_MAX, maxX = 0, minY = CGFLOAT_MAX, maxY = 0;
		for (NSArray *row in seats) {
			for (NSDictionary *seat in row) {
				CGFloat top = [seat[@"top"] floatValue];
				CGFloat left = [seat[@"left"] floatValue];
				minX = MIN(minX, left);
				maxX = MAX(maxX, left);
				minY = MIN(minY, top);
				maxY = MAX(maxY, top);
			}
		}
		maxX += seatSize.width;
		maxY += seatSize.height;
		
		CGFloat scale = _scrollView.frame.size.width/(20+maxX-minX);
		
		CGFloat startY = (_scrollView.frame.size.height-(20+maxY-minY)*scale);
		
		_scrollView.contentSize = CGSizeMake((20+maxX-minX)*scale, startY+(20+maxY-minY)*scale);
		_scrollView.maximumZoomScale = 44./(seatSize.width*scale);
		
		[_contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
		_contentView.frame = CGRectMake(0, 0, _scrollView.contentSize.width, _scrollView.contentSize.height);
		
		UIView *platno = [UIView new];
		platno.frame = CGRectMake(5*scale, (startY-minY*2-6)*scale, _scrollView.contentSize.width-10*scale, 2);
		platno.backgroundColor = UIColor.blueColor;
		[_contentView addSubview:platno];
		
//		NSLog(@"seats: %@", seats);
		
		for (NSArray *row in seats) {
			for (NSDictionary *seat in row) {
				
				CGFloat top = [seat[@"top"] floatValue]+startY-minY*2;
				CGFloat left = [seat[@"left"] floatValue]-minX+10;
				
				NSUInteger placeVals[2] = {[seat[@"row"] unsignedIntegerValue], [seat[@"col"] unsignedIntegerValue]};
				NSIndexPath *place = [NSIndexPath indexPathWithIndexes:placeVals length:2];
				
				int status = [seat[@"status"] intValue];
				
				SeatButton *seatView = [SeatButton buttonWithType:UIButtonTypeCustom];
				seatView.frame = CGRectMake(left*scale, top*scale, seatSize.width*scale, seatSize.height*scale);
				seatView.status = status;
				seatView.place = place;
				[seatView addTarget:self action:@selector(seatButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
				[_contentView addSubview:seatView];
				
			}
		}
		
	}];
	
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return _contentView;
}

- (NSArray*)findAllViewsToScale:(UIView*)parentView {
	NSMutableArray* views = [NSMutableArray array];
	for (id view in parentView.subviews) {
		if ([view isKindOfClass:UIButton.class]) {
			[views addObject:view];
		} else if ([view respondsToSelector:@selector(subviews)]) {
			[views addObjectsFromArray:[self findAllViewsToScale:view]];
		}
	}
	return views;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
	CGFloat contentScale = scale * UIScreen.mainScreen.scale;
	NSArray *views = [self findAllViewsToScale:_contentView];
	for (UIView *view in views) {
		view.contentScaleFactor = contentScale;
	}
}

#pragma mark - Actions

- (IBAction)seatButtonPressed:(SeatButton *)sender {
	if (sender.status == 1 && _selectedSeats.count < _total) {
		[_selectedSeats addObject:sender.place];
		sender.status = 3;
	} else if (sender.status == 3) {
		[_selectedSeats removeObject:sender.place];
		sender.status = 1;
	}
	
	self.navigationItem.rightBarButtonItem.enabled = (_selectedSeats.count == _total);
}

- (IBAction)continueAction {
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
	OrderViewController *orderVC = [storyboard instantiateViewControllerWithIdentifier:@"OrderViewController"];
	orderVC.url = _url;
	orderVC.formInfo = _formInfo;
	orderVC.seats = _selectedSeats;
	[self.navigationController pushViewController:orderVC animated:YES];
}

@end
