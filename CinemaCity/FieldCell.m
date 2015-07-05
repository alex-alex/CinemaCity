//
//  FieldCell.m
//  CinemaCity
//
//  Created by Alex Studnicka on 16/04/14.
//  Copyright (c) 2014 Alex Studnicka. All rights reserved.
//

#import "FieldCell.h"

@implementation FieldCell

- (void)awakeFromNib {
//	_textField.textColor = AppDelegate.instance.window.tintColor;
	[_textField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
}

#pragma mark - Responder

- (BOOL)canBecomeFirstResponder {
	return [_textField canBecomeFirstResponder];
}

- (BOOL)becomeFirstResponder {
	return [_textField becomeFirstResponder];
}

- (BOOL)canResignFirstResponder {
	return [_textField canResignFirstResponder];
}

- (BOOL)resignFirstResponder {
	return [_textField resignFirstResponder];
}

- (BOOL)isFirstResponder {
	return [_textField isFirstResponder];
}

#pragma mark - Properties

- (void)setFieldCellType:(FieldCellType)fieldCellType {
	_fieldCellType = fieldCellType;

	NSString *placeholder;
	
	switch (fieldCellType) {
		case FieldCellTypeUsername:
			
			placeholder = NSLocalizedString(@"USERNAME", nil);
			_textField.returnKeyType = UIReturnKeyNext;
			
			break;
		case FieldCellTypePassword:
			
			placeholder = NSLocalizedString(@"PASSWORD", nil);
			_textField.secureTextEntry = YES;
			_textField.returnKeyType = UIReturnKeyDone;
			
			break;
		default:
			break;
	}
	
	_textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName: UIColor.lightGrayColor}];
	
}

- (NSString *)value {
	return _textField.text;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldChanged:(UITextField *)textField {
	if ([self.delegate respondsToSelector:@selector(textDidChangeInFieldCell:)]) {
		[self.delegate textDidChangeInFieldCell:self];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if ([self.delegate respondsToSelector:@selector(didReturnInFieldCell:)]) {
		[self.delegate didReturnInFieldCell:self];
	}
	return NO;
}

@end
