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
        _activeAccount = [Account initWithWebLoginFromViewControler:self];
        //_activeAccount = [Account initWithiOSAccountFromView:self.view];
    }

}

- (void)configureTableView {
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    [_tableView setEstimatedRowHeight:96];
    [_tableView setRowHeight:UITableViewAutomaticDimension];
    
    //add a PTR control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    //
    UINib *nib = [UINib nibWithNibName:@"BusinessTableViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"BusinessTableViewCell"];
    
}

- (void)styleNavigationBar {
    
    self.navigationItem.title = @"Home";
    
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
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logout:)];
    
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];

    //3. add right button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"New" style:UIBarButtonItemStylePlain target:self action:@selector(newPost:)];
    
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];

}

- (void)onRefresh:(id)sender {
    [_activeAccount.timeline refresh];
}

#pragma MARK delegate from timeline

-(void)didUpdateTimeline:(BOOL)hasMore {
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
    /*FiltersViewController* filtersPage = [[FiltersViewController alloc] init];
    filtersPage.delegate = self;
    [self.navigationController pushViewController:filtersPage animated:YES];*/
    
    //reload home with null data
}

- (void)newPost:(id) sender {
    //lauch composer
}



#pragma Tableview datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _activeAccount.timeline.homeTimeLine.count;
}
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"BusinessTableViewCell";
    
    BusinessTableViewCell *cell = (BusinessTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BusinessTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(BusinessTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    Business * business = _searchResult[row];
    cell.nameLabel.text = business.name;
    cell.reviewsLabel.text = business.reviews;
    cell.addrLabel.text = business.address;
    cell.categoryLabel.text = [[business.categories valueForKey:@"description"] componentsJoinedByString:@","];
    [cell.avatarView setImageWithURL:[NSURL URLWithString:business.photoUrl]];
    [cell.ratingImageView setImageWithURL:[NSURL URLWithString:business.ratingImgUrl]];
}
*/

#pragma tableview delegate

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


#pragma Mark private methods
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

- (void) dealloc
{
    // If you don't remove yourself as an observer, the Notification Center
    // will continue to try and send notification objects to the deallocated
    // object.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
