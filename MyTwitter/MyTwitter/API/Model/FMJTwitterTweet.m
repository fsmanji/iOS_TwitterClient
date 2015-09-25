//
//  FMJTwitterTweet.m
//  MyTwitter
//
//  Created by Cristan Zhang on 9/25/15.
//  Copyright (c) 2015 FSManJi. All rights reserved.
//

#import "FMJTwitterTweet.h"

@implementation FMJTwitterTweet

+(FMJTwitterTweet *)initWithJsonString:(NSDictionary *)json {
    FMJTwitterTweet *tweet = [[FMJTwitterTweet alloc] init];
    
    tweet.tweetID = [json[@"id"] stringValue];
    tweet.text = json[@"text"];
    tweet.createTime = json[@"created_at"];
    tweet.retweetCount = [json[@"retweet_count"] intValue];
    tweet.favCount = [json[@"favorite_count"] intValue];
    tweet.faved = [json[@"favorited"] boolValue];
    tweet.retweeted = [json[@"retweeted"] boolValue];
    
    tweet.user = [FMJTwitterUser initWithJsonString:json[@"user"]];
    
    return tweet;
}

+(FMJTwitterTweet *)newTweetWithText:(NSString *)text {
    FMJTwitterTweet *tweet = [[FMJTwitterTweet alloc] init];
    tweet.text = text;
    return tweet;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"text=%@\n\tcreated=%@", _text, _createTime];
}

@end