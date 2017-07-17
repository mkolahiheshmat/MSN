//
//  ImageViewController.m
//  AdvisorsHealthCloud
//
//  Created by Yarima on 12/15/15.
//  Copyright (c) 2015 Yarima. All rights reserved.
//

#import "ImageViewController.h"
#import "UIImageView+AFNetworking.h"
#import "ImageResizer.h"
#import "DocumentDirectoy.h"
#import "Header.h"
//#import <Google/Analytics.h>

@interface ImageViewController ()<UIScrollViewDelegate>
{
     
    UIView *headerView;
    UIScrollView *scrollView;
    UIActivityIndicatorView *activityIndicator;
}
@property(nonatomic, retain)UIImageView *imageView;

@end

@implementation ImageViewController

/*
 - (void)viewWillAppear:(BOOL)animated{
 id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
 [tracker set:kGAIScreenName value:@"AdvisorsHealthCloud"];
 [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
 
 }
 */
- (void)viewDidLoad {
    self.navigationController.navigationBar.hidden = YES;

    [super viewDidLoad];
        //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"titleColor.png"]];
#pragma mark - header view
    headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth , 66)];
    headerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"titleColor.png"]];
    [self.view addSubview:headerView];
    
    [self makeTopbar];
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 66, screenWidth, screenHeight - 66)];
    scrollView.delegate = self;
    scrollView.minimumZoomScale = 1.0;
    scrollView.maximumZoomScale = 100.0;
    scrollView.userInteractionEnabled = YES;
    [self.view addSubview:scrollView];
    activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    self.imageView.userInteractionEnabled = YES;
    UIImage *tempImage = [self loadImageFilesWithPath:self.imageViewPath];
    if (tempImage) {
        self.imageView = [ImageResizer resizeImageWithImage:tempImage withHeight:screenWidth withPoint:CGPointMake(10, 66)];
    } else {
        activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicator.center = CGPointMake(self.imageView.frame.size.width/2, self.imageView.frame.size.height/2);
        [self.imageView addSubview:activityIndicator];
        [activityIndicator startAnimating];
        NSURLRequest *imageRequest = [[NSURLRequest alloc]initWithURL:
                                      [NSURL URLWithString:[NSString stringWithFormat:@"%@",self.imageViewURL]]];
        
        __unsafe_unretained typeof(self) weakSelf = self;
        [self.imageView setImageWithURLRequest:imageRequest placeholderImage:nil
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
             [weakSelf->activityIndicator setHidden:YES];
             [weakSelf->activityIndicator stopAnimating];
             weakSelf.imageView.image = image;
             weakSelf.imageView = [ImageResizer resizeImageWithImage:weakSelf.imageView.image withWidth:screenWidth withPoint:CGPointMake(0, 66)];
             //[weakSelf->scrollView addSubview:weakSelf->imageView];
             weakSelf->scrollView.contentSize = weakSelf.imageView.image.size;
         }
                                       failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
         {
             [weakSelf->activityIndicator setHidden:YES];
             [weakSelf->activityIndicator stopAnimating];
         }];
    }
    [scrollView addSubview:self.imageView];
    
    
    CGPoint centerPoint = CGPointMake(CGRectGetMidX(scrollView.bounds),
                                      CGRectGetMidY(scrollView.bounds));
    [self view:self.imageView setCenter:centerPoint];
    
    //NSLog(@"self.navigationControllers: %@", [self.navigationController viewControllers]);
}

- (void)makeTopbar{
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 70)];
    topView.backgroundColor = COLOR_3;
    [topView makeGradient:topView];
    [self.view addSubview:topView];
    
    CGFloat topViewHeight = topView.frame.size.height;
    
    UILabel *titleLabel =[[UILabel alloc]initWithFrame:CGRectMake(screenWidth/2 - 100, topViewHeight/2 - 15, 200, 40)];
    titleLabel.font = FONT_NORMAL(20);
    titleLabel.text = NSLocalizedString(@"favorites", @"");
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    //[topView addSubview:titleLabel];
    
    UIButton *backButtonImg = [[UIButton alloc]initWithFrame:CGRectMake(0, 16 , 45, 45)];
    [backButtonImg setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButtonImg addTarget:self action:@selector(backButtonImgAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButtonImg];
    
}

- (UIImage *)loadImageFilesWithPath:(NSString *)path{
    UIImageView *tempImageView = [[UIImageView alloc]init];
    tempImageView.image = [UIImage imageWithContentsOfFile:path];
    return tempImageView.image;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backButtonImgAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)view:(UIView*)view setCenter:(CGPoint)centerPoint
{
    CGRect vf = view.frame;
    CGPoint co = scrollView.contentOffset;
    
    CGFloat x = centerPoint.x - vf.size.width / 2.0;
    CGFloat y = centerPoint.y - vf.size.height / 2.0;
    
    if(x < 0)
    {
        co.x = -x;
        vf.origin.x = 0.0;
    }
    else
    {
        vf.origin.x = x;
    }
    if(y < 0)
    {
        co.y = -y;
        vf.origin.y = 0.0;
    }
    else
    {
        vf.origin.y = y;
    }
    
    view.frame = vf;
    scrollView.contentOffset = co;
}

- (void)scrollViewDidZoom:(UIScrollView *)sv
{
    UIView* zoomView = [sv.delegate viewForZoomingInScrollView:sv];
    CGRect zvf = zoomView.frame;
    if(zvf.size.width < sv.bounds.size.width)
    {
        zvf.origin.x = (sv.bounds.size.width - zvf.size.width) / 2.0;
    }
    else
    {
        zvf.origin.x = 0.0;
    }
    if(zvf.size.height < sv.bounds.size.height)
    {
        zvf.origin.y = (sv.bounds.size.height - zvf.size.height) / 2.0;
    }
    else
    {
        zvf.origin.y = 0.0;
    }
    zoomView.frame = zvf;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

@end
