//
//  FMJTweetCell.h
//  MyTwitter
//
//  Created by Cristan Zhang on 9/25/15.
//  Copyright (c) 2015 FSManJi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FMJTwitterTweet;

@protocol FMJTweetCellDelegate <NSObject>

-(void)onReply:(NSString *)tweetID;
-(void)onRetweet:(NSString *)tweetID;
-(void)onFav:(NSString *)tweetID;

@end

@interface FMJTweetCell : UITableViewCell

@property NSString *tweetID;
@property id<FMJTweetCellDelegate> delegate;

-(void)initWithTweet:(FMJTwitterTweet*)tweet;

@end
