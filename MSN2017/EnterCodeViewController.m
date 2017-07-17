//
//  LoginViewController.m
//  MSN
//
//  Created by Yarima on 5/11/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "EnterCodeViewController.h"
#import "ImageResizer.h"
#import "Header.h"
#import "CustomButton.h"
#import "ShakeAnimation.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <AFHTTPSessionManager.h>
#import "ProgressHUD.h"
#import "Database.h"
#import "ReplacerEngToPer.h"
#import "RootController.h"
#import "LandingPageViewController.h"
#import "HealthStatusViewController.h"
#import "ConsultationListViewController.h"
#import "UploadDocumentsViewController.h"
#import "FavoritesViewController.h"
#import "AboutViewController.h"
#import "NSString+FarsiTools.h"

@interface EnterCodeViewController()<UIScrollViewDelegate, UITextFieldDelegate>
{
    
    UIScrollView *_scrollView;
    UIPageControl *pageControl;
    UIImageView *logoImageView;
    UITextField *codeTextField;
    UIButton *sendButton;
    UIButton *resendButton;
    UIButton *registerLaterButton;
    UILabel *recordingTimerLabel;
    
}
@property int currentTimeInSeconds;
@property (weak, nonatomic) NSTimer *myTimer;
@property(nonatomic, retain)RootController *menuController;
@end
@implementation EnterCodeViewController

- (void)viewDidDisappear:(BOOL)animated{
    [ProgressHUD dismiss];
}
- (void)viewDidLoad{
    
    
    //self.view.backgroundColor = [UIColor colorWithRed:11/255.0 green:195/255.0 blue:193/255.0 alpha:1.0];
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *imageViewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissTextField)];
    [self.view addGestureRecognizer:imageViewTap];
    
    
    logoImageView = [ImageResizer resizeImageWithImage:[UIImage imageNamed:@"logo"] withWidth:screenWidth/3 withPoint:CGPointMake(screenWidth/3, 40)];
    [self.view addSubview:logoImageView];
    
    UIButton *backButtonImg = [[UIButton alloc]initWithFrame:CGRectMake(0, 16 , 45, 45)];
    [backButtonImg setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButtonImg addTarget:self action:@selector(backButtonImgAction) forControlEvents:UIControlEventTouchUpInside];
    //[self.view addSubview:backButtonImg];
    
    UILabel *titleLabel =[[UILabel alloc]initWithFrame:CGRectMake(10, logoImageView.frame.size.height + 20, screenWidth - 20, 40)];
    titleLabel.font = FONT_NORMAL(20);
    titleLabel.text = NSLocalizedString(@"dearuser", @"");
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    
    //loginTozih
    UILabel *tozihLabel =[[UILabel alloc]initWithFrame:CGRectMake(10, logoImageView.frame.size.height + 60, screenWidth - 20, 40)];
    tozihLabel.font = FONT_NORMAL(15);
    tozihLabel.text = NSLocalizedString(@"willReceiveCode", @"");
    tozihLabel.textColor = [UIColor grayColor];
    tozihLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tozihLabel];
    
    //yourMobile
    UILabel *youMobileLabel =[[UILabel alloc]initWithFrame:CGRectMake(10, logoImageView.frame.size.height + 100, screenWidth - 20, 40)];
    youMobileLabel.font = FONT_NORMAL(17);
    youMobileLabel.text = NSLocalizedString(@"yourMobile", @"");
    youMobileLabel.textColor = [UIColor blackColor];
    youMobileLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:youMobileLabel];
    
    //Mobile
    UILabel *mobileLabel =[[UILabel alloc]initWithFrame:CGRectMake(10, logoImageView.frame.size.height + 140, screenWidth - 20, 40)];
    mobileLabel.font = FONT_NORMAL(15);
    mobileLabel.text = _mobileString;
    mobileLabel.textColor = [UIColor blackColor];
    mobileLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:mobileLabel];
    
    
    codeTextField = [[UITextField alloc]initWithFrame:CGRectMake(screenWidth/2 - 100, logoImageView.frame.size.height + 200, 200, 30)];
    codeTextField.placeholder = NSLocalizedString(@"codeTaeed", @"");
    codeTextField.layer.cornerRadius = 15;
    codeTextField.backgroundColor = [UIColor whiteColor];
    codeTextField.clipsToBounds = YES;
    codeTextField.font = FONT_NORMAL(15);
    codeTextField.textAlignment = NSTextAlignmentCenter;
    codeTextField.delegate = self;
    codeTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    codeTextField.keyboardType = UIKeyboardTypeNumberPad;
    [self.view addSubview:codeTextField];
    
    sendButton = [CustomButton
                  initButtonWithTitle:NSLocalizedString(@"taeed2", @"")
                  withTitleColor:[UIColor whiteColor]
                  withBackColor:COLOR_5
                  withFrame:CGRectMake(screenWidth/2 - 80, logoImageView.frame.size.height + 260, 160, 30)];
    sendButton.titleLabel.font = FONT_NORMAL(15);
    [sendButton addTarget:self action:@selector(sendButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendButton];
    
    [self startTimer];
    
    //NSLog(@"self.navigationControllers: %@", [self.navigationController viewControllers]);
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(renewRootController) name:@"renewRootController" object:nil];
}

#pragma mark - custom methods

- (void)backButtonImgAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sendButtonAction{
    [self dismissTextField];
    if ([codeTextField.text length] == 0) {
        [ShakeAnimation startShake:codeTextField];
        return;
    }
    
    if ([self hasConnectivity]) {
        _mobileString = [_mobileString convertArabicAndFarsiNumbersToEnglish];
        codeTextField.text = [codeTextField.text convertArabicAndFarsiNumbersToEnglish];
        if ([_mobileString isEqualToString:@"09124059774"] && [codeTextField.text isEqualToString:@"1234"]) {//for demo account
            [[NSUserDefaults standardUserDefaults]setObject:codeTextField.text forKey:@"password"];
                //if ([[[dict objectForKey:@"data"]objectForKey:@"has_profile"]integerValue] == 1) {
            [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInteger:1] forKey:@"has_profile"];
            [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInteger:4] forKey:@"profileID"];
            [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInteger:3] forKey:@"userID"];
            [[NSUserDefaults standardUserDefaults]setObject:
             @"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6ImFkNzczMjBjNjFmNGExYWI5N2MwNjlkZmYzZDY3M2QwNDJiZGJmMDNhMWE4M2VkMTQ5OTU3ZDZlMTgxOGJmODE4OWY5MTkwZjA0OWUwZGEzIn0.eyJhdWQiOiIxIiwianRpIjoiYWQ3NzMyMGM2MWY0YTFhYjk3YzA2OWRmZjNkNjczZDA0MmJkYmYwM2ExYTgzZWQxNDk5NTdkNmUxODE4YmY4MTg5ZjkxOTBmMDQ5ZTBkYTMiLCJpYXQiOjE0OTcxOTI4NjMsIm5iZiI6MTQ5NzE5Mjg2MywiZXhwIjoxNTI4NzI4ODYzLCJzdWIiOiIzIiwic2NvcGVzIjpbXX0.RJABqanxJUYbnrgwsvAhAk13vUuwEyZgJEN5Qiry7Xdh0375Fola2LBfltmXAz4rF5sImjiHjYD7hm_SnXzeaWqmCtWZqlyMl-C_b2cGBeSi_AcWa4BfXIDuDBnxzyxODdPU0uMU5_clfnnQWb2LJbVPJPx5YAZDkmE3aMWmUoMTfb8XaoTTHetP75VIic34CASkplyt2oYhEin67TFArn5YNfYQ1ozRsHZY1Tm0U1YOqMMfBlYA1ImqyTxXpjFOci-DQUQUDWiz2gkfz4Xbo1oR-nz9JZ9BKqVAG3iHL_Ep2YMreebB6LgUCeUJ4prhLYeZXh2N5qaZbSiGbBeVJ0EERp2zS0PDEtE0Y0_2-54A731fcOhRJfqpAXZ67RVWX0ifakxWaxwaZYD0qaLrk9h7_k7nHcWKREayLQgQMZU6JWrEyADJqCQEFB5JZw8VJCFN1FRxfVb0FlAarJSQTHC2wT6P2qfy7lgkNwv-rokO_ClRfWamS64LbNzVwbvCeW-BLcQDfc0xjgAgBmrsgWtsEiQfx8mrLC6zMHN86dOo9xwH0FR8XoAE7Vd-6TyUxaJU3rsTDf4AJMdrc0NojdLdHg2IguQBWnmwDgv8oTUDPxTSj0uj3mngqmc6v7kXE9D-0PTIjff7XT3nrQVr7Syf2-ILz23O-k2jmakBUoQ" forKey:@"access_token"];
            [self pushToLandingpage];
        } else {
            [self validate_sms_tokenConnection];
        }
        
    }else{
        
    }
}

- (void)dismissTextField{
    if (IS_IPHONE_4_AND_OLDER_IOS7 || IS_IPHONE_4_AND_OLDER_IOS8 || IS_IPHONE_5_IOS7 || IS_IPHONE_5_IOS8) {
        [UIView animateWithDuration:0.4 animations:^{
            CGRect rect = self.view.frame;
            rect.origin.y = 0;
            [self.view setFrame:rect];
            
        }];
    }
    
    [codeTextField resignFirstResponder];
}

-(BOOL)isNumeric:(NSString*)inputString{
    BOOL isValid = NO;
    if ([inputString length] > 0) {
        NSCharacterSet *alphaNumbersSet = [NSCharacterSet decimalDigitCharacterSet];
        NSCharacterSet *stringSet = [NSCharacterSet characterSetWithCharactersInString:inputString];
        isValid = [alphaNumbersSet isSupersetOfSet:stringSet];
    }
    
    return isValid;
}

- (void)renewRootController{
    self.navigationController.viewControllers = @[[self LandingPageViewController],
                                                  [self HealthStatusViewController],
                                                  [self ConsultationListViewController],
                                                  [self UploadDocumentsViewController],
                                                  [self FavoritesViewController],
                                                  [self AboutViewController]
                                                  ];
}

- (void)pushToLandingpage{
    [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"dismissIntroView"];
    [self dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"dimissLoginView" object:nil];
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
     healthStatus.title = @"Tab3";
     healthStatus.tabBarItem.image = [UIImage imageNamed:@"BG"];
     
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
     [self.navigationController pushViewController:view animated:YES];
     */
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

- (void)showResendAndLaterButtons{
    resendButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth/2 - 100, sendButton.frame.origin.y + 60, 200, 40)];
    [resendButton setTitle:@"ارسال مجدد کد تاییدیه" forState:UIControlStateNormal];
    [resendButton setTitleColor:COLOR_5 forState:UIControlStateNormal];
    resendButton.titleLabel.font = FONT_NORMAL(13);
    [resendButton addTarget:self action:@selector(resendButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:resendButton];
    
    registerLaterButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth/2 - 100, resendButton.frame.origin.y + resendButton.frame.size.height + 20, 200, 40)];
    registerLaterButton.titleLabel.font = FONT_NORMAL(13);
    [registerLaterButton setTitle:@"بعدا ثبت نام خواهم کرد" forState:UIControlStateNormal];
    [registerLaterButton addTarget:self action:@selector(registerLaterButtonAction) forControlEvents:UIControlEventTouchUpInside];
    //[self.view addSubview:registerLaterButton];
    
}
- (void)registerLaterButtonAction{
    [self pushToLandingpage];
}

- (void)resendButtonAction{
    [self resendMobToReceiveCode];
}
#pragma mark - text field delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (IS_IPHONE_4_AND_OLDER_IOS7 || IS_IPHONE_4_AND_OLDER_IOS8 || IS_IPHONE_5_IOS7 || IS_IPHONE_5_IOS8) {
        [UIView animateWithDuration:0.5 animations:^{
            CGRect rect = self.view.frame;
            rect.origin.y -= 120;
            [self.view setFrame:rect];
            
        }];
    }
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [self dismissTextField];
    return YES;
}

#pragma mark - Timer

- (NSTimer *)createTimer {
    return [NSTimer scheduledTimerWithTimeInterval:1.0
                                            target:self
                                          selector:@selector(timerTicked:)
                                          userInfo:nil
                                           repeats:YES];
}

- (void)timerTicked:(NSTimer *)timer {
    
    _currentTimeInSeconds--;
    
    if (_currentTimeInSeconds == 0) {
        [self stopTimer];
        [self showResendAndLaterButtons];
    }
    
    recordingTimerLabel.text = [self formattedTime:_currentTimeInSeconds];
    
}

- (NSString *)formattedTime:(int)totalSeconds
{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    
    return [NSString stringWithFormat:@"%02d : %02d", minutes, seconds];
}



- (void)startTimer {
    [resendButton removeFromSuperview];
    [registerLaterButton removeFromSuperview];
    recordingTimerLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/2 - 30, sendButton.frame.origin.y + 60, 60, 25)];
    recordingTimerLabel.text = @"02 : 30";
    recordingTimerLabel.textColor = [UIColor blueColor];
    recordingTimerLabel.font = FONT_NORMAL(13);
    recordingTimerLabel.backgroundColor = [UIColor clearColor];
    recordingTimerLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:recordingTimerLabel];
    
    if (!_currentTimeInSeconds) {
        _currentTimeInSeconds = 2.5 * 60 ;
    }
    
    if (!_myTimer) {
        _myTimer = [self createTimer];
    }
}

- (void)stopTimer {
    [recordingTimerLabel removeFromSuperview];
    _currentTimeInSeconds = 0;
    [_myTimer invalidate];
}

#pragma mark - connection
- (BOOL)hasConnectivity {
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
    if(reachability != NULL) {
        //NetworkStatus retVal = NotReachable;
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(reachability, &flags)) {
            if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
            {
                // if target host is not reachable
                return NO;
            }
            
            if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
            {
                // if target host is reachable and no connection is required
                //  then we'll assume (for now) that your on Wi-Fi
                return YES;
            }
            
            
            if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
                 (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
            {
                // ... and the connection is on-demand (or on-traffic) if the
                //     calling application is using the CFSocketStream or higher APIs
                
                if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
                {
                    // ... and no [user] intervention is needed
                    return YES;
                }
            }
            
            if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
            {
                // ... but WWAN connections are OK if the calling application
                //     is using the CFNetwork (CFSocketStream?) APIs.
                return YES;
            }
        }
    }
    
    return NO;
}

- (void)validate_sms_tokenConnection{
    [ProgressHUD show:NSLocalizedString(@"retrievingdata", @"") Interaction:NO];
    if ([_mobileString length] == 0) {
        _mobileString = @"";
    }
    NSDictionary *params = @{@"username":_mobileString,
                             @"usertoken":[ReplacerEngToPer replacer:codeTextField.text]
                             };
    NSString *url = [NSString stringWithFormat:@"%@api/users/validate_sms_token", BaseURL];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        [ProgressHUD dismiss];
        NSDictionary *dict = responseObject;
        NSString *success =  [dict objectForKey:@"success"];
        if ([success integerValue] == 1) {
            [[NSUserDefaults standardUserDefaults]setObject:codeTextField.text forKey:@"password"];
            //if ([[[dict objectForKey:@"data"]objectForKey:@"has_profile"]integerValue] == 1) {
            [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInteger:[[[dict objectForKey:@"data"]objectForKey:@"has_profile"]integerValue]] forKey:@"has_profile"];
            NSInteger idOfProfile = [[[responseObject objectForKey:@"data"]objectForKey:@"entity_id"]integerValue];
            [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInteger:idOfProfile] forKey:@"profileID"];
            
            NSInteger userID = [[[responseObject objectForKey:@"data"]objectForKey:@"id"]integerValue];
            [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInteger:userID] forKey:@"userID"];
            //}
            [self getTokenConnection];
            // call Profile service
            //[self fetchProfileInfoFromServer];
        } else {
            NSString *alertMessage = [responseObject objectForKey:@"message"];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            }];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [ProgressHUD dismiss];
        
    }];
}

- (void)fetchProfileInfoFromServer{
    [ProgressHUD show:NSLocalizedString(@"retrievingdata", @"") Interaction:NO];
    NSDictionary *params = @{@"username":_mobileString,
                             @"password":codeTextField.text,
                             @"debug":@"1"
                             };
    NSString *url = [NSString stringWithFormat:@"%@profile", BaseURL];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        NSDictionary *dict = responseObject;
        NSString *login =  [dict objectForKey:@"login"];
        NSArray *medicalSectionArray = [[NSArray alloc]initWithArray:[dict objectForKey:@"medical_sections"]];
        //NSDictionary *tags = [dict objectForKey:@"tags"];
        NSDictionary *profileDic = [[dict objectForKey:@"profiles"]objectAtIndex:0];
        NSString *datetime = [dict objectForKey:@"datetime"];
        NSString *user_id = [dict objectForKey:@"user_id"];
        
        [Database initDB];
        
        for (NSInteger i = 0; i < [medicalSectionArray count]; i++) {
            NSDictionary *dic = [medicalSectionArray objectAtIndex:i];
            [Database insertIntoMedicalSectionWithFilePath:
             [Database getDbFilePath]
                                                     medID:[dic objectForKey:@"id"]
                                                   medName:[dic objectForKey:@"name"]
                                                  priority:[[dic objectForKey:@"priority"]integerValue]];
        }
        
        NSUserDefaults *defualt = [NSUserDefaults standardUserDefaults];
        [defualt setObject:_mobileString forKey:@"mobile"];
        [defualt setObject:codeTextField.text forKey:@"password"];
        [defualt setObject:user_id forKey:@"user_id"];
        
        
        if ([login integerValue]  == 1) {
            /*
             KeychainWrapper *keychainWrapper = [[KeychainWrapper alloc]init];
             [keychainWrapper mySetObject:usernameStr forKey:(__bridge id)(kSecAttrDescription)];
             [keychainWrapper mySetObject:passwordStr forKey:(__bridge id)(kSecAttrService)];
             [keychainWrapper mySetObject:doctor_user_id forKey:(__bridge id)(kSecValueData)];
             [keychainWrapper mySetObject:doctor_id forKey:(__bridge id)(kSecAttrAccount)];
             */
            [[NSUserDefaults standardUserDefaults]setObject:datetime forKey:@"dateTime"];
            //            KeychainWrapper *keychainWrapper = [[KeychainWrapper alloc]init];
            //            [keychainWrapper mySetObject:_mobileString forKey:(__bridge id)(kSecAttrDescription)];
            //            [keychainWrapper mySetObject:codeTextField.text forKey:(__bridge id)(kSecAttrService)];
            //            [keychainWrapper mySetObject:user_id forKey:(__bridge id)(kSecValueData)];
            
            //save profile dic
            NSData *profileData = [NSKeyedArchiver archivedDataWithRootObject:profileDic];
            //[keychainWrapper mySetObject:profileData forKey:(__bridge id)(kSecAttrAccount)];
            [[NSUserDefaults standardUserDefaults]setObject:profileData forKey:@"profileData"];
            [self pushToLandingpage];
            
        }else
        {
            //[self hideHUD];
            
            
            // when username or password is invalid.
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"شماره موبایل یا رمز وارد شده معتبر نیست" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                // ////NSLog(@"You pressed button OK");
            }];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [ProgressHUD dismiss];
        
    }];
}

- (void)resendMobToReceiveCode{
    
    [ProgressHUD show:NSLocalizedString(@"retrievingdata", @"") Interaction:NO];
    NSDictionary *params = @{@"username":_mobileString
                             };
    NSString *url = [NSString stringWithFormat:@"%@api/users/register", BaseURL];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        [ProgressHUD dismiss];
        NSDictionary *dict = responseObject;
        NSString *success =  [dict objectForKey:@"success"];
        if ([success integerValue] == 1) {
            NSString *alertMessage = [responseObject objectForKey:@"message"];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"error", @"") message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            }];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            
            [self startTimer];
            
        } else {
            NSString *alertMessage = [responseObject objectForKey:@"message"];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"error", @"") message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            }];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [ProgressHUD dismiss];
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:NSLocalizedString(@"errorinData", @"")
                                      message:[NSString stringWithFormat:@"%@",[error localizedDescription]]
                                      preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"OK", @"")
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 
                             }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }];
    
}

- (void)getTokenConnection{
    [ProgressHUD show:NSLocalizedString(@"retrievingdata", @"") Interaction:NO];
    NSDictionary *params = @{@"grant_type":@"password",
                             @"client_id":[NSNumber numberWithInt:1],
                             @"client_secret":@"kce0FrFNCGwa2XGBdMWyMpCbXwX9ejgmfXtXWnMy",
                             @"username":_mobileString,
                             @"password":codeTextField.text,
                             };
    NSString *url = [NSString stringWithFormat:@"%@api/oauth/token", BaseURL];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        [ProgressHUD dismiss];
        NSDictionary *dict = responseObject;
        NSString *accessToken =  [dict objectForKey:@"access_token"];
        [[NSUserDefaults standardUserDefaults]setObject:accessToken forKey:@"access_token"];
        [self pushToLandingpage];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [ProgressHUD dismiss];
        
    }];
}

@end
