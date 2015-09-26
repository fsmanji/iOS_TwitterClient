//
//  Account.h
//  MyTwitter
//
//  Created by Cristan Zhang on 9/23/15.
//  Copyright (c) 2015 FSManJi. All rights reserved.
//

#import <Foundation/Foundation.h>


@class STTwitterAPI;
@class UIView;
@class HomeViewController;
@class FMJTimeLine;
@class FMJTwitterTweet;

typedef NS_ENUM(NSUInteger, FMJTweetAction) {
    kReply,
    kRetweet,
    kFavorite
};

@protocol Account3LeggedOAuthDelegate <NSObject>

-(void)on3LeggedOAuthCallback;

@end

@interface Account : NSObject

@property STTwitterAPI* api;

@property FMJTimeLine* timeline;

@property id<Account3LeggedOAuthDelegate> delegate;

@property  HomeViewController* parentViewController;

//the same as screen_name: @somebody
@property NSString *username;


+ (id)initWithUsername:(NSString *)username password:(NSString *)password;

+ (id)initWithWebLoginFromViewControler:(HomeViewController *)viewcontroller;

+ (id)initWithiOSAccountFromView:(UIView *)parentview;

-(BOOL) handleOpenURL:(NSURL *)url;

-(void)newTweet:(NSString *)text successBlock:(void (^)(NSDictionary *))successblock errorBlock:(void (^)(NSError *))errorBlock;

-(void)updateTweet:(FMJTwitterTweet *)tweet withAction:(FMJTweetAction)action successBlock:(void (^)(NSDictionary *))successblock errorBlock:(void (^)(NSError *))errorBlock;

-(void)logout;

@end
