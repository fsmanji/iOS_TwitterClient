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


@interface Account : NSObject

@property STTwitterAPI* api;
@property  HomeViewController* parentViewController;


+ (id)initWithUsername:(NSString *)username password:(NSString *)password;

+ (id)initWithWebLoginFromViewControler:(HomeViewController *)viewcontroller;

+ (id)initWithiOSAccountFromView:(UIView *)parentview;

-(BOOL) handleOpenURL:(NSURL *)url;

@end
