//
//  TintColorSelectionCell.m
//  CinemaCity
//
//  Created by Alex Studnicka on 31/03/14.
//  Copyright (c) 2014 Alex Studnicka. All rights reserved.
//

#import "TintColorSelectionCell.h"

@implementation TintColorSelectionCell

#pragma mark - Init

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
	
	UIView *bgColorView = [UIView new];
    bgColorView.backgroundColor = [AppDelegate.instance.window.tintColor colorWithAlphaComponent:0.5];
    bgColorView.layer.masksToBounds = YES;
    self.selectedBackgroundView = bgColorView;
	
}

@end
