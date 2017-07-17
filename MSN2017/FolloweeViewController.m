//
//  FourthViewController.m
//  MSN
//
//  Created by Yarima on 11/5/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "FolloweeViewController.h"
#import "Header.h"
#import "FolloweeCustomCell.h"
#import "ProgressHUD.h"
#import <AFHTTPSessionManager.h>
#import <UIImageView+AFNetworking.h>
#import "GetUsernamePassword.h"
#import "TimeAgoViewController.h"
#import "CustomButton.h"
#import "NewMessageViewController.h"
#import "UIView+Bubble.h"
#import "MessageDetailViewController.h"
#import "UserProfileViewController.h"
#import "NSDictionary+LandingPage.h"
@interface FolloweeViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    BOOL    isBusyNow;
    NSInteger page;
    UILabel *noResultLabel;
}
@property(nonatomic, retain)UITableView *tableView;
@property(nonatomic, retain)NSMutableArray *tableArray;

@end

@implementation FolloweeViewController

- (void)viewWillAppear:(BOOL)animated{
    page = 1;
    self.tableArray = [[NSMutableArray alloc]init];
    [self fetchMessageFromServerWithPage:page];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    [self makeTopBar];
    [self makeBody];
    
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
    [self.view addSubview:topView];
    
    CGFloat topViewHeight = topView.frame.size.height;
    
    UILabel *titleLabel =[[UILabel alloc]initWithFrame:CGRectMake(screenWidth/2 - 100, topViewHeight/2 - 15, 200, 40)];
    titleLabel.font = FONT_NORMAL(16);
    if (_isFromComORProj) {
        titleLabel.text = @"لیست دنبال شونده ها";
        if (_isFollowee) {
            titleLabel.text = @"لیست دنبال کننده ها";
        }
    } else {
        titleLabel.text = @"لیست دنبال شونده ها";
        if (_isFollowee) {
            titleLabel.text = @"لیست دنبال کننده ها";
        }
    }
    
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:titleLabel];
    
    UIButton *backButtonImg = [[UIButton alloc]initWithFrame:CGRectMake(0, 16 , 45, 45)];
    [backButtonImg setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButtonImg addTarget:self action:@selector(backButtonImgAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButtonImg];
}

- (void)makeBody{
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 70, screenWidth, screenHeight - 70 - 40)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (void)refreshTable{
    page = 0;
    self.tableArray = [[NSMutableArray alloc]init];
    //[self fetchMessageFromServerWithPage:page];
}

- (void)newMessageAction{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NewMessageViewController *view = (NewMessageViewController *)[story instantiateViewControllerWithIdentifier:@"NewMessageViewController"];
    [self presentViewController:view animated:YES completion:nil];
}

- (void)confirmButtonAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSInteger idOf = [[[self.tableArray objectAtIndex:btn.tag]objectForKey:@"id"]integerValue];
    [self approveWithID:idOf];
}

- (void)backButtonImgAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)followButtonActionUser:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSInteger idx = [[[self.tableArray objectAtIndex:btn.tag]objectForKey:@"id"]integerValue];
    NSDictionary *dic = [self.tableArray objectAtIndex:btn.tag];
    [self followUnfollowUserConnection:idx withdic:dic];
}

#pragma mark - table view delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.tableArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (IS_IPAD) {
        return screenWidth + 10;
    } else {
        return 90;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    FolloweeCustomCell *cell = (FolloweeCustomCell *)[[FolloweeCustomCell alloc]
                                                    initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell1"];
    if (indexPath.row <= [self.tableArray count]) {
        NSDictionary *dic = [self.tableArray objectAtIndex:indexPath.row];
        cell.followerLabel.text = [dic objectForKey:@"name"];
        //cell.followeeLabel.text = [NSString stringWithFormat:@"%@ : برای", [dic objectForKey:@"name"]];
        //cell.bodyLabel.text = [[dic objectForKey:@"last_message"]objectForKey:@"body"];
        //date
        /*
        NSDateFormatter *currentDateFormatter = [[NSDateFormatter alloc]init];
        [currentDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *endDate = [NSDate date];
        
        double timestampval = [[[dic objectForKey:@"last_message"]objectForKey:@"created_at"]doubleValue];
        NSTimeInterval timestamp = (NSTimeInterval)timestampval;
        NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
        cell.dateLabel.text = [NSString stringWithFormat:@"%@",
                               [TimeAgoViewController timeIntervalWithStartDate:startDate withEndDate:endDate]];
         */
        [cell.myImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [dic objectForKey:@"avatar"]]] placeholderImage:[UIImage imageNamed:@"icon upload ax"]];
        
        if ([[dic objectForKey:@"follow"] isEqualToString:@"not_followed"]) {
            UIButton *followButton = [CustomButton initButtonWithTitle:@"دنبال می کنم" withTitleColor:COLOR_5 withBackColor:WHITE_COLOR isRounded:YES withFrame:CGRectMake(10, 28, 80, 30)];
            followButton.tag = indexPath.row;
            [followButton addTarget:self action:@selector(followButtonActionUser:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:followButton];
        } else if ([[dic objectForKey:@"follow"] isEqualToString:@"followed"]){
            UIButton *followButton = [CustomButton initButtonWithTitle:@"دنبال می کنم" withTitleColor:WHITE_COLOR withBackColor:COLOR_5 isRounded:YES withFrame:CGRectMake(10, 28, 80, 30)];
            followButton.tag = indexPath.row;
            [followButton addTarget:self action:@selector(followButtonActionUser:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:followButton];
        }else if ([[dic objectForKey:@"follow"] isEqualToString:@"pending_approve"]){
            UIButton *followButton = [CustomButton initButtonWithTitle:@"منتظر تایید" withTitleColor:WHITE_COLOR withBackColor:COLOR_5 isRounded:YES withFrame:CGRectMake(10, 28, 80, 30)];
            followButton.tag = indexPath.row;
            [followButton addTarget:self action:@selector(followButtonActionUser:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:followButton];
        }

    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *tempDic = [self.tableArray objectAtIndex:indexPath.row];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UserProfileViewController *view = (UserProfileViewController *)[story instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
    view.entityID = [[tempDic objectForKey:@"id"]integerValue];
    view.dictionary = tempDic;
    [self.navigationController pushViewController:view animated:YES];

}

#pragma mark - scrollview delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height) {
        // we are at the end
        page++;
        [self fetchMessageFromServerWithPage:page];
    }
}

#pragma mark - connection
- (void)fetchMessageFromServerWithPage:(NSInteger)pageOf{
    if (!isBusyNow) {
        self.tableView.userInteractionEnabled = NO;
        isBusyNow = YES;
        [ProgressHUD show:@""];
        NSInteger profileId = [[[NSUserDefaults standardUserDefaults]objectForKey:@"profileID"]integerValue];
        if (_entityID != 0) {
            profileId = _entityID;
        }
        NSDictionary *params = @{@"model":@"entity",
                                 @"foreign_key":[NSNumber numberWithInteger:profileId],
                                 @"page":[NSNumber numberWithInteger:pageOf],
                                 @"limit":[NSNumber numberWithInteger:20]
                                 };
        NSString *url = [NSString stringWithFormat:@"%@api/social_activity/following/all", BaseURL];
        if (_isFollowee) {
            url = [NSString stringWithFormat:@"%@api/social_activity/follower/all", BaseURL];
        }
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"application/json"];
        manager.requestSerializer.timeoutInterval = 45;
        //NSLog(@"%@", [GetUsernamePassword getAccessToken]);
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [GetUsernamePassword getAccessToken]] forHTTPHeaderField:@"Authorization"];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
        [manager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            
        } progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            [ProgressHUD dismiss];
            isBusyNow = NO;
            NSDictionary *tempDic = (NSDictionary *)responseObject;
            
            for (NSDictionary *dic in [tempDic objectForKey:@"data"]) {
                [self.tableArray addObject:dic];
            }
            
            [noResultLabel removeFromSuperview];
            if ([_tableArray count] == 0) {
                [noResultLabel removeFromSuperview];
                noResultLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 220, 10, 200,  25)];
                noResultLabel.font = FONT_MEDIUM(13);
                noResultLabel.text = @"کاربری ثبت نشده است";
                noResultLabel.minimumScaleFactor = 0.7;
                noResultLabel.textColor = [UIColor blackColor];
                noResultLabel.textAlignment = NSTextAlignmentRight;
                noResultLabel.adjustsFontSizeToFitWidth = YES;
                [_tableView addSubview:noResultLabel];
            }

            [self.tableView reloadData];
            
            self.tableView.userInteractionEnabled = YES;
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            isBusyNow = NO;
            self.tableView.userInteractionEnabled = YES;
            [ProgressHUD dismiss];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%@", [error localizedDescription]] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                // ////NSLog(@"You pressed button OK");
            }];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            
        }];
    }
}

- (void)approveWithID:(NSInteger)idOf{
        [ProgressHUD show:@""];
        NSDictionary *params = @{@"id":[NSNumber numberWithInteger:idOf]
                                 };
        NSString *url = [NSString stringWithFormat:@"%@api/social_activity/follow/approve", BaseURL];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"application/json"];
        manager.requestSerializer.timeoutInterval = 45;
        //NSLog(@"%@", [GetUsernamePassword getAccessToken]);
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [GetUsernamePassword getAccessToken]] forHTTPHeaderField:@"Authorization"];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
        [manager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            
        } progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            [ProgressHUD dismiss];
            NSDictionary *tempDic = (NSDictionary *)responseObject;
            if ([[tempDic objectForKey:@"success"]integerValue] == 1) {
                self.tableArray = [[NSMutableArray alloc]init];
                page = 1;
                [self fetchMessageFromServerWithPage:page];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [ProgressHUD dismiss];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%@", [error localizedDescription]] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                // ////NSLog(@"You pressed button OK");
            }];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            
        }];
}

-(void)followUnfollowUserConnection:(NSInteger)profileId withdic:(NSDictionary *)dic
{
    [ProgressHUD show:@""];
    NSDictionary *params = @{@"model":@"entity",
                             @"foreign_key":[NSNumber numberWithInteger:profileId]
                             };
    NSString *url = [NSString stringWithFormat:@"%@api/social_activity/follow", BaseURL];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"application/json"];
    manager.requestSerializer.timeoutInterval = 45;
        //NSLog(@"%@", [GetUsernamePassword getAccessToken]);
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [GetUsernamePassword getAccessToken]] forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    [manager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
    } progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [ProgressHUD dismiss];
        
        NSDictionary *resDic = responseObject;
        if ([[resDic objectForKey:@"success"]integerValue] == 1) {
            NSInteger row = [self.tableArray indexOfObject:dic];
            NSDictionary *searchDic = [self.tableArray objectAtIndex:row];
            
            if ([searchDic.LPFollow isEqualToString:@"not_followed"]) {
                NSMutableDictionary *tempDic = [[NSMutableDictionary alloc]initWithDictionary:searchDic];
                [tempDic setObject:@"pending_approve" forKey:@"follow"];
                [self.tableArray replaceObjectAtIndex:row withObject:tempDic];
                
            } else if ([searchDic.LPFollow isEqualToString:@"followed"]){
                NSMutableDictionary *tempDic = [[NSMutableDictionary alloc]initWithDictionary:searchDic];
                [tempDic setObject:@"not_followed" forKey:@"follow"];
                [self.tableArray replaceObjectAtIndex:row withObject:tempDic];
                
            }else if ([searchDic.LPFollow isEqualToString:@"pending_approve"]){
                NSMutableDictionary *tempDic = [[NSMutableDictionary alloc]initWithDictionary:searchDic];
                [tempDic setObject:@"not_followed" forKey:@"follow"];
                [self.tableArray replaceObjectAtIndex:row withObject:tempDic];
            }
            
            NSIndexPath *indexpath = [NSIndexPath indexPathForRow:row inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationNone];
        }
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[resDic objectForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                // ////NSLog(@"You pressed button OK");
        }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [ProgressHUD dismiss];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%@", [error localizedDescription]] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                // ////NSLog(@"You pressed button OK");
        }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    }];
}
@end
