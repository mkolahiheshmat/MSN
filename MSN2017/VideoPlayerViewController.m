//
//  VideoPlayerViewController.m
//  MSN
//
//  Created by Yarima on 5/17/16.
//  Copyright © 2016 Arash. All rights reserved.
//


#import "VideoPlayerViewController.h"
#import "DocumentDirectoy.h"
#import "NSDictionary+LandingPageTableView.h"
#import "Header.h"
#import "ProgressHUD.h"
@interface VideoPlayerViewController()<UIWebViewDelegate, UIScrollViewDelegate>
{
     
}
@end
@implementation VideoPlayerViewController

- (void)viewDidLoad{
    self.navigationController.navigationBar.hidden = YES;
    [self makeTopBar];
    [self makeVideoView];
    
    //NSLog(@"self.navigationControllers: %@", [self.navigationController viewControllers]);
}

- (void)makeTopBar{
    
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 70)];
    topView.backgroundColor = COLOR_3;
    [topView makeGradient:topView];
    [self.view addSubview:topView];
    
    CGFloat topViewHeight = topView.frame.size.height;
    
    UILabel *titleLabel =[[UILabel alloc]initWithFrame:CGRectMake(screenWidth/2 - 100, topViewHeight/2 - 15, 200, 40)];
    titleLabel.font = FONT_NORMAL(20);
    titleLabel.text = _titleString;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:titleLabel];
    
    UIButton *backButtonImg = [[UIButton alloc]initWithFrame:CGRectMake(0, 16 , 45, 45)];
    [backButtonImg setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButtonImg addTarget:self action:@selector(backButtonImgAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButtonImg];
}

- (void)makeVideoView{
    UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 70, screenWidth, screenHeight - 70)];
    webView.delegate = self;
    [self.view addSubview:webView];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", _urlString]]]];
    [ProgressHUD show:@""];
}

- (void)backButtonImgAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [ProgressHUD dismiss];
    [webView setScalesPageToFit:YES];
    webView.scrollView.delegate = self; // set delegate method of UISrollView
    webView.scrollView.maximumZoomScale = 20; // set as you want.
    webView.scrollView.minimumZoomScale = 1; // set as you want.
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    [ProgressHUD dismiss];
    NSLog(@"Error for WEBVIEW: %@", [error description]);
}
@end
