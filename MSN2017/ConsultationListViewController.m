//
//  ViewController.m
//  MSN
//
//  Created by Yarima on 4/6/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "ConsultationListViewController.h"
#import <AFHTTPSessionManager.h>
#import <UIImageView+AFNetworking.h>
#import "Header.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import "KeychainWrapper.h"
#import "ProgressHUD.h"
#import "ConsultationListCustomCell.h"
#import "TimeAgoViewController.h"
#import "CustomButton.h"
#import "UploadDocumentsViewController.h"
#import "NSDictionary+consultation.h"
#import "ConsultationDetailViewController.h"
#import "DirectQuestionViewController.h"
#import "GetUsernamePassword.h"
#import "HealthStatusViewController.h"
#import "FavoritesViewController.h"
#import "AboutViewController.h"
#import "Database.h"
#import "UIImage+Extra.h"
#import "NSDictionary+profile.h"
#import "ShakeAnimation.h"
#import "ConvertToPersianDate.h"
#import "LoginViewController.h"
#import "IntroViewController.h"
#define loadingCellTag  1273

@interface ConsultationListViewController ()<UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
{
     
    BOOL    isBusyNow;
    NSInteger  selectedRow;
    BOOL    isExpand;
    UIRefreshControl *refreshControl;
    UIButton *categoryButton;
    BOOL    isPagingForCategories;
    BOOL    noMoreData;
    BOOL    isRightMenuAppears;
    UIButton *menubuttons;
    UIView *rightMenuView;
    
    NSMutableArray *packegesArray;
    UIView *packageListView;
    NSInteger selectedPackageId;//is dictionary key from listPackage API
    NSInteger selectedPackgeByUser;//is selected package by touch by user
    CGFloat yPositionOfLabel;
    CGFloat yPositionOfSelectedButton;
    UILabel *selectLabel;
    UIView *packageBuyView;
    UIView *confirmationView;
    UIView *confirmationViewBGView;
    NSInteger availablePackageCounts;
    UIButton *questionCountButton;
    UIView *finishpackageView;
    NSMutableArray *packageColorArray;
    UIImageView *giftImageView;
    UIImageView *guideImageView;
    UIView *fillProfileView;
    UIView *fillProfileFormView;
    UITextField *sexTextField;
    UITextField *heightTextField;
    UITextField *weightTextField;
    UITextField *birthdateTextField;
    UIPickerView *sexPickerView;
    UIPickerView *datePickerView;
    NSArray *sexArray;
    UIToolbar *dateToolbar;
    NSString *year;
    NSString *month;
    NSString *day;
    NSMutableArray *daysArray;
    NSMutableArray *monthsArray;
    NSMutableArray *yearsArray;
    BOOL disableTableView;
    
}
@property(nonatomic, retain)UITableView *tableView;
@property(nonatomic, retain)NSMutableArray *tableArray;
@property(nonatomic, retain)NSMutableArray *likeArray;
@property(nonatomic, retain)NSMutableArray *favArray;
@property(nonatomic, strong)NSIndexPath *currentIndexPath;

@end

@implementation ConsultationListViewController
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
- (void)viewDidDisappear:(BOOL)animated{
    [ProgressHUD dismiss];
}

- (void)viewWillDisappear:(BOOL)animated{
    self.tableView.userInteractionEnabled = YES;
}
- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = YES;
    [super viewDidLoad];
    [self fetchConsultationsFromServer];
     
    selectedRow = 1000;
    isBusyNow = NO;
    self.tableArray = [[NSMutableArray alloc]init];
    
    selectedPackageId = 1000;
    availablePackageCounts = 0;
    [self getAvailableCountFromServer];
    
    //make View
    [self makeTopBar];
    [self makeTableViewWithYpos:70];
    [self populateTableViewArray];
    
    //NSLog(@"self.navigationControllers: %@", [self.navigationController viewControllers]);
    //NSArray *medicalSectionArray = [Database selectFromMedicalSectionWithFilePath:[Database getDbFilePath]];
    
    disableTableView = YES;
    
    NSString *showPackageList = [[NSUserDefaults standardUserDefaults]objectForKey:@"showPackageLIST"];
    if ([showPackageList isEqualToString:@"YES"]) {
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"showPackageLIST"];
        [self getPackagesFromServer];
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
    [self.view addSubview:topView];
    
    CGFloat topViewHeight = topView.frame.size.height;
    
    UILabel *titleLabel =[[UILabel alloc]initWithFrame:CGRectMake(screenWidth/2 - 100, topViewHeight/2 - 15, 200, 40)];
    titleLabel.font = FONT_NORMAL(18);
    titleLabel.text = NSLocalizedString(@"consulting", @"");
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
    
    //200 × 69
    questionCountButton = [[UIButton alloc]initWithFrame:CGRectMake(10, topView.frame.size.height/2 - 11, 60, 21)];
    [questionCountButton setBackgroundImage:[UIImage imageNamed:@"traffic2"] forState:UIControlStateNormal];
    [questionCountButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    questionCountButton.titleLabel.font = FONT_NORMAL(12);
    [questionCountButton addTarget:self action:@selector(getPackagesFromServer) forControlEvents:UIControlEventTouchUpInside];
    questionCountButton.accessibilityIdentifier = @"questionCountButton";
    [topView addSubview:questionCountButton];
    
    //45x69
    UIButton *searchButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - 100, topViewHeight/2 - 10, 54 *0.4, 69 * 0.4)];
    [searchButton setBackgroundImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(searchButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:searchButton];

    
}

- (void)searchButtonAction {
    if (![self hasConnectivity]) {
         
    }else{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"GoToSearchView" object:nil];
        /*
         UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
         SearchViewController *view = (SearchViewController *)[story instantiateViewControllerWithIdentifier:@"SearchViewController"];
         [self.navigationController pushViewController:view animated:YES];
         */
    }
}

- (void)makeTableViewWithYpos:(CGFloat )yPos{
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, yPos, screenWidth, screenHeight - yPos)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableView];
    
    refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
}

- (BOOL)checkForEmptyProfileData{
    //check for empty profile data
    NSDictionary *profileDic = [GetUsernamePassword getProfileData];
    NSArray *weightsArray = profileDic.weightsArrayProfile;
    NSString *sex = profileDic.sexProfile;
    NSInteger height = profileDic.heightProfile;
    NSString *birthdate = profileDic.birthdate;
    if (sex == (id)[NSNull null]) {
        sex = @"";
    }
    
    if (birthdate == (id)[NSNull null]) {
        birthdate = @"";
    }
    
    if ([weightsArray count] == 0 ||
        [sex length] == 0 ||
        height < 50 ||
        [birthdate length] == 0) {
        
        [self showAlertToFillProfile];
        return YES;
    }
    
    return NO;
    
}
- (void)showAlertToFillProfile{
    fillProfileView = [[UIView alloc]initWithFrame:CGRectMake(50, 180, screenWidth - 100, 200)];
    fillProfileView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    fillProfileView.layer.borderWidth = 5.0;
    fillProfileView.layer.cornerRadius = 9.0;
    fillProfileView.clipsToBounds = YES;
    fillProfileView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:fillProfileView];
    
    UIImageView *logoImageView = [[UIImageView alloc]initWithFrame:CGRectMake(fillProfileView.frame.size.width/2 - 35, 10, 70, 60)];
    logoImageView.image = [UIImage imageNamed:@"abresalamatlogo"];
    [fillProfileView addSubview:logoImageView];
    
    UILabel *titleLabel =[[UILabel alloc]initWithFrame:CGRectMake(10, 80, fillProfileView.frame.size.width - 20, 70)];
    titleLabel.font = FONT_NORMAL(11);
    titleLabel.numberOfLines = 3;
    titleLabel.text = NSLocalizedString(@"fillprofile", @"");
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [fillProfileView addSubview:titleLabel];
    
    UIButton *fillProfileButton = [[UIButton alloc]initWithFrame:CGRectMake(fillProfileView.frame.size.width/2 - 18, 155, 35, 35)];
    [fillProfileButton setBackgroundImage:[UIImage imageNamed:@"ok"] forState:UIControlStateNormal];
    [fillProfileButton addTarget:self action:@selector(fillProfileButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [fillProfileView addSubview:fillProfileButton];
    
}
- (void)fillProfileButtonAction{
    [fillProfileView removeFromSuperview];
    [self showFormToFillProfile];
}

- (void)showFormToFillProfile{
    
    [self makePickerView];
    
    fillProfileFormView = [[UIView alloc]initWithFrame:CGRectMake(20, 150, screenWidth - 40, 330)];
    fillProfileFormView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    fillProfileFormView.layer.borderWidth = 5.0;
    fillProfileFormView.layer.cornerRadius = 9.0;
    fillProfileFormView.clipsToBounds = YES;
    fillProfileFormView.backgroundColor = [UIColor whiteColor];
    fillProfileFormView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapForFillProfile:)];
    [fillProfileFormView addGestureRecognizer:tap];
    [self.view addSubview:fillProfileFormView];
    
    UIImageView *logoImageView = [[UIImageView alloc]initWithFrame:CGRectMake(fillProfileFormView.frame.size.width/2 - 35, 10, 70, 60)];
    logoImageView.image = [UIImage imageNamed:@"abresalamatlogo"];
    [fillProfileFormView addSubview:logoImageView];
    
    UILabel *titleLabel =[[UILabel alloc]initWithFrame:CGRectMake(10, 60, fillProfileFormView.frame.size.width - 20, 70)];
    titleLabel.font = FONT_NORMAL(11);
    titleLabel.numberOfLines = 3;
    titleLabel.text = NSLocalizedString(@"fillprofile", @"");
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [fillProfileFormView addSubview:titleLabel];
    
    UILabel *sexLabel =[[UILabel alloc]initWithFrame:CGRectMake(fillProfileFormView.frame.size.width - 100, titleLabel.frame.origin.y + 70, 80, 25)];
    sexLabel.font = FONT_NORMAL(13);
    sexLabel.text = NSLocalizedString(@"sex", @"");
    sexLabel.textColor = [UIColor blackColor];
    sexLabel.textAlignment = NSTextAlignmentRight;
    [fillProfileFormView addSubview:sexLabel];
    
    sexTextField = [[UITextField alloc]initWithFrame:CGRectMake(40, titleLabel.frame.origin.y + 70, 150, 30)];
    sexTextField.delegate = self;
    sexTextField.tag = 54;
    sexTextField.font = FONT_NORMAL(13);
    sexTextField.inputView = sexPickerView;
    sexTextField.textAlignment = NSTextAlignmentCenter;
    sexTextField.layer.cornerRadius = 15;
    sexTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    sexTextField.layer.borderWidth = 2.0;
    sexTextField.clipsToBounds = YES;
    sexTextField.backgroundColor = [UIColor whiteColor];
    [fillProfileFormView addSubview:sexTextField];
    
    UILabel *heightLabel =[[UILabel alloc]initWithFrame:CGRectMake(fillProfileFormView.frame.size.width - 100, titleLabel.frame.origin.y + 110, 80, 25)];
    heightLabel.font = FONT_NORMAL(13);
    heightLabel.text = [NSString stringWithFormat:@"%@ :", NSLocalizedString(@"height", @"")];
    heightLabel.textColor = [UIColor blackColor];
    heightLabel.textAlignment = NSTextAlignmentRight;
    [fillProfileFormView addSubview:heightLabel];
    
    heightTextField = [[UITextField alloc]initWithFrame:CGRectMake(40, titleLabel.frame.origin.y + 110, 150, 30)];
    heightTextField.delegate = self;
    heightTextField.tag = 55;
    heightTextField.font = FONT_NORMAL(13);
    heightTextField.textAlignment = NSTextAlignmentCenter;
    heightTextField.keyboardType = UIKeyboardTypeNumberPad;
    heightTextField.layer.cornerRadius = 15;
    heightTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    heightTextField.layer.borderWidth = 2.0;
    heightTextField.clipsToBounds = YES;
    heightTextField.backgroundColor = [UIColor whiteColor];
    [fillProfileFormView addSubview:heightTextField];
    
    UILabel *weightLabel =[[UILabel alloc]initWithFrame:CGRectMake(fillProfileFormView.frame.size.width - 100, titleLabel.frame.origin.y + 150, 80, 25)];
    weightLabel.font = FONT_NORMAL(13);
    weightLabel.text = [NSString stringWithFormat:@"%@ :", NSLocalizedString(@"weight2", @"")];
    weightLabel.textColor = [UIColor blackColor];
    weightLabel.textAlignment = NSTextAlignmentRight;
    [fillProfileFormView addSubview:weightLabel];
    
    weightTextField = [[UITextField alloc]initWithFrame:CGRectMake(40, titleLabel.frame.origin.y + 150, 150, 30)];
    weightTextField.delegate = self;
    weightTextField.tag = 56;
    weightTextField.font = FONT_NORMAL(13);
    weightTextField.textAlignment = NSTextAlignmentCenter;
    weightTextField.keyboardType = UIKeyboardTypeNumberPad;
    weightTextField.layer.cornerRadius = 15;
    weightTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    weightTextField.layer.borderWidth = 2.0;
    weightTextField.clipsToBounds = YES;
    weightTextField.backgroundColor = [UIColor whiteColor];
    [fillProfileFormView addSubview:weightTextField];
    
    UILabel *birthdateLabel =[[UILabel alloc]initWithFrame:CGRectMake(fillProfileFormView.frame.size.width - 100, titleLabel.frame.origin.y + 190, 80, 25)];
    birthdateLabel.font = FONT_NORMAL(13);
    birthdateLabel.text = [NSString stringWithFormat:@"%@ :", NSLocalizedString(@"birthdate", @"")];
    birthdateLabel.textColor = [UIColor blackColor];
    birthdateLabel.textAlignment = NSTextAlignmentRight;
    [fillProfileFormView addSubview:birthdateLabel];
    
    birthdateTextField = [[UITextField alloc]initWithFrame:CGRectMake(40, titleLabel.frame.origin.y + 190, 150, 30)];
    birthdateTextField.delegate = self;
    birthdateTextField.font = FONT_NORMAL(13);
    birthdateTextField.tag = 57;
    birthdateTextField.textAlignment = NSTextAlignmentCenter;
    birthdateTextField.inputView = datePickerView;
    birthdateTextField.layer.cornerRadius = 15;
    birthdateTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    birthdateTextField.layer.borderWidth = 2.0;
    birthdateTextField.clipsToBounds = YES;
    birthdateTextField.backgroundColor = [UIColor whiteColor];
    [fillProfileFormView addSubview:birthdateTextField];
    
    UIButton *fillProfileButton = [[UIButton alloc]initWithFrame:CGRectMake(fillProfileFormView.frame.size.width/2 - 18, 285, 35, 35)];
    [fillProfileButton setBackgroundImage:[UIImage imageNamed:@"ok"] forState:UIControlStateNormal];
    [fillProfileButton addTarget:self action:@selector(sendProfileDataToServer) forControlEvents:UIControlEventTouchUpInside];
    [fillProfileFormView addSubview:fillProfileButton];
}

- (void)makePickerView{
    
    sexArray = [[NSArray alloc]initWithObjects:
                NSLocalizedString(@"man", @""),
                NSLocalizedString(@"woman", @""),
                nil];
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
    month = @"";
    year = @"";
    
}


- (void)tapForFillProfile:(UITapGestureRecognizer *)tap{
    [sexTextField resignFirstResponder];
    [heightTextField resignFirstResponder];
    [weightTextField resignFirstResponder];
    [birthdateTextField resignFirstResponder];
    CGRect rect = self.view.frame;
    rect.origin.y = 0;
    [UIView animateWithDuration:1.0 animations:^{
        [self.view setFrame:rect];
    }];
    
}
- (void)dismissGuideView{
    [giftImageView removeFromSuperview];
    [guideImageView removeFromSuperview];
}

- (void)newQuestionButtonAction{
    BOOL emptyProfile = [self checkForEmptyProfileData];
    if (!emptyProfile) {
    if ([questionCountButton.titleLabel.text integerValue] > 0) {
        [self pushToNewQuestion];
    } else {
         
        
    }
}
    
}

- (void)pushToNewQuestion{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DirectQuestionViewController *view = (DirectQuestionViewController *)[story instantiateViewControllerWithIdentifier:@"DirectQuestionViewController"];
    view.isNewQuestion = YES;
    [self.navigationController pushViewController:view animated:YES];
    
}

- (void)refreshTable{
    [self fetchConsultationsFromServer];
    [self getAvailableCountFromServer];
}

- (void)populateTableViewArray{
    NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:@"consultation"];
    if (data) {
        NSDictionary *jsonObject = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        self.tableArray = [[NSMutableArray alloc]init];
        NSMutableArray *tempArray = [[NSMutableArray alloc]init];
        for (NSDictionary *tempDic in [jsonObject objectForKey:@"items"]) {
            [tempArray addObject:tempDic];
        }
        self.tableArray = [[NSMutableArray alloc]initWithArray:[self sortArray:tempArray]];
        [self.tableView reloadData];
    }
}

- (NSArray *)sortArray:(NSArray *)inputArray{
    NSSortDescriptor *dateDescriptor = [NSSortDescriptor
                                        sortDescriptorWithKey:@"created"
                                        ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:dateDescriptor];
    NSArray *sortedArray = [inputArray
                            sortedArrayUsingDescriptors:sortDescriptors];
    return sortedArray;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)showProgressHUD {
    [ProgressHUD show:NSLocalizedString(@"retrievingdata", @"") Interaction:NO];
}

- (void)menuButtonAction {
    //[self showHideRightMenu];
    disableTableView = !disableTableView;
    self.tableView.userInteractionEnabled = disableTableView;

    [[NSNotificationCenter defaultCenter]postNotificationName:@"toggleMenuVisibility" object:nil];
}

- (CGFloat)getHeightOfString:(NSString *)labelText{
    
    UIFont *font = FONT_NORMAL(16);
    if (IS_IPAD) {
        font = FONT_NORMAL(22);
    }
    CGSize sizeOfText = [labelText boundingRectWithSize: CGSizeMake( self.view.bounds.size.width - 30,CGFLOAT_MAX)
                                                options: (NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                             attributes: [NSDictionary dictionaryWithObject:font
                                                                                     forKey:NSFontAttributeName]
                                                context: nil].size;
    
    return sizeOfText.height + 50;
    
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

- (IntroViewController *)IntroViewController{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    IntroViewController *view = (IntroViewController *)[story instantiateViewControllerWithIdentifier:@"IntroViewController"];
    return view;
}
- (void)pushToLoginView{
    [self presentViewController:[self IntroViewController] animated:YES completion:nil];
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

#pragma mark - textfield delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    CGRect rect = self.view.frame;
    rect.origin.y = -150;
    [UIView animateWithDuration:1.0 animations:^{
        [self.view setFrame:rect];
    }];
}

#pragma mark - pickerview delegate

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
            }else if (pickerView.tag == 4){
                count = [yearsArray count];
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
            }else if (pickerView.tag == 4){
                year = [NSString stringWithFormat:@"%@", [yearsArray objectAtIndex:row]];
            }
            break;
        case 1:
            if (pickerView.tag == 4){
                month = [NSString stringWithFormat:@"%@", [monthsArray objectAtIndex:row]];
            }
            break;
        case 2:
            if (pickerView.tag == 4){
                day = [NSString stringWithFormat:@"%@", [daysArray objectAtIndex:row]];
            }
            break;
    }
    
    birthdateTextField.text = [NSString stringWithFormat:@"%@ %@ %@", day, month, year];
}

#pragma mark - table view delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.tableArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return TABLEVIEW_CELL_HEIGHT;
}

- (ConsultationListCustomCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *cellIdentifier = [NSString stringWithFormat:@"S%1ldR%1ld",(long)indexPath.section,(long)indexPath.row];
    ConsultationListCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
        cell = (ConsultationListCustomCell *)[[ConsultationListCustomCell alloc]
                                              initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    if ([self.tableArray count] > 0) {
        NSDictionary *tempDic = [self.tableArray objectAtIndex:indexPath.row];
        
        //date
        NSDictionary *dic = tempDic.answersArray.lastObject;
        NSString *dateString = dic.created;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *startDate = [[NSDate alloc] init];
        startDate = [dateFormatter dateFromString:dateString];
        //current date
        NSDateFormatter *currentDateFormatter = [[NSDateFormatter alloc]init];
        [currentDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *endDate = [NSDate date];
        cell.dateLabel.text = [NSString stringWithFormat:@"%@",
                               [TimeAgoViewController timeIntervalWithStartDate:startDate withEndDate:endDate]];
        //category
        NSArray *medicalSectionArray = [Database selectFromMedicalSectionWithID:tempDic.medical_section_id WithFilePath:[Database getDbFilePath]];
        if([medicalSectionArray count] > 0)
            cell.categoryLabel.text = [NSString stringWithFormat:@"%@",
                                       [[medicalSectionArray objectAtIndex:0]objectForKey:@"name"]];
        
        if (tempDic.medical_section_id == 0)
            cell.categoryLabel.text = NSLocalizedString(@"soalAzPezeshk", @"");
        
        //title
        dic = tempDic.answersArray.firstObject;
        cell.mainTitleLabel.text = dic.messageText;
        
        NSInteger counter = 0;
        //NSLog(@"%ld", (unsigned long)[tempDic.answersArray count]);
        for (int i = 0; i < [tempDic.answersArray count]; i++) {
            if (tempDic.is_user_message == 0) {
                counter++;
            }
        }
        //counter
        cell.counterLabel.text = [NSString stringWithFormat:@"%ld", (long)counter];
        
        //lock status
        if (tempDic.is_closed == 0) {
            cell.lockStausImage.image = [UIImage imageNamed:@"list - opentab.png"];
        }else if (tempDic.is_closed == 1){
            cell.lockStausImage.image = [UIImage imageNamed:@"list - lockedtab.png"];
        }
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *tempDic = [self.tableArray objectAtIndex:indexPath.row];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ConsultationDetailViewController *view = (ConsultationDetailViewController *)[story instantiateViewControllerWithIdentifier:@"ConsultationDetailViewController"];
    view.dictionary = tempDic;
    [self.navigationController pushViewController:view animated:YES];
    
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

- (void)fetchConsultationsFromServer{
    [ProgressHUD show:@""];
    NSDictionary *userpassDic = [GetUsernamePassword getUsernamePassword];
    NSDictionary *params;
    if ([userpassDic count] > 1) {
        params = @{@"username":[userpassDic objectForKey:@"username"]/*@"09191234072"*/,
                   @"password":[userpassDic objectForKey:@"password"]/*@“123456”*/,
                   @"debug":@"1",
                   @"unit_id": @"3"
                   };
    }else{
        params = @{@"username":@"",
                   @"password":@"",
                   @"debug":@"1",
                   @"unit_id": @"3"
                   };
        
    }
    /*http://213.233.175.250:8081/web_services/v3/posts/timeline*/
    
    //    KeychainWrapper *keychainWrapper = [[KeychainWrapper alloc]init];
    //    NSString *username = [keychainWrapper myObjectForKey:(__bridge id)(kSecAttrDescription)];
    //    NSString *password = [keychainWrapper myObjectForKey:(__bridge id)(kSecAttrService)];
    NSString *url = [NSString stringWithFormat:@"%@consultation_list_with_voice", BaseURL];
    
    if (!isBusyNow) {
        isBusyNow = YES;
        [refreshControl endRefreshing];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        manager.requestSerializer.timeoutInterval = 45;;
        [manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
            [ProgressHUD dismiss];
            isBusyNow = NO;
            noMoreData = NO;
            NSDictionary *tempDic = (NSDictionary *)responseObject;
            NSString *login =  [tempDic objectForKey:@"login"];
            if ([login integerValue]  == 0) {
               
                [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"isPasswordChanged"];
                NSString *message;
                if ([userpassDic count] == 0) {
                    message = NSLocalizedString(@"notLogin", @"");
                } else {
                    message = NSLocalizedString(@"passwordIsChanged", @"");
                }

                 
                return;
            }
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:responseObject];
            [[NSUserDefaults standardUserDefaults]setObject:data forKey:@"consultation"];
            [self populateTableViewArray];
            [ProgressHUD dismiss];
            isBusyNow = NO;
            
            //NSString *firstTime = [[NSUserDefaults standardUserDefaults]objectForKey:@"consultaionFirstTime"];
            if ([self.tableArray count] == 0) {
                //[[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"consultaionFirstTime"];
                guideImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 70, screenWidth, screenHeight - 70)];
                guideImageView.image = [UIImage imageNamed:@"guide.png"];
                guideImageView.userInteractionEnabled = YES;
                UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissGuideView)];
                tap1.delegate = self;
                //[guideImageView addGestureRecognizer:tap1];
                [self.view addSubview:guideImageView];
                
                giftImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 70, screenWidth, screenHeight - 70)];
                giftImageView.userInteractionEnabled = YES;
                UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissGuideView)];
                tap2.delegate = self;
                //[giftImageView addGestureRecognizer:tap2];
                giftImageView.image = [UIImage imageNamed:@"popupGift.png"];
                [self.view addSubview:giftImageView];

            }
            
            UIButton *newQuestionButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - 110, screenHeight - 110, 100, 100)];
            [newQuestionButton addTarget:self action:@selector(newQuestionButtonAction) forControlEvents:UIControlEventTouchUpInside];
            [newQuestionButton setBackgroundImage:[UIImage imageNamed:@"Porsesh"] forState:UIControlStateNormal];
            [self.view addSubview:newQuestionButton];

            
        } failure:^(NSURLSessionTask *operation, NSError *error) {
             
            [ProgressHUD dismiss];
            isBusyNow = NO;
        }];
    }
}

- (void)getAvailableCountFromServer{
    [packageListView removeFromSuperview];
    [confirmationView removeFromSuperview];
    [confirmationViewBGView removeFromSuperview];
    NSString *url = [NSString stringWithFormat:@"%@availableCount", BaseURL];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    NSDictionary *userpassDic = [GetUsernamePassword getUsernamePassword];
    NSDictionary *params;
    if ([userpassDic count] > 1) {
        params = @{@"username":[userpassDic objectForKey:@"username"]/*@"09191234072"*/,
                   @"password":[userpassDic objectForKey:@"password"]/*@“123456”*/,
                   @"user_id":[GetUsernamePassword getUserId]/*@"6144"*/,
                   @"unit_id": @"3"
                   };
    }else{
        params = @{@"username":@"",
                   @"password":@"",
                   @"user_id":@""/*@"6144"*/,
                   @"unit_id": @"3"
                   };
    }
    
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        
        NSDictionary *dict = responseObject;
        if ([[dict objectForKey:@"status"]integerValue] == -1) {
            availablePackageCounts = 0;
            [questionCountButton setTitle:@"0" forState:UIControlStateNormal];
        } else {
            availablePackageCounts = [[dict objectForKey:@"available_count"]integerValue];
            [questionCountButton setTitle:[NSString stringWithFormat:@"%@", [dict objectForKey:@"available_count"]] forState:UIControlStateNormal];
        }
        
        
        questionCountButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        //self.questionNumber.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        [self.view setNeedsDisplay];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:[NSString stringWithFormat:@"%@", [error localizedDescription]] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

- (void)getPackagesFromServer{
    [ProgressHUD show:@""];
    [finishpackageView removeFromSuperview];
    [packageListView removeFromSuperview];
    [confirmationView removeFromSuperview];
    [confirmationViewBGView removeFromSuperview];
    NSString *url = [NSString stringWithFormat:@"%@listPackage", BaseURL];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        [ProgressHUD dismiss];
        packageListView = [[UIView alloc]initWithFrame:CGRectMake(20, screenHeight/3, screenWidth - 40, 200)];
        packageListView.backgroundColor = [UIColor whiteColor];
        NSDictionary *dict = responseObject;
        packegesArray = [[NSMutableArray alloc]init];
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 300, 25)];
        titleLabel.font = FONT_NORMAL(11);
        titleLabel.text = @"بسته مورد نظر خود را انتخاب کنید";
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
            button.tag = ([[dict objectForKey:@"packageList"]count] - 1) - i;
            //button.tag = [[[tempDic objectForKey:@"Package"]objectForKey:@"id"]integerValue];
            [button addTarget:self action:@selector(packageButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [packageListView addSubview:button];
            UILabel *aLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, yPositionOfLabel - 5, 120, 45)];
            aLabel.font = FONT_NORMAL(13);
            aLabel.numberOfLines = 2;
            aLabel.textAlignment = NSTextAlignmentRight;
            NSInteger price = [[[tempDic objectForKey:@"Package"]objectForKey:@"price"]integerValue];
            price /= 10;
            aLabel.text = [NSString stringWithFormat:@"%ldتومان\n%@", (long)price, [[tempDic objectForKey:@"Package"] objectForKey:@"description"]];
            aLabel.tag = ([[dict objectForKey:@"packageList"]count] - 1) - i;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(packageLabelAction:)];
            aLabel.userInteractionEnabled = YES;
            [aLabel addGestureRecognizer:tap];
            [packageListView addSubview:aLabel];
            
            yPositionOfLabel += 50;
        }
        UIButton *doneButtn = [CustomButton initButtonWithTitle:@"پرداخت با شارژ همراه اول" withTitleColor:[UIColor whiteColor] withBackColor:[UIColor colorWithRed:26/255.0 green:184/255.0 blue:180/255.0 alpha:1.0]
                                                      withFrame:CGRectMake(packageListView.frame.size.width - 190, yPositionOfLabel + 20, 180, 25)];
        [doneButtn addTarget:self action:@selector(packageConfirmatation) forControlEvents:UIControlEventTouchUpInside];
        [packageListView addSubview:doneButtn];
        UIButton *backButton = [CustomButton initButtonWithTitle:@"بازگشت" withTitleColor:[UIColor whiteColor] withBackColor:[UIColor grayColor] withFrame:CGRectMake(20, yPositionOfLabel + 20, 60, 25)];
        [backButton addTarget:self action:@selector(closePackageList) forControlEvents:UIControlEventTouchUpInside];
        [packageListView addSubview:backButton];
        CGRect rect = packageListView.frame;
        rect.size.height = yPositionOfLabel + 80;
        [packageListView setFrame:rect];
        packageListView.layer.cornerRadius = 14;
        packageListView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        packageListView.layer.borderWidth = 3.0;
        [self.view addSubview:packageListView];
        
        yPositionOfSelectedButton = 30;
        [selectLabel removeFromSuperview];
        selectLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, yPositionOfSelectedButton, packageListView.frame.size.width - 19, 45)];
        selectLabel.backgroundColor = [UIColor clearColor];
        selectLabel.layer.cornerRadius = 5;
        selectLabel.layer.borderWidth = 1.0;
        selectLabel.layer.borderColor = [UIColor colorWithRed:7/255.0 green:125/255.0 blue:195/255.0 alpha:1.0].CGColor;
        [packageListView addSubview:selectLabel];
        selectedPackageId = [[[[packegesArray objectAtIndex:0] objectForKey:@"Package"]objectForKey:@"id"]integerValue];
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [ProgressHUD dismiss];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:[NSString stringWithFormat:@"%@", [error localizedDescription]] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}
- (void)packageConfirmatation
{
    [packageListView removeFromSuperview];
    confirmationViewBGView = [[UIView alloc]initWithFrame:self.view.bounds];
    confirmationViewBGView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:confirmationViewBGView];
    confirmationView = [[UIView alloc]initWithFrame:CGRectMake(20, screenHeight/3, screenWidth - 40, 150)];
    confirmationView.backgroundColor = [UIColor whiteColor];
    confirmationView.layer.cornerRadius = 14;
    confirmationView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    confirmationView.layer.borderWidth = 3.0;
    [confirmationViewBGView addSubview:confirmationView];
    
    UIButton *backButtonConfirmation = [CustomButton initButtonWithTitle:@"<       " withTitleColor:[UIColor blackColor] withBackColor:[UIColor whiteColor] withFrame:CGRectMake(0, 10, 80, 25)];
    [backButtonConfirmation addTarget:self action:@selector(backButtonConfirmationAction) forControlEvents:UIControlEventTouchUpInside];
    [confirmationView addSubview:backButtonConfirmation];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 30, confirmationView.frame.size.width - 40, 25)];
    titleLabel.font = FONT_NORMAL(11);
    titleLabel.textColor = [UIColor redColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"تیم پزشکان سلامت همراه در خدمت شما هستند";
    [confirmationView addSubview:titleLabel];
    
    UILabel *titleLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(20, 50, confirmationView.frame.size.width - 40, 25)];
    titleLabel2.font = FONT_NORMAL(11);
    titleLabel2.textAlignment = NSTextAlignmentCenter;
    titleLabel2.text = @"شما بسته زیر راانتخاب کرده اید:";
    [confirmationView addSubview:titleLabel2];
    
    UIButton *button = [CustomButton initButtonWithTitle:
                        [NSString stringWithFormat:@"%@", [[[packegesArray objectAtIndex:selectedPackgeByUser] objectForKey:@"Package"]objectForKey:@"name"]]
                                          withTitleColor:[UIColor whiteColor]
                                           withBackColor:[packageColorArray objectAtIndex:selectedPackgeByUser]
                                               withFrame:CGRectMake(packageListView.frame.size.width - 100,
                                                                    80, 90, 25)];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [confirmationView addSubview:button];
    UILabel *aLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 80 - 5, 120, 45)];
    aLabel.font = FONT_NORMAL(11);
    aLabel.numberOfLines = 2;
    aLabel.textAlignment = NSTextAlignmentRight;
    NSInteger price = [[[[packegesArray objectAtIndex:selectedPackgeByUser] objectForKey:@"Package"]objectForKey:@"price"]integerValue];
    price /= 10;
    aLabel.text = [NSString stringWithFormat:@"%ldتومان\n%@ماهه%@ مشاوره", (long)price, [[[packegesArray objectAtIndex:selectedPackgeByUser] objectForKey:@"Package"] objectForKey:@"duration"], [[[packegesArray objectAtIndex:selectedPackgeByUser] objectForKey:@"Package"] objectForKey:@"question_count"]];
    [confirmationView addSubview:aLabel];
    
    UIButton *doneButtn = [CustomButton initButtonWithTitle:@"تایید" withTitleColor:[UIColor whiteColor] withBackColor:[UIColor colorWithRed:26/255.0 green:184/255.0 blue:180/255.0 alpha:1.0]
                                                  withFrame:CGRectMake(confirmationView.frame.size.width/2 - 60, 120, 120, 25)];
    [doneButtn addTarget:self action:@selector(buyPackage) forControlEvents:UIControlEventTouchUpInside];
    [confirmationView addSubview:doneButtn];
    
}

- (void)backButtonConfirmationAction{
    [confirmationView removeFromSuperview];
    [packageListView removeFromSuperview];
    [confirmationViewBGView removeFromSuperview];
    selectedPackgeByUser = 0;
    selectedPackageId = 1000;
}
- (void)buyPackage{
    if (selectedPackageId == 1000) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"لطفا ابتدا بسته ی مورد نظر را انتخاب کنید" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        [ProgressHUD show:@"" Interaction:NO];
        //    Start to Call Webservice feeds_old
        NSString *url = [NSString stringWithFormat:@"%@buyPackage", BaseURL];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes =
        [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        NSDictionary *userpassDic = [GetUsernamePassword getUsernamePassword];
        NSDictionary *params = @{@"username":[userpassDic objectForKey:@"username"]/*@"09191234072"*/,
                                 @"password":[userpassDic objectForKey:@"password"]/*@“123456”*/,
                                 @"user_id":[GetUsernamePassword getUserId]/*@"6144"*/,
                                 @"package_id":[NSNumber numberWithInteger:selectedPackageId],
                                 @"unit_id": @"3"
                                 };
        
        [manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
            [ProgressHUD dismiss];
            [confirmationView removeFromSuperview];
            [confirmationViewBGView removeFromSuperview];
            [packageListView removeFromSuperview];
            [packageBuyView removeFromSuperview];
            selectedPackgeByUser = 0;
            availablePackageCounts = selectedPackageId;
            selectedPackageId = 1000;
            NSDictionary *dict = responseObject;
            packageBuyView = [[UIView alloc]initWithFrame:CGRectMake(20, 150, screenWidth - 40, 150)];
            packageBuyView.backgroundColor = [UIColor whiteColor];
            packageBuyView.layer.cornerRadius = 6;
            packageBuyView.layer.borderColor = [UIColor lightGrayColor].CGColor;
            packageBuyView.layer.borderWidth = 3.0;
            [self.view addSubview:packageBuyView];
            
            UILabel *aLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, packageBuyView.frame.size.width - 20, 65)];
            aLabel.font = FONT_NORMAL(11);
            aLabel.numberOfLines = 2;
            aLabel.textAlignment = NSTextAlignmentCenter;
            aLabel.text = [NSString stringWithFormat:@"%@", [dict objectForKey:@"message"]];
            [packageBuyView addSubview:aLabel];
            
            UIButton *backButton = [CustomButton initButtonWithTitle:@"بازگشت" withTitleColor:[UIColor whiteColor] withBackColor:[UIColor colorWithRed:7/255.0 green:125/255.0 blue:195/255.0 alpha:1.0] withFrame:CGRectMake(packageBuyView.frame.size.width/2 - 35, aLabel.frame.origin.y + aLabel.frame.size.height + 20, 70, 25)];
            [backButton addTarget:self action:@selector(closePackageList) forControlEvents:UIControlEventTouchUpInside];
            [packageBuyView addSubview:backButton];
            [self getAvailableCountFromServer];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [ProgressHUD dismiss];
            [confirmationView removeFromSuperview];
            [confirmationViewBGView removeFromSuperview];
            [packageListView removeFromSuperview];
            selectedPackgeByUser = 0;
            selectedPackageId = 1000;
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:[NSString stringWithFormat:@"%@", [error localizedDescription]] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            }];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }];
    }
}

- (void)packageButtonAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    selectedPackgeByUser = btn.tag;
    selectedPackageId = [[[[packegesArray objectAtIndex:btn.tag] objectForKey:@"Package"]objectForKey:@"id"]integerValue];
    yPositionOfSelectedButton = 30 + btn.tag * 50;
    [selectLabel removeFromSuperview];
    selectLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, yPositionOfSelectedButton, packageListView.frame.size.width - 19, 45)];
    selectLabel.backgroundColor = [UIColor clearColor];
    selectLabel.layer.cornerRadius = 5;
    selectLabel.layer.borderWidth = 1.0;
    selectLabel.layer.borderColor = [UIColor colorWithRed:7/255.0 green:125/255.0 blue:195/255.0 alpha:1.0].CGColor;
    [packageListView addSubview:selectLabel];
    
}

- (void)packageLabelAction:(UITapGestureRecognizer *)sender{
    UILabel *btn = (UILabel *)sender.view;
    selectedPackgeByUser = btn.tag;
    selectedPackageId = [[[[packegesArray objectAtIndex:btn.tag] objectForKey:@"Package"]objectForKey:@"id"]integerValue];
    yPositionOfSelectedButton = 30 + btn.tag * 50;
    [selectLabel removeFromSuperview];
    selectLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, yPositionOfSelectedButton, packageListView.frame.size.width - 19, 45)];
    selectLabel.backgroundColor = [UIColor clearColor];
    selectLabel.layer.cornerRadius = 5;
    selectLabel.layer.borderWidth = 1.0;
    selectLabel.layer.borderColor = [UIColor colorWithRed:7/255.0 green:125/255.0 blue:195/255.0 alpha:1.0].CGColor;
    [packageListView addSubview:selectLabel];
    
}

- (void)closePackageList{
    [packageListView removeFromSuperview];
    [packageBuyView removeFromSuperview];
    selectedPackageId = 1000;
    [self getAvailableCountFromServer];
}

- (void)sendProfileDataToServer{
    //dismiss all textfield
    [self tapForFillProfile:nil];
    
    if ([sexTextField.text length] == 0) {
        [ShakeAnimation startShake:sexTextField];
        return;
    }
    
    if ([weightTextField.text length] == 0) {
        [ShakeAnimation startShake:weightTextField];
        return;
    }
    
    if ([heightTextField.text length] == 0) {
        [ShakeAnimation startShake:heightTextField];
        return;
    }
    
    NSString *birthdateString = birthdateTextField.text;
    if (([birthdateTextField.text length] < 5) ||
        [birthdateTextField.text containsString:@"null"] ||
        [day length] == 0 ||
        [month length] == 0 ||
        [year length] == 0){
        [ShakeAnimation startShake:birthdateTextField];
        return;
    }else{
        NSInteger monthNumber = [monthsArray indexOfObject:month] + 1;
        birthdateString = [NSString stringWithFormat:@"%@-%ld-%@", year, (long)monthNumber, day];
        //
        NSString *dateStr = birthdateString;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *birthdateDate = [[NSDate alloc] init];
        birthdateDate = [dateFormatter dateFromString:dateStr];
        birthdateString = [ConvertToPersianDate ConvertToGregorianDateWithYear:[year integerValue]
                                                                         month:monthNumber
                                                                           day:[day integerValue]];
    }
    
    
    [ProgressHUD show:@"" Interaction:NO];
    NSDictionary *userpassDic = [GetUsernamePassword getUsernamePassword];
    NSDictionary *params = @{@"username":[userpassDic objectForKey:@"username"]/*@"09191234072"*/,
                             @"password":[userpassDic objectForKey:@"password"]/*@"123456"*/,
                             @"profile_id":[GetUsernamePassword getProfileId],
                             @"gender":[self GenderConversionToEnglish:sexTextField.text],
                             @"birthdate": birthdateString,
                             @"height":heightTextField.text,
                             @"weight":weightTextField.text,
                             @"debug":@"1",
                             @"unit_id": @"3"};
    
    NSString *url = [NSString stringWithFormat:@"%@update_important_factors", BaseURL];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    manager.requestSerializer.timeoutInterval = 45;;
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        [ProgressHUD dismiss];
        NSDictionary *dict = responseObject;
        NSString *login =  [dict objectForKey:@"login"];
        NSString *success = [dict objectForKey:@"success"];
        NSString *error_code = [dict objectForKey:@"error_code"];
        //NSString *datetime = [dict objectForKey:@"datetime"];
        
        if ([login integerValue]  == 1) {
            
            if ([success  integerValue] == 1) {
                [self fetchProfileFromServer];
                [self dismissViewControllerAnimated:YES completion:nil];
                 
                
                [self pushToNewQuestion];
                
            }else // when there is a error
            {
                NSString *codeStr = @"خطا در بروز رسانی اطلاعات";;
                
                if ([error_code integerValue] == 0) {
                    codeStr = @"خطا در بروز رسانی اطلاعات";
                }else if ([error_code integerValue] == 1)
                {
                    codeStr = @"مشکل داخلی سرور";
                }else if ([error_code integerValue] == 2)
                {
                    codeStr = @"جنسیت به درستی وارد نشده است";
                }else if ([error_code integerValue] == 3)
                {
                    codeStr = @"وضعیت تاهل به درستی وارد نشده است";
                }else if ([error_code integerValue] == 4)
                {
                    codeStr = @"تاریخ تولد به درستی وارد نشده است";
                }else if ([error_code integerValue] == 5)
                {
                    codeStr = @"قد به درستی وارد نشده است";
                }else if ([error_code integerValue] == 6)
                {
                    codeStr = @"نوع گروه خونی به درستی انتخاب نشده است";
                }else if ([error_code integerValue] == 7)
                {
                    codeStr = @"ایمیل به درستی وارد نشده است";
                }else if ([error_code integerValue] == 8)
                {
                    codeStr = @"این حساب کاربری حذف شده است";
                }
                
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:codeStr preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                    // ////NSLog(@"You pressed button OK");
                }];
                
                [alert addAction:defaultAction];
                
                [self presentViewController:alert animated:YES completion:nil];
            }
        }else
        {
            // when username or password is invalid.
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"رمز عبور شما تغییر کرده است" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                // ////NSLog(@"You pressed button OK");
            }];
            
            [alert addAction:defaultAction];
            
            [self presentViewController:alert animated:YES completion:nil];
            
            
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [ProgressHUD dismiss];
         
    }];
}

- (void)fetchProfileFromServer{
    NSDictionary *userpassDic = [GetUsernamePassword getUsernamePassword];
    NSDictionary *params;
    if ([userpassDic count] > 1) {
        
        params = @{@"username":[userpassDic objectForKey:@"username"]/*@"09191234072"*/,
                   @"password":[userpassDic objectForKey:@"password"]/*@"123456"*/,
                   @"debug":@"1",
                   @"unit_id": @"3"};
    }else{
        params = @{@"username":@"",
                   @"password":@"",
                   @"debug":@"1",
                   @"unit_id": @"3"};
        
    }
    NSString *url = [NSString stringWithFormat:@"%@profile", BaseURL];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    manager.requestSerializer.timeoutInterval = 45;;
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        
        NSDictionary *dict = responseObject;
        NSString *login =  [dict objectForKey:@"login"];
        
        if ([login integerValue]  == 0) {
            [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"isNotLoggedin"];
            [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"isPasswordChanged"];
            
            return;
        }
        
        //        NSDictionary *medical_section = [dict objectForKey:@"medical_sections"];
        //        NSDictionary *tags = [dict objectForKey:@"tags"];
        //        NSDictionary *profiles = [dict objectForKey:@"profiles"];
        NSString *datetime = [dict objectForKey:@"datetime"];
        NSDictionary *profileDic = [[dict objectForKey:@"profiles"]objectAtIndex:0];
        
        if ([login integerValue]  == 1) {
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"profileData"];
            [[NSUserDefaults standardUserDefaults]setObject:datetime forKey:@"dateTime"];
           
            NSData *profileData = [NSKeyedArchiver archivedDataWithRootObject:profileDic];
            [[NSUserDefaults standardUserDefaults]setObject:profileData forKey:@"profileData"];
            
        }else{
            // when username or password is invalid.
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"رمز عبور شما تغییر کرده است" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                // ////NSLog(@"You pressed button OK");
            }];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
         
    }];
}

@end
