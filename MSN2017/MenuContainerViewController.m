//
//  MenuContainerViewController.m
//  MSN
//
//  Created by Yarima on 7/17/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "MenuContainerViewController.h"
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
#import "IntroViewController.h"
#import "SearchViewController.h"
@interface MenuContainerViewController(){
     
}
@property(nonatomic, retain)RootController *menuController;
@end

@implementation MenuContainerViewController
- (void)viewDidLoad{
     
    [self pushToLandingpage];
    //[self showIntroView];
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

- (SearchViewController *)SearchViewController{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SearchViewController *view = (SearchViewController *)[story instantiateViewControllerWithIdentifier:@"SearchViewController"];
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

- (IntroViewController *)IntroViewController{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    IntroViewController *view = (IntroViewController *)[story instantiateViewControllerWithIdentifier:@"IntroViewController"];
    return view;
}

- (void)pushToLandingpage{
    _menuController = [[RootController alloc]
                       initWithViewControllers:
                       @[[self LandingPageViewController],
                         [self HealthStatusViewController],
                         [self ConsultationListViewController],
                         [self UploadDocumentsViewController],
                         [self FavoritesViewController],
                         [self AboutViewController],
                         [self SearchViewController]
                         ]
                       andMenuTitles:@[ NSLocalizedString(@"mainView", @""),
                                        NSLocalizedString(@"healthStatus", @""),
                                        NSLocalizedString(@"consulting", @""),
                                        NSLocalizedString(@"uploadfiles", @""),
                                        NSLocalizedString(@"favorites", @""),
                                        NSLocalizedString(@"aboutus", @""),
                                        NSLocalizedString(@"search", @"")]
                       ];
    
    self.navigationController.viewControllers = [NSArray arrayWithObject: _menuController];
    
    NSString *goToConsultationListFromPushNotif = [[NSUserDefaults standardUserDefaults]objectForKey:@"goToConsultationListFromPushNotif"];
    if ([goToConsultationListFromPushNotif isEqualToString:@"YES"]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"GoToConsultationViewFromLandingPageDirectly" object:nil];
    }
}

- (void)showIntroView{
    [self.navigationController pushViewController:[self IntroViewController] animated:YES];
}

@end
