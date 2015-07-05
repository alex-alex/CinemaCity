//
//  MovieCell.m
//  CinemaCity
//
//  Created by Alex Studnicka on 27/03/14.
//  Copyright (c) 2014 Alex Studnicka. All rights reserved.
//

#import "MovieCell.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

@implementation MovieCell

- (void)setMovieDict:(NSDictionary *)movieDict {
	_movieDict = movieDict;

	_titleLabel.text = movieDict[@"czName"];
	
	NSURL *imageURL = [NSURL URLWithString:movieDict[@"imageURL"]];
	dispatch_async(dispatch_get_main_queue(), ^{
		[_imageView setImageWithURL:imageURL usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	});
}

@end
