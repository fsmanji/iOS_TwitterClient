//
//  HomeViewController.h
//  MyTwitter
//
//  Created by Cristan Zhang on 9/23/15.
//  Copyright (c) 2015 FSManJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController

- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verifier;

@end
