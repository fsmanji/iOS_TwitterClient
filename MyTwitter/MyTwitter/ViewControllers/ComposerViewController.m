//
//  ComposerViewController.m
//  MyTwitter
//
//  Created by Cristan Zhang on 9/26/15.
//  Copyright (c) 2015 FSManJi. All rights reserved.
//

#import "ComposerViewController.h"
#import "Account.h"
#import "FMJTimeLine.h"
#import "AccountManager.h"
#import "UIImageView+AFNetworking.h"
#import "FMJTwitterUser.h"
#import "UIImageView+FMJTwitter.h"
#import "UIViewController+FMJTwitter.h"

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
    
    UIColor *white = [UIColor whiteColor];
    //1. color the navigation bar as light blue
    UIColor * const navBarBgColor = [UIColor colorWithRed:89/255.0f green:174/255.0f blue:235/255.0f alpha:1.0f];
    
    [self setNavigationBarFontColor:white barBackgroundColor:navBarBgColor];
    
    
    //2. add left button
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancel:)];
    
    //3. add right button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Tweet" style:UIBarButtonItemStylePlain target:self action:@selector(onDone:)];
    if (_replyTo) {
        self.navigationItem.rightBarButtonItem.title = @"Reply";
    }
    
    //4. title
    [self setTitle:@"Composer" withColor:white];
    
}

-(void)setupComposerHeader {
    FMJTwitterUser *activeUser = [AccountManager sharedInstance].activeAccount.user;
    [_avatarView setImageWithURL:[NSURL URLWithString:activeUser.profileImgUrl]];
    _nameLabel.text = activeUser.username;
    _screenNameLabel.text = [NSString stringWithFormat:@"@%@", activeUser.screenName];
    
    [_avatarView fmj_AvatarStyle];
}

-(void)onCancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)onDone:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    NSString *text = _textField.text;
    if (_replyTo) {
        [[AccountManager sharedInstance].activeAccount.timeline updateTweet:_replyTo withAction:kReply  andObject:text successBlock:^(NSDictionary *response) {
            NSLog(@"reply: %@", response);
        } errorBlock:^(NSError *error){
            NSLog(@"error: %@", [error userInfo]);
        }];

    } else {
        [[AccountManager sharedInstance].activeAccount.timeline newTweet:text successBlock:^(NSDictionary * response) {
            NSLog(@"NewTeet posted: %@", response);
            
        } errorBlock:^(NSError *error) {
            NSLog(@"NewTweet failed: %@", [error userInfo]);
        }];

    }
}

@end
