//
//  AccountManager.m
//  MyTwitter
//
//  Created by Cristan Zhang on 9/25/15.
//  Copyright (c) 2015 FSManJi. All rights reserved.
//

#import <STTwitterAPI.h>
#import "AccountManager.h"
#import "Account.h"

@interface AccountManager ()

@property NSMutableArray* accounts;

@end

@implementation AccountManager

+ (AccountManager *) sharedInstance {
    static AccountManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AccountManager alloc] init];
    });
    
    return manager;
}

- (id)init {
    if (self = [super init]) {
        //
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

-(void)logout {
    _activeAccount = nil;
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kEventUserLogout
     object:self];
}

-(void)restoreUserSession {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString * accessToken = [defaults stringForKey:kTwitterOauthAccessTokenKey];
    NSString * accessTokenSecret = [defaults stringForKey:kTwitterOauthAccessTokenSecretKey];
    
    if (accessToken && accessTokenSecret) {
        NSLog(@"Previously saved user session discovered, trying to verify validity...");
        _activeAccount = [[Account alloc] init];
        _activeAccount.api = [STTwitterAPI twitterAPIWithOAuthConsumerKey:kConsumerKey
                                                           consumerSecret:kConsumerSecret
                                                               oauthToken:accessToken
                                                         oauthTokenSecret:accessTokenSecret];
        
        [_activeAccount.api verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
            
            NSLog(@"Verified: @%@ (%@)", username, userID);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kEventUserLogin object:self];
            
        } errorBlock:^(NSError *error) {
            NSLog(@"Verification failed: %@", error);
            //reset
            _activeAccount = nil;
        }];
        
    }
}

@end
