//
//  Account.h
//  MyTwitter
//
//  Created by Cristan Zhang on 9/23/15.
//  Copyright (c) 2015 FSManJi. All rights reserved.
//

#import <Foundation/Foundation.h>


@class STTwitterAPI;
@class FMJTimeLine;
@class FMJTwitterTweet;
@class FMJTwitterUser;

typedef NS_ENUM(NSUInteger, FMJTweetAction) {
    kReply,
    kRetweet,
    kFavorite
};



@interface Account : NSObject

@property STTwitterAPI* api;

@property FMJTwitterUser* user;

@property FMJTimeLine* timeline;

//the same as screen_name: @somebody
@property NSString *screenName;

-(void)getUserInfo:(NSString *)userID;

-(void)newTweet:(NSString *)text successBlock:(void (^)(NSDictionary *))successblock errorBlock:(void (^)(NSError *))errorBlock;

-(void)updateTweet:(FMJTwitterTweet *)tweet withAction:(FMJTweetAction)action successBlock:(void (^)(NSDictionary *))successblock errorBlock:(void (^)(NSError *))errorBlock;

-(void)logout;

@end
