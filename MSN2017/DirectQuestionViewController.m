//
//  DirectQuestionViewController.m
//  MSN
//
//  Created by Yarima on 5/4/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "DirectQuestionViewController.h"
#import "Database.h"
#import <AFHTTPSessionManager.h>
#import <UIImageView+AFNetworking.h>
#import "Header.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import "KeychainWrapper.h"
#import "ProgressHUD.h"
#import "TimeAgoViewController.h"
#import "CustomButton.h"
#import "UploadDocumentsViewController.h"
#import "ConsultationListViewController.h"
#import "GetUsernamePassword.h"
#import "HealthStatusViewController.h"
#import "FavoritesViewController.h"
#import "AboutViewController.h"
#import "UIImage+Extra.h"
#define Height_QuestionView 60

@interface DirectQuestionViewController()<UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
{
     
    BOOL    isBusyNow;
    UIImageView *coverImageView;
    UIImageView *doctorImageView;
    UILabel *authorNameLabel;
    UILabel *authorJobLabel;
    UIButton *menubuttons;
    UIView *questionView;
    UITextView *questionTextView;
    CGFloat lastHeightOfQuestionTextView;
    UIView *packageListView;
    NSMutableArray *packegesArray;
    CGFloat yPositionOfLabel;
    NSMutableArray *packageColorArray;
    CGFloat yPositionOfSelectedButton;
    NSInteger selectedPackageId;
    UIView *packageBuyView;
    UILabel *selectLabel;
    UIView *blurView;
    UIView *attachFileView;
    NSInteger idOfAttachment;
    UIView *medicalSectionBG;
    UIPickerView *medicalSectionPickerView;
    NSMutableArray *medicalSectionArray;
    BOOL isHidden;
    UIButton *medicalSectionButton;
    UIToolbar *dateToolbar;
    NSInteger idOfSelectedMedicalSection;
    UIView *warningView;
    UIButton *attachButton;
    UIButton *sendButton;
}

@end

@implementation DirectQuestionViewController
- (void)viewDidDisappear:(BOOL)animated{
    [ProgressHUD dismiss];
}
- (void)viewDidLoad {
    self.navigationController.navigationBar.hidden = YES;
    idOfSelectedMedicalSection = 1000;
    [super viewDidLoad];
    idOfAttachment = 0;
     
    isBusyNow = NO;
    lastHeightOfQuestionTextView = 40;
    //make View
    [self makeTopBar];
    if (!_isNewQuestion)
        [self makeCover];
    else
        [self makeMedicalSection];
    [self makeAgreementText];
    [self questionView];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showAttachImage:) name:@"showAttachImage" object:nil];
    
    //NSLog(@"self.navigationControllers: %@", [self.navigationController viewControllers]);
    
    NSString *isFirstQuestion = [[NSUserDefaults standardUserDefaults]objectForKey:@"isFirstTimeForQuestion"];
    if ([isFirstQuestion length] == 0) {
        [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"isFirstTimeForQuestion"];
        [self makeWarningView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom methods

- (void)makeTopBar{
    
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 70)];
    topView.backgroundColor = COLOR_3;
    [topView makeGradient:topView];
    topView.userInteractionEnabled = YES;
    [self.view addSubview:topView];
    
    CGFloat topViewHeight = topView.frame.size.height;
    
    UILabel *titleLabel =[[UILabel alloc]initWithFrame:CGRectMake(screenWidth/2 - 100, topViewHeight/2 - 15, 200, 40)];
    titleLabel.font = FONT_NORMAL(20);
    titleLabel.text = NSLocalizedString(@"soalAzPezeshk", @"");
    if(_isNewQuestion)
        titleLabel.text = NSLocalizedString(@"newConsultation", @"");
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:titleLabel];
    //54 × 39
    UIButton *menuButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - 60, topViewHeight/2 - 20, 54, 54)];
    //menuButton.backgroundColor = [UIColor redColor];
    UIImage *img = [UIImage imageNamed:@"menu side"];
    [menuButton setImage:[img imageByScalingProportionallyToSize:CGSizeMake(54/2,39/2)] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(menuButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:menuButton];
    
    UIButton *backButtonImg = [[UIButton alloc]initWithFrame:CGRectMake(0, 16 , 45, 45)];
    [backButtonImg setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButtonImg addTarget:self action:@selector(backButtonImgAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButtonImg];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissTextView)];
    [topView addGestureRecognizer:tap];
    
    
}

- (void)makeCover{
    coverImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 70, screenWidth, screenWidth * 0.43)];
    coverImageView.image = [UIImage imageNamed:@"difualt cover"];
    coverImageView.userInteractionEnabled = YES;
    [self.view addSubview:coverImageView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissTextView)];
    [coverImageView addGestureRecognizer:tap];
    
    
    CGFloat imageSizeBorder = screenWidth * 0.25;
    UIImageView *borderImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - imageSizeBorder - 10, coverImageView.frame.size.height/2 - (imageSizeBorder / 2), imageSizeBorder, imageSizeBorder)];
    borderImageView.image = [UIImage imageNamed:@"border pic"];
    [coverImageView addSubview:borderImageView];
    
    CGFloat imageSize = screenWidth * 0.2;
    doctorImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - imageSize - 20, coverImageView.frame.size.height/2 - (imageSize / 2), imageSize, imageSize)];
    [doctorImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", self.userAvatar]] placeholderImage:[UIImage imageNamed:@"icon upload ax"]];
    doctorImageView.layer.cornerRadius = imageSize / 2;
    doctorImageView.clipsToBounds = YES;
    [coverImageView addSubview:doctorImageView];
    
    authorNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, doctorImageView.frame.origin.y + 10, screenWidth - doctorImageView.frame.size.width - 50, 25)];
    authorNameLabel.font = FONT_MEDIUM(13);
    authorNameLabel.minimumScaleFactor = 0.7;
    authorNameLabel.textColor = [UIColor whiteColor];
    authorNameLabel.textAlignment = NSTextAlignmentRight;
    authorNameLabel.adjustsFontSizeToFitWidth = YES;
    authorNameLabel.text = self.userTitle;
    [coverImageView addSubview:authorNameLabel];
    
    authorJobLabel = [[UILabel alloc]initWithFrame:CGRectMake(doctorImageView.frame.origin.x - 200, authorNameLabel.frame.origin.y + 25, 180, 25)];
    authorJobLabel.font = FONT_NORMAL(11);
    //authorJobLabel.minimumScaleFactor = 0.7;
    authorJobLabel.textColor = [UIColor whiteColor];
    authorJobLabel.textAlignment = NSTextAlignmentRight;
    //authorJobLabel.adjustsFontSizeToFitWidth = YES;
    authorJobLabel.text = self.userJobTitle;
    [coverImageView addSubview:authorJobLabel];
    
}

- (void)makeWarningView{
    
    warningView = [[UIView alloc]initWithFrame:CGRectMake(0, 70, screenWidth, screenHeight - 70)];
    warningView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:warningView];
    
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(10, 15, screenWidth - 20, 50)];
    label1.backgroundColor = COLOR_1;
    label1.font = FONT_NORMAL(13);
    label1.numberOfLines = 2;
    label1.text = NSLocalizedString(@"warning1", @"");
    //authorJobLabel.minimumScaleFactor = 0.7;
    label1.textColor = [UIColor whiteColor];
    label1.textAlignment = NSTextAlignmentCenter;
    //authorJobLabel.adjustsFontSizeToFitWidth = YES;
    [warningView addSubview:label1];
    
    //make agreement text
    NSMutableString *string1 = [[NSMutableString alloc]initWithString:NSLocalizedString(@"text8", @"")];
    [string1 appendString:[NSString stringWithFormat:@"\n%@", NSLocalizedString(@"text9", @"")]];
    [string1 appendString:[NSString stringWithFormat:@"\n%@", NSLocalizedString(@"text10", @"")]];
    [string1 appendString:[NSString stringWithFormat:@"\n%@", NSLocalizedString(@"text11", @"")]];
    [string1 appendString:[NSString stringWithFormat:@"\n%@", NSLocalizedString(@"text12", @"")]];
    
    UITextView *textView1 = [[UITextView alloc]initWithFrame:CGRectMake(10, 70, screenWidth - 20, [self getHeightOfString:string1])];
    textView1.font = FONT_MEDIUM(12);
    if (IS_IPHONE_5_IOS7 || IS_IPHONE_5_IOS8 || IS_IPHONE_4_AND_OLDER_IOS7 || IS_IPHONE_4_AND_OLDER_IOS8) {
        textView1.font = FONT_NORMAL(10);
    }
    textView1.textAlignment = NSTextAlignmentRight;
    textView1.text = string1;
    textView1.userInteractionEnabled = NO;
    [warningView addSubview:textView1];
    
    UIButton *callEmergencyButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth/2 - 75, textView1.frame.origin.y + textView1.frame.size.height, 150, 30)];
    callEmergencyButton.layer.cornerRadius = 15;
    callEmergencyButton.clipsToBounds = YES;
    callEmergencyButton.backgroundColor = COLOR_1;
    callEmergencyButton.titleLabel.font = FONT_MEDIUM(13);
    [callEmergencyButton setTitle:NSLocalizedString(@"callEmergency", @"") forState:UIControlStateNormal];
    [callEmergencyButton addTarget:self action:@selector(callEmergencyButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [warningView addSubview:callEmergencyButton];
    
    NSMutableString *string2 = [[NSMutableString alloc]initWithString:NSLocalizedString(@"text13", @"")];
    [string2 appendString:[NSString stringWithFormat:@"\n%@", NSLocalizedString(@"text14", @"")]];
    [string2 appendString:[NSString stringWithFormat:@"\n%@", NSLocalizedString(@"text15", @"")]];
    [string2 appendString:[NSString stringWithFormat:@"\n%@", NSLocalizedString(@"text16", @"")]];
    [string2 appendString:[NSString stringWithFormat:@"\n%@", NSLocalizedString(@"text17", @"")]];
    UITextView *textView2 = [[UITextView alloc]initWithFrame:CGRectMake(10, callEmergencyButton.frame.origin.y + callEmergencyButton.frame.size.height, screenWidth - 20, [self getHeightOfString:string2])];
    textView2.font = FONT_MEDIUM(12);
    if (IS_IPHONE_5_IOS7 || IS_IPHONE_5_IOS8 || IS_IPHONE_4_AND_OLDER_IOS7 || IS_IPHONE_4_AND_OLDER_IOS8) {
        textView2.font = FONT_NORMAL(10);
    }
    textView2.textAlignment = NSTextAlignmentRight;
    textView2.text = string2;
    textView2.userInteractionEnabled =NO;
    if (IS_IPHONE_4_AND_OLDER_IOS8)
        textView2.userInteractionEnabled = YES;
    
    [warningView addSubview:textView2];
    
    UIButton *okButton = [CustomButton initButtonWithTitle:NSLocalizedString(@"IAccept", @"") withTitleColor:[UIColor whiteColor] withBackColor:COLOR_1 withFrame:CGRectMake(screenWidth/2 - 100, screenHeight - 150, 200, 30)];
    [okButton addTarget:self action:@selector(hideWarningView) forControlEvents:UIControlEventTouchUpInside];
    [warningView addSubview:okButton];
    
}

- (void)hideWarningView{
    [warningView removeFromSuperview];
}

- (void)makeMedicalSection{
    medicalSectionBG = [[UIView alloc]initWithFrame:CGRectMake(0, 70, screenWidth, 50)];
    medicalSectionBG.backgroundColor = [UIColor colorWithRed:0.102 green:0.722 blue:0.706 alpha:0.7];
    [self.view addSubview:medicalSectionBG];
    
    medicalSectionButton = [CustomButton initButtonWithTitle:NSLocalizedString(@"selectMS", @"") withTitleColor:[UIColor blackColor] withBackColor:[UIColor clearColor] withFrame:CGRectMake(10, 10, screenWidth - 20, 30)];
    medicalSectionButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [medicalSectionButton addTarget:self action:@selector(medicalSectionButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [medicalSectionBG addSubview:medicalSectionButton];
    
    //25 × 18
    UIImageView *dropdownImage = [[UIImageView alloc]initWithFrame:CGRectMake(10, 17, 25 * 0.8, 18 * 0.8)];
    dropdownImage.image = [UIImage imageNamed:@"dropdown"];
    [medicalSectionBG addSubview:dropdownImage];
}
- (void)makeAgreementText{
    NSMutableString *string1 = [[NSMutableString alloc]initWithString:NSLocalizedString(@"text1", @"")];
    [string1 appendString:[NSString stringWithFormat:@"\n%@", NSLocalizedString(@"text2", @"")]];
    [string1 appendString:[NSString stringWithFormat:@"\n%@", NSLocalizedString(@"text3", @"")]];
    CGFloat ypos = coverImageView.frame.origin.y + coverImageView.frame.size.height;
    if(_isNewQuestion)
        ypos = medicalSectionBG.frame.origin.y + medicalSectionBG.frame.size.height;
    //ypos = 70;
    UITextView *textView1 = [[UITextView alloc]initWithFrame:CGRectMake(10, ypos, screenWidth - 20, [self getHeightOfString:string1])];
    textView1.font = FONT_MEDIUM(12);
    if (IS_IPHONE_5_IOS7 || IS_IPHONE_5_IOS8 || IS_IPHONE_4_AND_OLDER_IOS7 || IS_IPHONE_4_AND_OLDER_IOS8) {
        textView1.font = FONT_NORMAL(10);
    }
    textView1.textAlignment = NSTextAlignmentRight;
    textView1.text = string1;
    textView1.userInteractionEnabled = NO;
    [self.view addSubview:textView1];
    
    UIButton *callEmergencyButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth/2 - 75, textView1.frame.origin.y + textView1.frame.size.height, 150, 30)];
    callEmergencyButton.layer.cornerRadius = 15;
    callEmergencyButton.clipsToBounds = YES;
    callEmergencyButton.backgroundColor = COLOR_1;
    callEmergencyButton.titleLabel.font = FONT_MEDIUM(13);
    [callEmergencyButton setTitle:NSLocalizedString(@"callEmergency", @"") forState:UIControlStateNormal];
    [callEmergencyButton addTarget:self action:@selector(callEmergencyButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:callEmergencyButton];
    
    NSMutableString *string2 = [[NSMutableString alloc]initWithString:NSLocalizedString(@"text4", @"")];
    [string2 appendString:[NSString stringWithFormat:@"\n%@", NSLocalizedString(@"text5", @"")]];
    [string2 appendString:[NSString stringWithFormat:@"\n%@", NSLocalizedString(@"text6", @"")]];
    [string2 appendString:[NSString stringWithFormat:@"\n%@", NSLocalizedString(@"text7", @"")]];
    UITextView *textView2 = [[UITextView alloc]initWithFrame:CGRectMake(10, callEmergencyButton.frame.origin.y + callEmergencyButton.frame.size.height, screenWidth - 20, [self getHeightOfString:string2])];
    textView2.font = FONT_MEDIUM(12);
    if (IS_IPHONE_5_IOS7 || IS_IPHONE_5_IOS8 || IS_IPHONE_4_AND_OLDER_IOS7 || IS_IPHONE_4_AND_OLDER_IOS8) {
        textView2.font = FONT_NORMAL(10);
    }
    textView2.textAlignment = NSTextAlignmentRight;
    textView2.text = string2;
    textView2.userInteractionEnabled =NO;
    if (IS_IPHONE_4_AND_OLDER_IOS8)
        textView2.userInteractionEnabled = YES;
    
    [self.view addSubview:textView2];
}

- (void)dismissTextView{
    [UIView animateWithDuration:0.5 animations:^{
        CGRect rect = questionView.frame;
        rect.origin.y = screenHeight - Height_QuestionView;
        [questionView setFrame:rect];
        [questionTextView resignFirstResponder];
    }];
}

- (void)questionView{
    questionView = [[UIView alloc]initWithFrame:CGRectMake(0, screenHeight - 50, screenWidth, Height_QuestionView)];
    questionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:questionView];
    
    attachButton = [[UIButton alloc]initWithFrame:CGRectMake(10, questionView.frame.size.height/2 - 25, 40, 40)];
    [attachButton setBackgroundImage:[UIImage imageNamed:@"attach icon"] forState:UIControlStateNormal];
    [attachButton addTarget:self action:@selector(attachButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [questionView addSubview:attachButton];
    
    sendButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - 50, questionView.frame.size.height/2 - 25, 40, 40)];
    [sendButton setBackgroundImage:[UIImage imageNamed:@"send icon"] forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [questionView addSubview:sendButton];
    
    questionTextView = [[UITextView alloc]initWithFrame:CGRectMake(attachButton.frame.size.width + attachButton.frame.origin.x + 10, 5, screenWidth - 120, 40)];
    questionTextView.font = FONT_MEDIUM(12);
    questionTextView.tag = 534;
    questionTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    questionTextView.delegate = self;
    questionTextView.layer.borderColor = [UIColor grayColor].CGColor;
    questionTextView.layer.borderWidth = 1.0;
    questionTextView.textColor = [UIColor grayColor];
    questionTextView.contentSize = CGSizeMake(screenWidth, 1000);
    [questionTextView setScrollEnabled:YES];
    questionTextView.text = NSLocalizedString(@"enteryouText", @"");
    //questionTextView.backgroundColor = [UIColor brownColor];
    questionTextView.textAlignment = NSTextAlignmentRight;
    [questionView addSubview:questionTextView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHideHandler:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}
- (void)showAttachImage:(NSNotification *)notif{
    NSDictionary *notifDic = notif.object;
    idOfAttachment = [[notifDic objectForKey:@"id"]integerValue];
    //NSLog(@"%@", notif.object);
    [attachFileView removeFromSuperview];
    attachFileView = [[UIView alloc]initWithFrame:CGRectMake(0, questionView.frame.origin.y - 68, screenWidth, 60)];
    attachFileView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:attachFileView];
    
    NSInteger documentImageViewWidth = 45;
    UIImageView *documentImageView = [[UIImageView alloc]initWithFrame:
                                      CGRectMake(screenWidth - 140, 5,documentImageViewWidth, documentImageViewWidth)];
    documentImageView.layer.cornerRadius = documentImageViewWidth / 2;
    documentImageView.clipsToBounds = YES;
    [attachFileView addSubview:documentImageView];
    [documentImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL, [notifDic objectForKey:@"file"]]] placeholderImage:[UIImage imageNamed:@"broken_image"]];
    
    UIButton *removeAttachButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - 45, 15, 30, 30)];
    [removeAttachButton setBackgroundImage:[UIImage imageNamed:@"popup_no"] forState:UIControlStateNormal];
    [removeAttachButton addTarget:self action:@selector(removeAttachButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [attachFileView addSubview:removeAttachButton];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, screenWidth - 100, 25)];
    titleLabel.font = FONT_NORMAL(11);
    titleLabel.text = [NSString stringWithFormat:@"%@", [notifDic objectForKey:@"name"]];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [attachFileView addSubview:titleLabel];
    
}

-(void)removeAttachButtonAction{
    [attachFileView removeFromSuperview];
    idOfAttachment = 0;
}

- (void)attachButtonAction{
    [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"isComingFromDirectQuestion"];
    [self dismissTextView];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UploadDocumentsViewController *view = (UploadDocumentsViewController *)[story instantiateViewControllerWithIdentifier:@"UploadDocumentsViewController"];
    view.isFromDirectQuestion = YES;
    [self.navigationController pushViewController:view animated:YES];
}

- (void)sendButtonAction{
    if ([questionTextView.text length] > 10 && ![questionTextView.text isEqualToString:NSLocalizedString(@"enteryouText", @"")]) {
        [self sendQuestionToServer];
    }else{
        //
        //
        //
        // = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"soalAzPezeshk", @"")
        
        //
        //
        //
        //
        //
        
    }
}

- (CGFloat)getHeightOfString:(NSString *)labelText{
    
    UIFont *myFont = FONT_MEDIUM(11);
    if (IS_IPHONE_5_IOS7 || IS_IPHONE_5_IOS8 || IS_IPHONE_4_AND_OLDER_IOS7 || IS_IPHONE_4_AND_OLDER_IOS8) {
        myFont = FONT_NORMAL(9);
    }
    
    if (IS_IPAD) {
        myFont = FONT_NORMAL(22);
    }
    CGSize sizeOfText = [labelText boundingRectWithSize: CGSizeMake( self.view.bounds.size.width - 20,CGFLOAT_MAX)
                                                options: (NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                             attributes: [NSDictionary dictionaryWithObject:myFont
                                                                                     forKey:NSFontAttributeName]
                                                context: nil].size;
    CGFloat height = sizeOfText.height + 50;
    if (IS_IPHONE_4_AND_OLDER_IOS8)
        height = sizeOfText.height + 10;
    return height;
    
}

- (void)callEmergencyButtonAction{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://115"]];
}

- (void)menuButtonAction {
    //[self showHideRightMenu];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"toggleMenuVisibility" object:nil];
}

- (void)backButtonImgAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)pushToUploadDocs{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UploadDocumentsViewController *view = (UploadDocumentsViewController *)[story instantiateViewControllerWithIdentifier:@"UploadDocumentsViewController"];
    [self.navigationController pushViewController:view animated:YES];
}

- (void)pushToConsultation{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ConsultationListViewController *view = (ConsultationListViewController *)[story instantiateViewControllerWithIdentifier:@"ConsultationListViewController"];
    [self.navigationController pushViewController:view animated:YES];
}

- (void)pushToHealthStatus{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HealthStatusViewController *view = (HealthStatusViewController *)[story instantiateViewControllerWithIdentifier:@"HealthStatusViewController"];
    [self.navigationController pushViewController:view animated:YES];
}

- (void)pushToFav{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FavoritesViewController *view = (FavoritesViewController *)[story instantiateViewControllerWithIdentifier:@"FavoritesViewController"];
    [self.navigationController pushViewController:view animated:YES];
}

- (void)pushToAbout{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AboutViewController *view = (AboutViewController *)[story instantiateViewControllerWithIdentifier:@"AboutViewController"];
    [self.navigationController pushViewController:view animated:YES];
}

- (void)medicalSectionButtonAction{
    medicalSectionArray = [[NSMutableArray alloc]initWithArray:
                           [Database selectFromMedicalSectionWithFilePath:[Database getDbFilePath]]];
    [self makePickerView];
    [self showPickerView];
}

- (void)makePickerView{
    
    medicalSectionPickerView = [[UIPickerView alloc] init];
    [medicalSectionPickerView setDataSource: self];
    [medicalSectionPickerView setDelegate: self];
    medicalSectionPickerView.tag = 1;
    medicalSectionPickerView.backgroundColor = [UIColor whiteColor];
    [medicalSectionPickerView setFrame: CGRectMake(0, screenHeight, screenWidth, 200.0f)];
    [self.view addSubview:medicalSectionPickerView];
}

- (void)showPickerView{
    [questionTextView resignFirstResponder];
    medicalSectionButton.userInteractionEnabled = NO;
    isHidden = NO;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         medicalSectionPickerView.frame = CGRectMake(0, screenHeight - 180, screenWidth, 200.0f);
                     }
                     completion:^(BOOL finished){
                         //
                     }];
    
    dateToolbar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,screenHeight - 220,screenWidth,44)];
    [dateToolbar setBarStyle:UIBarStyleBlackOpaque];
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"تایید"
                                                                      style:UIBarButtonItemStyleDone target:self action:@selector(DoneButtonForBirthdatePickerView:)];
    dateToolbar.items = @[barButtonDone];
    //barButtonDone.tintColor=[UIColor whiteColor];
    [self.view addSubview:dateToolbar];
}

- (void)DoneButtonForBirthdatePickerView:(id)sender{
    
    [self hidePickerView];
}

- (void)hidePickerView{
    medicalSectionButton.userInteractionEnabled = YES;
    isHidden = YES;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         medicalSectionPickerView.frame = CGRectMake(0, screenHeight, screenWidth, 200.0f);
                     }
                     completion:^(BOOL finished){
                     }];
    dateToolbar.hidden = YES;
    [dateToolbar removeFromSuperview];
}

#pragma mark - pickerview delegate
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [medicalSectionArray count];
}

//- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
//{
//    NSString *title = [medicalSectionArray objectAtIndex:row];
//    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName:[UIFont fontWithName:@"YekanMob" size:11]}];
//
//    return attString;
//}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    UILabel* tView = (UILabel*)view;
    NSString *title = [[medicalSectionArray objectAtIndex:row]objectForKey:@"name"];
    if (!tView){
        tView = [[UILabel alloc] init];
        UIFont *font = FONT_NORMAL(14);
        tView.textAlignment = NSTextAlignmentCenter;
        tView.font =font;
    }
    tView.text = [NSString stringWithFormat:@"%@", title];
    return tView;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    [medicalSectionButton setTitle:[[medicalSectionArray objectAtIndex:row]objectForKey:@"name"] forState:UIControlStateNormal];
    idOfSelectedMedicalSection = [[[medicalSectionArray objectAtIndex:row]objectForKey:@"Id"]integerValue];
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
                
                rect = attachButton.frame;
                rect.origin.y += 25;
                [attachButton setFrame:rect];
                
                rect = questionView.frame;
                rect.size.height += 25;
                rect.origin.y -= 25;
                [questionView setFrame:rect];
            }else
                NSLog(@"this is enough frame");
        }
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    if (textView.tag == 534) {
        [UIView animateWithDuration:0.5 animations:^{
            CGRect rect = questionView.frame;
            if (IS_IPAD) rect.origin.y = screenHeight - 360;
            else rect.origin.y = screenHeight - 260;
            [questionView setFrame:rect];
            
            rect = questionTextView.frame;
            rect.size.height = lastHeightOfQuestionTextView;
            if (lastHeightOfQuestionTextView > 40) {
                CGFloat numOfEnters = lastHeightOfQuestionTextView / 25;
                numOfEnters --;
                rect.origin.y = 0;//-= numOfEnters * 25;
                [questionTextView setFrame:rect];
                
                rect = sendButton.frame;
                rect.origin.y += questionView.frame.size.height/2 - 25;
                [sendButton setFrame:rect];
                
                rect = attachButton.frame;
                rect.origin.y += questionView.frame.size.height/2 - 25;
                [attachButton setFrame:rect];
                
                rect = questionView.frame;
                rect.size.height = lastHeightOfQuestionTextView + 25;
                numOfEnters --;
                rect.origin.y -= numOfEnters * 25;
                [questionView setFrame:rect];
                
                rect = sendButton.frame;
                rect.origin.y = questionView.frame.size.height - 65;
                [sendButton setFrame:rect];
                
                rect = attachButton.frame;
                rect.origin.y = questionView.frame.size.height - 70;
                [attachButton setFrame:rect];

            }
            
            [textView layoutIfNeeded];
            [textView becomeFirstResponder];
        }];
    }
}

- (void)resignQuestionTextView {
    [UIView animateWithDuration:0.5 animations:^{
        CGRect rect = questionView.frame;
        rect.origin.y = screenHeight - Height_QuestionView;
        rect.size.height = Height_QuestionView;
        [questionView setFrame:rect];
        
        rect = sendButton.frame;
        rect.origin.y = questionView.frame.size.height/2 - 25;
        [sendButton setFrame:rect];
        
        rect = attachButton.frame;
        rect.origin.y = questionView.frame.size.height/2 - 25;
        [attachButton setFrame:rect];
        
        //CGRectMake(attachButton.frame.size.width + attachButton.frame.origin.x + 10, 5, screenWidth - 120, 40)
        rect = questionTextView.frame;
        rect.size.height = 40;
        rect.origin.y = 5;
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
#pragma mark - connection

- (void)sendQuestionToServer{
    
    /*
     call-> "consultationDirect";
     
     if access_service == false{
     call->"consultationDirectPackageList"
     
     on click on buy{
     call->"buyConsultationDirect" with id 84;
     if access_service == true{
     call-> "consultationDirect";
     if result == true{
     show dialog 24h and back to consultationList
     }
     }
     }
     }else{
     show dialog 24h and back to consultationList
     }
     */
    [self resignQuestionTextView];
    [self closePackageList];
    NSData *plainTextData = [questionTextView.text dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64Message = [plainTextData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
    NSDictionary *userpassDic = [GetUsernamePassword getUsernamePassword];
    NSDictionary *params = @{@"username":[userpassDic objectForKey:@"username"]/*@"09191234072"*/,
                             @"password":[userpassDic objectForKey:@"password"]/*@“123456”*/,
                             @"profile_id":[GetUsernamePassword getProfileId]/*@"30273"*/,
                             @"doctor_id":[NSString stringWithFormat:@"%@", _userEntityId],
                             @"message":base64Message,
                             @"document_id":[NSNumber numberWithInteger:idOfAttachment],
                             @"debug":@"1",
                             @"unit_id": @"3",
                             @"source":@"mci_ios"
                             };
    /*http://213.233.175.250:8081/web_services/v3/posts/timeline*/
    
    //    KeychainWrapper *keychainWrapper = [[KeychainWrapper alloc]init];
    //    NSString *username = [keychainWrapper myObjectForKey:(__bridge id)(kSecAttrDescription)];
    //    NSString *password = [keychainWrapper myObjectForKey:(__bridge id)(kSecAttrService)];
    NSString *url = [NSString stringWithFormat:@"%@consultationDirect", BaseURL];
    
    if (_isNewQuestion) {
        if (idOfSelectedMedicalSection == 1000) {
            medicalSectionArray = [[NSMutableArray alloc]initWithArray:
                                   [Database selectFromMedicalSectionWithFilePath:[Database getDbFilePath]]];
            idOfSelectedMedicalSection = [[[medicalSectionArray objectAtIndex:0]objectForKey:@"Id"]integerValue];
//            //
        //
        //
        // = [[UIAlertView alloc] initWithTitle:@""
//                                                                message:NSLocalizedString(@"selectMSPlease", @"")
//                                                               delegate:nil
//                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
//            //
//            return;
        }
        /*
         username
         password
         profile_id
         medical_section_id
         message
         document_id
         debug
         */
        params = @{@"username":[userpassDic objectForKey:@"username"]/*@"09191234072"*/,
                   @"password":[userpassDic objectForKey:@"password"]/*@“123456”*/,
                   @"profile_id":[GetUsernamePassword getProfileId]/*@"30273"*/,
                   @"medical_section_id":[NSNumber numberWithInteger:idOfSelectedMedicalSection],
                   @"message":base64Message,
                   @"document_id":[NSNumber numberWithInteger:idOfAttachment],
                   @"debug":@"1",
                   @"unit_id": @"3",
                   @"source":@"mci_ios"
                   };
        url = [NSString stringWithFormat:@"%@consultation_request", BaseURL];
        
    }
    if (!isBusyNow) {
        [ProgressHUD show:@"" Interaction:NO];
        isBusyNow = YES;
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        [manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
            idOfSelectedMedicalSection = 1000;
            NSDictionary *tempDic = (NSDictionary *)responseObject;
            if (_isNewQuestion) {
                if ([[tempDic objectForKey:@"success"]integerValue] == 1) {
                    [self backButtonImgAction];
                    //
        //
        //
        // = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"soalAzPezeshk", @"")
                                                                                          //
                    
                } else {
                    //
        //
        //
        // = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"errorinData", @"")
                    
                }
                
            } else {
                if ([[tempDic objectForKey:@"access_service"]integerValue] == 0) {
                    [self consultationDirectPackageList];
                } else {
                    [self backButtonImgAction];
                    //
        //
        //
        // = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"soalAzPezeshk", @"")
                                                                                           //
                }
            }
            //[ProgressHUD dismiss];
            isBusyNow = NO;
        } failure:^(NSURLSessionTask *operation, NSError *error) {
             
            [ProgressHUD dismiss];
            isBusyNow = NO;
        }];
    }
    
}

- (void)consultationDirectPackageList{
    [ProgressHUD show:@"" Interaction:NO];
    NSString *url = [NSString stringWithFormat:@"%@consultationDirectPackageList", BaseURL];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:url parameters:nil progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        [ProgressHUD dismiss];
        blurView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
        blurView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.6];
        [self.view addSubview:blurView];
        
        packageListView = [[UIView alloc]initWithFrame:CGRectMake(20, screenHeight/3, screenWidth - 40, 200)];
        packageListView.backgroundColor = [UIColor whiteColor];
        NSDictionary *dict = responseObject;
        packegesArray = [[NSMutableArray alloc]init];
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 300, 25)];
        titleLabel.font = FONT_NORMAL(11);
        titleLabel.text = NSLocalizedString(@"selectPackage", @"");
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [packageListView addSubview:titleLabel];
        yPositionOfLabel = 40;
        packageColorArray = [[NSMutableArray alloc]initWithObjects:
                             [UIColor colorWithRed:255/255.0 green:23/255.0 blue:68/255.0 alpha:1.0],
                             [UIColor colorWithRed:0/255.0 green:184/255.0 blue:212/255.0 alpha:1.0],
                             [UIColor colorWithRed:128/255.0 green:216/255.0 blue:255/255.0 alpha:1.0],nil];
        for (NSInteger i = [[dict objectForKey:@"packageList"]count] - 1; i >= 0 ; i-- ) {
            NSDictionary *tempDic = [[dict objectForKey:@"packageList"]objectAtIndex:i];
            [packegesArray addObject:tempDic];
            NSInteger indexOfColor = ([[dict objectForKey:@"packageList"]count] - 1) - i % 3;
            UIButton *button = [CustomButton initButtonWithTitle:
                                [NSString stringWithFormat:@"%@", [[tempDic objectForKey:@"Package"]objectForKey:@"name"]]
                                                  withTitleColor:[UIColor whiteColor]
                                                   withBackColor:[packageColorArray objectAtIndex:indexOfColor]
                                                       withFrame:CGRectMake(packageListView.frame.size.width - 100,
                                                                            yPositionOfLabel, 90, 25)];
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            [packageListView addSubview:button];
            UILabel *aLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, yPositionOfLabel - 10, screenWidth - 160, 45)];
            aLabel.font = FONT_NORMAL(11);
            aLabel.numberOfLines = 2;
            aLabel.textAlignment = NSTextAlignmentCenter;
            NSInteger price = [[[tempDic objectForKey:@"Package"] objectForKey:@"price"]integerValue];
            price = price / 10;
            aLabel.text = [NSString stringWithFormat:@"%ld تومان\n%@", (long)price,[[tempDic objectForKey:@"Package"] objectForKey:@"description"]];
            [packageListView addSubview:aLabel];
            
            yPositionOfLabel += 50;
        }
        UIButton *doneButtn = [CustomButton initButtonWithTitle:NSLocalizedString(@"payWithhamraheAval", @"") withTitleColor:[UIColor whiteColor] withBackColor:[UIColor colorWithRed:26/255.0 green:184/255.0 blue:180/255.0 alpha:1.0]
                                                      withFrame:CGRectMake(packageListView.frame.size.width - 190, yPositionOfLabel + 20, 180, 25)];
        [doneButtn addTarget:self action:@selector(buyConsultationDirect) forControlEvents:UIControlEventTouchUpInside];
        [packageListView addSubview:doneButtn];
        UIButton *backButton = [CustomButton initButtonWithTitle:NSLocalizedString(@"back", @"") withTitleColor:[UIColor whiteColor] withBackColor:[UIColor grayColor] withFrame:CGRectMake(10, yPositionOfLabel + 20, 70, 25)];
        [backButton removeTarget:self action:@selector(closePackageList) forControlEvents:UIControlEventTouchUpInside];
        [backButton addTarget:self action:@selector(closePackageList) forControlEvents:UIControlEventTouchUpInside];
        [packageListView addSubview:backButton];
        CGRect rect = packageListView.frame;
        rect.size.height = yPositionOfLabel + 80;
        [packageListView setFrame:rect];
        packageListView.layer.cornerRadius = 14;
        packageListView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        packageListView.layer.borderWidth = 3.0;
        [blurView addSubview:packageListView];
        
        yPositionOfSelectedButton = 30;
        [selectLabel removeFromSuperview];
        selectLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, yPositionOfSelectedButton, packageListView.frame.size.width - 19, 45)];
        selectLabel.backgroundColor = [UIColor clearColor];
        selectLabel.layer.cornerRadius = 5;
        selectLabel.layer.borderWidth = 1.0;
        selectLabel.layer.borderColor = [UIColor colorWithRed:7/255.0 green:125/255.0 blue:195/255.0 alpha:1.0].CGColor;
        [packageListView addSubview:selectLabel];
        selectedPackageId = [[[[packegesArray objectAtIndex:0] objectForKey:@"Package"]objectForKey:@"id"]integerValue];
        
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
         
        [ProgressHUD dismiss];
    }];
}

- (void)buyConsultationDirect{
    [ProgressHUD show:@"" Interaction:NO];
    [self closePackageList];
    NSDictionary *userpassDic = [GetUsernamePassword getUsernamePassword];
    NSDictionary *params = @{@"username":[userpassDic objectForKey:@"username"]/*@"09191234072"*/,
                             @"password":[userpassDic objectForKey:@"password"]/*@“123456”*/,
                             @"profile_id":[GetUsernamePassword getProfileId]/*@"30273"*/,
                             @"debug":@"1",
                             @"unit_id": @"3"
                             };
    NSString *url = [NSString stringWithFormat:@"%@buyConsultationDirect", BaseURL];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        [ProgressHUD dismiss];
        NSDictionary *tempDic = (NSDictionary *)responseObject;
        if (([[tempDic objectForKey:@"success"]integerValue] == 1) &&
            ([[tempDic objectForKey:@"access_service"]integerValue] == 1)) {
            [self sendQuestionToServer];
        }else{
            //
        //
        //
        // = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"kharideBaste", @"")
                                                                          //
            
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        //
        //
        //
        // = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"kharideBaste", @"")
                                                                   //
        [ProgressHUD dismiss];
    }];
}

- (void)closePackageList{
    [packageListView removeFromSuperview];
    [packageBuyView removeFromSuperview];
    [blurView removeFromSuperview];
    selectedPackageId = 1000;
}

@end
