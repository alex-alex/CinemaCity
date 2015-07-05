//
//  MovieCell.h
//  CinemaCity
//
//  Created by Alex Studnicka on 27/03/14.
//  Copyright (c) 2014 Alex Studnicka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieCell : UICollectionViewCell {
	
	__weak IBOutlet UIImageView *_imageView;
	__weak IBOutlet UILabel *_titleLabel;
	
}

@property (nonatomic, strong) NSDictionary *movieDict;

@end
