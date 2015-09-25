//
//  WebViewController.m
//  MyTwitter
//
//  Created by Cristan Zhang on 9/24/15.
//  Copyright (c) 2015 FSManJi. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


- (IBAction)onCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)sendRequest:(NSURLRequest *)request{
    [_webView loadRequest:request];
}

@end
