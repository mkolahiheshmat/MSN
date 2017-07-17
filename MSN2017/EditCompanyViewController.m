//
//  EditProfileViewController.m
//  MSN
//
//  Created by Yarima on 5/16/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "EditCompanyViewController.h"
#import "Header.h"
#import <AFHTTPSessionManager.h>
#import <UIImageView+AFNetworking.h>
#import "CustomButton.h"
#import "ProgressHUD.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import "DocumentDirectoy.h"
#import "ConvertToPersianDate.h"
#import "GetUsernamePassword.h"
#import "NSDictionary+profile.h"
#import "UIImage+Extra.h"
#import "SelectProjMemberViewController.h"
@interface EditCompanyViewController()<UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    
    UIScrollView *scrollView;
    UIImageView *profileImageView;
    UIView *galleryCameraView;
    UITextField *nameTextField;
    UITextField *lastnameTextField;
    UITextField *sexTextField;
    UITextField *materialStatusTextField;
    UITextField *birthdateTextField;
    UIImageView *yearImageView;
    UITextField *mobileTextField;
    UITextField *aboutTextField;
    UITextField *emailTextField;
    UITextField *websiteTextField;
    UIPickerView *sexPickerView;
    UIPickerView *materialStatusPickerView;
    UIPickerView *bloodTypesPickerView;
    NSArray *sexArray;
    NSArray *materialStatusArray;
    NSArray *bloodTypesArray;
    
    UIPickerView *datePickerView;
    NSMutableArray *daysArray;
    NSMutableArray *monthsArray;
    NSMutableArray *yearsArray;
    BOOL isHidden;
    UIToolbar *dateToolbar;
    NSString *year;
    NSString *month;
    NSString *day;
    BOOL isBirthdateChanged;
    UIButton *taeedButton;
    UIScrollView *namesScrollView;
    NSMutableArray *selectedTagsArray;
    NSMutableArray *selectedTagsArrayWithID;
    NSMutableArray *selectedTagsArrayForExpertise;
    UIScrollView *namesScrollViewForExpertise;
    NSMutableArray *expertiseArray;
    UITextField *expertiseTextField;
    UIPickerView *expertisePickerView;
    UIToolbar *toolbar;
    UIView *transparentView;
}

@end
@implementation EditCompanyViewController

- (void)viewDidDisappear:(BOOL)animated{
    [ProgressHUD dismiss];
}
- (void)viewDidLoad{
    self.navigationController.navigationBar.hidden = YES;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(fillSelectedProjMembers:) name:@"fillSelectedProjMembers" object:nil];
    
    [self getExpertiseFromServer];
    //make View
    [self makeTopBar];
    [self makePickerView];
    [self makeScrollView];
    [self makePersonalInfo];
    
    //NSLog(@"self.navigationControllers: %@", [self.navigationController viewControllers]);
    
    if (_isFromEditCompany) {
        [self getProfileDataFromServer];
    }
    
    //NSString *str = [DocumentDirectoy getDocuementsDirectory];
}

#pragma mark - Custom methods

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
    titleLabel.font = FONT_NORMAL(20);
    titleLabel.text = @"ثبت پروفایل شرکت";
    if (_isFromEditCompany) {
        titleLabel.text = @"ویرایش پروفایل شرکت";
    }
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:titleLabel];
    
    UIButton *backButtonImg = [[UIButton alloc]initWithFrame:CGRectMake(0, 16 , 45, 45)];
    [backButtonImg setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButtonImg addTarget:self action:@selector(backButtonImgAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButtonImg];
}

- (void)makeScrollView{
    
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 70, screenWidth, screenHeight - 70 - 40)];
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideAllViews)];
    [scrollView addGestureRecognizer:tap];
    scrollView.contentSize = CGSizeMake(screenWidth, screenHeight * 1.2);
    [self.view addSubview:scrollView];
    
    profileImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth/2 - 50, 5, 100, 100)];
    profileImageView.layer.cornerRadius = 50;
    profileImageView.clipsToBounds = YES;
    profileImageView.image = [UIImage imageNamed:@"icon upload ax"];
    profileImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(profileImageViewAction)];
    [profileImageView addGestureRecognizer:tap2];
    [scrollView addSubview:profileImageView];
    
    UIImageView *uploadImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth/2 - 20, profileImageView.frame.size.height - 20, 40, 40)];
    uploadImageView.image = [UIImage imageNamed:@"upload_avatar"];
    [scrollView addSubview:uploadImageView];
    
    [self loadImageFileFromDocument];
}

- (void)makePersonalInfo{
    
    //name
    nameTextField = [[UITextField alloc]initWithFrame:CGRectMake(screenWidth/2 - 80, profileImageView.frame.origin.y + profileImageView.frame.size.height + 30, 160, 25)];
    nameTextField.backgroundColor = [UIColor whiteColor];
    nameTextField.placeholder = @"نام شرکت";
    nameTextField.text = _profileDictionary.first_nameProfile;
    nameTextField.tag = 101;
    nameTextField.delegate = self;
    nameTextField.font = FONT_NORMAL(15);
    nameTextField.layer.borderColor = [UIColor clearColor].CGColor;
    nameTextField.layer.borderWidth = 1.0;
    nameTextField.layer.cornerRadius = 5;
    nameTextField.clipsToBounds = YES;
    nameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    nameTextField.textAlignment = NSTextAlignmentCenter;
    [nameTextField addToolbar];
    [scrollView addSubview:nameTextField];
    
    //29x40
    UIImageView *nameImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 40, profileImageView.frame.origin.y + profileImageView.frame.size.height + 30, 29 / 2, 40 / 2)];
    nameImageView.image = [UIImage imageNamed:@"icon upload ax"];
    nameImageView.userInteractionEnabled = YES;
    [scrollView addSubview:nameImageView];
    
    UIView *horizontalLine = [[UIView alloc]initWithFrame:CGRectMake(20, nameTextField.frame.origin.y + 25, screenWidth - 40, 0.5)];
    horizontalLine.backgroundColor = [UIColor lightGrayColor];
    [scrollView addSubview:horizontalLine];
    
    //email
    aboutTextField = [[UITextField alloc]initWithFrame:CGRectMake(screenWidth/2 - 80, horizontalLine.frame.origin.y + 40, 160, 25)];
    aboutTextField.backgroundColor = [UIColor whiteColor];
    aboutTextField.placeholder = @"درباره";
    aboutTextField.text = _profileDictionary.emailProfile;
    aboutTextField.tag = 103;
    aboutTextField.delegate = self;
    aboutTextField.font = FONT_NORMAL(15);
    aboutTextField.layer.borderColor = [UIColor clearColor].CGColor;
    aboutTextField.layer.borderWidth = 1.0;
    aboutTextField.layer.cornerRadius = 5;
    aboutTextField.clipsToBounds = YES;
    aboutTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    aboutTextField.textAlignment = NSTextAlignmentCenter;
    aboutTextField.minimumFontSize = 0.5;
    aboutTextField.adjustsFontSizeToFitWidth = YES;
    aboutTextField.keyboardType = UIKeyboardTypeEmailAddress;
    [aboutTextField addToolbar];
    [scrollView addSubview:aboutTextField];
    
    //44x31
    UIImageView *aboutImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 40, horizontalLine.frame.origin.y + 40, 33 / 2, 34 / 2)];
    aboutImageView.image = [UIImage imageNamed:@"icon_job"];
    aboutImageView.userInteractionEnabled = YES;
    [scrollView addSubview:aboutImageView];
    
    UIView *horizontalLine3 = [[UIView alloc]initWithFrame:CGRectMake(20, aboutTextField.frame.origin.y + 25, screenWidth - 40, 0.5)];
    horizontalLine3.backgroundColor = [UIColor lightGrayColor];
    [scrollView addSubview:horizontalLine3];
    
    //60x24
    UIImageView *takhasosImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 40, horizontalLine3.frame.origin.y + 28, 60 / 3, 24 / 3)];
    takhasosImageView.image = [UIImage imageNamed:@"takhasos"];
    takhasosImageView.userInteractionEnabled = YES;
    [scrollView addSubview:takhasosImageView];
    
    //expertise
    expertiseTextField = [[UITextField alloc]initWithFrame:CGRectMake(screenWidth - 170, horizontalLine3.frame.origin.y + 20, 120, 25)];
    expertiseTextField.backgroundColor = [UIColor clearColor];
    expertiseTextField.text = @"انتخاب تخصص";
    expertiseTextField.inputView = expertisePickerView;
    expertiseTextField.tag = 106;
    expertiseTextField.delegate = self;
    expertiseTextField.font = FONT_NORMAL(15);
    expertiseTextField.layer.borderColor = [UIColor clearColor].CGColor;
    expertiseTextField.layer.borderWidth = 1.0;
    expertiseTextField.layer.cornerRadius = 5;
    expertiseTextField.clipsToBounds = YES;
    expertiseTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    expertiseTextField.textAlignment = NSTextAlignmentCenter;
    expertiseTextField.keyboardType = UIKeyboardTypeNumberPad;
    expertiseTextField.textColor = COLOR_5;
    [[expertiseTextField valueForKey:@"textInputTraits"] setValue:[UIColor clearColor] forKey:@"insertionPointColor"];
    [scrollView addSubview:expertiseTextField];
    
    selectedTagsArrayForExpertise = [[NSMutableArray alloc]initWithArray:_selectedTagsArray1];
    namesScrollViewForExpertise = [[UIScrollView alloc]initWithFrame:CGRectMake(0, horizontalLine3.frame.origin.y + 50, screenWidth - 40, 40)];
    namesScrollViewForExpertise.contentSize = CGSizeMake(screenWidth * 2, 40);
    [scrollView addSubview:namesScrollViewForExpertise];
    [self reloadTagsView];
    
    [self makeTamasInfo:namesScrollViewForExpertise.frame.origin.y + 45];
}

- (void)makeTamasInfo:(CGFloat)yPos{
    UILabel *Label =[[UILabel alloc]initWithFrame:CGRectMake(0, yPos, screenWidth, 30)];
    Label.font = FONT_NORMAL(16);
    Label.minimumScaleFactor = 0.5;
    Label.adjustsFontSizeToFitWidth = YES;
    Label.text = @"راه های تماس";
    Label.textColor = [UIColor whiteColor];
    Label.backgroundColor = [UIColor colorWithRed:47/255.0 green:197/255.0 blue:137/255.0 alpha:1.0];
    Label.textAlignment = NSTextAlignmentCenter;
    [scrollView addSubview:Label];
    
    emailTextField = [[UITextField alloc]initWithFrame:CGRectMake(screenWidth/2 - 80, Label.frame.origin.y + Label.frame.size.height + 30, 160, 25)];
    emailTextField.backgroundColor = [UIColor whiteColor];
    emailTextField.placeholder = NSLocalizedString(@"email", @"");
    emailTextField.text = _profileDictionary.first_nameProfile;
    emailTextField.tag = 201;
    emailTextField.delegate = self;
    emailTextField.font = FONT_NORMAL(15);
    emailTextField.layer.borderColor = [UIColor clearColor].CGColor;
    emailTextField.layer.borderWidth = 1.0;
    emailTextField.layer.cornerRadius = 5;
    emailTextField.clipsToBounds = YES;
    emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    emailTextField.textAlignment = NSTextAlignmentCenter;
    [emailTextField addToolbar];
    [scrollView addSubview:emailTextField];
    
    //63 × 30
    UIImageView *nameImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 40, Label.frame.origin.y + Label.frame.size.height + 30, 44 / 2, 31 / 2)];
    nameImageView.image = [UIImage imageNamed:@"icon_email"];
    nameImageView.userInteractionEnabled = YES;
    [scrollView addSubview:nameImageView];
    
    UIView *horizontalLine = [[UIView alloc]initWithFrame:CGRectMake(20, emailTextField.frame.origin.y + 25, screenWidth - 40, 0.5)];
    horizontalLine.backgroundColor = [UIColor lightGrayColor];
    [scrollView addSubview:horizontalLine];
    
    //mobile
    mobileTextField = [[UITextField alloc]initWithFrame:CGRectMake(screenWidth/2 - 80, horizontalLine.frame.origin.y + 40, 160, 25)];
    mobileTextField.placeholder = @"شماره تماس";
    mobileTextField.backgroundColor = [UIColor clearColor];
    mobileTextField.tag = 104;
    mobileTextField.delegate = self;
    mobileTextField.font = FONT_NORMAL(15);
    mobileTextField.layer.borderColor = [UIColor clearColor].CGColor;
    mobileTextField.layer.borderWidth = 1.0;
    mobileTextField.layer.cornerRadius = 5;
    mobileTextField.clipsToBounds = YES;
    mobileTextField.keyboardType = UIKeyboardTypeNumberPad;
    mobileTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    mobileTextField.textAlignment = NSTextAlignmentCenter;
    mobileTextField.keyboardType = UIKeyboardTypeNumberPad;
    [mobileTextField addToolbar];
    [scrollView addSubview:mobileTextField];
    
    //36x36
    UIImageView *mobileImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 40, horizontalLine.frame.origin.y + 40, 33 / 2, 34 / 2)];
    mobileImageView.image = [UIImage imageNamed:@"icon_tel"];
    mobileImageView.userInteractionEnabled = YES;
    [scrollView addSubview:mobileImageView];
    
    UIView *horizontalLine4 = [[UIView alloc]initWithFrame:CGRectMake(20, mobileTextField.frame.origin.y + 25, screenWidth - 40, 0.5)];
    horizontalLine4.backgroundColor = [UIColor lightGrayColor];
    [scrollView addSubview:horizontalLine4];
    
    //mobile
    websiteTextField = [[UITextField alloc]initWithFrame:CGRectMake(screenWidth/2 - 80, horizontalLine4.frame.origin.y + 40, 160, 25)];
    websiteTextField.placeholder = @"وب سایت";
    websiteTextField.tag = 104;
    websiteTextField.delegate = self;
    websiteTextField.font = FONT_NORMAL(15);
    websiteTextField.layer.borderColor = [UIColor clearColor].CGColor;
    websiteTextField.layer.borderWidth = 1.0;
    websiteTextField.layer.cornerRadius = 5;
    websiteTextField.clipsToBounds = YES;
    websiteTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    websiteTextField.textAlignment = NSTextAlignmentCenter;
    [websiteTextField addToolbar];
    [scrollView addSubview:websiteTextField];
    
    //56x46
    UIImageView *websiteImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 40, horizontalLine4.frame.origin.y + horizontalLine4.frame.size.height + 30, 40 / 2, 40 / 2)];
    websiteImageView.image = [UIImage imageNamed:@"icon_website"];
    websiteImageView.userInteractionEnabled = YES;
    [scrollView addSubview:websiteImageView];
    
    UIView *horizontalLine2 = [[UIView alloc]initWithFrame:CGRectMake(20, websiteTextField.frame.origin.y + 25, screenWidth - 40, 0.5)];
    horizontalLine2.backgroundColor = [UIColor lightGrayColor];
    [scrollView addSubview:horizontalLine2];
    
    //[self makeMembersInfo:websiteTextField.frame.origin.y + 35];
    
    taeedButton = [CustomButton initButtonWithTitle:NSLocalizedString(@"taeed2", @"") withTitleColor:[UIColor whiteColor] withBackColor:[UIColor colorWithRed:92/255.0 green:134/255.0 blue:217/255.0 alpha:1.0] isRounded:NO withFrame:CGRectMake(- 5,screenHeight - 40, screenWidth + 10, 44)];
    [taeedButton addTarget:self action:@selector(sendButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [taeedButton makeGradient:taeedButton];
    [self.view addSubview:taeedButton];
    [taeedButton setBackgroundColor:COLOR_3];
    //taeedButton.userInteractionEnabled = NO;
    
}

- (void)makeMembersInfo:(CGFloat)yPos{
    UILabel *Label =[[UILabel alloc]initWithFrame:CGRectMake(0, yPos, screenWidth, 30)];
    Label.font = FONT_NORMAL(16);
    Label.minimumScaleFactor = 0.5;
    Label.adjustsFontSizeToFitWidth = YES;
    Label.text = @"اعضای پروژه";
    Label.textColor = [UIColor whiteColor];
    Label.backgroundColor = [UIColor colorWithRed:47/255.0 green:197/255.0 blue:137/255.0 alpha:1.0];
    Label.textAlignment = NSTextAlignmentCenter;
    [scrollView addSubview:Label];
    
    //56x46
    UIImageView *websiteImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 40, Label.frame.origin.y + Label.frame.size.height + 15, 40 / 2, 30 / 2)];
    websiteImageView.image = [UIImage imageNamed:@"icon_pojectmembers"];
    websiteImageView.userInteractionEnabled = YES;
    [scrollView addSubview:websiteImageView];
    
    UIButton *projMembers = [CustomButton initButtonWithTitle:@"اعضای پروژه" withTitleColor:COLOR_5 withBackColor:[UIColor whiteColor] withFrame:CGRectMake(screenWidth - 150, Label.frame.origin.y + Label.frame.size.height + 7, 100, 30)];
    [projMembers addTarget:self action:@selector(projMembersAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:projMembers];
    
    namesScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, projMembers.frame.origin.y + 30, screenWidth, 40)];
    namesScrollView.contentSize = CGSizeMake(screenWidth * 2, 40);
    //namesScrollView.backgroundColor = COLOR_1;
    [scrollView addSubview:namesScrollView];
    
}

- (void)projMembersAction{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SelectProjMemberViewController *view = (SelectProjMemberViewController *)[story instantiateViewControllerWithIdentifier:@"SelectProjMemberViewController"];
    [self presentViewController:view animated:YES completion:nil];
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

- (void)deleteTagImageAction:(UITapGestureRecognizer *)tapy{
    
    NSInteger idOfTapLabel = tapy.view.tag;
    [selectedTagsArray removeObjectAtIndex:idOfTapLabel];
    
    NSArray *viewsToRemove = [namesScrollView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    [self reloadTagsView];
}

- (void)reloadTagsView{
    NSArray *viewsToRemove = [namesScrollView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }

    //CGFloat yPosOfSelectTagsLabel = 10;
    NSInteger countOfTags = [selectedTagsArray count];
    CGFloat yPOS = 10;
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
    
    if ([selectedTagsArray count] > 0) {
        [taeedButton setBackgroundColor:COLOR_3];
        //taeedButton.userInteractionEnabled = YES;
    }else{
        [taeedButton setBackgroundColor:GRAY_COLOR];
        ///taeedButton.userInteractionEnabled = NO;
    }
}

- (void)sendButtonAction{
    if ([self hasConnectivity]) {
        if (_isFromEditCompany) {
            [self editProfileToServer];
        } else {
            [self uploadProfileDataToServer];
        }
    } else {
        
    }
}
- (void)makePickerView{
    
    sexArray = [[NSArray alloc]initWithObjects:
                @"",
                NSLocalizedString(@"man", @""),
                NSLocalizedString(@"woman", @""),
                nil];
    materialStatusArray = [[NSArray alloc]initWithObjects:
                           @"",
                           NSLocalizedString(@"married", @""),
                           NSLocalizedString(@"single", @""),
                           nil];
    bloodTypesArray = [[NSArray alloc]initWithObjects:@"O-", @"O+",@"A-",@"A+",@"B-",@"B+",@"AB-",@"AB+", nil];
    
    yearsArray = [[NSMutableArray alloc]init];
    daysArray = [[NSMutableArray alloc]init];
    for (NSInteger i = 1320; i < 1380; i++) {
        [yearsArray addObject:[NSNumber numberWithInteger:i]];
    }
    
    for (NSInteger i = 1; i < 32; i++) {
        [daysArray addObject:[NSNumber numberWithInteger:i]];
    }
    
    monthsArray = [[NSMutableArray alloc]initWithObjects:
                   NSLocalizedString(@"far", @""),
                   NSLocalizedString(@"ordi", @""),
                   NSLocalizedString(@"khordad", @""),
                   NSLocalizedString(@"tir", @""),
                   NSLocalizedString(@"mordad", @""),
                   NSLocalizedString(@"shahrivar", @""),
                   NSLocalizedString(@"mahr", @""),
                   NSLocalizedString(@"aban", @""),
                   NSLocalizedString(@"azar", @""),
                   NSLocalizedString(@"day", @""),
                   NSLocalizedString(@"bahman", @""),
                   NSLocalizedString(@"esfand", @"")
                   ,nil];
    
    
    sexPickerView = [[UIPickerView alloc] init];
    [sexPickerView setDataSource: self];
    [sexPickerView setDelegate: self];
    sexPickerView.tag = 1;
    sexPickerView.backgroundColor = [UIColor whiteColor];
    [sexPickerView setFrame: CGRectMake(0, screenHeight, screenWidth, 200.0f)];
    [sexTextField addSubview:sexPickerView];
    
    datePickerView = [[UIPickerView alloc] init];
    [datePickerView setDataSource: self];
    [datePickerView setDelegate: self];
    datePickerView.tag = 4;
    datePickerView.backgroundColor = [UIColor whiteColor];
    [datePickerView setFrame: CGRectMake(0, screenHeight, screenWidth, 200.0f)];
    [birthdateTextField addSubview:datePickerView];
    
    day = @"";
    month = @"";//NSLocalizedString(@"far", @"");
    year = @"";
    
    expertisePickerView = [[UIPickerView alloc] init];
    [expertisePickerView setDataSource: self];
    [expertisePickerView setDelegate: self];
    expertisePickerView.tag = 6;
    expertisePickerView.backgroundColor = [UIColor whiteColor];
    [expertisePickerView setFrame: CGRectMake(0, screenHeight, screenWidth, 200.0f)];
    [expertiseTextField addSubview:expertisePickerView];
}

- (void)dismissTextField{
    //[self hideGalleryCameraView];
    [nameTextField resignFirstResponder];
    [lastnameTextField resignFirstResponder];
    [sexTextField resignFirstResponder];
    [materialStatusTextField resignFirstResponder];
    //[birthdateTextField resignFirstResponder];
    [mobileTextField resignFirstResponder];
    [aboutTextField resignFirstResponder];
    [emailTextField resignFirstResponder];
    [websiteTextField resignFirstResponder];
    //[expertiseTextField resignFirstResponder];
    
}

- (void)backButtonImgAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)hideAllViews{
    [self hideGalleryCameraView];
    [self dismissTextField];
}

- (void)profileImageViewAction{
    [self dismissTextField];
    [self showgalleryCameraView];
}

- (void)loadImageFileFromDocument{
    if (_profileDictionary.photoProfile != (id)[NSNull null]){
        NSString *imageFileName = [NSString stringWithFormat:@"%@/%@", [DocumentDirectoy getDocuementsDirectory], [_profileDictionary.photoProfile lastPathComponent]];
        //NSString *imageFileName = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject]stringByAppendingPathComponent:profileDictionary.photoProfile]lastPathComponent];
        NSString *pathOfImage = [[NSURL fileURLWithPath:imageFileName]path];
        BOOL isDirectory;
        if ([[NSFileManager defaultManager]fileExistsAtPath:pathOfImage isDirectory:&isDirectory]) {
            profileImageView.image = [UIImage imageWithContentsOfFile:pathOfImage];
        }else{
            UIImage *defaultImage = [UIImage imageNamed:@"icon upload ax"];
            UIImage *currentImage = profileImageView.image;
            if ([UIImagePNGRepresentation(defaultImage) isEqualToData:UIImagePNGRepresentation(currentImage)]) {
                [self loadImageProfileFromServer];
            }
            
        }
    }
}


- (void)loadImageProfileFromServer{
    UIImage *defaultImage = [UIImage imageNamed:@"icon upload ax"];
    UIImage *currentImage = profileImageView.image;
    if ([UIImagePNGRepresentation(defaultImage) isEqualToData:UIImagePNGRepresentation(currentImage)]) {
        dispatch_async(kBgQueue, ^{
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/thumb_%@",BaseURL,[GetUsernamePassword getProfileId],_profileDictionary.photoProfile]];
            NSData *imgData = [NSData dataWithContentsOfURL:url];
            
            if (imgData) {
                UIImage *image = [UIImage imageWithData:imgData];
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        profileImageView.image  = image;
                        [self saveImageIntoDocumets];
                    });
                }
            }
        });
        
    }
    
}

- (void)saveImageIntoDocumets{
    //convert image into .png format.
    NSData *imageData = UIImagePNGRepresentation(profileImageView.image);
    //create instance of NSFileManager
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *appDocumentsDirectory = [DocumentDirectoy getDocuementsDirectory];
    //add our image to the path
    if (_profileDictionary.photoProfile != (id)[NSNull null]) {
        NSString *fullPath = [appDocumentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", [_profileDictionary.photoProfile lastPathComponent]]];
        //finally save the path (image)
        BOOL resultSave = [fileManager createFileAtPath:fullPath contents:imageData attributes:nil];
        if (resultSave) {
            //NSLog(@"image saved");
        }
        
    }else{
        
    }
}

-(NSString *)GenderConversionToEnglish : (NSString *) MaritalStatus
{
    NSString *result = @"";
    if ([MaritalStatus isEqualToString:NSLocalizedString(@"man", @"")]) {
        result = @"m";
    }else if ([MaritalStatus isEqualToString:NSLocalizedString(@"woman", @"")])
    {
        result = @"f";
    }
    return result;
}

-(NSString *)DetermineIsMarried : (NSString *) IsMarried
{
    NSString *result = @"";
    if ([IsMarried isEqualToString:NSLocalizedString(@"married", @"")]) {
        result = @"y";
    }else if ([IsMarried isEqualToString:NSLocalizedString(@"single", @"")])
    {
        result = @"n";
    }
    
    return result;
}

- (NSString *)encodeToBase64String:(UIImage *)image {
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:0];
}

- (void)fillSelectedProjMembers:(NSNotification *)notif{
    NSArray *array = notif.object;
    selectedTagsArray = [[NSMutableArray alloc]initWithArray:array];
    [self reloadTagsView];
}

- (void)reloadTagsViewForExpertise{
    NSArray *viewsToRemove = [namesScrollViewForExpertise subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    
    //CGFloat yPosOfSelectTagsLabel = 10;
    NSInteger countOfTags = [selectedTagsArrayForExpertise count];
    CGFloat yPOS = 5;
    CGFloat xPOS = 10;
    for (NSInteger i = 0; i < countOfTags; i++) {
        NSString *tagName = [[selectedTagsArrayForExpertise objectAtIndex:i]objectForKey:@"name"];
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
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(deleteTagImageForExpertiseAction:)];
        [label addGestureRecognizer:tap];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [NSString stringWithFormat:@"%@ x", tagName];
        label.font = FONT_NORMAL(13);
        label.textColor = COLOR_1;
        label.layer.cornerRadius = 12;
        label.layer.borderColor = COLOR_1.CGColor;
        label.layer.borderWidth = 0.5;
        label.clipsToBounds = YES;
        [namesScrollViewForExpertise addSubview:label];
        
        xPOS += label.frame.size.width + 15;
        namesScrollViewForExpertise.contentSize = CGSizeMake(xPOS, 40);
    }
}

- (void)deleteTagImageForExpertiseAction:(UITapGestureRecognizer *)tapy{
    
    NSInteger idOfTapLabel = tapy.view.tag;
    [selectedTagsArrayForExpertise removeObjectAtIndex:idOfTapLabel];
    
    NSArray *viewsToRemove = [namesScrollViewForExpertise subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    [self reloadTagsViewForExpertise];
}

- (void)makeToolBarOnView{
    [toolbar removeFromSuperview];
    toolbar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,screenHeight - 220,screenWidth,44)];
    [toolbar setBarStyle:UIBarStyleBlackOpaque];
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"تایید"
                                                                      style:UIBarButtonItemStyleDone target:self action:@selector(pickerToolbarDone)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
        //UIBarButtonItem *barButtonToday = [[UIBarButtonItem alloc] initWithTitle:@"امروز"
        //                                                                   style:UIBarButtonItemStyleDone target:self action:@selector(showTodayDate)];
    toolbar.items = @[flex, barButtonDone];
    //barButtonDone.tintColor=[UIColor whiteColor];
    [self.view addSubview:toolbar];
}

- (void)makeToolBarOnPickerView{
    [toolbar removeFromSuperview];
    if (IS_IPHONE_5_IOS8) {
        toolbar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,screenHeight - 215,screenWidth,44)];
    } else {
        toolbar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,screenHeight - 245,screenWidth,44)];
    }
    [toolbar setBarStyle:UIBarStyleBlackOpaque];
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"تایید"
                                                                      style:UIBarButtonItemStyleDone target:self action:@selector(pickerToolbarDone)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
        //UIBarButtonItem *barButtonToday = [[UIBarButtonItem alloc] initWithTitle:@"امروز"
        //                                                                   style:UIBarButtonItemStyleDone target:self action:@selector(showTodayDate)];
    toolbar.items = @[flex, barButtonDone];
        //barButtonDone.tintColor=[UIColor whiteColor];
    [self.view addSubview:toolbar];
}

- (void)pickerToolbarDone{
    [toolbar removeFromSuperview];
    [self hideTransparentView];
    [birthdateTextField resignFirstResponder];
    [expertiseTextField resignFirstResponder];
}

- (void)showTransparentView{
    [transparentView removeFromSuperview];
    transparentView  = [[UIView alloc]initWithFrame:CGRectMake(0, 64, screenWidth, screenHeight - 64 - 195)];
//    transparentView.userInteractionEnabled = YES;
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideTransparentView)];
//    [transparentView addGestureRecognizer:tap];
    transparentView.backgroundColor = [UIColor blackColor];
    transparentView.alpha = 0.5;
    [self.view addSubview:transparentView];
}

- (void)hideTransparentView{
    [transparentView removeFromSuperview];
}

#pragma mark - textfield delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    UIScrollView* v = (UIScrollView*)scrollView ;
    CGRect rc = [textField bounds];
    rc = [textField convertRect:rc toView:v];
    rc.origin.x = 0 ;
    rc.origin.y -= 60 ;
    
    rc.size.height = 400;
    scrollView.contentSize = CGSizeMake(screenWidth, screenHeight * 1.5 + 70);
    [scrollView scrollRectToVisible:rc animated:YES];
    
    
    if (textField.tag == 106) {
        [self showTransparentView];
        [self makeToolBarOnPickerView];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
    
    if (textField.tag == 106){
        [self hideTransparentView];
        [self pickerToolbarDone];
    }

    UIScrollView* v = (UIScrollView*)scrollView;
    CGRect rc = [textField bounds];
    rc = [textField convertRect:rc toView:v];
    rc.origin.x = 0 ;
    rc.origin.y = 0 ;
    
    //rc.size.height = 400;
    scrollView.contentSize = CGSizeMake(screenWidth, screenHeight * 1.5);
    [scrollView scrollRectToVisible:rc animated:NO];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -  pickerview delegate

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    if (pickerView.tag == 4) return 3;
    else return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    NSInteger count =   0;
    switch (component) {
        case 0:
            
            if (pickerView.tag == 1) {
                count = [sexArray count];
            } else if (pickerView.tag == 2){
                count = [materialStatusArray count];
            }else if (pickerView.tag == 3){
                count = [bloodTypesArray count];
            }else if (pickerView.tag == 4){
                count = [yearsArray count];
            }else if (pickerView.tag == 6){
                count = [expertiseArray count];
            }
            break;
        case 1:
            if (pickerView.tag == 4){
                count = [monthsArray count];
            }
            break;
        case 2:
            if (pickerView.tag == 4){
                count = [daysArray count];
            }
            break;
    }
    return count;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    UILabel* tView = (UILabel*)view;
    NSString *title = @"";
    switch (component) {
        case 0:
            if (pickerView.tag == 1) {
                title = [sexArray objectAtIndex:row];
            } else if (pickerView.tag == 2){
                title = [materialStatusArray objectAtIndex:row];
            }else if (pickerView.tag == 3){
                title = [bloodTypesArray objectAtIndex:row];
            }else if (pickerView.tag == 4){
                title = [yearsArray objectAtIndex:row];
            }if (pickerView.tag == 6) {
                title = [[expertiseArray objectAtIndex:row]objectForKey:@"name"];;
            }
            break;
        case 1:
            if (pickerView.tag == 4) {
                title = [monthsArray objectAtIndex:row];
            }
            break;
        case 2:
            if (pickerView.tag == 4) {
                title = [daysArray objectAtIndex:row];
            }
            break;
    }
    
    if (!tView){
        tView = [[UILabel alloc] init];
        UIFont *font = FONT_NORMAL(19);
        tView.textAlignment = NSTextAlignmentCenter;
        tView.font =font;
    }
    tView.text = [NSString stringWithFormat:@"%@", title];
    return tView;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    switch (component) {
        case 0:
            if (pickerView.tag == 1) {
                sexTextField.text = [sexArray objectAtIndex:row];
            } else if (pickerView.tag == 2){
                materialStatusTextField.text = [materialStatusArray objectAtIndex:row];
            } else if (pickerView.tag == 4){
                isBirthdateChanged = YES;
                year = [yearsArray objectAtIndex:row];
            }if (pickerView.tag == 6) {
                if ([selectedTagsArrayForExpertise count] > 0) {
                    BOOL isContainsObject = NO;
                    for (NSInteger i = 0; i < [selectedTagsArrayForExpertise count]; i++) {
                        if ([[[expertiseArray objectAtIndex:row]objectForKey:@"id"]integerValue] == [[[selectedTagsArrayForExpertise objectAtIndex:i]objectForKey:@"id"]integerValue]){
                            isContainsObject = YES;
                            break;
                        }
                    }
                    if (!isContainsObject) {
                        [selectedTagsArrayForExpertise addObject:[expertiseArray objectAtIndex:row]];
                        [self reloadTagsViewForExpertise];
                    }
                }else{
                    if ([expertiseArray count] > 0) {
                        [selectedTagsArrayForExpertise addObject:[expertiseArray objectAtIndex:row]];
                        [self reloadTagsViewForExpertise];
                    }
                    
                }
            }

            break;
        case 1:
            if (pickerView.tag == 4){
                isBirthdateChanged = YES;
                month = [monthsArray objectAtIndex:row];
            }
            break;
        case 2:
            if (pickerView.tag == 4){
                isBirthdateChanged = YES;
                day = [daysArray objectAtIndex:row];
            }
            break;
    }
    
    birthdateTextField.text = [NSString stringWithFormat:@"%@ %@ %@", day, month, year];
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
    [self takePhoto];
}

- (void)showgalleryCameraView{
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
    [self presentViewController:picker animated:YES completion:NULL];
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
    profileImageView.image = chosenImage;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    //upload new image to server
    //[self sendPhotoToServer];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Connection

- (BOOL)hasConnectivity {
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
    if(reachability != NULL) {
        //NetworkStatus retVal = NotReachable;
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(reachability, &flags)) {
            if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
            {
                // if target host is not reachable
                return NO;
            }
            
            if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
            {
                // if target host is reachable and no connection is required
                //  then we'll assume (for now) that your on Wi-Fi
                return YES;
            }
            
            
            if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
                 (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
            {
                // ... and the connection is on-demand (or on-traffic) if the
                //     calling application is using the CFSocketStream or higher APIs
                
                if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
                {
                    // ... and no [user] intervention is needed
                    return YES;
                }
            }
            
            if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
            {
                // ... but WWAN connections are OK if the calling application
                //     is using the CFNetwork (CFSocketStream?) APIs.
                return YES;
            }
        }
    }
    
    return NO;
}

- (void)uploadProfileDataToServer{
    
    if ([nameTextField.text length] == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"نام پروژه را وارد کنید" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    
    if ([aboutTextField.text length] == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"درباره پروژه را وارد کنید" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    
    if ([emailTextField.text length] == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"ایمیل را وارد کنید" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    

    [ProgressHUD show:@""];
    selectedTagsArrayWithID  = [[NSMutableArray alloc]init];
    for (NSInteger i = 0; i < [selectedTagsArray count]; i++) {
        [selectedTagsArrayWithID addObject:[NSNumber numberWithInteger:[[[selectedTagsArray objectAtIndex:i]objectForKey:@"id"]integerValue]]];
    }
    
    nameTextField.text = [nameTextField.text stringByReplacingOccurrencesOfString:@"ي" withString:@"ی" options:2 range:NSMakeRange(0, [nameTextField.text length])];
    nameTextField.text = [nameTextField.text stringByReplacingOccurrencesOfString:@"ك" withString:@"ک" options:2 range:NSMakeRange(0, [nameTextField.text length])];
    
    NSMutableString *expertiseString = [[NSMutableString alloc]init];
    for (NSInteger i = 0; i < [selectedTagsArrayForExpertise count]; i++) {
        if (i < [selectedTagsArrayForExpertise count] - 1) {
            [expertiseString appendString:[NSString stringWithFormat:@"%ld,", (long)[[[selectedTagsArrayForExpertise objectAtIndex:i]objectForKey:@"id"]integerValue]]];
        } else {
            [expertiseString appendString:[NSString stringWithFormat:@"%ld]", (long)[[[selectedTagsArrayForExpertise objectAtIndex:i]objectForKey:@"id"]integerValue]]];
        }
    }
    if ([expertiseString length] > 0) {
        [expertiseString insertString:@"[" atIndex:0];
    }

    NSDictionary *params = @{@"entity_type_id":[NSNumber numberWithInt:3],
                             @"name":nameTextField.text,
                             @"email":emailTextField.text,
                             @"phone":mobileTextField.text,
                             @"about":aboutTextField.text,
                             @"website":websiteTextField.text,
                             @"expertises":expertiseString
                             /*,
                             @"members":selectedTagsArrayWithID*/
                             };
    
    NSData *imageData = UIImagePNGRepresentation(profileImageView.image);
    NSString *url = [NSString stringWithFormat:@"%@api/entity/add", BaseURL];
    if (_isFromEditCompany) {
        url = [NSString stringWithFormat:@"%@api/entity/edit", BaseURL];
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"application/json"];
    manager.requestSerializer.timeoutInterval = 45;
    //NSLog(@"%@", [GetUsernamePassword getAccessToken]);
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [GetUsernamePassword getAccessToken]] forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    taeedButton.userInteractionEnabled = NO;
    [manager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (imageData) {
            [formData appendPartWithFileData:imageData
                                        name:@"avatar"
                                    fileName:@"avatar" mimeType:@"image/jpeg"];
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
                //[sendButton setTitle:[NSString stringWithFormat:@"%2.0f %%", uploadProgress.fractionCompleted * 100] forState:UIControlStateNormal];
            [ProgressHUD show:[NSString stringWithFormat:@"%2.0f %%", uploadProgress.fractionCompleted * 100]];
        });
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        [ProgressHUD dismiss];
        taeedButton.userInteractionEnabled = YES;
        if ([[responseObject objectForKey:@"success"]integerValue] == 1) {
            [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInteger:1] forKey:@"has_profile"];
            //NSInteger idOfProfile = [[[responseObject objectForKey:@"data"]objectForKey:@"id"]integerValue];
            //[[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInteger:idOfProfile] forKey:@"profileID"];
            //[[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"isProfileCompleted"];
        }
        
        

        [self dismissViewControllerAnimated:YES completion:^{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%@", [responseObject objectForKey:@"message"]] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                // ////NSLog(@"You pressed button OK");
            }];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [ProgressHUD dismiss];
        taeedButton.userInteractionEnabled = YES;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%@", [error localizedDescription]] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            // ////NSLog(@"You pressed button OK");
        }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

- (void)editProfileToServer{
    
    if ([selectedTagsArrayForExpertise count] == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"تخصص را انتخاب کنید" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            // ////NSLog(@"You pressed button OK");
        }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }

    
    if ([nameTextField.text length] == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"نام پروژه را وارد کنید" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    
    if ([aboutTextField.text length] == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"درباره پروژه را وارد کنید" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    
    if ([emailTextField.text length] == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"ایمیل را وارد کنید" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    

    [ProgressHUD show:@""];
    NSString *birthdateString = birthdateTextField.text;
    if (([birthdateTextField.text length] < 5) || [birthdateTextField.text containsString:@"null"]){
        birthdateTextField.text = @"";
        birthdateString = @"";
    }else{
        NSInteger monthNumber = [monthsArray indexOfObject:month] + 1;
        birthdateString = [NSString stringWithFormat:@"%@/%ld/%@", year, (long)monthNumber, day];
        /*
         NSString *dateStr = birthdateString;
         NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
         [dateFormatter setDateFormat:@"yyyy-MM-dd"];
         NSDate *birthdateDate = [[NSDate alloc] init];
         birthdateDate = [dateFormatter dateFromString:dateStr];
         birthdateString = [ConvertToPersianDate ConvertToGregorianDateWithYear:[year integerValue]
         month:monthNumber
         day:[day integerValue]];
         */
        
    }
    if (isBirthdateChanged == NO) {
        birthdateString = @"";
    }
    
    NSMutableString *expertiseString = [[NSMutableString alloc]init];
    for (NSInteger i = 0; i < [selectedTagsArrayForExpertise count]; i++) {
        if (i < [selectedTagsArrayForExpertise count] - 1) {
            [expertiseString appendString:[NSString stringWithFormat:@"\"%@\",", [[selectedTagsArrayForExpertise objectAtIndex:i]objectForKey:@"id"]]];
        } else {
            [expertiseString appendString:[NSString stringWithFormat:@"\"%@\"]", [[selectedTagsArrayForExpertise objectAtIndex:i]objectForKey:@"id"]]];
        }
    }
    [expertiseString insertString:@"[" atIndex:0];
    
    NSInteger profileId = [[_profileDictionary objectForKey:@"id"]integerValue];
    NSDictionary *params = @{@"id":[NSNumber numberWithInteger:profileId],
                             @"name":nameTextField.text,
                             @"about":aboutTextField.text,
                             @"email":emailTextField.text,
                             @"phone":mobileTextField.text,
                             @"website":websiteTextField.text,
                             @"expertises":expertiseString
                             };
    
    NSData *imageData = UIImagePNGRepresentation(profileImageView.image);
    NSString *url = [NSString stringWithFormat:@"%@api/entity/edit", BaseURL];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"application/json"];
    manager.requestSerializer.timeoutInterval = 45;
    //NSLog(@"%@", [GetUsernamePassword getAccessToken]);
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [GetUsernamePassword getAccessToken]] forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    taeedButton.userInteractionEnabled = NO;
    [manager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData
                                    name:@"avatar"
                                fileName:@"avatar" mimeType:@"image/jpeg"];
    } progress:^(NSProgress * _Nonnull uploadProgress){
        dispatch_async(dispatch_get_main_queue(), ^{
                //[sendButton setTitle:[NSString stringWithFormat:@"%2.0f %%", uploadProgress.fractionCompleted * 100] forState:UIControlStateNormal];
            [ProgressHUD show:[NSString stringWithFormat:@"%2.0f %%", uploadProgress.fractionCompleted * 100]];
        });
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        [ProgressHUD dismiss];
        taeedButton.userInteractionEnabled = YES;
        //[[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"isProfileCompleted"];
        [self dismissViewControllerAnimated:YES completion:^{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%@", [responseObject objectForKey:@"message"]] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                // ////NSLog(@"You pressed button OK");
            }];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [ProgressHUD dismiss];
        taeedButton.userInteractionEnabled = YES;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%@", [error localizedDescription]] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            // ////NSLog(@"You pressed button OK");
        }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

-(void)getProfileDataFromServer
{
    [ProgressHUD show:@""];
    NSString *url = [NSString stringWithFormat:@"%@api/entity/detail", BaseURL];
    NSInteger profileId = [[_profileDictionary objectForKey:@"id"]integerValue];
    NSDictionary *params = @{@"id":[NSNumber numberWithInteger:profileId]
                             };
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
        NSDictionary *resDic  =responseObject;
        if ([[resDic objectForKey:@"success"]integerValue] == 1) {
            NSDictionary *dic  =[responseObject objectForKey:@"data"];
            nameTextField.text = [dic objectForKey:@"name"];
            aboutTextField.text = [dic objectForKey:@"about"];
            mobileTextField.text = [dic objectForKey:@"phone"];
            emailTextField.text = [dic objectForKey:@"email"];
            websiteTextField.text = [dic objectForKey:@"website"];
            [profileImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [dic objectForKey:@"avatar"]]]];
            selectedTagsArrayForExpertise = [[NSMutableArray alloc]init];
            for (NSDictionary *dic in [[resDic objectForKey:@"data"]objectForKey:@"expertises"]) {
                [selectedTagsArrayForExpertise addObject:dic];
            }
            [self reloadTagsViewForExpertise];

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

- (void)getExpertiseFromServer{
    [ProgressHUD show:@""];
    NSString *url = [NSString stringWithFormat:@"%@api/expertise/all", BaseURL];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"application/json"];
    manager.requestSerializer.timeoutInterval = 45;
    //NSLog(@"%@", [GetUsernamePassword getAccessToken]);
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [GetUsernamePassword getAccessToken]] forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    [manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
    } progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [ProgressHUD dismiss];
        NSDictionary *resDic = (NSDictionary *)responseObject;
        expertiseArray = [[NSMutableArray alloc]init];
        for (NSDictionary *dic in [resDic objectForKey:@"data"]) {
            [expertiseArray addObject:dic];
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
