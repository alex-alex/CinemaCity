//
//  TicketCell.m
//  CinemaCity
//
//  Created by Alex Studnicka on 30/03/14.
//  Copyright (c) 2014 Alex Studnicka. All rights reserved.
//

#import "TicketCell.h"

@implementation TicketCell {
	NSString *_priceID;
}

#pragma mark - Setter

- (void)setPriceDict:(NSDictionary *)priceDict quantity:(int)quantity {
	_priceID = priceDict[@"nameID"];
	
	_nameLabel.text = priceDict[@"name"];
	_priceLabel.text = priceDict[@"price"];

	if (priceDict[@"charge"]) {
		_chargeLabel.text = [NSString stringWithFormat:@"+ %@", priceDict[@"charge"]];
	}
	
	_stepper.value = quantity;
	_quantityLabel.text = [NSString stringWithFormat:@"%d", quantity];
	
}

#pragma mark - Actions

- (IBAction)stepperValueChanged:(UIStepper *)sender {
	_quantityLabel.text = [NSString stringWithFormat:@"%d", (int)sender.value];
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(ticketCell:didChangeQuantity:forPriceID:)]) {
		[self.delegate ticketCell:self didChangeQuantity:sender.value forPriceID:_priceID];
	}
}

@end
