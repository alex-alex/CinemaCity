//
//  FieldCell.h
//  CinemaCity
//
//  Created by Alex Studnicka on 16/04/14.
//  Copyright (c) 2014 Alex Studnicka. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	FieldCellTypeUsername,
	FieldCellTypePassword,
	FieldCellTypeOther
} FieldCellType;

@protocol FieldCellDelegate;

@interface FieldCell : UITableViewCell <UITextFieldDelegate> {
	IBOutlet UITextField *_textField;
}

@property (nonatomic) FieldCellType fieldCellType;
@property (nonatomic, weak) id <FieldCellDelegate> delegate;
@property (nonatomic, readonly) NSString *value;

@end

@protocol FieldCellDelegate <NSObject>

@optional
- (void)textDidChangeInFieldCell:(FieldCell *)cell;
- (void)didReturnInFieldCell:(FieldCell *)cell;

@end
