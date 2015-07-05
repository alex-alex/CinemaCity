//
//  Presentations.h
//  CinemaCity
//
//  Created by Alex Studnicka on 29/03/14.
//  Copyright (c) 2014 Alex Studnicka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Presentations : NSObject

+ (instancetype)presentationsWithDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (NSArray *)sites;
- (NSString *)siteNameForSiteCode:(NSString *)siteCode;
- (NSString *)movieNameForSite:(NSString *)siteCode;
- (NSDictionary *)templateForSite:(NSString *)siteCode;
- (NSArray *)presentationsAtSite:(NSString *)siteCode date:(NSDate *)date;
- (NSArray *)presentationTypeNamesAtSite:(NSString *)siteCode date:(NSDate *)date;

@end
