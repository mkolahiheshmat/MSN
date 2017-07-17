//
//  CommentViewController.m
//  MSN
//
//  Created by Yarima on 11/23/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "CommentViewController.h"
#import "Header.h"
#import <AFHTTPSessionManager.h>
#import "ProgressHUD.h"
#import "GetUsernamePassword.h"
#import "CommentCustomCell.h"
#import <UIImageView+AFNetworking.h>
#import "NSDictionary+LandingPage.h"
#import "CustomButton.h"
#import "ReportAbuseViewController.h"
#import "CommentReplyViewController.h"
#import "TimeAgoViewController.h"
#import "UserProfileViewController.h"
#import "NSDictionary+LandingPageTableView.h"
#define Height_QuestionView 40
#define Height_FOR_REPLY 30
@interface CommentViewController ()<UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>
{
    UITableView *_tableView;
    NSMutableArray *tableArray;
    UIView *replyViewBG;
    UIButton *sendButton;
    UITextView *questionTextView;
    CGFloat lastHeightOfQuestionTextView;
    NSInteger profileID;
    UILabel *noResultLabelPost;
    NSInteger page;
}
@end

@implementation CommentViewController

- (void)viewWillAppear:(BOOL)animated{
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    ////NSLog(@"%ld", (long)_postId);
    profileID = [[[NSUserDefaults standardUserDefaults]objectForKey:@"profileID"]integerValue];
    [self makeTopBar];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 70, screenWidth, screenHeight - 70 - Height_QuestionView) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.estimatedRowHeight = 44.0;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    [self.view addSubview:_tableView];
    
    replyViewBG = [[UIView alloc]initWithFrame:CGRectMake(0, screenHeight - Height_QuestionView, screenWidth, Height_QuestionView)];
    replyViewBG.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:replyViewBG];
    sendButton = [CustomButton initButtonWithTitle:NSLocalizedString(@"ارسال", @"") withTitleColor:[UIColor whiteColor] withBackColor:[UIColor colorWithRed:92/255.0 green:134/255.0 blue:217/255.0 alpha:1.0] isRounded:NO withFrame:CGRectMake(screenWidth - 60, 0, 60, Height_QuestionView)];
    [sendButton addTarget:self action:@selector(sendButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [sendButton makeGradient:sendButton];
    [replyViewBG addSubview:sendButton];
    
    questionTextView = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, screenWidth - 60, Height_QuestionView)];
    questionTextView.font = FONT_MEDIUM(12);
    questionTextView.tag = 534;
    questionTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    questionTextView.delegate = self;
    questionTextView.layer.borderColor = [UIColor grayColor].CGColor;
    questionTextView.layer.borderWidth = 1.0;
    questionTextView.textColor = [UIColor grayColor];
    questionTextView.contentSize = CGSizeMake(screenWidth, 1000);
    [questionTextView setScrollEnabled:YES];
    questionTextView.text = NSLocalizedString(@"نظر خود را بنویسید", @"");
    questionTextView.textAlignment = NSTextAlignmentRight;
    [replyViewBG addSubview:questionTextView];
    lastHeightOfQuestionTextView = 40;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHideHandler:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    tableArray =[[NSMutableArray alloc]init];
    page = 1;
    [self fetchCommentsWithID:_postId];
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
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissTextView)];
    [topView addGestureRecognizer:tap];
    [self.view addSubview:topView];
    
    CGFloat topViewHeight = topView.frame.size.height;
    
    UILabel *titleLabel =[[UILabel alloc]initWithFrame:CGRectMake(screenWidth/2 - 100, topViewHeight/2 - 15, 200, 40)];
    titleLabel.font = FONT_NORMAL(16);
    titleLabel.text = NSLocalizedString(@"نظرات کاربران", @"");
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:titleLabel];
    
    UIButton *backButtonImg = [[UIButton alloc]initWithFrame:CGRectMake(0, 14 , 45, 45)];
    [backButtonImg setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButtonImg addTarget:self action:@selector(backButtonImgAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButtonImg];
}

- (void)dismissTextView{
    [UIView animateWithDuration:0.5 animations:^{
        CGRect rect = replyViewBG.frame;
        rect.origin.y = screenHeight - Height_QuestionView;
        [replyViewBG setFrame:rect];
        [questionTextView resignFirstResponder];
    }];
}

- (void)sendButtonAction{
    [self sendCommentsWithID:_postId];
}

- (void)backButtonImgAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dismissTextField{
    
}

- (CGFloat)getHeightOfString:(NSString *)labelText{
    
    UIFont *font = FONT_NORMAL(15);
    if (IS_IPAD) {
        font = FONT_NORMAL(26);
    }
    CGSize sizeOfText = [labelText boundingRectWithSize: CGSizeMake( self.view.bounds.size.width - 30,CGFLOAT_MAX)
                                                options: (NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                             attributes: [NSDictionary dictionaryWithObject:font
                                                                                     forKey:NSFontAttributeName]
                                                context: nil].size;
    CGFloat height = sizeOfText.height;
    if (height < 100){
        //height = 100;
    }
    
    return height + 22;
    
}

- (CGFloat)getHeightOfString2:(NSString *)labelText{
    
    UIFont *font = FONT_NORMAL(15);
    if (IS_IPAD) {
        font = FONT_NORMAL(26);
    }
    CGSize sizeOfText = [labelText boundingRectWithSize: CGSizeMake( self.view.bounds.size.width - 30 - 50,CGFLOAT_MAX)
                                                options: (NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                             attributes: [NSDictionary dictionaryWithObject:font
                                                                                     forKey:NSFontAttributeName]
                                                context: nil].size;
    CGFloat height = sizeOfText.height;
    return height;
    
}

- (void)replyButtonAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSDictionary *dic = [tableArray objectAtIndex:btn.tag];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CommentReplyViewController *view = (CommentReplyViewController *)[story instantiateViewControllerWithIdentifier:@"CommentReplyViewController"];
    view.commentId = [dic.LPPostID integerValue];
    [self.navigationController pushViewController:view animated:YES];

}

- (void)reportButtonAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSDictionary *dic = [tableArray objectAtIndex:btn.tag];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ReportAbuseViewController *view = (ReportAbuseViewController *)[story instantiateViewControllerWithIdentifier:@"ReportAbuseViewController"];
    view.idOfProfile = [dic.LPPostID integerValue];
    view.model = @"comment";
    [self presentViewController:view animated:YES completion:nil];
    
}

- (void)deleteButtonAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSDictionary *dic = [tableArray objectAtIndex:btn.tag];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"آیا از حذف کامنت مطمئن هستید؟" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"حذف" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self deleteCommentsWithID:[[dic objectForKey:@"id"]integerValue]];
    }];
    [alert addAction:deleteAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
    }];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)authorImageViewAction:(UITapGestureRecognizer *)tap{
    NSDictionary *tempDic = [tableArray objectAtIndex:tap.view.tag];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UserProfileViewController *view = (UserProfileViewController *)[story instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
    view.entityID = [[[tempDic objectForKey:@"entity"]objectForKey:@"id"]integerValue];//[[[tempDic objectForKey:@"entity"]objectForKey:@"id"]integerValue];
    view.dictionary = tempDic;
    [self.navigationController pushViewController:view animated:YES];
}

- (void)authorNameAction:(UITapGestureRecognizer *)tap{
    NSDictionary *tempDic = [tableArray objectAtIndex:tap.view.tag];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UserProfileViewController *view = (UserProfileViewController *)[story instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
    view.entityID = [[[tempDic objectForKey:@"entity"]objectForKey:@"id"]integerValue];//[[[tempDic objectForKey:@"entity"]objectForKey:@"id"]integerValue];
    view.dictionary = tempDic;
    [self.navigationController pushViewController:view animated:YES];
}

#pragma mark - connection

- (void)fetchCommentsWithID:(NSInteger)idOfPost{
    [ProgressHUD show:@""];
    _tableView.userInteractionEnabled = NO;
    NSDictionary *params = @{@"model":@"post",
                             @"foreign_key":[NSNumber numberWithInteger:idOfPost],
                             @"page":[NSNumber numberWithInteger:page],
                             @"limit":[NSNumber numberWithInteger:20]
                             };
    NSString *url = [NSString stringWithFormat:@"%@api/social_activity/comment/all", BaseURL];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"application/json"];
    manager.requestSerializer.timeoutInterval = 45;
    ////NSLog(@"%@", [GetUsernamePassword getAccessToken]);
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [GetUsernamePassword getAccessToken]] forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    [manager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
    } progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [ProgressHUD dismiss];
        NSDictionary *resDic  = (NSDictionary *)responseObject;
        _dictionary = [resDic objectForKey:@"data"];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"updateCommentsCount"
                                                           object:[NSNumber numberWithInteger:
                                                                   [[_dictionary objectForKey:@"count"]integerValue]]];
        for (NSDictionary *dic in [_dictionary objectForKey:@"comments"]) {
            [tableArray addObject:dic];
            
            //check for reply comments, inline comments
            if ([[dic objectForKey:@"comments"]count]  > 0) {
                for (NSDictionary *dic2 in [dic objectForKey:@"comments"]) {
                    [tableArray addObject:dic2];
                }
            }
        }
        
        [noResultLabelPost removeFromSuperview];
        
        if ([tableArray count] == 0) {
            noResultLabelPost = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 220, 10, 200,  25)];
            noResultLabelPost.font = FONT_MEDIUM(13);
            noResultLabelPost.text = @"تاکنون نظری ثبت نشده است";
            noResultLabelPost.minimumScaleFactor = 0.7;
            noResultLabelPost.textColor = [UIColor blackColor];
            noResultLabelPost.textAlignment = NSTextAlignmentRight;
            noResultLabelPost.adjustsFontSizeToFitWidth = YES;
            [_tableView addSubview:noResultLabelPost];
        }
        [_tableView reloadData];
        _tableView.userInteractionEnabled = YES;
        
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

- (void)sendCommentsWithID:(NSInteger)idOfPost{
    [self resignQuestionTextView];
    [ProgressHUD show:@""];
    NSDictionary *params = @{@"model":@"post",
                             @"foreign_key":[NSNumber numberWithInteger:idOfPost],
                             @"comment":questionTextView.text
                             };
    NSString *url = [NSString stringWithFormat:@"%@api/social_activity/comment", BaseURL];
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
        //NSDictionary *resDic  = (NSDictionary *)responseObject;
        questionTextView.text = @"";
        tableArray = [[NSMutableArray alloc]init];
        [self fetchCommentsWithID:_postId];
        
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

- (void)deleteCommentsWithID:(NSInteger)idOfPost{
    [self resignQuestionTextView];
    [ProgressHUD show:@""];
    NSDictionary *params = @{@"id":[NSNumber numberWithInteger:idOfPost]
                             };
    NSString *url = [NSString stringWithFormat:@"%@api/social_activity/comment/delete", BaseURL];
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
        NSDictionary *resDic = (NSDictionary *)responseObject;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@" حذف کامنت" message:[resDic objectForKey:@"message"]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            // ////NSLog(@"You pressed button OK");
        }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        tableArray =[[NSMutableArray alloc]init];
        [self fetchCommentsWithID:_postId];
        
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

#pragma mark - tableview delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [tableArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = [tableArray objectAtIndex:indexPath.row];
    CGFloat height = 0;
    if ([dic count] == 9) {
        height =  [self getHeightOfString:[[tableArray objectAtIndex:indexPath.row]objectForKey:@"comment"]];
        //NSLog(@"cell height:%f", height);
        if (height < 25) {
            return 20 + Height_FOR_REPLY;
        } else {
            height = height + 35 + Height_FOR_REPLY + 20;
        }
    }else if ([dic count] == 8){
        height = [self getHeightOfString2:[[tableArray objectAtIndex:indexPath.row]objectForKey:@"comment"]];
        if (height < 25) {
            return 20 + Height_FOR_REPLY;
        } else {
            height = height + 40 + Height_FOR_REPLY;
        }
    }
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = [tableArray objectAtIndex:indexPath.row];
    CommentCustomCell *cell = (CommentCustomCell *)[[CommentCustomCell alloc]
                                                    initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    ////NSLog(@"[dic count]:%ld", (long)[dic count]);
    [cell.authorImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", dic.LPUserAvatarUrl]] placeholderImage:[UIImage imageNamed:@"broken_image"]];
    cell.authorImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(authorImageViewAction:)];
    cell.authorImageView.tag = indexPath.row;
    [cell.authorImageView addGestureRecognizer:tap];
    
    cell.authorNameLabel.text = dic.LPUserTitle;
    cell.authorNameLabel.tag = indexPath.row;
    cell.authorNameLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(authorNameAction:)];
    [cell.authorNameLabel addGestureRecognizer:tap2];
    
    NSLog(@"tag: %ld",  (long)cell.authorNameLabel.tag);
    
    //date
    NSDateFormatter *currentDateFormatter = [[NSDateFormatter alloc]init];
    [currentDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *endDate = [NSDate date];
    
    double timestampval = [[dic objectForKey:@"created_at"]doubleValue];
    NSTimeInterval timestamp = (NSTimeInterval)timestampval;
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
    cell.dateLabel.text = [NSString stringWithFormat:@"%@",
                           [TimeAgoViewController timeIntervalWithStartDate:startDate withEndDate:endDate]];
    
    cell.contentLabel.text = [dic objectForKey:@"comment"];
    //cell.contentLabel.backgroundColor = [UIColor redColor];
    
    CGRect rect = cell.contentLabel.frame;
    rect.size.height = [self getHeightOfString:cell.contentLabel.text];
    cell.contentLabel.frame = rect;
    
    cell.replyButton = [CustomButton initButtonWithTitle:@"جواب" withTitleColor:COLOR_5 withBackColor:[UIColor clearColor] withFrame:CGRectMake(10, cell.contentLabel.frame.origin.y+ cell.contentLabel.frame.size.height + 5, 40, 30)];
    [cell addSubview:cell.replyButton];
    cell.replyButton.tag = indexPath.row;
    [cell.replyButton addTarget:self action:@selector(replyButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    if (profileID == [[[dic objectForKey:@"entity"]objectForKey:@"id"]integerValue]) {
        cell.deleteButton = [CustomButton initButtonWithTitle:@"حذف" withTitleColor:COLOR_5 withBackColor:[UIColor clearColor] withFrame:CGRectMake(60, cell.contentLabel.frame.origin.y+ cell.contentLabel.frame.size.height + 5, 40, 30)];
        [cell addSubview:cell.reportButton];
        cell.deleteButton.tag = indexPath.row;
        [cell.deleteButton addTarget:self action:@selector(deleteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:cell.deleteButton];
    } else {
        cell.reportButton = [CustomButton initButtonWithTitle:@"گزارش" withTitleColor:COLOR_5 withBackColor:[UIColor clearColor] withFrame:CGRectMake(60, cell.contentLabel.frame.origin.y+ cell.contentLabel.frame.size.height + 5, 40, 30)];
        [cell addSubview:cell.reportButton];
        cell.reportButton.tag = indexPath.row;
        [cell.reportButton addTarget:self action:@selector(reportButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    //customize for reply comment
    if ([dic count] == 8) {
        CGRect rect = cell.authorImageView.frame;
        rect.origin.x = rect.origin.x - 20;
        cell.authorImageView.frame = rect;
        
        rect = cell.authorNameLabel.frame;
        rect.origin.x = rect.origin.x - 20;
        cell.authorNameLabel.frame = rect;
        
        rect = cell.contentLabel.frame;
        rect.origin.y = cell.authorNameLabel.frame.origin.y + 26;
        rect.size.width = screenWidth - 20 - 55;
        rect.size.height = [self getHeightOfString2:[[tableArray objectAtIndex:indexPath.row]objectForKey:@"comment"]];
        cell.contentLabel.frame = rect;
        
        UIView *horizontalLine = [[UIView alloc]initWithFrame:CGRectMake(20, cell.contentLabel.frame.origin.y + cell.contentLabel.frame.size.height - 20, screenWidth - 40, 0.5)];
        horizontalLine.backgroundColor = [UIColor lightGrayColor];
        //[cell addSubview:horizontalLine];
        
        cell.replyButton.hidden = YES;
        
        rect = cell.reportButton.frame;
        rect.origin.y = cell.contentLabel.frame.origin.y + cell.contentLabel.frame.size.height;
        cell.reportButton.frame = rect;
        
        rect = cell.deleteButton.frame;
        rect.origin.y = cell.contentLabel.frame.origin.y + cell.contentLabel.frame.size.height;
        cell.deleteButton.frame = rect;
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - textview delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (textView.tag == 534) {
        if ([textView.text isEqualToString:NSLocalizedString(@"enteryouText", @"")]) {
            textView.text = @"";
            textView.textColor = [UIColor blackColor];
        }
        if( [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location != NSNotFound ) {
            CGRect rect = textView.frame;
            if (rect.size.height <= screenHeight * 0.3){
                rect.size.height += 25;
                lastHeightOfQuestionTextView = rect.size.height;
                //rect.origin.y -= 25;
                [textView setFrame:rect];
                
                rect = sendButton.frame;
                rect.origin.y += 25;
                [sendButton setFrame:rect];
                
//                rect = attachButton.frame;
//                rect.origin.y += 25;
//                [attachButton setFrame:rect];
                
                rect = replyViewBG.frame;
                rect.size.height += 25;
                rect.origin.y -= 25;
                [replyViewBG setFrame:rect];
            }else
                NSLog(@"this is enough frame");
        }
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    if (textView.tag == 534) {
        if ([textView.text isEqualToString:NSLocalizedString(@"نظر خود را بنویسید",@"")]) {
            textView.text = @"";
        }
        [UIView animateWithDuration:0.5 animations:^{
            CGRect rect = replyViewBG.frame;
            if (IS_IPAD) rect.origin.y = screenHeight - 360;
            else rect.origin.y = screenHeight - 260;
            [replyViewBG setFrame:rect];
            
            rect = questionTextView.frame;
            rect.size.height = lastHeightOfQuestionTextView;
            if (lastHeightOfQuestionTextView > 40) {
                CGFloat numOfEnters = lastHeightOfQuestionTextView / 25;
                numOfEnters --;
                rect.origin.y = 0;//-= numOfEnters * 25;
                [questionTextView setFrame:rect];
                
                rect = sendButton.frame;
                rect.origin.y += replyViewBG.frame.size.height/2 - 25;
                [sendButton setFrame:rect];
                
//                rect = attachButton.frame;
//                rect.origin.y += replyViewBG.frame.size.height/2 - 25;
//                [attachButton setFrame:rect];
                
                rect = replyViewBG.frame;
                rect.size.height = lastHeightOfQuestionTextView + 25;
                numOfEnters --;
                rect.origin.y -= numOfEnters * 25;
                [replyViewBG setFrame:rect];
                
                rect = sendButton.frame;
                rect.origin.y = replyViewBG.frame.size.height - 65;
                [sendButton setFrame:rect];
                
//                rect = attachButton.frame;
//                rect.origin.y = replyViewBG.frame.size.height - 70;
//                [attachButton setFrame:rect];
            }
            
            [textView layoutIfNeeded];
            [textView becomeFirstResponder];
        }];
    }
}

- (void)resignQuestionTextView {
    [UIView animateWithDuration:0.5 animations:^{
        CGRect rect = replyViewBG.frame;
        rect.origin.y = screenHeight - Height_QuestionView;
        rect.size.height = Height_QuestionView;
        [replyViewBG setFrame:rect];
        
        rect = sendButton.frame;
        rect.origin.y = 0;
        [sendButton setFrame:rect];
        
//        rect = attachButton.frame;
//        rect.origin.y = replyViewBG.frame.size.height/2 - 25;
//        [attachButton setFrame:rect];
        
        //CGRectMake(attachButton.frame.size.width + attachButton.frame.origin.x + 10, 5, screenWidth - 120, 40)
        rect = questionTextView.frame;
        rect.size.height = 40;
        rect.origin.y = 0;
        [questionTextView setFrame:rect];
        [questionTextView resignFirstResponder];
    }];
}

- (void) keyboardWillHideHandler:(NSNotification *)notification {
    //show another viewcontroller here
    [self resignQuestionTextView];
}

- (void) keyboardDidHideHandler:(NSNotification *)notification {
    //show another viewcontroller here
    //[self resignQuestionTextView];
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    [self resignQuestionTextView];
}

#pragma mark - scrollview delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height) {
            // we are at the end
        page++;
        [self fetchCommentsWithID:_postId];
    }
}

@end
