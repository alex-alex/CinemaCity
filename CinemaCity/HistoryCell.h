//
//  HistoryCell.h
//  CinemaCity
//
//  Created by Alex Studnicka on 31/03/14.
//  Copyright (c) 2014 Alex Studnicka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryCell : UITableViewCell {
	
	__weak IBOutlet UILabel *_dateLabel;
	__weak IBOutlet UILabel *_placeLabel;
	__weak IBOutlet UILabel *_itemLabel;
	__weak IBOutlet UILabel *_priceLabel;
	__weak IBOutlet UILabel *_pointsLabel;
	
}

@property (nonatomic, strong) NSDictionary *historyDict;

@end
