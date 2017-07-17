//
//  FourthViewController.m
//  MSN
//
//  Created by Yarima on 11/5/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "FourthViewController.h"
#import "Header.h"
#import "PendingCustomCell.h"
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
@interface FourthViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    BOOL    isBusyNow;
    UIRefreshControl *refreshControl;
    NSInteger page;
    UILabel *noResultLabel;
}
@property(nonatomic, retain)UITableView *tableView;
@property(nonatomic, retain)NSMutableArray *tableArray;

@end

@implementation FourthViewController

- (void)viewWillAppear:(BOOL)animated{
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    [self makeTopBar];
    [self makeBody];
    
    page = 1;
    self.tableArray = [[NSMutableArray alloc]init];
    [self fetchMessageFromServerWithPage:page];

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
    titleLabel.text = @"لیست درخواست ها";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:titleLabel];
}

- (void)makeBody{
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 70, screenWidth, screenHeight - 70 - 40)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
}

- (void)refreshTable{
    page = 0;
    //[self fetchMessageFromServerWithPage:page];
}

- (void)newMessageAction{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NewMessageViewController *view = (NewMessageViewController *)[story instantiateViewControllerWithIdentifier:@"NewMessageViewController"];
    [self presentViewController:view animated:YES completion:nil];
}

- (void)confirmButtonAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSInteger idOf = [[[self.tableArray myObjectAtIndex:btn.tag]objectForKey:@"id"]integerValue];
    [self approveWithID:idOf];
}

- (void)denyButtonAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSInteger idOf = [[[self.tableArray myObjectAtIndex:btn.tag]objectForKey:@"id"]integerValue];
    [self denyWithID:idOf];
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
    
    PendingCustomCell *cell = (PendingCustomCell *)[[PendingCustomCell alloc]
                                                    initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell1"];
    if (indexPath.row <= [self.tableArray count]) {
        NSDictionary *dic = [self.tableArray myObjectAtIndex:indexPath.row];
        cell.followerLabel.text = [[dic objectForKey:@"follower"]objectForKey:@"name"];
        cell.followeeLabel.text = [NSString stringWithFormat:@" برای :%@", [[dic objectForKey:@"following"]objectForKey:@"name"]];
        [cell.myImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[dic objectForKey:@"follower"]objectForKey:@"avatar"]]] placeholderImage:[UIImage imageNamed:@"icon upload ax"]];
        
        UIButton *confirmButton = [CustomButton initButtonWithImage:[UIImage imageNamed:@"confirm_button"] withFrame:CGRectMake(10, 26, 25, 25)];
        confirmButton.tag = indexPath.row;
        [confirmButton addTarget:self action:@selector(confirmButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:confirmButton];
        
        UIButton *denyButton = [CustomButton initButtonWithImage:[UIImage imageNamed:@"reject"] withFrame:CGRectMake(45, 26, 25, 25)];
        denyButton.tag = indexPath.row;
        [denyButton addTarget:self action:@selector(denyButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:denyButton];

    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = [self.tableArray myObjectAtIndex:indexPath.row];
    NSInteger entityID = [[[dic objectForKey:@"follower" ]objectForKey:@"id"]integerValue];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UserProfileViewController *view = (UserProfileViewController *)[story instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
    view.entityID = entityID;
    view.dictionary = dic;
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
        isBusyNow = YES;
        [refreshControl endRefreshing];
        [ProgressHUD show:@""];
        NSDictionary *params = @{@"page":[NSNumber numberWithInteger:pageOf],
                                 @"limit":[NSNumber numberWithInteger:20]
                                 };
        NSString *url = [NSString stringWithFormat:@"%@api/social_activity/follow/pending", BaseURL];
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
            
            if (pageOf == 0 || pageOf == 1) {
                self.tableArray = [[NSMutableArray alloc]init];
            }
            
            for (NSDictionary *dic in [tempDic objectForKey:@"data"]) {
                [self.tableArray addObject:dic];
            }
            
            [self.tableView reloadData];
            
            [noResultLabel removeFromSuperview];
            if ([_tableArray count] == 0) {
                [noResultLabel removeFromSuperview];
                noResultLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 220, 10, 200,  25)];
                noResultLabel.font = FONT_MEDIUM(13);
                noResultLabel.text = @"هیچ درخواست دوستی وجود ندارد";
                noResultLabel.minimumScaleFactor = 0.7;
                noResultLabel.textColor = [UIColor blackColor];
                noResultLabel.textAlignment = NSTextAlignmentRight;
                noResultLabel.adjustsFontSizeToFitWidth = YES;
                [_tableView addSubview:noResultLabel];
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            isBusyNow = NO;
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
        [refreshControl endRefreshing];
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

- (void)denyWithID:(NSInteger)idOf{
    [refreshControl endRefreshing];
    [ProgressHUD show:@""];
    NSDictionary *params = @{@"id":[NSNumber numberWithInteger:idOf]
                             };
    NSString *url = [NSString stringWithFormat:@"%@api/social_activity/follow/reject", BaseURL];
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

@end
