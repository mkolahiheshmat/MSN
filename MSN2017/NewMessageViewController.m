//
//  FifthViewController.m
//  MSN
//
//  Created by Yarima on 11/5/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "NewMessageViewController.h"
#import "Header.h"
#import "ContactListCustomCell.h"
#import "ProgressHUD.h"
#import <AFHTTPSessionManager.h>
#import <UIImageView+AFNetworking.h>
#import "GetUsernamePassword.h"
#import "TimeAgoViewController.h"
#import "CustomButton.h"
#import "NewMessageViewController.h"
#import "MessageDetailViewController.h"

@interface NewMessageViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
    BOOL    isBusyNow;
    NSInteger page;
    UITextField *searchTextField;
    UITextField *titleTextField;
    UIScrollView *namesScrollView;
    NSMutableArray *selectedTagsArray;
    UIButton *taeedButton;
    NSMutableArray *copyArray;// copy of tableArray for futur use
    UILabel *noResultLabel;
    UILabel *noResultLabelPost;
}
@property(nonatomic, retain)UITableView *tableView;
@property(nonatomic, retain)NSMutableArray *tableArray;

@end

@implementation NewMessageViewController

- (void)viewWillAppear:(BOOL)animated{
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    
    [self makeTopBar];
    [self makeBody];
    selectedTagsArray = [[NSMutableArray alloc]init];
    
    page = 1;
    self.tableArray = [[NSMutableArray alloc]init];
    [self fetchContactlistFromServerWithPage:1];
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
    titleLabel.text = @"نوشتن پیام";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:titleLabel];
    
    UIButton *backButtonImg = [[UIButton alloc]initWithFrame:CGRectMake(0, 16 , 45, 45)];
    [backButtonImg setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButtonImg addTarget:self action:@selector(backButtonImgAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButtonImg];
    
}

- (void)makeBody{
    
    UILabel *titleLabel =[[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 80, 70, 70, 40)];
    titleLabel.font = FONT_NORMAL(16);
    titleLabel.text = @"برای:";
    titleLabel.textColor = COLOR_3;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    
    //name
    searchTextField = [[UITextField alloc]initWithFrame:CGRectMake(5, 70, screenWidth - 70 - 5, 40)];
    searchTextField.backgroundColor = [UIColor whiteColor];
    searchTextField.placeholder = @"جستجو مخاطب";
    searchTextField.tag = 101;
    searchTextField.delegate = self;
    searchTextField.font = FONT_NORMAL(15);
    searchTextField.layer.borderColor = [UIColor clearColor].CGColor;
    searchTextField.layer.borderWidth = 1.0;
    searchTextField.layer.cornerRadius = 5;
    searchTextField.clipsToBounds = YES;
    searchTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    searchTextField.textAlignment = NSTextAlignmentRight;
    [searchTextField addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    [searchTextField addToolbar];
    [self.view addSubview:searchTextField];
    
    UIView *whiteLineView = [[UIView alloc]initWithFrame:CGRectMake(0, searchTextField.frame.origin.y + searchTextField.frame.size.height - 1, screenWidth, 1)];
    whiteLineView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:whiteLineView];
    
    //title
    titleTextField = [[UITextField alloc]initWithFrame:CGRectMake(2, searchTextField.frame.origin.y + searchTextField.frame.size.height, screenWidth - 4, 40)];
    titleTextField.backgroundColor = [UIColor clearColor];
    titleTextField.placeholder = @"دراین قسمت موضوع نوشته می شود.";
    titleTextField.tag = 102;
    titleTextField.delegate = self;
    titleTextField.font = FONT_NORMAL(15);
    titleTextField.layer.borderColor = [UIColor whiteColor].CGColor;
    titleTextField.layer.borderWidth = 1.0;
    //titleTextField.layer.cornerRadius = 5;
    //titleTextField.clipsToBounds = YES;
    titleTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    [titleTextField addTarget:self
                        action:@selector(textFieldDidChange:)
              forControlEvents:UIControlEventEditingChanged];
    titleTextField.textAlignment = NSTextAlignmentRight;
    [titleTextField addToolbar];
    [self.view addSubview:titleTextField];
    
    UIView *whiteLineView2 = [[UIView alloc]initWithFrame:CGRectMake(0, titleTextField.frame.origin.y + titleTextField.frame.size.height - 1, screenWidth, 1)];
    whiteLineView2.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:whiteLineView2];
    
    namesScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, whiteLineView2.frame.origin.y + 2, screenWidth, 40)];
    namesScrollView.contentSize = CGSizeMake(screenWidth, 40);
    //namesScrollView.backgroundColor = COLOR_1;
    [self.view addSubview:namesScrollView];
    
    [noResultLabel removeFromSuperview];
    if ([selectedTagsArray count] == 0) {
        [noResultLabel removeFromSuperview];
        noResultLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, screenWidth - 40,  40)];
        noResultLabel.font = FONT_MEDIUM(13);
        noResultLabel.text = @"مخاطب خود را انتخاب کنید";
        noResultLabel.minimumScaleFactor = 0.7;
        noResultLabel.textColor = [UIColor blackColor];
        noResultLabel.textAlignment = NSTextAlignmentCenter;
        noResultLabel.adjustsFontSizeToFitWidth = YES;
        [namesScrollView addSubview:noResultLabel];
    }

    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, namesScrollView.frame.origin.y + namesScrollView.frame.size.height, screenWidth, screenHeight - (namesScrollView.frame.origin.y + namesScrollView.frame.size.height + 50))];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    taeedButton = [CustomButton initButtonWithTitle:@"√" withTitleColor:WHITE_COLOR withBackColor:GRAY_COLOR isRounded:NO withFrame:CGRectMake(-5, screenHeight - 40, screenWidth + 10, 44)];
    taeedButton.titleLabel.font = FONT_NORMAL(25);
    [taeedButton addTarget:self action:@selector(taeedButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:taeedButton];
    [taeedButton makeGradient:taeedButton];
    taeedButton.userInteractionEnabled = NO;
}

- (void)newMessageAction{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NewMessageViewController *view = (NewMessageViewController *)[story instantiateViewControllerWithIdentifier:@"NewMessageViewController"];
    [self.navigationController pushViewController:view animated:YES];
}

- (void)backButtonImgAction{
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)taeedButtonAction{
    [self uploadMessage];
}

- (void)reloadTagsView{
    NSArray *viewsToRemove = [namesScrollView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }

    //CGFloat yPosOfSelectTagsLabel = 10;
    NSInteger countOfTags = [selectedTagsArray count];
    CGFloat yPOS = 5;
    CGFloat xPOS = 10;
    for (NSInteger i = 0; i < countOfTags; i++) {
        NSString *tagName = [[selectedTagsArray objectAtIndex:i]objectForKey:@"name"];
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
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(deleteTagImageAction:)];
        [label addGestureRecognizer:tap];
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
    
    if ([selectedTagsArray count] > 0 && [titleTextField.text length] > 0) {
        [taeedButton setBackgroundColor:COLOR_3];
        taeedButton.userInteractionEnabled = YES;
    }else{
        [taeedButton setBackgroundColor:GRAY_COLOR];
        taeedButton.userInteractionEnabled = NO;
    }
    
    [noResultLabel removeFromSuperview];
    if ([selectedTagsArray count] == 0) {
        [noResultLabel removeFromSuperview];
        noResultLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, screenWidth - 40,  40)];
        noResultLabel.font = FONT_MEDIUM(13);
        noResultLabel.text = @"مخاطب خود را انتخاب کنید";
        noResultLabel.minimumScaleFactor = 0.7;
        noResultLabel.textColor = [UIColor blackColor];
        noResultLabel.textAlignment = NSTextAlignmentCenter;
        noResultLabel.adjustsFontSizeToFitWidth = YES;
        [namesScrollView addSubview:noResultLabel];
    }

}

- (void)deleteTagImageAction:(UITapGestureRecognizer *)tapy{
    
    NSInteger idOfTapLabel = tapy.view.tag;
    [selectedTagsArray removeObjectAtIndex:idOfTapLabel];
    
    NSArray *viewsToRemove = [namesScrollView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    [self reloadTagsView];
}

- (void)deleteTagWithIndex:(NSInteger)index{
    
    NSInteger idOfTapLabel = index;
    [selectedTagsArray removeObjectAtIndex:idOfTapLabel];
    
    NSArray *viewsToRemove = [namesScrollView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    [self reloadTagsView];
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

- (void)goToMessageDetail:(NSInteger)idx{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MessageDetailViewController *view = (MessageDetailViewController *)[story instantiateViewControllerWithIdentifier:@"MessageDetailViewController"];
    view.conversationId = idx;
    view.participantsArray = selectedTagsArray;
    view.subjectString = titleTextField.text;
    view.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:view animated:YES];
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
        
        NSInteger ind = [selectedTagsArray indexOfObject:[self.tableArray objectAtIndex:indexPath.row]];
        if (ind == NSNotFound) {
            cell.statusImageView.image = [UIImage imageNamed:@"circle"];
        }else{
            cell.statusImageView.image = [UIImage imageNamed:@"fill_circle"];
        }

    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger ind = [selectedTagsArray indexOfObject:[self.tableArray objectAtIndex:indexPath.row]];
    if (ind == NSNotFound) {
        [selectedTagsArray addObject:[self.tableArray objectAtIndex:indexPath.row]];
        [self reloadTagsView];
    }else{
        [self deleteTagWithIndex:ind];
    }
    
    if ([selectedTagsArray count] > 0) {
        [noResultLabel removeFromSuperview];
    }else{
        [noResultLabel removeFromSuperview];
        if ([selectedTagsArray count] == 0) {
            [noResultLabel removeFromSuperview];
            noResultLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, screenWidth - 40,  40)];
            noResultLabel.font = FONT_MEDIUM(13);
            noResultLabel.text = @"مخاطب خود را انتخاب کنید";
            noResultLabel.minimumScaleFactor = 0.7;
            noResultLabel.textColor = [UIColor blackColor];
            noResultLabel.textAlignment = NSTextAlignmentCenter;
            noResultLabel.adjustsFontSizeToFitWidth = YES;
            [namesScrollView addSubview:noResultLabel];
        }

    }
}

#pragma mark - scrollview delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height) {
        // we are at the end
        page++;
        //[self fetchContactlistFromServerWithPage:1];
    }
}

#pragma mark - connection
- (void)fetchContactlistFromServerWithPage:(NSInteger)pageOf{
    if (!isBusyNow) {
        isBusyNow = YES;
        [ProgressHUD show:@""];
        NSDictionary *params = @{@"page":[NSNumber numberWithInteger:pageOf],
                                 @"limit":[NSNumber numberWithInteger:200]
                                 };
        NSString *url = [NSString stringWithFormat:@"%@api/contact_list", BaseURL];
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
            
            copyArray = [[NSMutableArray alloc]initWithArray:self.tableArray];
            [self.tableView reloadData];
            
            if ([self.tableArray count] == 0) {
                [noResultLabelPost removeFromSuperview];
                noResultLabelPost = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, screenWidth - 40,  40)];
                noResultLabelPost.font = FONT_MEDIUM(13);
                noResultLabelPost.text = @"لطفا ابتدا دوستان خود را دنبال کنید";
                noResultLabelPost.minimumScaleFactor = 0.7;
                noResultLabelPost.textColor = [UIColor blackColor];
                noResultLabelPost.textAlignment = NSTextAlignmentCenter;
                noResultLabelPost.adjustsFontSizeToFitWidth = YES;
                [namesScrollView addSubview:noResultLabelPost];
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

- (void)uploadMessage{
    if ([titleTextField.text length] == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"لطفا عنوان را وارد نمایید" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            // ////NSLog(@"You pressed button OK");
        }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    if (!isBusyNow) {
        isBusyNow = YES;
        [ProgressHUD show:@""];
        NSMutableString *participantString = [[NSMutableString alloc]init];
        for (NSInteger i = 0; i < [selectedTagsArray count]; i++) {
            if (i < [selectedTagsArray count] - 1) {
                [participantString appendString:[NSString stringWithFormat:@"%ld,", (long)[[[selectedTagsArray objectAtIndex:i]objectForKey:@"id"]integerValue]]];
            } else {
                [participantString appendString:[NSString stringWithFormat:@"%ld", (long)[[[selectedTagsArray objectAtIndex:i]objectForKey:@"id"]integerValue]]];
            }
            
        }
        NSDictionary *params = @{@"subject":titleTextField.text,
                                 @"participant":participantString,
                                 @"text":@""
                                 };
        NSData *imageData = [[NSData alloc]init];
        NSString *url = [NSString stringWithFormat:@"%@api/message/conversation/add", BaseURL];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"application/json"];
        manager.requestSerializer.timeoutInterval = 45;
        //NSLog(@"%@", [GetUsernamePassword getAccessToken]);
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [GetUsernamePassword getAccessToken]] forHTTPHeaderField:@"Authorization"];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
        [manager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:imageData
                                        name:@"file"
                                    fileName:@"file" mimeType:@"image/jpeg"];
        } progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            [ProgressHUD dismiss];
            isBusyNow = NO;
            NSDictionary *tempDic = (NSDictionary *)responseObject;
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[tempDic objectForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"ادامه" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                [self goToMessageDetail:[[[tempDic objectForKey:@"data"]objectForKey:@"id"]integerValue]];
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

-(void)textFieldDidChange :(UITextField *)theTextField{
    if (theTextField.tag == 101) {
        if ([theTextField.text length] == 0) {
            self.tableArray = [[NSMutableArray alloc]initWithArray:copyArray];
            [self.tableView reloadData];
        } else {
            self.tableArray = [[NSMutableArray alloc]initWithArray:copyArray];
            NSMutableArray *tempArray = [[NSMutableArray alloc]init];
            for (NSInteger i = 0; i < [self.tableArray count]; i++) {
                if ([[[[self.tableArray objectAtIndex:i]objectForKey:@"name"]lowercaseString] containsString:[theTextField.text lowercaseString]]) {
                    [tempArray addObject:[self.tableArray objectAtIndex:i]];
                }
            }
            self.tableArray = [[NSMutableArray alloc]initWithArray:tempArray];
            [self.tableView reloadData];
        }
    }
    
    if (theTextField.tag == 102) {
        if ([selectedTagsArray count] > 0 && [titleTextField.text length] > 0) {
            [taeedButton setBackgroundColor:COLOR_3];
            taeedButton.userInteractionEnabled = YES;
        }else{
            [taeedButton setBackgroundColor:GRAY_COLOR];
            taeedButton.userInteractionEnabled = NO;
        }
    }
}
@end
