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
    _tweet = tweet;
    [_userImage setImageWithURL:[NSURL URLWithString:tweet.user.profileImgUrl]];
    [self setupProfileImage];
    
    _userName.text= tweet.user.username;
    _text.text = tweet.text;
    _screenName.text = [NSString stringWithFormat:@"@%@", tweet.user.screenName];
    
    NSDate *timeAgoDate = [NSDate dateWithString:tweet.createTime formatString:@"eee MMM dd HH:mm:ss ZZZZ yyyy"];

    _timeLabel.text = [timeAgoDate shortTimeAgoSinceNow];
    
    [self updateIconStates];
}
- (IBAction)onTapFavorite:(id)sender {
    _tweet.faved = !_tweet.faved;
    
    [_delegate onFav:_tweet];
    
    [self updateIconStates];
}

- (IBAction)onTapRetweet:(id)sender {
    [_delegate onRetweet:_tweet];
    _tweet.retweeted = YES;
    [self updateIconStates];
}

- (IBAction)onTapReply:(id)sender {
    [_delegate onReply:_tweet];

}

-(void) setupProfileImage {
    _userImage.layer.cornerRadius = 10.0f;
    _userImage.clipsToBounds = YES;
    _userImage.layer.borderColor = [UIColor whiteColor].CGColor;
    _userImage.layer.borderWidth = 2.0f;
}

-(void) updateIconStates {
    //fav icon
    if (_tweet.faved) {
        [_favButton setImage:[UIImage imageNamed:@"favorite_on.png"] forState:UIControlStateNormal];
    } else {
        [_favButton setImage:[UIImage imageNamed:@"favorite.png"] forState:UIControlStateNormal];
    }
    //retweeted icon
    if (_tweet.retweeted) {
        [_retweetButton setImage:[UIImage imageNamed:@"retweet_on.png"] forState:UIControlStateNormal];
    } else {
        [_retweetButton setImage:[UIImage imageNamed:@"retweet.png"] forState:UIControlStateNormal];
    }
}

@end
