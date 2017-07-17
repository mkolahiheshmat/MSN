//
//  CommentViewController.m
//  MSN
//
//  Created by Yarima on 11/23/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "EmkanatViewController.h"
#import "Header.h"
#import <AFHTTPSessionManager.h>
#import "ProgressHUD.h"
#import "GetUsernamePassword.h"
#import "EmkanatCustomCell.h"
#import <UIImageView+AFNetworking.h>
#import "NSDictionary+LandingPage.h"
#import "CustomButton.h"
#import "CommentReplyViewController.h"
#import "EditProjectViewController.h"
#import "EditCompanyViewController.h"
#import "FavoritesViewController.h"
#import "VotingViewController.h"
#import "AboutUSViewController.h"
#import "PishnahadatViewController.h"
#define Height_QuestionView 40
@interface EmkanatViewController ()<UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>
{
    UITableView *_tableView;
    NSMutableArray *tableArray;
    UIView *replyViewBG;
    UIButton *sendButton;
    UITextView *questionTextView;
    CGFloat lastHeightOfQuestionTextView;
}
@end

@implementation EmkanatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    ////NSLog(@"%ld", (long)_postId);
    
    [self makeTopBar];
    
    tableArray = [[NSMutableArray alloc]initWithObjects:@"ایجاد نظرسنجی",
                  @"ایجاد صفحه پروژه",
                  @"ایجاد صفحه شرکت",
                  @"علاقه مندی ها",
                  @"تنظیمات",
                  @"انتقادات و پیشنهادات",
                  @"درباره ما",
                  nil];
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 70, screenWidth, screenHeight - 70 - Height_QuestionView) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    //_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.estimatedRowHeight = 44.0;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    [self.view addSubview:_tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - custom methods
- (void)makeTopBar{
    
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 70)];
    topView.backgroundColor = COLOR_3;
    [topView makeGradient:topView];
    topView.userInteractionEnabled = YES;
    [self.view addSubview:topView];
    
    CGFloat topViewHeight = topView.frame.size.height;
    
    UILabel *titleLabel =[[UILabel alloc]initWithFrame:CGRectMake(screenWidth/2 - 100, topViewHeight/2 - 15, 200, 40)];
    titleLabel.font = FONT_NORMAL(16);
    titleLabel.text = @"امکانات";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:titleLabel];
    
    UIButton *backButtonImg = [[UIButton alloc]initWithFrame:CGRectMake(0, 16 , 45, 45)];
    [backButtonImg setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButtonImg addTarget:self action:@selector(backButtonImgAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButtonImg];
}

- (void)backButtonImgAction{
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark - tableview delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [tableArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *str = [tableArray objectAtIndex:indexPath.row];
    EmkanatCustomCell *cell = (EmkanatCustomCell *)[[EmkanatCustomCell alloc]
                                                    initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    
    cell.contentLabel.text = str;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row == 1) {
        //project
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        EditProjectViewController *view = (EditProjectViewController *)[story instantiateViewControllerWithIdentifier:@"EditProjectViewController"];
        [self presentViewController:view animated:YES completion:nil];
    } else if (indexPath.row == 2){
        //company
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        EditCompanyViewController *view = (EditCompanyViewController *)[story instantiateViewControllerWithIdentifier:@"EditCompanyViewController"];
        [self presentViewController:view animated:YES completion:nil];
    } else if (indexPath.row == 3){
        //favorite
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        FavoritesViewController *view = (FavoritesViewController *)[story instantiateViewControllerWithIdentifier:@"FavoritesViewController"];
        [self.navigationController pushViewController:view animated:YES];

    }else if (indexPath.row == 0){
        //favorite
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        VotingViewController *view = (VotingViewController *)[story instantiateViewControllerWithIdentifier:@"VotingViewController"];
        [self.navigationController pushViewController:view animated:YES];
        
    }else if (indexPath.row == 5){
            //favorite
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PishnahadatViewController *view = (PishnahadatViewController *)[story instantiateViewControllerWithIdentifier:@"PishnahadatViewController"];
        [self.navigationController pushViewController:view animated:YES];
    }else if (indexPath.row == 6){
        //favorite
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        AboutUSViewController *view = (AboutUSViewController *)[story instantiateViewControllerWithIdentifier:@"AboutUSViewController"];
        [self.navigationController pushViewController:view animated:YES];
    }
}

@end
