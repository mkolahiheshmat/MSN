//
//  FifthViewController.m
//  MSN
//
//  Created by Yarima on 11/5/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "EditMessageViewController.h"
#import "Header.h"
#import "ContactListCustomCell.h"
#import "ProgressHUD.h"
#import <AFHTTPSessionManager.h>
#import <UIImageView+AFNetworking.h>
#import "GetUsernamePassword.h"
#import "TimeAgoViewController.h"
#import "CustomButton.h"
#import "NewMessageViewController.h"
#import "UserProfileViewController.h"
@interface EditMessageViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
    BOOL    isBusyNow;
    NSInteger page;
    UITextField *nameTextField;
    UITextField *titleTextField;
    UIScrollView *namesScrollView;
    UIButton *taeedButton;
}
@property(nonatomic, retain)UITableView *tableView;

@end

@implementation EditMessageViewController

- (void)viewWillAppear:(BOOL)animated{
    
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
    titleLabel.text = @"لیست اعضا";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:titleLabel];
    
    UIButton *backButtonImg = [[UIButton alloc]initWithFrame:CGRectMake(0, 16 , 45, 45)];
    [backButtonImg setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButtonImg addTarget:self action:@selector(backButtonImgAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButtonImg];
    
}

- (void)makeBody{
    
    //title
    titleTextField = [[UITextField alloc]initWithFrame:CGRectMake(2, 70, screenWidth - 4, 40)];
    titleTextField.backgroundColor = [UIColor clearColor];
    titleTextField.tag = 102;
    titleTextField.text = _subjectString;
    titleTextField.delegate = self;
    titleTextField.font = FONT_NORMAL(15);
    titleTextField.layer.borderColor = [UIColor whiteColor].CGColor;
    titleTextField.layer.borderWidth = 1.0;
    //titleTextField.layer.cornerRadius = 5;
    //titleTextField.clipsToBounds = YES;
    titleTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    titleTextField.textAlignment = NSTextAlignmentRight;
    //[self.view addSubview:titleTextField];
    
    UIView *whiteLineView2 = [[UIView alloc]initWithFrame:CGRectMake(0, titleTextField.frame.origin.y + titleTextField.frame.size.height - 1, screenWidth, 1)];
    whiteLineView2.backgroundColor = [UIColor lightGrayColor];
    //[self.view addSubview:whiteLineView2];
    
    self.tableView = [[UITableView alloc]initWithFrame:
                      CGRectMake(0, 70, screenWidth, screenHeight - /*(namesScrollView.frame.origin.y + namesScrollView.frame.size.height + 50)*/70)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    taeedButton = [CustomButton initButtonWithTitle:@"اعمال تغییرات" withTitleColor:WHITE_COLOR withBackColor:COLOR_3 isRounded:NO withFrame:CGRectMake(0, screenHeight - 40, screenWidth, 40)];
    [taeedButton addTarget:self action:@selector(taeedButtonAction) forControlEvents:UIControlEventTouchUpInside];
    //[self.view addSubview:taeedButton];
    taeedButton.userInteractionEnabled = YES;
}

- (void)newMessageAction{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NewMessageViewController *view = (NewMessageViewController *)[story instantiateViewControllerWithIdentifier:@"NewMessageViewController"];
    [self.navigationController pushViewController:view animated:YES];
}

- (void)backButtonImgAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)taeedButtonAction{
    [self editSubject];
}

- (void)reloadTagsView{
    NSArray *viewsToRemove = [namesScrollView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }

    //CGFloat yPosOfSelectTagsLabel = 10;
    NSInteger countOfTags = [self.tableArray count];
    CGFloat yPOS = 5;
    CGFloat xPOS = 10;
    for (NSInteger i = 0; i < countOfTags; i++) {
        NSString *tagName = [[self.tableArray objectAtIndex:i]objectForKey:@"name"];
        CGSize size = [self getSizeOfString:tagName];
        if (countOfTags == 1)
            //xPOS = screenWidth/2 - size.width/2;
            if (xPOS + size.width+10 > screenWidth) {
                xPOS = 10;
                yPOS += 30;
            }
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(xPOS, yPOS, size.width + 15, 25)];
        label.userInteractionEnabled = YES;
        label.tag = i;
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [NSString stringWithFormat:@"%@ x", tagName];
        label.font = FONT_NORMAL(13);
        label.textColor = COLOR_1;
        label.layer.cornerRadius = 12;
        label.layer.borderColor = COLOR_1.CGColor;
        label.layer.borderWidth = 0.5;
        label.clipsToBounds = YES;
        [namesScrollView addSubview:label];
        
        xPOS += label.frame.size.width + 15;
        namesScrollView.contentSize = CGSizeMake(xPOS, 40);
    }
    
    [self.tableView reloadData];
}

- (CGSize)getSizeOfString:(NSString *)labelText{
    
    UIFont *font = FONT_NORMAL(13);
    if (IS_IPAD) {
        font = FONT_NORMAL(26);
    }
    CGSize sizeOfText = [labelText boundingRectWithSize: CGSizeMake( self.view.bounds.size.width - 30,CGFLOAT_MAX)
                                                options: (NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                             attributes: [NSDictionary dictionaryWithObject:font
                                                                                     forKey:NSFontAttributeName]
                                                context: nil].size;
    return sizeOfText;
    
}

#pragma mark - table view delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.tableArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (IS_IPAD) {
        return screenWidth + 10;
    } else {
        return 60;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ContactListCustomCell *cell = (ContactListCustomCell *)[[ContactListCustomCell alloc]
                                                            initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell1"];
    if (indexPath.row <= [self.tableArray count]) {
        NSDictionary *dic = [self.tableArray objectAtIndex:indexPath.row];
        cell.authorLabel.text = [dic objectForKey:@"name"];
        [cell.myImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [dic objectForKey:@"avatar"]]] placeholderImage:[UIImage imageNamed:@"icon upload ax"]];
        if (_isJustForShow) {
            cell.statusImageView.hidden = YES;
        }else{
            cell.statusImageView.image = [UIImage imageNamed:@"fill_circle"];
        }

    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *tempDic = [self.tableArray objectAtIndex:indexPath.row];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UserProfileViewController *view = (UserProfileViewController *)[story instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
    view.entityID = [[tempDic objectForKey:@"entity_id"]integerValue];
    view.dictionary = tempDic;
    [self.navigationController pushViewController:view animated:YES];

}

#pragma mark - connection
- (void)editSubject{
    if (!isBusyNow) {
        isBusyNow = YES;
        [ProgressHUD show:@""];
        NSDictionary *params = @{@"conversation_id":[NSNumber numberWithInteger:_conversationID],
                                 @"subject":titleTextField.text
                                 };
        NSString *url = [NSString stringWithFormat:@"%@api/message/conversation/editSubject", BaseURL];
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
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[tempDic objectForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            
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

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
@end
