//
//  TicketCell.h
//  CinemaCity
//
//  Created by Alex Studnicka on 30/03/14.
//  Copyright (c) 2014 Alex Studnicka. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TicketCellDelegate;

@interface TicketCell : UITableViewCell {
	
	__weak IBOutlet UILabel *_nameLabel;
	__weak IBOutlet UILabel *_priceLabel;
	__weak IBOutlet UILabel *_chargeLabel;
	__weak IBOutlet UILabel *_quantityLabel;
	__weak IBOutlet UIStepper *_stepper;
	
}

@property (nonatomic, strong) id<TicketCellDelegate> delegate;

- (void)setPriceDict:(NSDictionary *)priceDict quantity:(int)quantity;

- (IBAction)stepperValueChanged:(UIStepper *)sender;

@end

@protocol TicketCellDelegate <NSObject>
@optional

- (void)ticketCell:(TicketCell *)cell didChangeQuantity:(int)quantity forPriceID:(NSString *)priceID;

@end
