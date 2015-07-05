//
//  Utilities.h
//  CinemaCity
//
//  Created by Alex Studnicka on 27/03/14.
//  Copyright (c) 2014 Alex Studnicka. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NSNullIfNil(_obj) _obj == nil ? (id)[NSNull null] : _obj
#define EmptyStringIfNil(_obj) _obj == nil ? (id)@"" : _obj

@interface Utilities : NSObject

+ (NSString *)stringByStrippingHTML:(NSString *)html;
+ (NSString *)URLEscapeString:(NSString *)string;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

@end
