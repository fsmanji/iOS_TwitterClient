//
//  FMJTimeLine.m
//  MyTwitter
//
//  Created by Cristan Zhang on 9/25/15.
//  Copyright (c) 2015 FSManJi. All rights reserved.
//

#import "FMJTimeLine.h"
#import "Account.h"
#import "AccountManager.h"
#import "FMJTwitterTweet.h"
#import "STTwitterAPI.h"

#define kPageSize 20
#define kPageSizeString @"20"

@interface FMJTimeLine ()

@property NSString * lastID; //the current oldest tweet id fetched.
@property NSString * sinceID;

@end

@implementation FMJTimeLine

-(FMJTimeLine *)init {
    self = [super init];
    if (self) {
        _homeTimeLine = [NSMutableArray array];
        _pendingTweets = [NSMutableArray array];
    }
    return self;
}

-(void)loadMore:(BOOL)refresh {
    Account * account = [AccountManager sharedInstance].activeAccount;
    
    [account.api getStatusesHomeTimelineWithCount:kPageSizeString
                                          sinceID:_sinceID
                                            maxID:_lastID
                                         trimUser:nil
                                   excludeReplies:nil
                               contributorDetails:nil
                                  includeEntities:nil
                                     successBlock:^(NSArray *statuses)
     {
         if (refresh) {
             //TODO: find a way to save old tweets instead of fetch again in future.
             [_homeTimeLine removeAllObjects];
             
         }
         
        NSLog(@"Loaded count: %lu", statuses.count);
        
        [statuses enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
            FMJTwitterTweet *tweet = [FMJTwitterTweet initWithJsonString:obj];
            NSLog(@"Parsing Tweet: %@", tweet);
            [_homeTimeLine addObject:tweet];
        }];
        
        FMJTwitterTweet *lastOne = [_homeTimeLine lastObject];
        
        _lastID = lastOne.tweetID;
        
        if (_delegate) {
            _hasMore = kPageSize == statuses.count;
            [_delegate didUpdateTimeline:_hasMore];
        }
        
    } errorBlock:^(NSError *error) {
        NSLog(@"Error getHomeTimeline: %@", [error userInfo]);
        
    }];
}

-(void)refresh {
    FMJTwitterTweet *first = [_homeTimeLine firstObject];
    _sinceID = first.tweetID;
    
    
    [self loadMore:YES];
}

@end
