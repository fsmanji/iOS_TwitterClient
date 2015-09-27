//
//  Account.m
//  MyTwitter
//
//  Created by Cristan Zhang on 9/23/15.
//  Copyright (c) 2015 FSManJi. All rights reserved.
//

#import "Account.h"
#import <STTWitter.h>
#import <UIKit/UIKit.h>
#import "AccountManager.h"
#import <Accounts/Accounts.h>
#import "WebViewController.h"
#import "HomeViewController.h"
#import "FMJTimeLine.h"
#import "FMJTwitterTweet.h"

@interface Account () 

@end

@implementation Account

-(id)init {
    self = [super init];
    if (self) {
        [AccountManager sharedInstance].activeAccount = self;   
        _timeline = [[FMJTimeLine alloc] init];
        
    }

    return self;
}

-(void)logout {
    _api = nil;
    
    //Shall we remove access_tokens ?
}

-(void)getUserInfo:(NSString *)userID {
    
    [_api getUserInformationFor:userID successBlock:^(NSDictionary *user) {
        self.user = [FMJTwitterUser initWithJsonString:user];
        NSLog(@"Active user: %@", user);
        
    } errorBlock:^(NSError *error) {
        NSLog(@"Fetching user info failed: %@", [error userInfo]);
        
    }];
}

-(void)newTweet:(NSString *)text successBlock:(void (^)(NSDictionary *))successblock errorBlock:(void (^)(NSError *))errorBlock {
    [_api postStatusUpdate:text
         inReplyToStatusID:nil
                  latitude:nil
                 longitude:nil
                   placeID:nil
        displayCoordinates:nil
                  trimUser:nil
              successBlock:^(NSDictionary *status) {
                  successblock(status);
              } errorBlock:^(NSError *error) {
                  errorBlock(error);
              }];
}

-(void)updateTweet:(FMJTwitterTweet *)tweet withAction:(FMJTweetAction)action successBlock:(void (^)(NSDictionary *))successblock errorBlock:(void (^)(NSError *))errorBlock{
    switch (action) {
        case kFavorite:{
            [_api postFavoriteState:tweet.faved forStatusID:tweet.tweetID successBlock:successblock
                         errorBlock:errorBlock];
        }
            break;
        case kReply:{
            [_api postStatusUpdate:@"test reply"
                 inReplyToStatusID:tweet.tweetID
                          latitude:nil
                         longitude:nil
                           placeID:nil
                displayCoordinates:nil
                          trimUser:nil
                      successBlock:successblock
                        errorBlock:errorBlock];
        }
            break;
        case kRetweet:{
            [_api postStatusRetweetWithID:tweet.tweetID successBlock:successblock errorBlock:errorBlock];
        }
            break;
        default:
            break;
    }
}

@end
