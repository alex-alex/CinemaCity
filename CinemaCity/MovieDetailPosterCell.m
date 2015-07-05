//
//  MovieDetailPosterCell.m
//  CinemaCity
//
//  Created by Alex Studnicka on 27/03/14.
//  Copyright (c) 2014 Alex Studnicka. All rights reserved.
//

#import "MovieDetailPosterCell.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "XCDYouTubeVideoPlayerViewController.h"
#import "MovieDetailViewController.h"

@implementation MovieDetailPosterCell

- (void)setInfoDict:(NSDictionary *)infoDict {
	_infoDict = infoDict;
	
	NSURL *imageURL = [NSURL URLWithString:infoDict[@"imageURL"]];
	[_imageView setImageWithURL:imageURL usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	
	[FAKFontAwesome playIconWithSize:25];
	
	_trailerButton.hidden = !(_infoDict[@"trailerYoutubeID"]);
}

#pragma mark - Actions

- (IBAction)playTrailer {
	
	id view = [self superview];
	while (view && ![view isKindOfClass:UITableView.class]) {
		view = [view superview];
	}
    UITableView *tableView = (UITableView *)view;
	MovieDetailViewController *movieDetailVC = (MovieDetailViewController *)tableView.delegate;
	
	XCDYouTubeVideoPlayerViewController *youtubeVC = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:_infoDict[@"trailerYoutubeID"]];
	youtubeVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	[movieDetailVC presentViewController:youtubeVC animated:YES completion:NULL];
	
}

@end
