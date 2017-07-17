//
//  FifthViewController.m
//  MSN
//
//  Created by Yarima on 11/5/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "FifthViewController.h"
#import "Header.h"
#import "MessageCustomCell.h"
#import "ProgressHUD.h"
#import <AFHTTPSessionManager.h>
#import <UIImageView+AFNetworking.h>
#import "GetUsernamePassword.h"
#import "TimeAgoViewController.h"
#import "CustomButton.h"
#import "NewMessageViewController.h"
#import "UIView+Bubble.h"
#import "MessageDetailViewController.h"
@interface FifthViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    BOOL    isBusyNow;
    UIRefreshControl *refreshControl;
    NSInteger page;
    UILabel *noResultLabel;
    BOOL    goToNewMessage;
}
@property(nonatomic, retain)UITableView *tableView;
@property(nonatomic, retain)NSMutableArray *tableArray;

@end

@implementation FifthViewController

- (void)viewWillAppear:(BOOL)animated{
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    //    UIView *myview = [UIView makeBubble:CGRectMake(10, 100, screenWidth/2 , 170) flipped:YES color:COLOR_3];
    //    [self.view addSubview:myview];
    //
    //    UIView *myview2 = [UIView makeBubble:CGRectMake(10, 400, screenWidth/2 , 70) flipped:NO color:COLOR_3];
    //    [self.view addSubview:myview2];
    
    [self makeTopBar];
    [self makeBody];
    
    page = 1;
    self.tableArray = [[NSMutableArray alloc]init];
    [self fetchMessageFromServerWithPage:page];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(fetchNewMessages) name:@"fetchNewMessages" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - custom methods

- (void)fetchNewMessages{
    page = 1;
    self.tableArray = [[NSMutableArray alloc]init];
    [self fetchMessageFromServerWithPage:page];
}
- (void)GoToNewMessage{
    CGPoint newOffset = CGPointMake(0, -[_tableView contentInset].top);
    [_tableView setContentOffset:newOffset animated:YES];
    page = 0;
    self.tableArray = [[NSMutableArray alloc]init];
    goToNewMessage = YES;
}

- (void)makeTopBar{
    
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 70)];
    topView.backgroundColor = COLOR_3;
    [topView makeGradient:topView];
    [self.view addSubview:topView];
    
    CGFloat topViewHeight = topView.frame.size.height;
    
    UILabel *titleLabel =[[UILabel alloc]initWithFrame:CGRectMake(screenWidth/2 - 100, topViewHeight/2 - 15, 200, 40)];
    titleLabel.font = FONT_NORMAL(16);
    titleLabel.text = @"لیست پیام ها";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:titleLabel];
    
    //46 × 40
    UIButton *newMessage = [CustomButton initButtonWithImage:[UIImage imageNamed:@"Create_Message"] withFrame:CGRectMake(screenWidth - 40, 30, 46/2, 40/2)];
    [newMessage addTarget:self action:@selector(newMessageAction) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:newMessage];
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
    view.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:view animated:YES];
    //[self presentViewController:view animated:YES completion:nil];
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        NSDictionary *dic = [self.tableArray myObjectAtIndex:indexPath.row];
        [self deleteConversationFromServerWithID:[[dic myObjectForKey:@"id"]integerValue]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MessageCustomCell *cell = (MessageCustomCell *)[[MessageCustomCell alloc]
                                                    initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell1"];
    if (indexPath.row <= [self.tableArray count]) {
        NSDictionary *dic = [self.tableArray myObjectAtIndex:indexPath.row];
        cell.authorLabel.text = [dic myObjectForKey:@"participants"];
        cell.titleLabel.text = [dic myObjectForKey:@"subject"];
        cell.bodyLabel.text = [[dic myObjectForKey:@"last_message"]myObjectForKey:@"body"];
        //date
        NSDateFormatter *currentDateFormatter = [[NSDateFormatter alloc]init];
        [currentDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *endDate = [NSDate date];
        
        double timestampval = [[[dic myObjectForKey:@"last_message"]myObjectForKey:@"created_at"]doubleValue];
        NSTimeInterval timestamp = (NSTimeInterval)timestampval;
        NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
        cell.dateLabel.text = [NSString stringWithFormat:@"%@",
                               [TimeAgoViewController timeIntervalWithStartDate:startDate withEndDate:endDate]];
        [cell.myImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [dic myObjectForKey:@"image"]]] placeholderImage:[UIImage imageNamed:@"icon upload ax"]];
        
        if ([[dic myObjectForKey:@"count_new_message"]integerValue] > 0) {
            UILabel *countLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, cell.dateLabel.frame.origin.y + 30, 26, 26)];
            countLabel.clipsToBounds = YES;
            countLabel.textAlignment = NSTextAlignmentCenter;
            countLabel.font = FONT_NORMAL(13);
            countLabel.layer.borderColor = COLOR_5.CGColor;
            countLabel.layer.borderWidth = 1.0;
            countLabel.layer.cornerRadius = 13.0;
            countLabel.layer.backgroundColor = COLOR_5.CGColor;
            countLabel.textColor = [UIColor whiteColor];
            countLabel.text = [NSString stringWithFormat:@"%@", [dic myObjectForKey:@"count_new_message"]];
            [cell addSubview:countLabel];
        }
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = [self.tableArray myObjectAtIndex:indexPath.row];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MessageDetailViewController *view = (MessageDetailViewController *)[story instantiateViewControllerWithIdentifier:@"MessageDetailViewController"];
    view.conversationId = [[dic myObjectForKey:@"id"]integerValue];
    NSString *participantsStr = [dic myObjectForKey:@"participants"];
    NSArray *participantsArray = [participantsStr componentsSeparatedByString:@","];
    view.participantsArray = participantsArray;
    view.participantsString = participantsStr;
    view.subjectString = [dic myObjectForKey:@"subject"];
    view.hidesBottomBarWhenPushed = YES;
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
        [ProgressHUD show:@"" Interaction:NO];
        self.tableView.userInteractionEnabled = NO;
        NSDictionary *params = @{@"page":[NSNumber numberWithInteger:pageOf],
                                 @"limit":[NSNumber numberWithInteger:20]
                                 };
        NSString *url = [NSString stringWithFormat:@"%@api/message/conversation/all", BaseURL];
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
            
            for (NSDictionary *dic in [tempDic myObjectForKey:@"data"]) {
                [self.tableArray addObject:dic];
            }
            
            [noResultLabel removeFromSuperview];
            if ([_tableArray count] == 0) {
                [noResultLabel removeFromSuperview];
                noResultLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 220, 10, 200,  25)];
                noResultLabel.font = FONT_MEDIUM(13);
                noResultLabel.text = @"پیامی یافت نشد";
                noResultLabel.minimumScaleFactor = 0.7;
                noResultLabel.textColor = [UIColor blackColor];
                noResultLabel.textAlignment = NSTextAlignmentRight;
                noResultLabel.adjustsFontSizeToFitWidth = YES;
                [_tableView addSubview:noResultLabel];
            }

            [self.tableView reloadData];
            
            if (goToNewMessage) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                [self.tableView.delegate tableView:self.tableView didSelectRowAtIndexPath:indexPath];
                goToNewMessage = NO;
            }
            
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

- (void)deleteConversationFromServerWithID:(NSInteger)idOf{
    if (!isBusyNow) {
        isBusyNow = YES;
        [refreshControl endRefreshing];
        [ProgressHUD show:@""];
        NSDictionary *params = @{@"conversation_id":[NSNumber numberWithInteger:idOf]
                                 };
        NSString *url = [NSString stringWithFormat:@"%@api/message/conversation/remove", BaseURL];
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
            if ([[tempDic myObjectForKey:@"success"]integerValue] == 1) {
                self.tableArray = [[NSMutableArray alloc]init];
                page = 0;
                [self fetchMessageFromServerWithPage:page];
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

@end
