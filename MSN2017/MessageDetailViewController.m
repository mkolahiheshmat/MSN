//
//  FifthViewController.m
//  MSN
//
//  Created by Yarima on 11/5/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "MessageDetailViewController.h"
#import "Header.h"
#import "MessageDetailCustomCell.h"
#import "ProgressHUD.h"
#import <AFHTTPSessionManager.h>
#import <UIImageView+AFNetworking.h>
#import "GetUsernamePassword.h"
#import "TimeAgoViewController.h"
#import "CustomButton.h"
#import "EditMessageViewController.h"
#import "UIView+Bubble.h"
#import "ImageViewController.h"

#define Height_QuestionView 40
@interface MessageDetailViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate>
{
    BOOL    isBusyNow;
    NSInteger page;
    UITextField *nameTextField;
    UITextField *titleTextField;
    UIView *namesView;
    NSMutableArray *selectedTagsArray;
    UIButton *taeedButton;
    UIView *replyViewBG;
    UIButton *sendButton;
    UITextView *questionTextView;
    CGFloat lastHeightOfQuestionTextView;
    NSString *requestType;
    NSInteger messageID;
    UIImageView *attachImageView;
    UIView *galleryCameraView;
    NSInteger entityID;
    NSMutableArray *participantImageArray;
    BOOL isQuestionTextViewTyping;
    UIView *imagePreviewView;
}
@property(nonatomic, retain)UITableView *tableView;
@property(nonatomic, retain)NSMutableArray *tableArray;

@end

@implementation MessageDetailViewController

- (void)viewWillAppear:(BOOL)animated{
    if ([participantImageArray count] > 0) {//use to update view when come back from edit participant
        for (UIView *v in [namesView subviews]) {
            [v removeFromSuperview];
        }
        [self makeParticipantView];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    
    entityID = [[[NSUserDefaults standardUserDefaults]objectForKey:@"profileID"]integerValue];
    [self makeTopBar];
    [self makeBody];
    selectedTagsArray = [[NSMutableArray alloc]init];
    
    requestType = @"";
    page = 1;
    self.tableArray = [[NSMutableArray alloc]init];
    [self fetchConversationFromServerWithPage:page requestType:requestType];
    [self fetchParticipants];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"fetchNewMessages" object:nil];
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
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissTextField)];
    [topView addGestureRecognizer:tap];
    [self.view addSubview:topView];
    
    CGFloat topViewHeight = topView.frame.size.height;
    
    UILabel *titleLabel =[[UILabel alloc]initWithFrame:CGRectMake(screenWidth/2 - 100, topViewHeight/2 - 15, 200, 40)];
    titleLabel.font = FONT_NORMAL(16);
    titleLabel.text = _subjectString;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:titleLabel];
    
    UIButton *backButtonImg = [[UIButton alloc]initWithFrame:CGRectMake(0, 16 , 45, 45)];
    [backButtonImg setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButtonImg addTarget:self action:@selector(backButtonImgAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButtonImg];
    
}

- (void)makeBody{
    
    namesView = [[UIView alloc]initWithFrame:CGRectMake(0, 70, screenWidth, 55)];
    [self.view addSubview:namesView];
    
    UIView *whiteLineView = [[UIView alloc]initWithFrame:CGRectMake(0, namesView.frame.origin.y + namesView.frame.size.height - 1, screenWidth, 1)];
    whiteLineView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:whiteLineView];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, namesView.frame.origin.y + namesView.frame.size.height, screenWidth, screenHeight - (namesView.frame.origin.y + namesView.frame.size.height + 40))];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissTextField)];
    [self.tableView addGestureRecognizer:tap];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    replyViewBG = [[UIView alloc]initWithFrame:CGRectMake(0, screenHeight - Height_QuestionView, screenWidth, Height_QuestionView)];
    replyViewBG.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:replyViewBG];
    sendButton = [CustomButton initButtonWithTitle:@"ارسال" withTitleColor:[UIColor whiteColor] withBackColor:[UIColor colorWithRed:92/255.0 green:134/255.0 blue:217/255.0 alpha:1.0] isRounded:YES withFrame:CGRectMake(screenWidth - 60, 0, 120, Height_QuestionView)];
    [sendButton addTarget:self action:@selector(sendButtonAction) forControlEvents:UIControlEventTouchUpInside];
    sendButton.titleEdgeInsets = UIEdgeInsetsMake(0, -50, 0, 0);
    [replyViewBG addSubview:sendButton];
    
    questionTextView = [[UITextView alloc]initWithFrame:CGRectMake(40, 0, screenWidth - 60 - 40, Height_QuestionView)];
    questionTextView.font = FONT_MEDIUM(12);
    questionTextView.tag = 534;
    questionTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    questionTextView.delegate = self;
    //    questionTextView.layer.borderColor = [UIColor grayColor].CGColor;
    //    questionTextView.layer.borderWidth = 1.0;
    questionTextView.textColor = [UIColor grayColor];
    questionTextView.contentSize = CGSizeMake(screenWidth, 1000);
    [questionTextView setScrollEnabled:YES];
    questionTextView.text = NSLocalizedString(@"لطفا متن خود را بنویسید", @"");
    questionTextView.textAlignment = NSTextAlignmentRight;
    [replyViewBG addSubview:questionTextView];
    lastHeightOfQuestionTextView = 40;
    
    UIButton *attachButton = [CustomButton initButtonWithImage:[UIImage imageNamed:@"attach"] withFrame:CGRectMake(10, 10, 54 * 0.3, 73 * 0.3)];
    [attachButton addTarget:self action:@selector(showgalleryCameraView) forControlEvents:UIControlEventTouchUpInside];
    [replyViewBG addSubview:attachButton];
    
    UIView *whiteLineView2 = [[UIView alloc]initWithFrame:CGRectMake(0, screenHeight - Height_QuestionView, screenWidth, 1)];
    whiteLineView2.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:whiteLineView2];
}

- (void)editMessageAction{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    EditMessageViewController *view = (EditMessageViewController *)[story instantiateViewControllerWithIdentifier:@"EditMessageViewController"];
    view.tableArray = participantImageArray;
    view.conversationID = _conversationId;
    view.subjectString = _subjectString;
    view.isJustForShow = YES;
    [self.navigationController pushViewController:view animated:YES];
}

- (void)backButtonImgAction{
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)sendButtonAction{
    [self sendReply];
}

- (void)dismissTextField{
    [questionTextView resignFirstResponder];
    [self hideGalleryCameraView];
    
}

- (CGSize)getSizeOfString:(NSString *)labelText{
    if ([labelText length] == 0) {
        CGSize size = CGSizeZero;
        return size;
    }
    UIFont *font = FONT_NORMAL(11);
    if (IS_IPAD) {
        font = FONT_NORMAL(26);
    }
    CGSize sizeOfText = [labelText boundingRectWithSize: CGSizeMake( self.view.bounds.size.width / 2,CGFLOAT_MAX)
                                                options: (NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                             attributes: [NSDictionary dictionaryWithObject:font
                                                                                     forKey:NSFontAttributeName]
                                                context: nil].size;
    return sizeOfText;
    
}

- (void)makeParticipantView {
    CGFloat xPOs = 5;
    for (NSInteger i = 0; i < [participantImageArray count]; i++) {
        UIImageView *myImageView = [[UIImageView alloc]initWithFrame:CGRectMake(xPOs, 4, 40, 40)];
        myImageView.layer.cornerRadius = 20;
        myImageView.clipsToBounds = YES;
        [myImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[participantImageArray objectAtIndex:i]objectForKey:@"avatar"]]] placeholderImage:[UIImage imageNamed:@"icon upload ax"]];
        [namesView addSubview:myImageView];
        
        xPOs += 58;
        
        if (i == 2) {
            break;
        }
    }
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 50, 4, 40, 40)];
    label.font = FONT_MEDIUM(14);
    label.minimumScaleFactor = 0.7;
    label.textColor = WHITE_COLOR;
    label.backgroundColor = COLOR_3;
    label.textAlignment = NSTextAlignmentCenter;
    label.adjustsFontSizeToFitWidth = YES;
    label.text = [NSString stringWithFormat:@"%ld", (unsigned long)[participantImageArray count]];
    label.layer.cornerRadius = 20;
    label.clipsToBounds = YES;
    label.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showParticipantsList:)];
    [label addGestureRecognizer:tap];
    [namesView addSubview:label];
    
    xPOs += 58;
    UIButton *inviteButton = [CustomButton initButtonWithTitle:@"ویرایش عنوان" withTitleColor:WHITE_COLOR withBackColor:COLOR_3 isRounded:YES withFrame:CGRectMake(xPOs, 5, screenWidth - xPOs - 10, 33)];
    [inviteButton addTarget:self action:@selector(editMessageAction) forControlEvents:UIControlEventTouchUpInside];
    //[namesView addSubview:inviteButton];
}

- (void)showParticipantsList:(UITapGestureRecognizer *)tap{
    [self editMessageAction];
}
- (void)tapImageView:(UITapGestureRecognizer *)tap{
    NSDictionary *tempDic = [self.tableArray objectAtIndex:tap.view.tag];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ImageViewController *view = (ImageViewController *)[story instantiateViewControllerWithIdentifier:@"ImageViewController"];
    NSString *url = [[tempDic objectForKey:@"media"]objectForKey:@"url"];
    view.imageViewURL = [NSString stringWithFormat:@"%@",
                         [NSString stringWithFormat:@"%@", url]];
    [self.navigationController pushViewController:view animated:YES];
    
}

- (void)tapToDismissImage:(UITapGestureRecognizer *)tapy{
    [imagePreviewView removeFromSuperview];
}

- (void)removePreviewImage{
    [imagePreviewView removeFromSuperview];
}

#pragma mark - camera roll and camera delegate
- (void)hideGalleryCameraView{
    [galleryCameraView removeFromSuperview];
}

- (void)galleryButtonAction{
    [self hideGalleryCameraView];
    [self selectPhoto];
}

- (void)cameraButtonAction{
    [self hideGalleryCameraView];
    //[[NSOperationQueue mainQueue] addOperationWithBlock:^{
    [self takePhoto];
    //}];
    
}

- (void)showgalleryCameraView{
    [self dismissTextField];
    
    [self hideGalleryCameraView];
    CGFloat viewSize = 200;
    galleryCameraView =[[UIView alloc]initWithFrame:CGRectMake(screenWidth/2 - viewSize/2, screenHeight/2 - viewSize/2, viewSize, viewSize)];
    galleryCameraView.layer.cornerRadius = 5;
    galleryCameraView.clipsToBounds = NO;
    galleryCameraView.layer.shadowOffset = CGSizeMake(0, 0);
    galleryCameraView.layer.shadowRadius = 20;
    galleryCameraView.layer.shadowOpacity = 0.1;
    galleryCameraView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:galleryCameraView];
    
    UIButton *galleryButton = [CustomButton initButtonWithTitle:NSLocalizedString(@"gallery", @"") withTitleColor:[UIColor whiteColor] withBackColor:[UIColor colorWithRed:0.05 green:0.408 blue:0.577 alpha:1.0] withFrame:CGRectMake(20, 40, galleryCameraView.frame.size.width - 40, 40)];
    [galleryButton addTarget:self action:@selector(galleryButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [galleryCameraView addSubview:galleryButton];
    
    UIButton *cameraButton = [CustomButton initButtonWithTitle:NSLocalizedString(@"camera", @"") withTitleColor:[UIColor whiteColor] withBackColor:[UIColor colorWithRed:0.05 green:0.408 blue:0.577 alpha:1.0] withFrame:CGRectMake(20, 130, galleryCameraView.frame.size.width - 40, 40)];
    [cameraButton addTarget:self action:@selector(cameraButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [galleryCameraView addSubview:cameraButton];
}


- (void)takePhoto {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    picker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)selectPhoto {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    attachImageView = [[UIImageView alloc]init];
    attachImageView.image = chosenImage;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    [imagePreviewView removeFromSuperview];
    imagePreviewView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    imagePreviewView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.6];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 50, screenWidth, screenWidth)];
    imageView.image = attachImageView.image;
    [imagePreviewView addSubview:imageView];
    imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapToDismissImage:)];
    [imageView addGestureRecognizer:tap];
    [self.view addSubview:imagePreviewView];
    
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 60)];
    [topView makeGradient:topView];
    [imagePreviewView addSubview:topView];
    
    UIButton *sendBtn = [CustomButton initButtonWithTitle:@"ارسال" withTitleColor:[UIColor whiteColor] withBackColor:COLOR_5 isRounded:NO withFrame:CGRectMake(screenWidth/2, imageView.frame.origin.y + imageView.frame.size.height, screenWidth/2, 40)];
    [sendBtn addTarget:self action:@selector(sendReply) forControlEvents:UIControlEventTouchUpInside];
    [imagePreviewView addSubview:sendBtn];
    
    UIButton *cancelBtn = [CustomButton initButtonWithTitle:@"لغو" withTitleColor:[UIColor whiteColor] withBackColor:COLOR_5 isRounded:NO withFrame:CGRectMake(0, imageView.frame.origin.y + imageView.frame.size.height, screenWidth/2, 40)];
    [cancelBtn addTarget:self action:@selector(removePreviewImage) forControlEvents:UIControlEventTouchUpInside];
    [imagePreviewView addSubview:cancelBtn];
    
    UILabel *titleLabel =[[UILabel alloc]initWithFrame:CGRectMake(screenWidth/2 - 100, 10, 200, 40)];
    titleLabel.font = FONT_NORMAL(16);
    titleLabel.text = @"پیش نمایش";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [imagePreviewView addSubview:titleLabel];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (NSArray *)sort:(NSArray *)inputArray{
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id"
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [inputArray sortedArrayUsingDescriptors:sortDescriptors];
    return  sortedArray;
}
#pragma mark - table view delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.tableArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = [self.tableArray objectAtIndex:indexPath.row];
    NSString *str = [dic objectForKey:@"body"];
    CGFloat ratio = [[[dic objectForKey:@"media"]objectForKey:@"ratio"]floatValue];
    if (IS_IPAD) {
        if ([[[dic objectForKey:@"media"]objectForKey:@"url"] length]  > 0) {
            return [self getSizeOfString:str].height + 100 + (screenWidth/2 / ratio);
        }else{
            return [self getSizeOfString:str].height + 50;
        }
    } else {
        if ([[[dic objectForKey:@"media"]objectForKey:@"url"] length]  > 0) {
            //NSLog(@"height:%f--ratio:%f", [self getSizeOfString:str].height + 100 + (screenWidth/2 / ratio), ratio);
            return [self getSizeOfString:str].height + 70 + (screenWidth/2 / ratio);
        }else{
            return [self getSizeOfString:str].height + 50;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MessageDetailCustomCell *cell;
    
    if (indexPath.row <= [self.tableArray count]) {
        NSDictionary *dic = [self.tableArray objectAtIndex:indexPath.row];
        NSInteger entityidOfPost = [[[dic objectForKey:@"sender"]objectForKey:@"entity_id"]integerValue];
        NSString *str = [dic objectForKey:@"body"];
        CGFloat ratio = [[[dic objectForKey:@"media"]objectForKey:@"ratio"]floatValue];
        if (entityID == entityidOfPost) {//this is my post
            cell = (MessageDetailCustomCell *)[[MessageDetailCustomCell alloc]
                                               initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:@"cell1"
                                               isSameUser:YES
                                               height:[self getSizeOfString:str].height];
            [cell.myImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[dic objectForKey:@"sender"]objectForKey:@"avatar"]]] placeholderImage:[UIImage imageNamed:@"icon upload ax"]];
            //date
            NSDateFormatter *currentDateFormatter = [[NSDateFormatter alloc]init];
            [currentDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
            [currentDateFormatter setTimeZone:timeZone];
            NSDate *endDate = [NSDate date];
            
            double timestampval = [[dic objectForKey:@"created_at"]doubleValue];
            //NSLog(@"%f", timestampval);
            NSTimeInterval timestamp = (NSTimeInterval)timestampval;
            NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
            cell.dateLabel.text = [NSString stringWithFormat:@"%@",
                                   [TimeAgoViewController timeIntervalWithStartDate:startDate withEndDate:endDate]];
            
            CGFloat widthOfString = [self getSizeOfString:str].width;
            if ([str length] == 0) {
                widthOfString = 0;
            }
            CGFloat widthOfBubble = 0.0;
            CGFloat xPosOfBubble = 110.0;
            if (widthOfString < screenWidth/2 + 10) {
                widthOfBubble = widthOfString + 10;
                xPosOfBubble = screenWidth - 80 - widthOfBubble;
            }else{
                widthOfBubble = screenWidth/2 + 10;
            }
            
            if ([str length] == 0) {
                widthOfBubble = 0;
            }
            UIView *bubbleview = [UIView makeBubble:CGRectMake(xPosOfBubble, cell.myImageView.frame.size.height / 2, widthOfBubble, [self getSizeOfString:str].height + 7) flipped:NO color:COLOR_3];
            [cell addSubview:bubbleview];
            
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(2, 4, bubbleview.frame.size.width - 4, [self getSizeOfString:str].height)];
            titleLabel.font = FONT_MEDIUM(11);
            //titleLabel.minimumScaleFactor = 0.6;
            titleLabel.numberOfLines = 0;
            titleLabel.textColor = [UIColor whiteColor];
            titleLabel.textAlignment = NSTextAlignmentRight;
            titleLabel.adjustsFontSizeToFitWidth = YES;
            titleLabel.text = str;
            [bubbleview addSubview:titleLabel];
            
            if ([[[dic objectForKey:@"media"]objectForKey:@"url"] length]  > 0) {
                CGFloat yPos = bubbleview.frame.origin.y + bubbleview.frame.size.height + 10;
                if ([str length] == 0) {
                    yPos = 45;
                }
                UIImageView *imageView = [[UIImageView alloc]initWithFrame:
                                          CGRectMake(110, yPos, screenWidth/2, (screenWidth/2) / ratio)];
                [imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[dic objectForKey:@"media"]objectForKey:@"url"]]] placeholderImage:[UIImage imageNamed:@"broken_image"]];
                imageView.layer.cornerRadius = 8;
                imageView.clipsToBounds = YES;
                imageView.userInteractionEnabled = YES;
                imageView.tag = indexPath.row;
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImageView:)];
                [imageView addGestureRecognizer:tap];
                [cell addSubview:imageView];
            }
            
        } else {//other's post
            cell = (MessageDetailCustomCell *)[[MessageDetailCustomCell alloc]
                                               initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:@"cell1"
                                               isSameUser:NO
                                               height:[self getSizeOfString:str].height];
            [cell.myImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[dic objectForKey:@"sender"]objectForKey:@"avatar"]]] placeholderImage:[UIImage imageNamed:@"icon upload ax"]];
            //date
            NSDateFormatter *currentDateFormatter = [[NSDateFormatter alloc]init];
            [currentDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
            [currentDateFormatter setTimeZone:timeZone];
            NSDate *endDate = [NSDate date];
            
            double timestampval = [[dic objectForKey:@"created_at"]doubleValue];
            //NSLog(@"%f", timestampval);
            NSTimeInterval timestamp = (NSTimeInterval)timestampval;
            NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
            cell.dateLabel.text = [NSString stringWithFormat:@"%@",
                                   [TimeAgoViewController timeIntervalWithStartDate:startDate withEndDate:endDate]];
            
            CGFloat widthOfString = [self getSizeOfString:str].width;
            
            CGFloat widthOfBubble = 0.0;
            if (widthOfString < screenWidth/2 + 10) {
                widthOfBubble = widthOfString + 10;
            }else{
                widthOfBubble = screenWidth/2 + 10;
            }
            
            if ([str length] == 0) {
                widthOfBubble = 0;
            }
            UIView *bubbleview = [UIView makeBubble:CGRectMake(70, cell.myImageView.frame.size.height / 2, widthOfBubble, [self getSizeOfString:str].height + 7) flipped:YES color:COLOR_1];
            [cell addSubview:bubbleview];
            
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(2, 4, bubbleview.frame.size.width - 4, [self getSizeOfString:str].height)];
            titleLabel.font = FONT_MEDIUM(11);
            //titleLabel.minimumScaleFactor = 0.8;
            titleLabel.numberOfLines = 0;
            titleLabel.textColor = [UIColor whiteColor];
            titleLabel.textAlignment = NSTextAlignmentRight;
            titleLabel.adjustsFontSizeToFitWidth = YES;
            titleLabel.text = str;
            [bubbleview addSubview:titleLabel];
            
            if ([[[dic objectForKey:@"media"]objectForKey:@"url"] length]  > 0) {
                CGFloat yPos = bubbleview.frame.origin.y + bubbleview.frame.size.height + 10;
                if ([str length] == 0) {
                    yPos = 45;
                }
                UIImageView *imageView = [[UIImageView alloc]initWithFrame:
                                          CGRectMake(70, yPos, screenWidth/2, (screenWidth/2) / ratio)];
                [imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[dic objectForKey:@"media"]objectForKey:@"url"]]] placeholderImage:[UIImage imageNamed:@"broken_image"]];
                imageView.layer.cornerRadius = 8;
                imageView.clipsToBounds = YES;
                imageView.userInteractionEnabled = YES;
                imageView.tag = indexPath.row;
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImageView:)];
                [imageView addGestureRecognizer:tap];
                [cell addSubview:imageView];
            }
        }
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - scrollview delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (!isQuestionTextViewTyping) {
        float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
        float scrollOffset = scrollView.contentOffset.y;
        if (bottomEdge >= scrollView.contentSize.height) {//end of scrollview
            // we are at the end
            messageID = [[[self.tableArray lastObject]objectForKey:@"id"]integerValue];
            requestType = @"new";
            page++;
            [self fetchConversationFromServerWithPage:page requestType:requestType];
        }else if (scrollOffset == 0){//top of scrollview
            messageID = [[[self.tableArray firstObject]objectForKey:@"id"]integerValue];
            requestType = @"old";
            page--;
            [self fetchConversationFromServerWithPage:page requestType:requestType];
        }
    }
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
    [self hideGalleryCameraView];
    isQuestionTextViewTyping = YES;
    if (textView.tag == 534) {
        if ([textView.text isEqualToString:NSLocalizedString(@"لطفا متن خود را بنویسید",@"")]) {
            textView.text = @"";
        }
        [UIView animateWithDuration:0.5 animations:^{
            questionTextView.backgroundColor = COLOR_4;
            CGRect rect = replyViewBG.frame;
            if (IS_IPAD) rect.origin.y = screenHeight - 360;
            else rect.origin.y = screenHeight - 255;
            [replyViewBG setFrame:rect];
            
            rect = self.tableView.frame;
            rect.size.height = 60;
            //[_tableView setFrame:rect];
            
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
            }
            
            [textView layoutIfNeeded];
            [textView becomeFirstResponder];
        }];
    }
    
    self.tableView.userInteractionEnabled = NO;
}

- (void)resignQuestionTextView {
    isQuestionTextViewTyping = NO;
    [UIView animateWithDuration:0.5 animations:^{
        questionTextView.backgroundColor = [UIColor whiteColor];
        CGRect rect = replyViewBG.frame;
        rect.origin.y = screenHeight - Height_QuestionView;
        rect.size.height = Height_QuestionView;
        [replyViewBG setFrame:rect];
        
        rect = sendButton.frame;
        rect.origin.y = 0;
        [sendButton setFrame:rect];
        
        rect = questionTextView.frame;
        rect.size.height = 40;
        rect.origin.y = 0;
        [questionTextView setFrame:rect];
        [questionTextView resignFirstResponder];
        
        rect = self.tableView.frame;
        rect.size.height = screenHeight - (namesView.frame.origin.y + namesView.frame.size.height + 60);
        //[_tableView setFrame:rect];
    }];
    
    self.tableView.userInteractionEnabled = YES;
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

#pragma mark - connection
- (void)fetchConversationFromServerWithPage:(NSInteger)pageOf requestType:(NSString *)requestTypeOf{
    if (!isBusyNow) {
        isBusyNow = YES;
        [ProgressHUD show:@""];
        NSDictionary *params = @{@"conversation_id":[NSNumber numberWithInteger:_conversationId],
                                 @"request":requestTypeOf,
                                 @"message_id":[NSNumber numberWithInteger:messageID],
                                 @"limit":[NSNumber numberWithInteger:20]
                                 };
        NSString *url = [NSString stringWithFormat:@"%@api/message/conversation/getMessage", BaseURL];
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
            if ([[tempDic objectForKey:@"success"]integerValue] == 0) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[tempDic objectForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                    // ////NSLog(@"You pressed button OK");
                }];
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
                return;
            }
            
            if ([[tempDic objectForKey:@"data"]count] > 0) {
                for (NSDictionary *dic in [tempDic objectForKey:@"data"]) {
                    
                    NSInteger ind = [self.tableArray indexOfObject:dic];
                    if (ind == NSNotFound){
                        if ([requestType isEqualToString:@"old"]) {
                            [self.tableArray insertObject:dic atIndex:0];
                        }else{
                            [self.tableArray addObject:dic];
                        }
                    }
                }
                
                //sort array ascending
                NSArray *tempArray = [[NSArray alloc]initWithArray:self.tableArray];
                tempArray = [self sort:tempArray];
                self.tableArray = [[NSMutableArray alloc]initWithArray:tempArray];
                [self.tableView reloadData];
                
                if ([requestType isEqualToString:@"old"]) {
                    //[self.tableView scrollsToTop];
                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.tableArray.count-20 inSection:0]
                                          atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                } else {
                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.tableArray.count-1 inSection:0]
                                          atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                }
            }
            
            
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

- (void)sendReply{
    [self removePreviewImage];
    [self resignQuestionTextView];
    [ProgressHUD show:@""];
    if ([questionTextView.text isEqualToString:@"لطفا متن خود را بنویسید"]) {
        questionTextView.text = @"";
    }
    NSDictionary *params = @{@"conversation_id":[NSNumber numberWithInteger:_conversationId],
                             @"text":questionTextView.text,
                             @"recipients":@""
                             };
    NSData *imageData = UIImagePNGRepresentation(attachImageView.image);
    
    NSString *url = [NSString stringWithFormat:@"%@api/message/conversation/sendMessage", BaseURL];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"application/json"];
    manager.requestSerializer.timeoutInterval = 45;
    //NSLog(@"%@", [GetUsernamePassword getAccessToken]);
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [GetUsernamePassword getAccessToken]] forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    
    [manager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (imageData) {
            [formData appendPartWithFileData:imageData
                                        name:@"file"
                                    fileName:@"file" mimeType:@"image/jpeg"];
        }
        
    } progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [ProgressHUD dismiss];
        NSDictionary *resDic = (NSDictionary *)responseObject;
        if ([[resDic objectForKey:@"success"]integerValue] == 1) {
            attachImageView.image = nil;
            questionTextView.text = @"";
            messageID = [[[self.tableArray firstObject]objectForKey:@"id"]integerValue];
            requestType = @"";
            page = 1;
            [self fetchConversationFromServerWithPage:page requestType:requestType];
            
        }else{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[resDic objectForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                // ////NSLog(@"You pressed button OK");
            }];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
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

- (void)fetchParticipants{
    NSDictionary *params = @{@"conversation_id":[NSNumber numberWithInteger:_conversationId]
                             };
    NSString *url = [NSString stringWithFormat:@"%@api/message/conversation/getParticipant", BaseURL];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"application/json"];
    manager.requestSerializer.timeoutInterval = 45;
    //NSLog(@"%@", [GetUsernamePassword getAccessToken]);
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [GetUsernamePassword getAccessToken]] forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    [manager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
    } progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *tempDic = (NSDictionary *)responseObject;
        if ([[tempDic objectForKey:@"success"]integerValue] == 0) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[tempDic objectForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                // ////NSLog(@"You pressed button OK");
            }];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        
        if ([[tempDic objectForKey:@"data"]count] > 0) {
            participantImageArray = [[NSMutableArray alloc]init];
            for (NSDictionary *dic in [tempDic objectForKey:@"data"]) {
                [participantImageArray addObject:dic];
            }
        }
        
        [self makeParticipantView];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self fetchParticipants];
    }];
}

@end
