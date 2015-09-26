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

typedef void (^accountChooserBlock_t)(ACAccount *account, NSString *errorMessage); // don't bother with NSError for that

@interface Account () <UIActionSheetDelegate>

@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) NSArray *iOSAccounts;
@property (nonatomic, strong) accountChooserBlock_t accountChooserBlock;

@end

@implementation Account

-(id)init {
    self = [super init];
    if (self) {
        self.accountStore = [[ACAccountStore alloc] init];
        __weak typeof(self) weakSelf = self;
        
        self.accountChooserBlock = ^(ACAccount *account, NSString *errorMessage) {
            
            NSString *status = nil;
            if(account) {
                status = [NSString stringWithFormat:@"Did select %@", account.username];
                
                [weakSelf loginWithiOSAccount:account];
            } else {
                status = errorMessage;
            }
            NSLog(@"Account chooser: %@", status);
        };
        
    }
    
    [AccountManager sharedInstance].activeAccount = self;
    
    _timeline = [[FMJTimeLine alloc] init];
    
    return self;
}

+ (id)initWithUsername:(NSString *)username password:(NSString *)password {
    Account * account = [[Account alloc] init];
    
    
    account.api = [STTwitterAPI twitterAPIWithOAuthConsumerKey:kConsumerKey
                                                consumerSecret:kConsumerSecret
                                                      username:username
                                                      password:password];
    
    return account;
}

+ (id)initWithWebLoginFromViewControler:(HomeViewController *)viewcontroller{
    Account * account = [[Account alloc] init];
    account.api = [STTwitterAPI twitterAPIWithOAuthConsumerKey:kConsumerKey
                                                consumerSecret:kConsumerSecret];
    account.parentViewController = viewcontroller;

    [account.api postTokenRequest:^(NSURL *url, NSString *oauthToken) {
        NSLog(@"url: %@", url);
        NSLog(@"oauthToken: %@", oauthToken);
        
        //[[UIApplication sharedApplication] openURL:url];
        
        WebViewController *webViewVC = [[WebViewController alloc] init];
        
        //set call back delegate
        account.delegate = webViewVC;
        
        [viewcontroller presentViewController:webViewVC animated:YES completion:^{
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            [webViewVC sendRequest:request];
        }];
        
    } authenticateInsteadOfAuthorize:NO
                    forceLogin:@(YES)
                    screenName:nil
                 oauthCallback:kCallbackURL
                    errorBlock:^(NSError *error) {
                        NSLog(@"-- error: %@", error);
                    }];
    
    return account;
}

+ (id)initWithiOSAccountFromView:(UIView *)parentview{
    Account * account = [[Account alloc] init];
    [account chooseAccount:parentview];
    
    return account;
}

- (void)chooseAccount:(UIView *)parentview  {
    
    ACAccountType *accountType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    ACAccountStoreRequestAccessCompletionHandler accountStoreRequestCompletionHandler = ^(BOOL granted, NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            if(granted == NO) {
                _accountChooserBlock(nil, @"Acccess not granted.");
                return;
            }
            
            self.iOSAccounts = [_accountStore accountsWithAccountType:accountType];
            
            if([_iOSAccounts count] == 1) {
                ACAccount *account = [_iOSAccounts lastObject];
                _accountChooserBlock(account, nil);
            } else {
                UIActionSheet *chooserDialog = [[UIActionSheet alloc] initWithTitle:@"Select an account:"
                                                                delegate:self
                                                       cancelButtonTitle:@"Cancel"
                                                  destructiveButtonTitle:nil otherButtonTitles:nil];
                for(ACAccount *account in _iOSAccounts) {
                    [chooserDialog addButtonWithTitle:[NSString stringWithFormat:@"@%@", account.username]];
                }
                [chooserDialog showInView:parentview];
            }
        }];
    };
    
#if TARGET_OS_IPHONE &&  (__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0)
    if (floor(NSFoundationVersionNumber) < NSFoundationVersionNumber_iOS_6_0) {
        [self.accountStore requestAccessToAccountsWithType:accountType
                                     withCompletionHandler:accountStoreRequestCompletionHandler];
    } else {
        [self.accountStore requestAccessToAccountsWithType:accountType
                                                   options:NULL
                                                completion:accountStoreRequestCompletionHandler];
    }
#else
    [self.accountStore requestAccessToAccountsWithType:accountType
                                               options:NULL
                                            completion:accountStoreRequestCompletionHandler];
#endif
    
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex == [actionSheet cancelButtonIndex]) {
        _accountChooserBlock(nil, @"Account selection was cancelled.");
        return;
    }
    
    NSUInteger accountIndex = buttonIndex - 1;
    ACAccount *account = [_iOSAccounts objectAtIndex:accountIndex];
    
    _accountChooserBlock(account, nil);
}

- (void)loginWithiOSAccount:(ACAccount *)account {
    
    self.api = nil;
    self.api = [STTwitterAPI twitterAPIOSWithAccount:account];
    
    [_api verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kEventUserLogin object:self];
        
        _username = username;
        NSLog(@"Verified: @%@ (%@)", username, userID);
              
    } errorBlock:^(NSError *error) {
        NSLog(@"Verification failed: %@", error);
    }];
    
}



-(BOOL) handleOpenURL:(NSURL *)url {
    if ([[url scheme] isEqualToString:@"myapp"] == NO)
        return NO;
    
    [_delegate on3LeggedOAuthCallback];
    
    NSDictionary *d = [self parametersDictionaryFromQueryString:[url query]];
    
    NSString *verifier = d[@"oauth_verifier"];
    
    [_api postAccessTokenRequestWithPIN:verifier successBlock:^(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName) {
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
        [defaults setObject:_api.oauthAccessToken forKey:kTwitterOauthAccessTokenKey];
        [defaults setObject:_api.oauthAccessTokenSecret forKey:kTwitterOauthAccessTokenSecretKey];
        [defaults synchronize];
        NSLog(@"Twitter access tokens saved.");
        
    } errorBlock:^(NSError *error) {
        
        NSLog(@"-- %@", [error localizedDescription]);
    }];
    return YES;
}

- (NSDictionary *)parametersDictionaryFromQueryString:(NSString *)queryString {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    NSArray *queryComponents = [queryString componentsSeparatedByString:@"&"];
    
    for(NSString *s in queryComponents) {
        NSArray *pair = [s componentsSeparatedByString:@"="];
        if([pair count] != 2) continue;
        
        NSString *key = pair[0];
        NSString *value = pair[1];
        
        md[key] = value;
    }
    
    return md;
}

-(void)logout {
    _api = nil;
    
    //Shall we remove access_tokens ?
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
