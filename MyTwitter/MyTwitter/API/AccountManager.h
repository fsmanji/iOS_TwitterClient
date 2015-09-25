//
//  AccountManager.h
//  MyTwitter
//
//  Created by Cristan Zhang on 9/25/15.
//  Copyright (c) 2015 FSManJi. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kConsumerKey @"Z6wRBswlWtdf1CZnGsyNOUVa4"
#define kConsumerSecret @"pE1PXeyTLIoKgKgXRKch1PETSyoepT5mYZ7T2sjyFuSkKmBbi1"

#define kTwitterOauthAccessTokenKey @"TwitterOauthAccessTokenKey"
#define kTwitterOauthAccessTokenSecretKey @"TwitterOauthAccessTokenSecretKey"

#define kCallbackURL @"myapp://twitter_access_tokens/"

@class  Account;
@class NSURL;

@interface AccountManager : NSObject

@property Account* activeAccount;

+ (AccountManager *) sharedInstance;

-(Account *)activeAccount;

-(void)restoreUserSession;

@end
