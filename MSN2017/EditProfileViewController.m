//
//  EditProfileViewController.m
//  MSN
//
//  Created by Yarima on 5/16/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "EditProfileViewController.h"
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
@interface EditProfileViewController()<UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
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
    UITextField *emailTextField;
    UITextField *educationTextField;
    UITextField *savabeghTextField;
    UIPickerView *sexPickerView;
    UIPickerView *materialStatusPickerView;
    UIPickerView *bloodTypesPickerView;
    UIPickerView *expertisePickerView;
    UIPickerView *jobTitlePickerView;
    UITextField *expertiseTextField;
    NSArray *sexArray;
    NSArray *materialStatusArray;
    NSArray *bloodTypesArray;
    
    UIPickerView *datePickerView;
    NSMutableArray *daysArray;
    NSMutableArray *monthsArray;
    NSMutableArray *yearsArray;
    BOOL isHidden;
    UIToolbar *dateToolbar;
    UIToolbar *toolbar;
    NSString *year;
    NSString *month;
    NSString *day;
    BOOL isBirthdateChanged;
    UIButton *taeedButton;
    UITextField *jobPositionTextField;
    UIScrollView *namesScrollView;
    NSMutableArray *selectedTagsArray;
    NSMutableArray *expertiseArray;
    NSMutableArray *jobTitleArray;
    NSInteger selectedJobPositionID;
    UIView *transparentView;
    BOOL isShamsiDatePickerON;
}

@end
@implementation EditProfileViewController

- (void)viewDidDisappear:(BOOL)animated{
    [ProgressHUD dismiss];
}
- (void)viewDidLoad{
    self.navigationController.navigationBar.hidden = YES;
    
    [self getExpertiseFromServer];
    [self getJobTitleFromServer];
    
    //make View
    [self makeTopBar];
    [self makePickerView];
    [self makeScrollView];
    [self makePersonalInfo];
    
    //NSLog(@"self.navigationControllers: %@", [self.navigationController viewControllers]);
    
    if (_isFromEditProfile) {
        [self getProfileDataFromServer];
    }
    selectedJobPositionID = _selectedJobTileID;
    
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
    titleLabel.text = NSLocalizedString(@"editProfile", @"");
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
    scrollView.backgroundColor = [UIColor whiteColor];
    scrollView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideAllViews)];
    [scrollView addGestureRecognizer:tap];
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
    nameTextField.placeholder = NSLocalizedString(@"name", @"");
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
    
    //birthdate
    birthdateTextField = [[UITextField alloc]initWithFrame:CGRectMake(screenWidth/2 - 80, horizontalLine.frame.origin.y + 40, 160, 25)];
    birthdateTextField.backgroundColor = [UIColor clearColor];
    birthdateTextField.placeholder = NSLocalizedString(@"birthdate", @"");
    birthdateTextField.inputView = datePickerView;
    //NSLog(@"%@", [ConvertToPersianDate ConvertToPersianDate:[NSString stringWithFormat:@"%@", [NSDate date]]]);
    if (_profileDictionary.birthdate != (id)[NSNull null]) {
        //NSArray *dateArray = [_profileDictionary.birthdate componentsSeparatedByString:@"-"];
        birthdateTextField.text = @"تاریخ تولد";/*[ConvertToPersianDate ConvertToPersianDateWithYear:[[dateArray objectAtIndex:0]integerValue]
                                                                               month:[[dateArray objectAtIndex:1]integerValue]
                                                                                 day:[[dateArray objectAtIndex:2]integerValue]];
                                                                                 */
//        NSArray *arr = [birthdateTextField.text componentsSeparatedByString:@" "];
//        day = [arr objectAtIndex:0];
//        month = [arr objectAtIndex:1];
//        year = [arr objectAtIndex:2];
    }
    birthdateTextField.tag = 102;
    birthdateTextField.delegate = self;
    birthdateTextField.font = FONT_NORMAL(15);
    birthdateTextField.layer.borderColor = [UIColor clearColor].CGColor;
    birthdateTextField.layer.borderWidth = 1.0;
    birthdateTextField.layer.cornerRadius = 5;
    birthdateTextField.clipsToBounds = YES;
    birthdateTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    birthdateTextField.textAlignment = NSTextAlignmentCenter;
    birthdateTextField.keyboardType = UIKeyboardTypeNumberPad;
    [scrollView addSubview:birthdateTextField];
    
    //33x34
    UIImageView *birthdateImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 40, horizontalLine.frame.origin.y + 40, 33 / 2, 34 / 2)];
    birthdateImageView.image = [UIImage imageNamed:@"icon_birthday"];
    birthdateImageView.userInteractionEnabled = YES;
    [scrollView addSubview:birthdateImageView];
    
    UIView *horizontalLine2 = [[UIView alloc]initWithFrame:CGRectMake(20, birthdateTextField.frame.origin.y + 25, screenWidth - 40, 0.5)];
    horizontalLine2.backgroundColor = [UIColor lightGrayColor];
    [scrollView addSubview:horizontalLine2];
    
    //email
    emailTextField = [[UITextField alloc]initWithFrame:CGRectMake(screenWidth/2 - 80, horizontalLine2.frame.origin.y + 40, 160, 25)];
    emailTextField.backgroundColor = [UIColor whiteColor];
    emailTextField.placeholder = NSLocalizedString(@"email", @"");
    emailTextField.text = _profileDictionary.emailProfile;
    emailTextField.tag = 103;
    emailTextField.delegate = self;
    emailTextField.font = FONT_NORMAL(12);
    emailTextField.layer.borderColor = [UIColor clearColor].CGColor;
    emailTextField.layer.borderWidth = 1.0;
    emailTextField.layer.cornerRadius = 5;
    emailTextField.clipsToBounds = YES;
    emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    emailTextField.textAlignment = NSTextAlignmentCenter;
    emailTextField.minimumFontSize = 0.5;
    emailTextField.adjustsFontSizeToFitWidth = YES;
    emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    [emailTextField addToolbar];
    [scrollView addSubview:emailTextField];
    
    //44x31
    UIImageView *emailImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 40, horizontalLine2.frame.origin.y + 40, 44 / 2, 31 / 2)];
    emailImageView.image = [UIImage imageNamed:@"icon_email"];
    emailImageView.userInteractionEnabled = YES;
    [scrollView addSubview:emailImageView];
    
    UIView *horizontalLine3 = [[UIView alloc]initWithFrame:CGRectMake(20, emailTextField.frame.origin.y + 25, screenWidth - 40, 0.5)];
    horizontalLine3.backgroundColor = [UIColor lightGrayColor];
    [scrollView addSubview:horizontalLine3];
    
    //mobile
    mobileTextField = [[UITextField alloc]initWithFrame:CGRectMake(screenWidth/2 - 80, horizontalLine3.frame.origin.y + 40, 160, 25)];
    mobileTextField.placeholder = NSLocalizedString(@"mobile", @"");
    mobileTextField.backgroundColor = [UIColor clearColor];
    mobileTextField.tag = 104;
    mobileTextField.textColor = [UIColor grayColor];
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
    mobileTextField.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"mobile"];
    [mobileTextField addToolbar];
    [scrollView addSubview:mobileTextField];
    mobileTextField.userInteractionEnabled = NO;
    
    //36x36
    UIImageView *mobileImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 40, horizontalLine3.frame.origin.y + 40, 33 / 2, 34 / 2)];
    mobileImageView.image = [UIImage imageNamed:@"icon_tel"];
    mobileImageView.userInteractionEnabled = YES;
    [scrollView addSubview:mobileImageView];
    
    UIView *horizontalLine4 = [[UIView alloc]initWithFrame:CGRectMake(20, mobileTextField.frame.origin.y + 25, screenWidth - 40, 0.5)];
    horizontalLine4.backgroundColor = [UIColor lightGrayColor];
    [scrollView addSubview:horizontalLine4];
    
    //job position
    jobPositionTextField = [[UITextField alloc]initWithFrame:CGRectMake(screenWidth/2 - 80, horizontalLine4 .frame.origin.y + 40, 160, 25)];
    jobPositionTextField.backgroundColor = [UIColor clearColor];
    jobPositionTextField.placeholder = @"سمت شغلی";
    jobPositionTextField.inputView = jobTitlePickerView;
    jobPositionTextField.tag = 105;
    jobPositionTextField.delegate = self;
    jobPositionTextField.font = FONT_NORMAL(15);
    jobPositionTextField.layer.borderColor = [UIColor clearColor].CGColor;
    jobPositionTextField.layer.borderWidth = 1.0;
    jobPositionTextField.layer.cornerRadius = 5;
    jobPositionTextField.clipsToBounds = YES;
    jobPositionTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    jobPositionTextField.textAlignment = NSTextAlignmentCenter;
    jobPositionTextField.keyboardType = UIKeyboardTypeNumberPad;
    [scrollView addSubview:jobPositionTextField];
    
    //60x60
    UIImageView *jobImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 40, horizontalLine4.frame.origin.y + 40, 60 / 4, 60 / 4)];
    jobImageView.image = [UIImage imageNamed:@"shoghl"];
    jobImageView.userInteractionEnabled = YES;
    [scrollView addSubview:jobImageView];
    
    UIView *horizontalLine5 = [[UIView alloc]initWithFrame:CGRectMake(20, jobPositionTextField.frame.origin.y + 25, screenWidth - 40, 0.5)];
    horizontalLine5.backgroundColor = [UIColor lightGrayColor];
    [scrollView addSubview:horizontalLine5];
    
    //60x24
    UIImageView *takhasosImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 40, horizontalLine5.frame.origin.y + 27, 60 / 3, 24 / 3)];
    takhasosImageView.image = [UIImage imageNamed:@"takhasos"];
    takhasosImageView.userInteractionEnabled = YES;
    [scrollView addSubview:takhasosImageView];
    
    //expertise
    expertiseTextField = [[UITextField alloc]initWithFrame:CGRectMake(screenWidth - 170, horizontalLine5.frame.origin.y + 20, 120, 25)];
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
    
    selectedTagsArray = [[NSMutableArray alloc]initWithArray:_selectedTagsArray1];
    namesScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, horizontalLine5.frame.origin.y + 50, screenWidth - 40, 40)];
    namesScrollView.contentSize = CGSizeMake(screenWidth * 2, 40);
    [scrollView addSubview:namesScrollView];
    [self reloadTagsView];
    
    [self makeSavabeghInfo:namesScrollView.frame.origin.y + 45];
}

- (void)makeSavabeghInfo:(CGFloat)yPos{
    UILabel *Label =[[UILabel alloc]initWithFrame:CGRectMake(0, yPos, screenWidth, 30)];
    Label.font = FONT_NORMAL(16);
    Label.minimumScaleFactor = 0.5;
    Label.adjustsFontSizeToFitWidth = YES;
    Label.text = NSLocalizedString(@"savabegh", @"");
    Label.textColor = [UIColor whiteColor];
    Label.backgroundColor = [UIColor colorWithRed:47/255.0 green:197/255.0 blue:137/255.0 alpha:1.0];
    Label.textAlignment = NSTextAlignmentCenter;
    [scrollView addSubview:Label];
    
    educationTextField = [[UITextField alloc]initWithFrame:CGRectMake(screenWidth/2 - 80, Label.frame.origin.y + Label.frame.size.height + 30, 160, 25)];
    educationTextField.backgroundColor = [UIColor whiteColor];
    educationTextField.placeholder = NSLocalizedString(@"education", @"");
    educationTextField.text = _profileDictionary.first_nameProfile;
    educationTextField.tag = 201;
    educationTextField.delegate = self;
    educationTextField.font = FONT_NORMAL(15);
    educationTextField.layer.borderColor = [UIColor clearColor].CGColor;
    educationTextField.layer.borderWidth = 1.0;
    educationTextField.layer.cornerRadius = 5;
    educationTextField.clipsToBounds = YES;
    educationTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    educationTextField.textAlignment = NSTextAlignmentCenter;
    [educationTextField addToolbar];
    [scrollView addSubview:educationTextField];
    
    //63 × 30
    UIImageView *nameImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 40, Label.frame.origin.y + Label.frame.size.height + 30, 63 / 3, 30 / 3)];
    nameImageView.image = [UIImage imageNamed:@"icon_education"];
    nameImageView.userInteractionEnabled = YES;
    [scrollView addSubview:nameImageView];
    
    UIView *horizontalLine = [[UIView alloc]initWithFrame:CGRectMake(20, educationTextField.frame.origin.y + 25, screenWidth - 40, 0.5)];
    horizontalLine.backgroundColor = [UIColor lightGrayColor];
    [scrollView addSubview:horizontalLine];
    
    savabeghTextField = [[UITextField alloc]initWithFrame:CGRectMake(screenWidth/2 - 80, horizontalLine.frame.origin.y + horizontalLine.frame.size.height + 30, 160, 25)];
    savabeghTextField.backgroundColor = [UIColor whiteColor];
    savabeghTextField.placeholder = NSLocalizedString(@"savabeghShogli", @"");
    savabeghTextField.text = _profileDictionary.first_nameProfile;
    savabeghTextField.tag = 202;
    savabeghTextField.delegate = self;
    savabeghTextField.font = FONT_NORMAL(15);
    savabeghTextField.layer.borderColor = [UIColor clearColor].CGColor;
    savabeghTextField.layer.borderWidth = 1.0;
    savabeghTextField.layer.cornerRadius = 5;
    savabeghTextField.clipsToBounds = YES;
    savabeghTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    savabeghTextField.textAlignment = NSTextAlignmentCenter;
    [savabeghTextField addToolbar];
    [scrollView addSubview:savabeghTextField];
    
    //56x46
    UIImageView *savabeghImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 40, horizontalLine.frame.origin.y + horizontalLine.frame.size.height + 30, 56 / 3, 46 / 3)];
    savabeghImageView.image = [UIImage imageNamed:@"icon_job"];
    savabeghImageView.userInteractionEnabled = YES;
    [scrollView addSubview:savabeghImageView];
    
    UIView *horizontalLine2 = [[UIView alloc]initWithFrame:CGRectMake(20, savabeghTextField.frame.origin.y + 25, screenWidth - 40, 0.5)];
    horizontalLine2.backgroundColor = [UIColor lightGrayColor];
    [scrollView addSubview:horizontalLine2];
    
    taeedButton = [CustomButton initButtonWithTitle:NSLocalizedString(@"taeed2", @"") withTitleColor:[UIColor whiteColor] withBackColor:[UIColor colorWithRed:92/255.0 green:134/255.0 blue:217/255.0 alpha:1.0] isRounded:NO withFrame:CGRectMake(-5, screenHeight - 40, screenWidth + 10, 42)];
    [taeedButton addTarget:self action:@selector(sendButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [taeedButton makeGradient:taeedButton];
    [self.view addSubview:taeedButton];
    
    scrollView.contentSize = CGSizeMake(screenWidth, savabeghTextField.frame.origin.y + 50);
    
}
- (void)sendButtonAction{
    if ([self hasConnectivity]) {
        if (_isFromEditProfile) {
            [self editProfileToServer];
        } else {
            [self uploadProfileDataToServer];
        }
    } else {
        
    }
    
}
- (void)makePickerView{
    
    sexArray = [[NSArray alloc]initWithObjects:
                NSLocalizedString(@"man", @""),
                NSLocalizedString(@"woman", @""),
                nil];
    materialStatusArray = [[NSArray alloc]initWithObjects:
                           NSLocalizedString(@"married", @""),
                           NSLocalizedString(@"single", @""),
                           nil];
    bloodTypesArray = [[NSArray alloc]initWithObjects:@"O-", @"O+",@"A-",@"A+",@"B-",@"B+",@"AB-",@"AB+", nil];
    
    yearsArray = [[NSMutableArray alloc]init];
    daysArray = [[NSMutableArray alloc]init];
    for (NSInteger i = 1320; i < 1380; i++) {
        [yearsArray addObject:[NSNumber numberWithInteger:i]];
    }
    [yearsArray insertObject:@"" atIndex:0];
    
    for (NSInteger i = 1; i < 32; i++) {
        [daysArray addObject:[NSNumber numberWithInteger:i]];
    }
    [daysArray insertObject:@"" atIndex:0];
    
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
    
    jobTitlePickerView = [[UIPickerView alloc] init];
    [jobTitlePickerView setDataSource: self];
    [jobTitlePickerView setDelegate: self];
    jobTitlePickerView.tag = 5;
    jobTitlePickerView.backgroundColor = [UIColor whiteColor];
    [jobTitlePickerView setFrame: CGRectMake(0, screenHeight, screenWidth, 200.0f)];
    [jobPositionTextField addSubview:jobTitlePickerView];
    
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
    [emailTextField resignFirstResponder];
    [educationTextField resignFirstResponder];
    [savabeghTextField resignFirstResponder];
    //[jobPositionTextField resignFirstResponder];
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
    [self showgalleryCameraView];
    [self dismissTextField];
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

- (void)reloadTagsView{
    NSArray *viewsToRemove = [namesScrollView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
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
}

- (void)deleteTagImageAction:(UITapGestureRecognizer *)tapy{
    
    NSInteger idOfTapLabel = tapy.view.tag;
    if (idOfTapLabel < [selectedTagsArray count]) {
        [selectedTagsArray removeObjectAtIndex:idOfTapLabel];
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
    [jobPositionTextField resignFirstResponder];
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
    UIScrollView* v = (UIScrollView*) scrollView ;
    CGRect rc = [textField bounds];
    rc = [textField convertRect:rc toView:v];
    rc.origin.x = 0 ;
    rc.origin.y -= 60 ;
    
    rc.size.height = 400;
    scrollView.contentSize = CGSizeMake(screenWidth, screenHeight * 1.5 + 70);
    [scrollView scrollRectToVisible:rc animated:YES];
    
    if (textField.tag == 102) {
    [self showTransparentView];
        [self makeToolBarOnPickerView];
    }else if (textField.tag == 105) {
        [self showTransparentView];
        [self makeToolBarOnPickerView];
    }else if (textField.tag == 106) {
    [self showTransparentView];
        [self makeToolBarOnPickerView];
    }else if (textField.tag == 6) {
    [self showTransparentView];
        [self makeToolBarOnView];
    }
    
    //sex, date, job, expert
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
    UIScrollView* v = (UIScrollView*)scrollView;
    CGRect rc = [textField bounds];
    rc = [textField convertRect:rc toView:v];
    rc.origin.x = 0 ;
    rc.origin.y = 0 ;
    
    rc.size.height = 400;
    scrollView.contentSize = CGSizeMake(screenWidth, savabeghTextField.frame.origin.y + 50);
    [scrollView scrollRectToVisible:rc animated:NO];
    
    if (textField.tag == 102 ||
        textField.tag == 106 ||
        textField.tag == 5 ||
        textField.tag == 6 ){
        [self hideTransparentView];
        [self pickerToolbarDone];
    }
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
            }else if (pickerView.tag == 5){
                count = [jobTitleArray count];
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

/*
 - (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
 {
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
 
 NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName:[UIFont fontWithName:@"YekanMob" size:11]}];
 
 return attString;
 }
 */
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
            }else if (pickerView.tag == 5) {
                title = [[jobTitleArray objectAtIndex:row]objectForKey:@"name"];
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
            }if (pickerView.tag == 5) {
                if ([jobTitleArray count] > 0) {
                    jobPositionTextField.text = [[jobTitleArray objectAtIndex:row]objectForKey:@"name"];
                    selectedJobPositionID = [[[jobTitleArray objectAtIndex:row]objectForKey:@"id"]integerValue];
                }
                
            }if (pickerView.tag == 6) {
                if ([selectedTagsArray count] > 0) {
                    BOOL isContainsObject = NO;
                    for (NSInteger i = 0; i < [selectedTagsArray count]; i++) {
                            if ([[[expertiseArray objectAtIndex:row]objectForKey:@"id"]integerValue] == [[[selectedTagsArray objectAtIndex:i]objectForKey:@"id"]integerValue]){
                                isContainsObject = YES;
                                break;
                            }
                    }
                    if (!isContainsObject) {
                        [selectedTagsArray addObject:[expertiseArray objectAtIndex:row]];
                        [self reloadTagsView];
                    }
                    
                }else{
                    if ([expertiseArray count]  > 0) {
                        [selectedTagsArray addObject:[expertiseArray objectAtIndex:row]];
                        [self reloadTagsView];
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
    
    if (isBirthdateChanged) {
        birthdateTextField.text = [NSString stringWithFormat:@"%@ %@ %@", day, month, year];
    }
    
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
    
    if ([nameTextField.text length] == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"ویرایش پروفایل" message:@"نام و نام خانوادگی را بنویسید" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;

    }
    
    if ([selectedTagsArray count] == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"ویرایش پروفایل" message:@"تخصص را انتخاب کنید" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    if ([jobPositionTextField.text length] == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"ویرایش پروفایل" message:@"سمت شغلی را انتخاب کنید" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    NSMutableString *participantString = [[NSMutableString alloc]init];
    for (NSInteger i = 0; i < [selectedTagsArray count]; i++) {
        if (i < [selectedTagsArray count] - 1) {
            [participantString appendString:[NSString stringWithFormat:@"\"%@\",", [[selectedTagsArray objectAtIndex:i]objectForKey:@"id"]]];
        } else {
            [participantString appendString:[NSString stringWithFormat:@"\"%@\"]", [[selectedTagsArray objectAtIndex:i]objectForKey:@"id"]]];
        }
    }
    [participantString insertString:@"[" atIndex:0];
    
    NSInteger profileId = [[[NSUserDefaults standardUserDefaults]objectForKey:@"profileID"]integerValue];
    NSDictionary *params = @{@"entity_type_id":[NSNumber numberWithInt:1],
                             @"id":[NSNumber numberWithInteger:profileId],
                             @"name":nameTextField.text,
                             @"birth_date":birthdateString,
                             @"email":emailTextField.text,
                             @"mobile":mobileTextField.text,
                             @"education":educationTextField.text,
                             @"work_experience":savabeghTextField.text,
                             @"job_title_id":[NSNumber numberWithInteger:selectedJobPositionID],
                             @"expertises":participantString
                             };
    
    [ProgressHUD show:@""];
    NSData *imageData = UIImagePNGRepresentation(profileImageView.image);
    NSString *url = [NSString stringWithFormat:@"%@api/entity/add", BaseURL];
    if (_isFromEditProfile) {
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
        if ([[responseObject objectForKey:@"success"]integerValue] == 1) {
            [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInteger:1] forKey:@"has_profile"];
            NSInteger idOfProfile = [[[responseObject objectForKey:@"data"]objectForKey:@"id"]integerValue];
            [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInteger:idOfProfile] forKey:@"profileID"];
            [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"isProfileCompleted"];
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
    if ([selectedTagsArray count] == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"تخصص را انتخاب کنید" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            // ////NSLog(@"You pressed button OK");
        }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    
    if ([jobPositionTextField.text length] == 0) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"سمت شغلی را انتخاب کنید" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            // ////NSLog(@"You pressed button OK");
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
    
    NSMutableString *participantString = [[NSMutableString alloc]init];
    for (NSInteger i = 0; i < [selectedTagsArray count]; i++) {
        if (i < [selectedTagsArray count] - 1) {
            [participantString appendString:[NSString stringWithFormat:@"\"%@\",", [[selectedTagsArray objectAtIndex:i]objectForKey:@"id"]]];
        } else {
            [participantString appendString:[NSString stringWithFormat:@"\"%@\"]", [[selectedTagsArray objectAtIndex:i]objectForKey:@"id"]]];
        }
    }
    [participantString insertString:@"[" atIndex:0];
    
    NSInteger profileId = [[[NSUserDefaults standardUserDefaults]objectForKey:@"profileID"]integerValue];
    NSDictionary *params = @{@"id":[NSNumber numberWithInteger:profileId],
                             @"name":nameTextField.text,
                             @"birth_date":birthdateString,
                             @"email":emailTextField.text,
                             @"mobile":mobileTextField.text,
                             @"education":educationTextField.text,
                             @"work_experience":savabeghTextField.text,
                             @"job_title_id":[NSNumber numberWithInteger:selectedJobPositionID],
                             @"expertises":participantString
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
    NSInteger profileId = [[[NSUserDefaults standardUserDefaults]objectForKey:@"profileID"]integerValue];
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
            birthdateTextField.text = [dic objectForKey:@"birth_date"];
            emailTextField.text = [dic objectForKey:@"email"];
            mobileTextField.text = [dic objectForKey:@"mobile"];
            educationTextField.text = [dic objectForKey:@"education"];
            savabeghTextField.text = [dic objectForKey:@"work_experience"];
            jobPositionTextField.text = [[[resDic objectForKey:@"data"]objectForKey:@"job_title"]objectForKey:@"name"];
            [profileImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [dic objectForKey:@"avatar"]]]];
            
            selectedTagsArray = [[NSMutableArray alloc]init];
            for (NSDictionary *dic in [[resDic objectForKey:@"data"]objectForKey:@"expertises"]) {
                [selectedTagsArray addObject:dic];
            }
            [self reloadTagsView];
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

- (void)getJobTitleFromServer{
    [ProgressHUD show:@""];
    NSString *url = [NSString stringWithFormat:@"%@api/job_title/all", BaseURL];
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
        jobTitleArray = [[NSMutableArray alloc]init];
        for (NSDictionary *dic in [resDic objectForKey:@"data"]) {
            [jobTitleArray addObject:dic];
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
