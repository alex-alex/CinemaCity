//
//  API.m
//  CinemaCity
//
//  Created by Alex Studnicka on 27/03/14.
//  Copyright (c) 2014 Alex Studnicka. All rights reserved.
//

#import "API.h"
#import "TFHpple.h"

@implementation API

#pragma mark - Init

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static API * __sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [self new];
    });
    return __sharedInstance;
}

- (id)init {
    self = [super init];
	if (self) {
		
		_networkQueue = [NSOperationQueue new];
		_networkQueue.name = @"Network Queue";
		
		_dateFormatter = [NSDateFormatter new];
		_dateFormatter.dateFormat = @"dd/MM/yyyy";
		
		_timeFormatter = [NSDateFormatter new];
		_timeFormatter.dateFormat = @"HH:mm";
		
		_humanDateFormatter = [NSDateFormatter new];
		_humanDateFormatter.dateStyle = NSDateFormatterFullStyle;
		
		_humanDateTimeFormatter = [NSDateFormatter new];
		_humanDateTimeFormatter.dateStyle = NSDateFormatterLongStyle;
		_humanDateTimeFormatter.timeStyle = NSDateFormatterShortStyle;
		
	}
    return self;
}

#pragma mark - Login

- (void)loginUser:(NSString *)username password:(NSString *)password completionHandler:(void (^)(NSDictionary *userInfo))handler {
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://cinemacity.cz/titanLogin"]];
	
	NSDictionary *options = @{
		@"username": EmptyStringIfNil(username),
		@"password": EmptyStringIfNil(password),
	};
	
	NSMutableString *requestString = [NSMutableString string];
	[options enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
		[requestString appendFormat:@"%@=%@&", key, [Utilities URLEscapeString:obj]];
	}];
	
	request.HTTPMethod = @"POST";
	request.HTTPBody = [[requestString substringToIndex:requestString.length-1] dataUsingEncoding:NSUTF8StringEncoding];
	
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	
	[NSURLConnection sendAsynchronousRequest:request queue:self.networkQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
		
		if (connectionError) NSLog(@"Connection Error: %@", connectionError);
		
		if (!data || data.length <= 0) {
			
			if (handler) {
				dispatch_async(dispatch_get_main_queue(), ^{
					handler(nil);
				});
			}
			
			return;
		}
		
		NSError *error;
		NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
		if (error) NSLog(@"Error: %@", error); error = nil;
		
		if (handler) {
			dispatch_async(dispatch_get_main_queue(), ^{
				handler(responseDict);
			});
		}
		
	}];
	
}

- (void)logoutUserWithCompletionHandler:(void (^)(BOOL success))handler {

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://cinemacity.cz/logoutMembership"]];
	
	[NSURLConnection sendAsynchronousRequest:request queue:self.networkQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
		
		if (connectionError) NSLog(@"Connection Error: %@", connectionError);
		
		if (!data || data.length <= 0) {
			
			if (handler) {
				dispatch_async(dispatch_get_main_queue(), ^{
					handler(NO);
				});
			}
			
			return;
		}
		
		NSError *error;
		NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
		if (error) NSLog(@"Error: %@", error); error = nil;
		
		if (handler) {
			dispatch_async(dispatch_get_main_queue(), ^{
				handler([responseDict[@"success"] boolValue]);
			});
		}
		
	}];
	
}

#pragma mark - History

- (void)loadHistoryWithCompletionHandler:(void (^)(NSArray *history))handler {
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://cinemacity.cz/titanHistory"]];
	
	[NSURLConnection sendAsynchronousRequest:request queue:self.networkQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
		
		if (connectionError) NSLog(@"Connection Error: %@", connectionError);
		
		if (!data || data.length <= 0) {
			
			if (handler) {
				dispatch_async(dispatch_get_main_queue(), ^{
					handler(nil);
				});
			}
			
			return;
		}
		
		NSDateFormatter *dateFormatter = [NSDateFormatter new];
		dateFormatter.dateFormat = @"HH:mm dd/MM/yyyy";
		
		TFHpple *resultParser = [TFHpple hppleWithHTMLData:data];
		NSArray *rows = [resultParser searchWithXPathQuery:@"//tr[contains(concat(' ', normalize-space(@class), ' '), ' trans ')]"];
		NSMutableArray *history = [NSMutableArray arrayWithCapacity:rows.count];
		for (TFHppleElement *row in rows) {
			
			NSArray *cells = [row childrenWithTagName:@"td"];
			
			[history addObject:@{
				@"date": NSNullIfNil([dateFormatter dateFromString:[cells[0] strippedRaw]]),
				@"place": EmptyStringIfNil([cells[1] strippedRaw]),
				@"type": EmptyStringIfNil([cells[2] strippedRaw]),
				@"quantity": EmptyStringIfNil([cells[3] strippedRaw]),
				@"name": EmptyStringIfNil([cells[4] strippedRaw]),
				@"price": EmptyStringIfNil([cells[5] strippedRaw]),
				@"points": EmptyStringIfNil([cells[6] strippedRaw]),
			}];
			
		}
		
		if (handler) {
			dispatch_async(dispatch_get_main_queue(), ^{
				handler(history);
			});
		}
		
	}];
	
}

#pragma mark - Movies

- (void)getMoviesWithCompletionHandler:(void (^)(NSArray *movies))handler {
	
	NSRegularExpression *catRegex = [NSRegularExpression regularExpressionWithPattern:@"cat_(\\d*)" options:0 error:NULL];
	
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://cinemacity.cz/loadFunction?layoutId=100&layerId=1&exportCode=movies_filter"]];
	[NSURLConnection sendAsynchronousRequest:request queue:self.networkQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
		
		if (connectionError) NSLog(@"Connection Error: %@", connectionError);
		
		if (!data || data.length <= 0) {
			
			if (handler) {
				dispatch_async(dispatch_get_main_queue(), ^{
					handler(nil);
				});
			}
			
			return;
		}
		
		TFHpple *resultParser = [TFHpple hppleWithHTMLData:data];
		NSArray *movieElements = [resultParser searchWithXPathQuery:@"//*[contains(concat(' ', normalize-space(@class), ' '), ' poster ')]"];
		NSMutableArray *movies = [NSMutableArray arrayWithCapacity:movieElements.count];
		for (TFHppleElement *movie in movieElements) {
			
			NSString *class = movie[@"class"];
			NSInteger category = NSNotFound;
			NSTextCheckingResult *result = [catRegex firstMatchInString:class options:0 range:NSMakeRange(0, class.length)];
			if (result) {
				category = [[class substringWithRange:[result rangeAtIndex:1]] integerValue];
			}
			
			TFHppleElement *link = [movie firstChildWithTagName:@"a"];
			
			TFHppleElement *featureMoreInfo = [[link firstChildWithTagName:@"div"] firstChildWithClassName:@"featureMoreInfo"];
			TFHppleElement *featureName = [featureMoreInfo firstChildWithClassName:@"featureName"];
			TFHppleElement *featureAltName = [featureMoreInfo firstChildWithClassName:@"featureAltName"];
			TFHppleElement *featurePrimer = [featureMoreInfo firstChildWithClassName:@"featurePrimer"];
			
			TFHppleElement *image = [[link firstChildWithTagName:@"div"] firstChildWithTagName:@"img"];
			
			NSDate *date = [self.dateFormatter dateFromString:featurePrimer.text];
			date = [date dateByAddingTimeInterval:12*3600];
			
			[movies addObject:@{
				@"category": @(category),
				@"code": EmptyStringIfNil(link[@"data-code"]),
				@"czName": EmptyStringIfNil(featureName.text),
				@"enName": EmptyStringIfNil(featureAltName.text),
				@"date": EmptyStringIfNil(date),
				@"imageURL": EmptyStringIfNil(image[@"data-src"])
			}];
			
		}
		
		if (handler) {
			dispatch_async(dispatch_get_main_queue(), ^{
				handler(movies);
			});
		}
		
	}];
	
}

#pragma mark - Schedule

- (void)getScheduleForCinema:(NSString *)cinemaID venueTypeID:(NSString *)venueTypeID date:(NSDate *)date completionHandler:(void (^)(NSArray *schedule))handler {
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://cinemacity.cz/scheduleInfoRows"]];
	
	NSDictionary *options = @{
		@"date": [self.dateFormatter stringFromDate:date],
		@"locationId": cinemaID,
		@"venueTypeId": venueTypeID,
	};
	
	NSMutableString *requestString = [NSMutableString string];
	[options enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
		[requestString appendFormat:@"%@=%@&", key, [Utilities URLEscapeString:obj]];
	}];
	
	request.HTTPMethod = @"POST";
	request.HTTPBody = [[requestString substringToIndex:requestString.length-1] dataUsingEncoding:NSUTF8StringEncoding];
	
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	
	[NSURLConnection sendAsynchronousRequest:request queue:self.networkQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
		
		if (connectionError) NSLog(@"Connection Error: %@", connectionError);
		
		if (!data || data.length <= 0) {
			
			if (handler) {
				dispatch_async(dispatch_get_main_queue(), ^{
					handler(nil);
				});
			}
			
			return;
		}
		
		TFHpple *resultParser = [TFHpple hppleWithHTMLData:data];
		NSArray *rows = [resultParser searchWithXPathQuery:@"//tbody/tr"];
		NSMutableArray *movies = [NSMutableArray arrayWithCapacity:rows.count];
		for (TFHppleElement *row in rows) {
			
			NSArray *cells = [row childrenWithTagName:@"td"];
			
			NSMutableArray *presentations = [NSMutableArray arrayWithCapacity:8];
			for (TFHppleElement *cell in cells) {
				if ([cell[@"class"] rangeOfString:@"prsnt"].location != NSNotFound && [cell[@"class"] rangeOfString:@"noDisplay"].location == NSNotFound) {
					if (cell.strippedRaw.length > 0) {
						NSString *time = cell.strippedRaw;
						time = [time stringByReplacingOccurrencesOfString:@"IMAX" withString:@""];
						time = [time stringByReplacingOccurrencesOfString:@"4DX" withString:@""];
						[presentations addObject:time];
					} else {
						[presentations addObject:NSNull.null];
					}
				}
			}
			
			TFHppleElement *link = [cells[0] firstChildWithTagName:@"a"];
			
			if (cells.count >= 4) {
				[movies addObject:@{
					@"name": EmptyStringIfNil([cells[0] strippedRaw]),
					@"code": EmptyStringIfNil(link[@"data-feature_code"]),
					@"detailURL": NSNullIfNil([NSURL URLWithString:link[@"href"] relativeToURL:[NSURL URLWithString:@"http://cinemacity.cz/"]]),
					@"rating": EmptyStringIfNil([cells[1] strippedRaw]),
					@"type": EmptyStringIfNil([cells[2] strippedRaw]),
					@"version": EmptyStringIfNil([cells[3] strippedRaw]),
					@"duration": @([[cells[4] strippedRaw] integerValue]),
					@"presentations": presentations
				}];
			}
			
		}
		
		if (handler) {
			dispatch_async(dispatch_get_main_queue(), ^{
				handler(movies);
			});
		}
		
	}];
	
}

- (void)getPresentationsForURL:(NSURL *)url completionHandler:(void (^)(Presentations *presentations))handler {
	
	[self getDetailOfMovieWithURL:url completionHandler:^(NSDictionary *movieDetail) {
		
		NSString *distributionCode = movieDetail[@"attributes"][@"feature"][@"dc"];
		
		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://cinemacity.cz/presentationsJSON?subSiteId=0&venueTypeId=0&distribCode=%@&showExpired=true&filter=null", distributionCode]]];
		[NSURLConnection sendAsynchronousRequest:request queue:self.networkQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
			
			if (connectionError) NSLog(@"Connection Error: %@", connectionError);
			
			if (!data || data.length <= 0) {
				
				if (handler) {
					dispatch_async(dispatch_get_main_queue(), ^{
						handler(nil);
					});
				}
				
				return;
			}
			
			NSError *error;
			NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
			if (error) NSLog(@"Error: %@", error); error = nil;
			
			if (handler) {
				dispatch_async(dispatch_get_main_queue(), ^{
					handler([Presentations presentationsWithDictionary:responseDict]);
				});
			}
			
		}];
		
	}];
	
}

#pragma mark - Movie Detail

- (void)getDetailOfMovieWithFeatureCode:(NSString *)featureCode completionHandler:(void (^)(NSDictionary *movieDetail))handler {
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://cinemacity.cz/featureInfo?featureCode=%@", featureCode]];
	[self getDetailOfMovieWithURL:url completionHandler:handler];
}

- (void)getDetailOfMovieWithURL:(NSURL *)url completionHandler:(void (^)(NSDictionary *movieDetail))handler {
	
	NSRegularExpression *youtubeRegex = [NSRegularExpression regularExpressionWithPattern:@"/([^/?]*)\\?" options:0 error:NULL];
	NSRegularExpression *jsonRegex = [NSRegularExpression regularExpressionWithPattern:@"presentationSelect\\(([^\\)]*)\\);" options:0 error:NULL];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	
	[NSURLConnection sendAsynchronousRequest:request queue:self.networkQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
		
		if (connectionError) NSLog(@"Connection Error: %@", connectionError);
		
		if (!data || data.length <= 0) {
			
			if (handler) {
				dispatch_async(dispatch_get_main_queue(), ^{
					handler(nil);
				});
			}
			
			return;
		}
		
		NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:12];
		NSTextCheckingResult *result;
		
		NSString *resultString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		result = [jsonRegex firstMatchInString:resultString options:0 range:NSMakeRange(0, resultString.length)];
		NSString *jsonString = [resultString substringWithRange:[result rangeAtIndex:1]];
		
		NSError *error;
		NSDictionary *attributes = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
		if (error) NSLog(@"Error: %@", error); error = nil;
		if (!attributes) attributes = @{};
		info[@"attributes"] = attributes;
		
		TFHpple *resultParser = [TFHpple hppleWithHTMLData:data];
		
		TFHppleElement *nameEl = [resultParser peekAtSearchWithXPathQuery:@"//*[contains(concat(' ', normalize-space(@class), ' '), ' feature_info_title ')]"];
		info[@"name"] = EmptyStringIfNil([nameEl strippedRaw]);
		
		TFHppleElement *synopsisEl = [resultParser peekAtSearchWithXPathQuery:@"//*[contains(concat(' ', normalize-space(@class), ' '), ' feature_info_synopsis ')]"];
		NSString *synopsis = [synopsisEl raw];
		synopsis = [synopsis stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
		synopsis = [synopsis stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
		synopsis = [synopsis stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
		synopsis = [Utilities stringByStrippingHTML:synopsis];
		info[@"synopsis"] = EmptyStringIfNil(synopsis);
		
		NSArray *rows = [resultParser searchWithXPathQuery:@"//*[contains(concat(' ', normalize-space(@class), ' '), ' feature_info_row ')]"];
//		info[@"name"] = [[rows[0] childrenWithTagName:@"div"][1] strippedRaw];
		info[@"genere"] = EmptyStringIfNil([[rows[1] childrenWithTagName:@"div"][1] strippedRaw]);
		info[@"duration"] = @([[[rows[2] childrenWithTagName:@"div"][1] strippedRaw] integerValue]);
		info[@"version"] = EmptyStringIfNil([[rows[3] childrenWithTagName:@"div"][1] strippedRaw]);
		info[@"premiere"] = EmptyStringIfNil([[rows[4] childrenWithTagName:@"div"][1] strippedRaw]);
		info[@"rating"] = EmptyStringIfNil([[rows[5] childrenWithTagName:@"div"][1] strippedRaw]);
		info[@"director"] = EmptyStringIfNil([[rows[6] childrenWithTagName:@"div"][1] strippedRaw]);
		info[@"actors"] = EmptyStringIfNil([[rows[7] childrenWithTagName:@"div"][1] strippedRaw]);
		info[@"origin"] = EmptyStringIfNil([[rows[8] childrenWithTagName:@"div"][1] strippedRaw]);
		
		TFHppleElement *imageEl = [resultParser peekAtSearchWithXPathQuery:@"//*[contains(concat(' ', normalize-space(@class), ' '), ' feature_info_media ')]//img"];
		info[@"imageURL"] = EmptyStringIfNil(imageEl[@"src"]);
		
		TFHppleElement *trailerLink = [resultParser peekAtSearchWithXPathQuery:@"//*[contains(concat(' ', normalize-space(@class), ' '), ' featureTrailerLinkVisible ')]"];
		if (trailerLink) {
			result = [youtubeRegex firstMatchInString:trailerLink[@"href"] options:0 range:NSMakeRange(0, [trailerLink[@"href"] length])];
			info[@"trailerYoutubeID"] = [trailerLink[@"href"] substringWithRange:[result rangeAtIndex:1]];
		}
		
		if (handler) {
			dispatch_async(dispatch_get_main_queue(), ^{
				handler(info);
			});
		}
		
	}];
	
}

#pragma mark - Select Tickets

- (void)loadSelectTicketsFormWithURL:(NSURL *)url completionHandler:(void (^)(NSURL *url, NSDictionary *formInfo, NSArray *prices))handler {

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	
	[NSURLConnection sendAsynchronousRequest:request queue:self.networkQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
		
		if (connectionError) NSLog(@"Connection Error: %@", connectionError);
		
		if (!data || data.length <= 0) {
			
			if (handler) {
				dispatch_async(dispatch_get_main_queue(), ^{
					handler(nil, nil, nil);
				});
			}
			
			return;
		}
		
		TFHpple *resultParser = [TFHpple hppleWithHTMLData:data];
		
		TFHppleElement *form = [resultParser searchWithXPathQuery:@"//form[@id='aspnetForm']"].firstObject;
		NSURL *url = [NSURL URLWithString:form[@"action"] relativeToURL:[NSURL URLWithString:@"http://195.117.18.73/ReservationsCZ/"]];
		
		NSArray *inputs = [resultParser searchWithXPathQuery:@"//form[@id='aspnetForm']//input[@type='hidden']"];
		NSMutableDictionary *formInfo = [NSMutableDictionary dictionaryWithCapacity:inputs.count];
		for (TFHppleElement *input in inputs) {
			if (input[@"name"]) {
				formInfo[input[@"name"]] = EmptyStringIfNil(input[@"value"]);
			}
		}
		
		NSArray *rows = [resultParser searchWithXPathQuery:@"//tr[@class='General_Result_Row']"];
		NSMutableArray *prices = [NSMutableArray arrayWithCapacity:rows.count];
		for (TFHppleElement *row in rows) {
			NSMutableDictionary *priceDict = [NSMutableDictionary dictionaryWithCapacity:4];
			NSArray *cells = [row childrenWithTagName:@"td"];
			priceDict[@"name"] = EmptyStringIfNil([cells[1] firstChildWithTagName:@"span"].text);
			priceDict[@"price"] = EmptyStringIfNil([cells[2] firstChildWithTagName:@"span"].text);
			if (cells.count > 4) priceDict[@"charge"] = EmptyStringIfNil([cells[3] firstChildWithTagName:@"span"].text);
			priceDict[@"nameID"] = EmptyStringIfNil([[cells lastObject] firstChildWithTagName:@"select"][@"name"]);
			[prices addObject:priceDict];
		}
		
		if (handler) {
			dispatch_async(dispatch_get_main_queue(), ^{
				handler(url, formInfo, prices);
			});
		}
		
	}];
	
}

- (void)loadSelectTicketsWithURL:(NSURL *)url formInfo:(NSDictionary *)formInfo tickets:(NSDictionary *)tickets completionHandler:(void (^)(NSURL *url, NSDictionary *formInfo, NSArray *seats, CGSize seatSize))handler {
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	
	NSMutableDictionary *options = [formInfo mutableCopy];
	[options addEntriesFromDictionary:tickets];
	[options addEntriesFromDictionary:@{
		@"ctl00$CPH1$imgNext1.x": @"20",
		@"ctl00$CPH1$imgNext1.y": @"20",
	}];
	
	NSMutableString *requestString = [NSMutableString string];
	[options enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
		[requestString appendFormat:@"%@=%@&", key, [Utilities URLEscapeString:obj]];
	}];
	
	request.HTTPMethod = @"POST";
	request.HTTPBody = [[requestString substringToIndex:requestString.length-1] dataUsingEncoding:NSUTF8StringEncoding];
	
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	
	[NSURLConnection sendAsynchronousRequest:request queue:self.networkQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
		
		if (connectionError) NSLog(@"Connection Error: %@", connectionError);
		
		if (!data || data.length <= 0) {
			
			if (handler) {
				dispatch_async(dispatch_get_main_queue(), ^{
					handler(nil, nil, nil, CGSizeZero);
				});
			}
			
			return;
		}
		
		NSRegularExpression *seatNumRegex = [NSRegularExpression regularExpressionWithPattern:@"(\\d+)_(\\d+)" options:0 error:NULL];
		NSRegularExpression *topRegex = [NSRegularExpression regularExpressionWithPattern:@"top:(\\d*)px" options:NSRegularExpressionCaseInsensitive error:NULL];
		NSRegularExpression *leftRegex = [NSRegularExpression regularExpressionWithPattern:@"left:(\\d*)px" options:NSRegularExpressionCaseInsensitive error:NULL];
		NSRegularExpression *widthRegex = [NSRegularExpression regularExpressionWithPattern:@"W=(\\d*)" options:NSRegularExpressionCaseInsensitive error:NULL];
		NSRegularExpression *heightRegex = [NSRegularExpression regularExpressionWithPattern:@"H=(\\d*)" options:NSRegularExpressionCaseInsensitive error:NULL];
		NSRegularExpression *statusRegex = [NSRegularExpression regularExpressionWithPattern:@"Status=(\\d*)" options:NSRegularExpressionCaseInsensitive error:NULL];
		NSTextCheckingResult *result;
		NSString *raw;
		
		TFHpple *resultParser = [TFHpple hppleWithHTMLData:data];
		
		TFHppleElement *form = [resultParser searchWithXPathQuery:@"//form[@id='aspnetForm']"].firstObject;
		NSURL *url = [NSURL URLWithString:form[@"action"] relativeToURL:[NSURL URLWithString:@"http://195.117.18.73/ReservationsCZ/"]];
		
		NSArray *inputs = [resultParser searchWithXPathQuery:@"//form[@id='aspnetForm']//input[@type='hidden']"];
		NSMutableDictionary *formInfo = [NSMutableDictionary dictionaryWithCapacity:inputs.count];
		for (TFHppleElement *input in inputs) {
			if (input[@"name"]) {
				formInfo[input[@"name"]] = EmptyStringIfNil(input[@"value"]);
			}
		}
		
		NSArray *spans = [resultParser searchWithXPathQuery:@"//*[@id='ctl00_CPH1_SPC_pnlVenueSection']//span"];
		
		int width = 0, height = 0;
		
		NSString *currentRow;
		NSMutableArray *rows = [NSMutableArray array];
		NSMutableArray *cols;
		for (TFHppleElement *span in spans) {
			if (span.text && ![span.text isEqualToString:currentRow]) {
				currentRow = span.text;
				if (cols) [rows addObject:cols];
				cols = [NSMutableArray array];
			}
			
			if (!span.text) {
				
				TFHppleElement *div = [span firstChildWithClassName:@"seat"];
				
				raw = div[@"id"];
				
				result = [seatNumRegex firstMatchInString:raw options:0 range:NSMakeRange(0, raw.length)];
				int row = [[raw substringWithRange:[result rangeAtIndex:1]] intValue];
				int col = [[raw substringWithRange:[result rangeAtIndex:2]] intValue];
				
				raw = div[@"style"];
				
				result = [topRegex firstMatchInString:raw options:0 range:NSMakeRange(0, raw.length)];
				int top = [[raw substringWithRange:[result rangeAtIndex:1]] intValue];
				
				result = [leftRegex firstMatchInString:raw options:0 range:NSMakeRange(0, raw.length)];
				int left = [[raw substringWithRange:[result rangeAtIndex:1]] intValue];
				
				result = [statusRegex firstMatchInString:raw options:0 range:NSMakeRange(0, raw.length)];
				int status = [[raw substringWithRange:[result rangeAtIndex:1]] intValue];
				
				if (width == 0 && height == 0) {
					result = [widthRegex firstMatchInString:raw options:0 range:NSMakeRange(0, raw.length)];
					width = [[raw substringWithRange:[result rangeAtIndex:1]] intValue];
					
					result = [heightRegex firstMatchInString:raw options:0 range:NSMakeRange(0, raw.length)];
					height = [[raw substringWithRange:[result rangeAtIndex:1]] intValue];
				}
				
				[cols addObject:@{
					@"row": @(row),
					@"col": @(col),
					@"top": @(top),
					@"left": @(left),
					@"status": @(status),
				}];
				
			}
		}
		if (cols) [rows addObject:cols];
		
		if (handler) {
			dispatch_async(dispatch_get_main_queue(), ^{
				handler(url, formInfo, rows, CGSizeMake(width, height));
			});
		}
		
	}];
	
}

- (void)selectSeatsWithURL:(NSURL *)url formInfo:(NSDictionary *)formInfo seats:(NSArray *)seats completionHandler:(void (^)(NSURL *url, NSDictionary *formInfo, NSDate *expirationDate, NSURL *captchaURL))handler captchaHandler:(void (^)(UIImage *captcha))captchaHandler {
	
	NSMutableString *selectedSeats = [NSMutableString string];
	for (NSIndexPath *seat in seats) {
		[selectedSeats appendFormat:@"%lu,%lu#", (unsigned long)[seat indexAtPosition:0], (unsigned long)[seat indexAtPosition:1]];
	}
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	
	NSMutableDictionary *options = [formInfo mutableCopy];
	[options addEntriesFromDictionary:@{
		@"ctl00$CPH1$SPC$imgSubmit2.x": @"20",
		@"ctl00$CPH1$SPC$imgSubmit2.y": @"20",
		@"tbSelectedSeats": selectedSeats,
	}];
	
	NSMutableString *requestString = [NSMutableString string];
	[options enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
		[requestString appendFormat:@"%@=%@&", key, [Utilities URLEscapeString:obj]];
	}];
	
	request.HTTPMethod = @"POST";
	request.HTTPBody = [[requestString substringToIndex:requestString.length-1] dataUsingEncoding:NSUTF8StringEncoding];
	
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	
	[NSURLConnection sendAsynchronousRequest:request queue:self.networkQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
		
		if (connectionError) NSLog(@"Connection Error: %@", connectionError);
		
		if (!data || data.length <= 0) {
			
			if (handler) {
				dispatch_async(dispatch_get_main_queue(), ^{
					handler(nil, nil, nil, nil);
				});
			}
			
			return;
		}
		
		TFHpple *resultParser = [TFHpple hppleWithHTMLData:data];
		
		TFHppleElement *form = [resultParser searchWithXPathQuery:@"//form[@id='aspnetForm']"].firstObject;
		NSURL *url = [NSURL URLWithString:form[@"action"] relativeToURL:[NSURL URLWithString:@"http://195.117.18.73/ReservationsCZ/"]];
		
		NSArray *inputs = [resultParser searchWithXPathQuery:@"//form[@id='aspnetForm']//input[@type='hidden']"];
		NSMutableDictionary *formInfo = [NSMutableDictionary dictionaryWithCapacity:inputs.count];
		for (TFHppleElement *input in inputs) {
			if (input[@"name"]) {
				formInfo[input[@"name"]] = EmptyStringIfNil(input[@"value"]);
			}
		}
		
		NSDateFormatter *dateFormatter = [NSDateFormatter new];
		dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
		TFHppleElement *iframe = [resultParser searchWithXPathQuery:@"//*[@id='ctl00_CPH1_OrderFormControl1_SessionInfoTimerControl1_iFrameCountDown']"].firstObject;
		NSString *dateStr = [[iframe[@"src"] componentsSeparatedByString:@"="] lastObject];
		NSDate *date = [dateFormatter dateFromString:dateStr];
		
		TFHppleElement *captcha = [resultParser searchWithXPathQuery:@"//*[@id='ctl00_CPH1_OrderFormControl1_AuthenticationTestControl1_imgAuthenticationImage']"].firstObject;
		NSURL *captchaURL = [NSURL URLWithString:[captcha[@"src"] stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"] relativeToURL:[NSURL URLWithString:@"http://195.117.18.73/ReservationsCZ/"]];
		
		if (captchaHandler) {
			NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:captchaURL];
			[NSURLConnection sendAsynchronousRequest:request queue:self.networkQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
				UIImage *image = [UIImage imageWithData:data];
				dispatch_async(dispatch_get_main_queue(), ^{
					captchaHandler(image);
				});
			}];
		}
		
		if (handler) {
			dispatch_async(dispatch_get_main_queue(), ^{
				handler(url, formInfo, date, captchaURL);
			});
		}
		
	}];
	
}

- (void)sendOrderWithURL:(NSURL *)url formInfo:(NSDictionary *)formInfo name:(NSString *)name surname:(NSString *)surname email:(NSString *)email phone:(NSString *)phone captcha:(NSString *)captcha completionHandler:(void (^)(NSURL *url, NSDictionary *formInfo))handler {
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	
	NSMutableDictionary *options = [formInfo mutableCopy];
	[options addEntriesFromDictionary:@{
		@"tbStoredValueNumber":																	@"",
		@"tbPincode":																			@"",
		@"tbValCode":																			@"",
		@"ctl00$CPH1$OrderFormControl1$Field_5":												name,
		@"ctl00$CPH1$OrderFormControl1$Field_7":												surname,
		@"ctl00$CPH1$OrderFormControl1$Field_20":												email,
		@"ctl00$CPH1$OrderFormControl1$Field_21":												phone,
		@"ctl00$CPH1$OrderFormControl1$AuthenticationTestControl1$txtAuthenticationCode":		captcha,
		@"ctl00$CPH1$WebTixsButtonControl1$ctl00.x":											@"20",
		@"ctl00$CPH1$WebTixsButtonControl1$ctl00.y":											@"20",
	}];
	
	NSMutableString *requestString = [NSMutableString string];
	[options enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
		[requestString appendFormat:@"%@=%@&", key, [Utilities URLEscapeString:obj]];
	}];
	
	request.HTTPMethod = @"POST";
	request.HTTPBody = [[requestString substringToIndex:requestString.length-1] dataUsingEncoding:NSUTF8StringEncoding];
	
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	
	[NSURLConnection sendAsynchronousRequest:request queue:self.networkQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
		
		if (connectionError) NSLog(@"Connection Error: %@", connectionError);
		
		if (!data || data.length <= 0) {
			
			if (handler) {
				dispatch_async(dispatch_get_main_queue(), ^{
					handler(nil, nil);
				});
			}
			
			return;
		}
		
//		dispatch_async(dispatch_get_main_queue(), ^{
//			UIWebView *webView = [UIWebView new];
//			webView.frame = CGRectMake(0, 64, 320, 320);
//			[webView loadData:data MIMEType:response.MIMEType textEncodingName:response.textEncodingName baseURL:response.URL];
//			[AppDelegate.instance.window addSubview:webView];
//		});
		
		TFHpple *resultParser = [TFHpple hppleWithHTMLData:data];
		
		TFHppleElement *form = [resultParser searchWithXPathQuery:@"//form[@id='aspnetForm']"].firstObject;
		NSURL *url = [NSURL URLWithString:form[@"action"] relativeToURL:[NSURL URLWithString:@"http://195.117.18.73/ReservationsCZ/"]];
		
		NSArray *inputs = [resultParser searchWithXPathQuery:@"//form[@id='aspnetForm']//input[@type='hidden']"];
		NSMutableDictionary *formInfo = [NSMutableDictionary dictionaryWithCapacity:inputs.count];
		for (TFHppleElement *input in inputs) {
			if (input[@"name"]) {
				formInfo[input[@"name"]] = EmptyStringIfNil(input[@"value"]);
			}
		}
		
		if (handler) {
			dispatch_async(dispatch_get_main_queue(), ^{
				handler(url, formInfo);
			});
		}
		
	}];
	
}

@end
