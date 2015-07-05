//
//  MovieDetailPosterCell.h
//  CinemaCity
//
//  Created by Alex Studnicka on 27/03/14.
//  Copyright (c) 2014 Alex Studnicka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieDetailPosterCell : UITableViewCell {
	__weak IBOutlet UIImageView *_imageView;
	__weak IBOutlet UIButton *_trailerButton;
}

@property (nonatomic, strong) NSDictionary *infoDict;

- (IBAction)playTrailer;

@end
