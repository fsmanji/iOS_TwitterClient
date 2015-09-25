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


@interface Account : NSObject

@property STTwitterAPI* api;

@property FMJTimeLine* timeline;


@property  HomeViewController* parentViewController;

//the same as screen_name: @somebody
@property NSString *userID;


+ (id)initWithUsername:(NSString *)username password:(NSString *)password;

+ (id)initWithWebLoginFromViewControler:(HomeViewController *)viewcontroller;

+ (id)initWithiOSAccountFromView:(UIView *)parentview;

-(BOOL) handleOpenURL:(NSURL *)url;

-(void)newTweet:(NSString *)text successBlock:(void (^)(NSDictionary *))successblock errorBlock:(void (^)(NSError *))errorBlock;
@end
