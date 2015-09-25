//
//  FMJTwitterTweet.h
//  MyTwitter
//
//  Created by Cristan Zhang on 9/25/15.
//  Copyright (c) 2015 FSManJi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMJTwitterUser.h"

@interface FMJTwitterTweet : NSObject

@property NSString *tweetID;
@property NSString *text;
@property NSString *createTime;
@property NSUInteger retweetCount;
@property NSUInteger favCount;
@property BOOL retweeted;
@property BOOL faved;

@property FMJTwitterUser *user;

+(FMJTwitterTweet *)initWithJsonString:(NSDictionary *)json;

+(FMJTwitterTweet *)newTweetWithText:(NSString *)text;

@end
