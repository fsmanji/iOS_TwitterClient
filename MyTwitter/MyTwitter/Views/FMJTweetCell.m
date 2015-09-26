//
//  FMJTweetCell.m
//  MyTwitter
//
//  Created by Cristan Zhang on 9/25/15.
//  Copyright (c) 2015 FSManJi. All rights reserved.
//

#import "FMJTweetCell.h"
#import "FMJTwitterTweet.h"
#import "UIImageView+AFNetworking.h"
#import <NSDate+DateTools.h>

@interface FMJTweetCell ()
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *screenName;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *text;

@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *favButton;


@end

@implementation FMJTweetCell

-(void)initWithTweet:(FMJTwitterTweet*)tweet {
    _tweetID = tweet.tweetID;
    [_userImage setImageWithURL:[NSURL URLWithString:tweet.user.profileImgUrl]];
    [self setupProfileImage];
    
    _userName.text= tweet.user.username;
    _text.text = tweet.text;
    _screenName.text = tweet.user.screenName;
    
    NSDate *timeAgoDate = [NSDate dateWithString:tweet.createTime formatString:@"eee MMM dd HH:mm:ss ZZZZ yyyy"];

    _timeLabel.text = [timeAgoDate shortTimeAgoSinceNow];
}
- (IBAction)onTapFavorite:(id)sender {
    [_delegate onFav:_tweetID];
}

- (IBAction)onTapRetweet:(id)sender {
    [_delegate onRetweet:_tweetID];
}

- (IBAction)onTapReply:(id)sender {
    [_delegate onReply:_tweetID];
}

-(void) setupProfileImage {
    _userImage.layer.cornerRadius = 10.0f;
    _userImage.clipsToBounds = YES;
    _userImage.layer.borderColor = [UIColor whiteColor].CGColor;
    _userImage.layer.borderWidth = 2.0f;
}

@end
