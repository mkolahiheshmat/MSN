//
//  CustomPageViewController.m
//  MSN
//
//  Created by Yarima on 8/23/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "CustomPageViewController.h"
#import "Header.h"
#import <UIImageView+AFNetworking.h>
#import "LandingPageDetailViewController.h"
#import "DoctorPageViewController.h"
#import "ClinicViewController.h"
#import "AnjomanViewController.h"
#import "SearchViewController.h"
@interface CustomPageViewController ()

@end

@implementation CustomPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = self.bgColor;

    [self makeTopBar];
    
    self.myImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 70, screenWidth, 300)];
    NSArray *arr = [_imageURL componentsSeparatedByString:@"png"];
    //NSLog(@"%@", arr[0]);
    [self.myImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@png", arr[0]]]];
    [self.view addSubview:self.myImage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)makeTopBar{
    
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 70)];
    topView.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:0.5];
    [self.view addSubview:topView];
    
    CGFloat topViewHeight = topView.frame.size.height;
    
    UILabel *titleLabel =[[UILabel alloc]initWithFrame:CGRectMake(screenWidth/2 - 100, topViewHeight/2 - 15, 200, 40)];
    titleLabel.font = FONT_NORMAL(20);
    titleLabel.text = _titleStr;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:titleLabel];
    
    UIButton *backButtonImg = [[UIButton alloc]initWithFrame:CGRectMake(0, 16 , 45, 45)];
    [backButtonImg setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButtonImg addTarget:self action:@selector(backButtonImgAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButtonImg];
    
    UIImageView *mainImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 70,screenWidth, screenHeight - 70)];
    mainImageView.image = [UIImage imageNamed:@""];
    [self.view addSubview:mainImageView];
    
    UIButton *continueButton = [[UIButton alloc]initWithFrame:CGRectMake(0, screenHeight - 45, screenWidth, 45)];
    [continueButton setBackgroundColor:[[UIColor grayColor]colorWithAlphaComponent:0.5]];
    [continueButton setTitle:NSLocalizedString(@"continue", @"") forState:UIControlStateNormal];
    [continueButton addTarget:self action:@selector(continueButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:continueButton];
}

- (void)backButtonImgAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)continueButtonAction{
    if ([[_jsonData objectForKey:@"category"]integerValue] == 1)/*Etela resani*/ {
        if ([[_jsonData objectForKey:@"type"]integerValue] == 1)/*post*/ {
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            LandingPageDetailViewController *view = (LandingPageDetailViewController *)[story instantiateViewControllerWithIdentifier:@"LandingPageDetailViewController"];
            view.postId = [_jsonData objectForKey:@"id"];
            view.isFromPushNotif = YES;
            [self.navigationController pushViewController:view animated:YES];
            
        } else if ([[_jsonData objectForKey:@"type"]integerValue] == 2)/*doctor*/ {
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            DoctorPageViewController *view = (DoctorPageViewController *)[story instantiateViewControllerWithIdentifier:@"DoctorPageViewController"];
            view.userEntityId = [_jsonData objectForKey:@"id"];;
            view.isFromPushNotif = YES;
            /*view.userTitle = tempDic.LPTVUserTitle;
             view.userJobTitle = tempDic.LPTVUserJobTitle;
             view.userAvatar = tempDic.LPTVUserAvatarUrl;*/
            [self.navigationController pushViewController:view animated:YES];
            
        }else if ([[_jsonData objectForKey:@"type"]integerValue] == 3)/*clinic*/ {
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ClinicViewController *view = (ClinicViewController *)[story instantiateViewControllerWithIdentifier:@"ClinicViewController"];
            view.userEntityId = [_jsonData objectForKey:@"id"];
            view.isFromPushNotif = YES;
            /*view.userAvatar = [tempDic objectForKey:@"avatar"];
             view.userTitle = [tempDic objectForKey:@"name"];
             view.userJobTitle = [tempDic objectForKey:@"job_title"];*/
            [self.navigationController pushViewController:view animated:YES];
            
        }else if ([[_jsonData objectForKey:@"type"]integerValue] == 4)/*anjoman*/ {
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            AnjomanViewController *view = (AnjomanViewController *)[story instantiateViewControllerWithIdentifier:@"AnjomanViewController"];
            view.userEntityId = [_jsonData objectForKey:@"id"];
            view.isFromPushNotif = YES;
            /*view.userAvatar = [tempDic objectForKey:@"avatar"];
             view.userTitle = [tempDic objectForKey:@"name"];
             view.userJobTitle = [tempDic objectForKey:@"job_title"];*/
            [self.navigationController pushViewController:view animated:YES];
            
        }else if ([[_jsonData objectForKey:@"type"]integerValue] == 5)/*event*/ {
            
        }else if ([[_jsonData objectForKey:@"type"]integerValue] == 6)/*azmoon*/ {
            
        }else if ([[_jsonData objectForKey:@"type"]integerValue] == 7)/*angizeshi*/ {
            
        }else if ([[_jsonData objectForKey:@"type"]integerValue] == 8)/*search*/ {
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            SearchViewController *view = (SearchViewController *)[story instantiateViewControllerWithIdentifier:@"SearchViewController"];
            view.userEntityId = [_jsonData objectForKey:@"id"];
            [self.navigationController pushViewController:view animated:YES];
            
        }else if ([[_jsonData objectForKey:@"type"]integerValue] == 9)/*about us*/ {
            NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInteger:5], @"id", nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"GoToPageNumber" object:dic];
            
        }else if ([[_jsonData objectForKey:@"type"]integerValue] == 10)/*madarek*/ {
            NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInteger:3], @"id", nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"GoToPageNumber" object:dic];
            
        }else if ([[_jsonData objectForKey:@"type"]integerValue] == 11)/*favorites*/ {
            NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInteger:4], @"id", nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"GoToPageNumber" object:dic];
        }
    } else if ([[_jsonData objectForKey:@"category"]integerValue] == 2)/*Eghtezaee*/ {
        if ([[_jsonData objectForKey:@"type"]integerValue] == 1)/*takmil profile*/ {
            
        } else if ([[_jsonData objectForKey:@"type"]integerValue] == 2)/*pasokh moshaver*/ {
            NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInteger:2], @"id", nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"GoToPageNumber" object:dic];
            
        }else if ([[_jsonData objectForKey:@"type"]integerValue] == 3)/*yadavari vaght molaght*/ {
            
        }else if ([[_jsonData objectForKey:@"type"]integerValue] == 4)/*kharid baste*/ {
            [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"showPackageLIST"];
            NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInteger:2], @"id", nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"GoToPageNumber" object:dic];
        }
    }

}
@end
