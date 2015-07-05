//
//  Utilities.m
//  CinemaCity
//
//  Created by Alex Studnicka on 27/03/14.
//  Copyright (c) 2014 Alex Studnicka. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

+ (NSString *)stringByStrippingHTML:(NSString *)html {
	NSRange r;
	NSString *s = [html copy];
	while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
		s = [s stringByReplacingCharactersInRange:r withString:@""];
	
	s = [s stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
	s = [s stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
	s = [s stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
	s = [s stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
	s = [s stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
	
	s = [s stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
	
	return s;
}

+ (NSString *)URLEscapeString:(NSString *)string {
	if (!string) return nil;
	return (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)string, NULL, CFSTR("!*'();:@&=+$,/?%#[]\" "), kCFStringEncodingUTF8);
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = CGRectZero;
	rect.size = size;
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
