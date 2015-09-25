//
//  HomeViewController.m
//  MyTwitter
//
//  Created by Cristan Zhang on 9/23/15.
//  Copyright (c) 2015 FSManJi. All rights reserved.
//

#import "HomeViewController.h"
#import "Account.h"
#import "AccountManager.h"
#import <STTWitter.h>

@interface HomeViewController ()

@property Account *activeAccount;


@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[AccountManager sharedInstance] restoreUserSession];
    _activeAccount = [AccountManager sharedInstance].activeAccount;
    if (_activeAccount == nil) {
        _activeAccount = [Account initWithWebLoginFromViewControler:self];
        //_activeAccount = [Account initWithiOSAccountFromView:self.view];
    }

}

- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verifier {
    
    // in case the user has just authenticated through WebViewVC
    [self dismissViewControllerAnimated:YES completion:nil];
    
    STTwitterAPI * api = _activeAccount.api;
    [api postAccessTokenRequestWithPIN:verifier successBlock:^(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName) {
        NSLog(@"-- screenName: %@", screenName);
        /*
         At this point, the user can use the API and you can read his access tokens with:
         
         _twitter.oauthAccessToken;
         _twitter.oauthAccessTokenSecret;
         
         You can store these tokens (in user default, or in keychain) so that the user doesn't need to authenticate again on next launches.
         
         Next time, just instanciate STTwitter with the class method:
         
         +[STTwitterAPI twitterAPIWithOAuthConsumerKey:consumerSecret:oauthToken:oauthTokenSecret:]
         
         Don't forget to call the -[STTwitter verifyCredentialsWithSuccessBlock:errorBlock:] after that.
         */
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:api.oauthAccessToken forKey:kTwitterOauthAccessTokenKey];
        [defaults setObject:api.oauthAccessTokenSecret forKey:kTwitterOauthAccessTokenSecretKey];
        [defaults synchronize];
        NSLog(@"Twitter access tokens saved.");
        
    } errorBlock:^(NSError *error) {
        
        NSLog(@"-- %@", [error localizedDescription]);
    }];
}


@end
