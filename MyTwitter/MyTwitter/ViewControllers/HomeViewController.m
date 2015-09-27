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
#import "FMJTweetCell.h"
#import "FMJTwitterTweet.h"
#import "FMJTimeLine.h"
#import "MBProgressHUD.h"
#import "ComposerViewController.h"
#import "UIViewController+FMJTwitter.h"

@interface HomeViewController () <FMJTweetCellDelegate>

@property Account *activeAccount;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property UIRefreshControl* refreshControl;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //listen to login
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onUserLogin:)
                                                 name:kEventUserLogin
                                               object:nil];
    //listen to logout
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onUserLogout:)
                                                 name:kEventUserLogout
                                               object:nil];
    
    [self styleNavigationBar];
    
    [[AccountManager sharedInstance] restoreUserSession];
    _activeAccount = [AccountManager sharedInstance].activeAccount;
    
    if (_activeAccount == nil) {
        _activeAccount  = [[AccountManager sharedInstance] accountWithWebLoginFromViewControler:self];
        //_activeAccount = [Account initWithiOSAccountFromView:self.view];
    }

    _activeAccount.timeline.delegate = self;
    
    [self setupTableView];
}

-(void)viewDidAppear:(BOOL)animated {
    [_tableView reloadData];
}

- (void)setupTableView {
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    [_tableView setEstimatedRowHeight:236];
    [_tableView setRowHeight:UITableViewAutomaticDimension];
    
    //add a PTR control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    //
    UINib *nib = [UINib nibWithNibName:[FMJTweetCell description] bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:[FMJTweetCell description]];
    
}

- (void)styleNavigationBar {
    UIColor *white = [UIColor whiteColor];
    UIColor * const navBarBgColor = [UIColor colorWithRed:89/255.0f green:174/255.0f blue:235/255.0f alpha:1.0f];
    
    //1. color the navigation bar as light blue
    [self setNavigationBarFontColor:white barBackgroundColor:navBarBgColor];
    
    //2. add left button
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logout:)];

    //3. add right button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"New" style:UIBarButtonItemStylePlain target:self action:@selector(newPost:)];
    
    //4. title
    [self setTitle:@"Home" withColor:white];
    
}

- (void)onRefresh:(id)sender {
    [_activeAccount.timeline refresh];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

#pragma MARK delegate from timeline

-(void)didUpdateTimeline:(BOOL)hasMore {
    [self.refreshControl endRefreshing];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [_tableView reloadData];
}

#pragma Notification from Account Manager

- (void)onUserLogin:(id) sender {

    [_activeAccount.timeline refresh];
}

- (void)onUserLogout:(id) sender {
    /*FiltersViewController* filtersPage = [[FiltersViewController alloc] init];
     filtersPage.delegate = self;
     [self.navigationController pushViewController:filtersPage animated:YES];*/
    
    //reload home with null data
}



- (void)logout:(id) sender {
    [[AccountManager sharedInstance] logout];
}

- (void)newPost:(id) sender {
    ComposerViewController *composer = [[ComposerViewController alloc] init];
    [self.navigationController pushViewController:composer animated:YES];
}

#pragma MARK - FMJTwitterCellDelegate

-(void)onReply:(FMJTwitterTweet *)tweet {
    ComposerViewController *composer = [[ComposerViewController alloc] init];
    composer.replyTo = tweet;
    
    [self.navigationController pushViewController:composer animated:YES];
}

-(void)onRetweet:(FMJTwitterTweet *)tweet {
    [_activeAccount.timeline updateTweet:tweet withAction:kRetweet andObject:nil successBlock:^(NSDictionary *response) {
        NSLog(@"reply: %@", response);
    } errorBlock:^(NSError *error){
        NSLog(@"error: %@", [error userInfo]);
    }];
}

-(void)onFav:(FMJTwitterTweet *)tweet {
    [_activeAccount.timeline updateTweet:tweet withAction:kFavorite  andObject:nil successBlock:^(NSDictionary *response) {
        NSLog(@"reply: %@", response);
    } errorBlock:^(NSError *error){
        NSLog(@"error: %@", [error userInfo]);
    }];
}

#pragma Tableview datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _activeAccount.timeline.homeTimeLine.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *simpleTableIdentifier = [FMJTweetCell description];
    
    FMJTweetCell *cell = (FMJTweetCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:simpleTableIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


- (void)configureCell:(FMJTweetCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    NSArray* timeline = _activeAccount.timeline.homeTimeLine;
    FMJTwitterTweet* tweet = timeline[row];
    [cell initWithTweet:tweet];
    
    cell.delegate = self;
}


#pragma tableview delegate
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    NSArray* timeline = _activeAccount.timeline.homeTimeLine;
    FMJTwitterTweet* tweet = timeline[row];
    if (tweet.mediaUrl) {
        return 300;
    } else {
        return 120;
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void) dealloc
{
    // If you don't remove yourself as an observer, the Notification Center
    // will continue to try and send notification objects to the deallocated
    // object.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
