//
//  ComposerViewController.m
//  MyTwitter
//
//  Created by Cristan Zhang on 9/26/15.
//  Copyright (c) 2015 FSManJi. All rights reserved.
//

#import "ComposerViewController.h"
#import "Account.h"
#import "AccountManager.h"
#import "UIImageView+AFNetworking.h"
#import "FMJTwitterUser.h"

@interface ComposerViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;

@end


@implementation ComposerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self styleNavigationBar];
    [self setupComposerHeader];
}

- (void)styleNavigationBar {
    
    self.navigationItem.title = @"Composer";
    
    //1. color the navigation bar as light blue
    UIColor * const navBarBgColor = [UIColor colorWithRed:89/255.0f green:174/255.0f blue:235/255.0f alpha:1.0f];
    
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    //ios 7+
    if ([[ver objectAtIndex:0] intValue] >= 7) {
        self.navigationController.navigationBar.barTintColor = navBarBgColor;
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }else{
        //ios 6 and older
        self.navigationController.navigationBar.tintColor = navBarBgColor;
    }
    
    
    //2. add left button
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancel:)];
    
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    //3. add right button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Tweet" style:UIBarButtonItemStylePlain target:self action:@selector(onDone:)];
    
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
}

-(void)setupComposerHeader {
    FMJTwitterUser *activeUser = [AccountManager sharedInstance].activeAccount.user;
    [_avatarView setImageWithURL:[NSURL URLWithString:activeUser.profileImgUrl]];
    _nameLabel.text = activeUser.username;
    _screenNameLabel.text = [NSString stringWithFormat:@"@%@", activeUser.screenName];
}

-(void)onCancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)onDone:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    NSString *text = _textField.text;
    [[AccountManager sharedInstance].activeAccount newTweet:text successBlock:^(NSDictionary * response) {
        NSLog(@"NewTeet posted: %@", response);
        
    } errorBlock:^(NSError *error) {
        NSLog(@"NewTweet failed: %@", [error userInfo]);
    }];
}

@end
