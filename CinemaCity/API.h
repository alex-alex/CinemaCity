//
//  API.h
//  CinemaCity
//
//  Created by Alex Studnicka on 27/03/14.
//  Copyright (c) 2014 Alex Studnicka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Presentations.h"

@interface API : NSObject

@property (nonatomic, readonly) NSOperationQueue *networkQueue;
@property (nonatomic, readonly) NSDateFormatter *dateFormatter;
@property (nonatomic, readonly) NSDateFormatter *timeFormatter;
@property (nonatomic, readonly) NSDateFormatter *humanDateFormatter;
@property (nonatomic, readonly) NSDateFormatter *humanDateTimeFormatter;

+ (instancetype)sharedInstance;

- (void)loginUser:(NSString *)username password:(NSString *)password completionHandler:(void (^)(NSDictionary *userInfo))handler;
- (void)logoutUserWithCompletionHandler:(void (^)(BOOL success))handler;

- (void)loadHistoryWithCompletionHandler:(void (^)(NSArray *history))handler;

- (void)getMoviesWithCompletionHandler:(void (^)(NSArray *movies))handler;

- (void)getScheduleForCinema:(NSString *)cinemaID venueTypeID:(NSString *)venueTypeID date:(NSDate *)date completionHandler:(void (^)(NSArray *schedule))handler;
- (void)getPresentationsForURL:(NSURL *)url completionHandler:(void (^)(Presentations *presentations))handler;

- (void)getDetailOfMovieWithFeatureCode:(NSString *)featureCode completionHandler:(void (^)(NSDictionary *movieDetail))handler;
- (void)getDetailOfMovieWithURL:(NSURL *)url completionHandler:(void (^)(NSDictionary *movieDetail))handler;

- (void)loadSelectTicketsFormWithURL:(NSURL *)url completionHandler:(void (^)(NSURL *url, NSDictionary *formInfo, NSArray *prices))handler;
- (void)loadSelectTicketsWithURL:(NSURL *)url formInfo:(NSDictionary *)formInfo tickets:(NSDictionary *)tickets completionHandler:(void (^)(NSURL *url, NSDictionary *formInfo, NSArray *seats, CGSize seatSize))handler;
- (void)selectSeatsWithURL:(NSURL *)url formInfo:(NSDictionary *)formInfo seats:(NSArray *)seats completionHandler:(void (^)(NSURL *url, NSDictionary *formInfo, NSDate *expirationDate, NSURL *captchaURL))handler captchaHandler:(void (^)(UIImage *captcha))captchaHandler;
- (void)sendOrderWithURL:(NSURL *)url formInfo:(NSDictionary *)formInfo name:(NSString *)name surname:(NSString *)surname email:(NSString *)email phone:(NSString *)phone captcha:(NSString *)captcha completionHandler:(void (^)(NSURL *url, NSDictionary *formInfo))handler;

@end
