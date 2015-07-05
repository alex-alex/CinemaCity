//
//  HistoryCell.m
//  CinemaCity
//
//  Created by Alex Studnicka on 31/03/14.
//  Copyright (c) 2014 Alex Studnicka. All rights reserved.
//

#import "HistoryCell.h"

@implementation HistoryCell

- (void)setHistoryDict:(NSDictionary *)historyDict {
	_historyDict = historyDict;
	
	_dateLabel.text = [historyDict[@"date"] isKindOfClass:NSDate.class] ? [API.sharedInstance.humanDateTimeFormatter stringFromDate:historyDict[@"date"]] : @"";
	_placeLabel.text = historyDict[@"place"];
	_itemLabel.text = [NSString stringWithFormat:@"%@ × %@", historyDict[@"quantity"], historyDict[@"name"]];
	_priceLabel.text = [historyDict[@"price"] length] ? [NSString stringWithFormat:@"%@ Kč", historyDict[@"price"]] : @"";
	_pointsLabel.text = [historyDict[@"points"] length] ? [NSString stringWithFormat:@"%@ b", historyDict[@"points"]] : @"";
	
}

@end
