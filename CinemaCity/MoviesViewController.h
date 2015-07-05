//
//  MoviesViewController.h
//  CinemaCity
//
//  Created by Alex Studnicka on 27/03/14.
//  Copyright (c) 2014 Alex Studnicka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMPickerViewController.h"

@interface MoviesViewController : UICollectionViewController <UIPickerViewDataSource, UIPickerViewDelegate>

- (IBAction)changeCategory;

@end
