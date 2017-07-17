//
//  IntroViewController.m
//  MSN
//
//  Created by Yarima on 5/11/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "IntroViewController.h"
#import "ImageResizer.h"
#import "Header.h"
#import "CustomButton.h"
#import "LoginViewController.h"
#import "GetUsernamePassword.h"
#import "RootController.h"
#import "LandingPageViewController.h"
#import "HealthStatusViewController.h"
#import "ConsultationListViewController.h"
#import "UploadDocumentsViewController.h"
#import "FavoritesViewController.h"
#import "AboutViewController.h"
#import "EnterCodeViewController.h"
@interface IntroViewController()<UIScrollViewDelegate>
{
    
    UIScrollView *_scrollView;
    UIPageControl *pageControl;
    UIImageView *logoImageView;
}
@property(nonatomic, retain)RootController *menuController;
@end
@implementation IntroViewController

- (void)viewDidLoad{
}
- (void)viewWillAppear:(BOOL)animated
{
    NSString *str = [[NSUserDefaults standardUserDefaults]objectForKey:@"mobile"];
    if ([str length] != 11) {
        [self registerButtonAction];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }

    
    /*
    self.view.backgroundColor = [UIColor colorWithRed:35/255.0 green:199/255.0 blue:197/255.0 alpha:1.0];
    logoImageView = [ImageResizer resizeImageWithImage:[UIImage imageNamed:@"logo"] withWidth:screenWidth withPoint:CGPointMake(0, 0)];
    [self.view addSubview:logoImageView];
    
    CGFloat yPosOfScrollview = logoImageView.frame.size.height - 1;
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, yPosOfScrollview, screenWidth, screenHeight - yPosOfScrollview)];
    _scrollView.pagingEnabled = YES;
    _scrollView.clipsToBounds = NO;
    _scrollView.delegate = self;
    [_scrollView setContentSize:CGSizeMake(screenWidth * 4, screenHeight - yPosOfScrollview)];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_scrollView];
    
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(screenWidth/2 - 100,screenHeight - 40, 200, 50)];
    pageControl.numberOfPages = 4;
    pageControl.currentPage = 0;
    [self.view addSubview:pageControl];
    pageControl.backgroundColor = [UIColor clearColor];
    
    [self setupImages];
    
    //NSLog(@"self.navigationControllers: %@", [self.navigationController viewControllers]);
    NSString *dismissStr = [[NSUserDefaults standardUserDefaults]objectForKey:@"dismissIntroView"];
    if ([dismissStr isEqualToString:@"YES"]) {
        [self backButtonImgAction];
    }
     */
}

#pragma mark - custom methods

-(BOOL)isNumeric:(NSString*)inputString{
    BOOL isValid = NO;
    if ([inputString length] > 0) {
        NSCharacterSet *alphaNumbersSet = [NSCharacterSet decimalDigitCharacterSet];
        NSCharacterSet *stringSet = [NSCharacterSet characterSetWithCharactersInString:inputString];
        isValid = [alphaNumbersSet isSupersetOfSet:stringSet];
    }
    
    return isValid;
}

- (LandingPageViewController *)LandingPageViewController{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LandingPageViewController *view = (LandingPageViewController *)[story instantiateViewControllerWithIdentifier:@"LandingPageViewController"];
    return view;
}

- (UploadDocumentsViewController *)UploadDocumentsViewController{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UploadDocumentsViewController *view = (UploadDocumentsViewController *)[story instantiateViewControllerWithIdentifier:@"UploadDocumentsViewController"];
    return view;
    
}

- (ConsultationListViewController *)ConsultationListViewController{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ConsultationListViewController *view = (ConsultationListViewController *)[story instantiateViewControllerWithIdentifier:@"ConsultationListViewController"];
    return view;
}

- (HealthStatusViewController *)HealthStatusViewController{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HealthStatusViewController *view = (HealthStatusViewController *)[story instantiateViewControllerWithIdentifier:@"HealthStatusViewController"];
    return view;
}

- (FavoritesViewController *)FavoritesViewController{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FavoritesViewController *view = (FavoritesViewController *)[story instantiateViewControllerWithIdentifier:@"FavoritesViewController"];
    return view;
}

- (AboutViewController *)AboutViewController{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AboutViewController *view = (AboutViewController *)[story instantiateViewControllerWithIdentifier:@"AboutViewController"];
    return view;
}

- (void)backButtonImgAction{
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"dismissIntroView"];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)pushToLandingpage{
    //    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //    UploadDocumentsViewController *view = (UploadDocumentsViewController *)[story instantiateViewControllerWithIdentifier:@"UploadDocumentsViewController"];
    //    view.isFromDirectQuestion = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self.navigationController pushViewController:[self LandingPageViewController] animated:YES];
    /*
     UITabBarController *tabBarController = [[UITabBarController alloc] init];
     UINavigationController *landingpage = [[UINavigationController alloc]
     initWithRootViewController:[self LandingPageViewController]];
     landingpage.title = @"Tab1";
     landingpage.tabBarItem.image = [UIImage imageNamed:@"BG"];
     
     UINavigationController *healthStatus = [[UINavigationController alloc]
     initWithRootViewController:[self HealthStatusViewController]];
     healthStatus.title = @"Tab2";
     healthStatus.tabBarItem.image = [UIImage imageNamed:@"BG"];
     
     UINavigationController *consultationList = [[UINavigationController alloc]
     initWithRootViewController:[self ConsultationListViewController]];
     consultationList.title = @"Tab3";
     consultationList.tabBarItem.image = [UIImage imageNamed:@"BG"];
     
     UINavigationController *uploadDocs = [[UINavigationController alloc]
     initWithRootViewController:[self UploadDocumentsViewController]];
     uploadDocs.title = @"Tab4";
     uploadDocs.tabBarItem.image = [UIImage imageNamed:@"BG"];
     
     UINavigationController *favorites = [[UINavigationController alloc]
     initWithRootViewController:[self FavoritesViewController]];
     favorites.title = @"Tab5";
     favorites.tabBarItem.image = [UIImage imageNamed:@"BG"];
     
     NSArray* controllers = [NSArray arrayWithObjects:
     landingpage,
     healthStatus,
     consultationList,
     uploadDocs,
     favorites,nil];
     [tabBarController setViewControllers:controllers animated:NO];
     [[self navigationController] pushViewController:tabBarController animated:YES];
     
     
     //NSLog(@"navigation controller:%@", self.navigationController);
     if (!_menuController) {
     NSString *visitWithoutLogin = [[NSUserDefaults standardUserDefaults]objectForKey:@"VisitWithoutLogin"];
     //if ([visitWithoutLogin length] == 0) {
     _menuController = [[RootController alloc]
     initWithViewControllers:
     @[[self LandingPageViewController],
     [self HealthStatusViewController],
     [self ConsultationListViewController],
     [self UploadDocumentsViewController],
     [self FavoritesViewController],
     [self AboutViewController]
     ]
     andMenuTitles:@[ NSLocalizedString(@"mainView", @""),
     NSLocalizedString(@"healthStatus", @""),
     NSLocalizedString(@"consulting", @""),
     NSLocalizedString(@"uploadfiles", @""),
     NSLocalizedString(@"favorites", @""),
     NSLocalizedString(@"aboutus", @"")]
     ];
     
     self.navigationController.viewControllers = [NSArray arrayWithObject: _menuController];
     //        } else {
     //            self.navigationController.viewControllers = [NSArray arrayWithObject: [self LandingPageViewController]];
     //        }
     
     [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"VisitWithoutLogin"];
     //NSLog(@"self.navigationControllers: %@", self.navigationController.viewControllers);
     }
     */
    /*
     UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
     LandingPageViewController *view = (LandingPageViewController *)[story instantiateViewControllerWithIdentifier:@"LandingPageViewController"];
     self.navigationController.viewControllers = [NSArray arrayWithObject:view];
     [self.navigationController pushViewController:view animated:NO];
     */
}

- (void)setupImages{
    CGFloat xPos = 0;
    NSArray *imageArray = [NSArray arrayWithObjects:
                           @"slider1",
                           @"slider2",
                           @"slider3",
                           nil];
    
    for (int i = 0; i < [imageArray count] ; i++) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, 0, screenWidth, _scrollView.frame.size.height)];
        NSString *imageName = [NSString stringWithFormat:@"%@", [imageArray objectAtIndex:i]];
        imageView.image = [UIImage imageNamed:imageName];
        [_scrollView addSubview:imageView];
        
        if (i  < [imageArray count]) {
            _scrollView.userInteractionEnabled = YES;
            UIButton *nextButton = [CustomButton initButtonWithTitle:@"" withTitleColor:[UIColor clearColor] withBackColor:[UIColor clearColor] withFrame:CGRectMake(xPos + (screenWidth - 40), _scrollView.frame.size.height / 2 - 15, 18, 30)];
            nextButton.tag = i;
            [nextButton setBackgroundImage:[UIImage imageNamed:@"arrow2"] forState:UIControlStateNormal];
            [nextButton addTarget:self action:@selector(nextButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [_scrollView addSubview:nextButton];
        }
        
        xPos += screenWidth;
    }
    
    UIView *lastView = [[UIView alloc]initWithFrame:CGRectMake(xPos, 0, screenWidth, _scrollView.frame.size.height)];
    lastView.backgroundColor = [UIColor colorWithRed:11/255.0 green:195/255.0 blue:193/255.0 alpha:1.0];
    [_scrollView addSubview:lastView];
    
    UILabel *titleLabel =[[UILabel alloc]initWithFrame:CGRectMake(10, 20, screenWidth - 20, 40)];
    titleLabel.font = FONT_NORMAL(20);
    titleLabel.text = NSLocalizedString(@"liveHealthier", @"");
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [lastView addSubview:titleLabel];
    
    UIButton *registerButton = [CustomButton
                                initButtonWithTitle:NSLocalizedString(@"register", @"")
                                withTitleColor:[UIColor whiteColor]
                                withBackColor:[UIColor colorWithRed:2/255.0 green:148/255.0 blue:151/255.0 alpha:1.0]
                                withFrame:CGRectMake(screenWidth/2 - 130, titleLabel.frame.origin.y + 80, 260, 50)];
    registerButton.titleLabel.font = FONT_NORMAL(15);
    [registerButton addTarget:self action:@selector(registerButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [lastView addSubview:registerButton];
    
    UIButton *registerLaterButton = [CustomButton
                                     initButtonWithTitle:NSLocalizedString(@"registerLater", @"")
                                     withTitleColor:[UIColor whiteColor]
                                     withBackColor:[UIColor clearColor]
                                     withFrame:CGRectMake(screenWidth/2 - 130, registerButton.frame.origin.y + 80, 260, 50)];
    registerLaterButton.titleLabel.font = FONT_NORMAL(15);
    [registerLaterButton addTarget:self action:@selector(registerLaterButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [lastView addSubview:registerLaterButton];
    
    NSString *mobileStr = [[NSUserDefaults standardUserDefaults]objectForKey:@"mobile"];
    if ([mobileStr length] > 0) {
        UIButton *entercodeButton = [CustomButton
                                     initButtonWithTitle:NSLocalizedString(@"entercode", @"")
                                     withTitleColor:[UIColor whiteColor]
                                     withBackColor:[UIColor clearColor]
                                     withFrame:CGRectMake(screenWidth/2 - 130, registerLaterButton.frame.origin.y + 80, 260, 50)];
        entercodeButton.titleLabel.font = FONT_NORMAL(15);
        [entercodeButton addTarget:self action:@selector(entercodeButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [lastView addSubview:entercodeButton];
    }
    
    
}

- (void)registerButtonAction{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *view = (LoginViewController *)[story instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [self presentViewController:view animated:YES completion:nil];
    //[self.navigationController pushViewController:view animated:YES];
}

- (void)registerLaterButtonAction{
    [self pushToLandingpage];
}

- (void)entercodeButtonAction{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    EnterCodeViewController *view = (EnterCodeViewController *)[story instantiateViewControllerWithIdentifier:@"EnterCodeViewController"];
    view.mobileString = [[NSUserDefaults standardUserDefaults]objectForKey:@"mobile"];
    [self presentViewController:view animated:YES completion:nil];
    //[self.navigationController pushViewController:view animated:YES];
}
#pragma mark - scrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    pageControl.currentPage = page;
}

- (void)nextButtonAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    //NSLog(@"%ld", (long)btn.tag);
    [_scrollView scrollRectToVisible:CGRectMake(screenWidth * (btn.tag + 1), _scrollView.frame.origin.y, screenWidth, _scrollView.frame.size.height) animated:YES];
}
@end
