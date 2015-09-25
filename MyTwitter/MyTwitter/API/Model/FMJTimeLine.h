//
//  FMJTimeLine.h
//  MyTwitter
//
//  Created by Cristan Zhang on 9/25/15.
//  Copyright (c) 2015 FSManJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FMJTimeLineDelegate <NSObject>

-(void)didUpdateTimeline:(BOOL)hasMore;

@end


@interface FMJTimeLine : NSObject

@property NSMutableArray *homeTimeLine;//home time line
@property NSMutableArray *userTimeLine;//user's own time line, include only user's tweets & replies
@property NSMutableArray *pendingTweets;
@property BOOL hasMore;

@property (nonatomic, weak) id<FMJTimeLineDelegate> delegate;

-(void)loadMore:(BOOL)refresh;
-(void)refresh;

@end
