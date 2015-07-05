//
//  Presentations.m
//  CinemaCity
//
//  Created by Alex Studnicka on 29/03/14.
//  Copyright (c) 2014 Alex Studnicka. All rights reserved.
//

#import "Presentations.h"

@implementation Presentations {
	NSDictionary *_dictionary;
}

#pragma mark - Init

+ (instancetype)presentationsWithDictionary:(NSDictionary *)dictionary {
	return [[Presentations alloc] initWithDictionary:dictionary];
}

- (instancetype)init {
    return [self initWithDictionary:nil];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _dictionary = dictionary;
    }
    return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ %@", super.description, _dictionary.description];
}

#pragma mark - Getters

- (NSArray *)sites {
	NSMutableArray *sites = [NSMutableArray arrayWithCapacity:[(NSArray *)_dictionary[@"sites"] count]];
	for (NSDictionary *site in _dictionary[@"sites"]) {
		[sites addObject:@{
			@"code": [site[@"si"] stringValue],
			@"name": site[@"sn"],
		}];
	}
	return sites;
}

- (NSString *)siteNameForSiteCode:(NSString *)siteCode {
	for (NSDictionary *site in _dictionary[@"sites"]) {
		if ([[site[@"si"] stringValue] isEqualToString:siteCode]) {
			return site[@"sn"];
		}
	}
	return nil;
}

- (NSString *)movieNameForSite:(NSString *)siteCode {
	for (NSDictionary *site in _dictionary[@"sites"]) {
		if ([[site[@"si"] stringValue] isEqualToString:siteCode]) {
			return [site[@"fe"] firstObject][@"fn"];
		}
	}
	return nil;
}

- (NSDictionary *)templateForSite:(NSString *)siteCode {
	for (NSDictionary *site in _dictionary[@"sites"]) {
		if ([[site[@"si"] stringValue] isEqualToString:siteCode]) {
			NSError *error;
			NSDictionary *template = [NSJSONSerialization JSONObjectWithData:[(NSString *)site[@"tu"] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
			if (error) NSLog(@"Error: %@", error); error = nil;
			return template;
		}
	}
	return nil;
}

- (NSArray *)presentationsAtSite:(NSString *)siteCode date:(NSDate *)date {
	for (NSDictionary *site in _dictionary[@"sites"]) {
		if ([[site[@"si"] stringValue] isEqualToString:siteCode]) {
			NSArray *allPresentations = [site[@"fe"] firstObject][@"pr"];
			int lang = [[site[@"fe"] firstObject][@"ol"] intValue];
			NSString *selectedDate = date ? [API.sharedInstance.dateFormatter stringFromDate:date] : nil;
			NSMutableArray *presentations = [NSMutableArray arrayWithCapacity:allPresentations.count];
			for (NSDictionary *presentation in allPresentations) {
				NSString *dateStr = [[presentation[@"dt"] componentsSeparatedByString:@" "] firstObject];
				if (!selectedDate || [dateStr isEqualToString:selectedDate]) {
					
					NSMutableDictionary *presentationDict = [NSMutableDictionary dictionaryWithCapacity:6];
					
					presentationDict[@"code"] = presentation[@"pc"];
					presentationDict[@"date"] = dateStr;
					presentationDict[@"time"] = presentation[@"tm"];
					
					int venueType = presentation[@"vt"] ? [presentation[@"vt"] intValue] : -1;
					if (venueType > 0 && [_dictionary[@"venueTypes"] count] > venueType) {
						presentationDict[@"venueType"] = _dictionary[@"venueTypes"][venueType];
					}
					
					int threeD = presentation[@"td"] ? [presentation[@"td"] intValue] : 0;
					if (threeD > 0) presentationDict[@"3D"] = @((BOOL)threeD);
					
					int exp = presentation[@"exp"] ? [presentation[@"ex"] intValue] : -1;
					if (exp > 0) presentationDict[@"expired"] = @((BOOL)exp);
					
					int dub = presentation[@"db"] ? [presentation[@"db"] intValue] : -1;
					if (dub > 0) presentationDict[@"dub"] = _dictionary[@"languages"][dub];
					
					int sub = presentation[@"sb"] ? [presentation[@"sb"] intValue] : -1;
					if (sub > 0) presentationDict[@"sub"] = _dictionary[@"languages"][sub];
					
					NSMutableString *name = [NSMutableString string];
					[name appendString:(threeD >= 0) ? (threeD ? @"3D " : @"2D ") : @""];
					if (dub >= 0) [name appendFormat:@"Dabing "];
					if (sub >= 0) [name appendFormat:@"Titulky "];
					if (sub < 0 && dub < 0 && lang >= 0) [name appendFormat:@"%@ ", _dictionary[@"languages"][lang]];
					presentationDict[@"name"] = [name stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
					
					[presentations addObject:presentationDict];
					
				}
			}
			return presentations;
		}
	}
	return nil;
}

- (NSArray *)presentationTypeNamesAtSite:(NSString *)siteCode date:(NSDate *)date {
	NSArray *presentations = [self presentationsAtSite:siteCode date:date];
	NSMutableArray *presentationTypeNames = [NSMutableArray arrayWithCapacity:presentations.count];
	for (NSDictionary *presentation in presentations) {
		[presentationTypeNames addObject:presentation[@"name"]];
	}
	return presentationTypeNames;
}

@end
