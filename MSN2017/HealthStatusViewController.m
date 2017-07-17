//
//  HealthStatusViewController.m
//  MSN
//
//  Created by Yarima on 5/14/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "HealthStatusViewController.h"
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
#import "KeychainWrapper.h"
#import "UUChart.h"
#import "ShakeAnimation.h"
#import "NSDictionary+profile.h"
#import "ConvertToPersianDate.h"
#import "DocumentDirectoy.h"
#import "EditProfileViewController.h"
#import "FavoritesViewController.h"
#import "AboutViewController.h"
#import "FavoritesViewController.h"
#import "AboutViewController.h"
#import "ConvertToPersianDate.h"
#import "UIImage+Extra.h"
#import "LoginViewController.h"
#import "IntroViewController.h"
#import "SearchViewController.h"
@interface HealthStatusViewController()<UUChartDataSource, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
     
    BOOL    isBusyNow;
    UIImageView *profileImageView;
    UIScrollView *scrollView;
    NSMutableDictionary *profileDictionary;
    NSMutableArray *weightsArray;
    NSMutableArray *BGArray;
    NSMutableArray *BPArray;
    CGFloat lastWeight;
    CGFloat lastHeight;
    CGFloat lastBPUp;
    CGFloat lastBPLow;
    CGFloat lastBG;
    UUChart *chartView;
    BOOL isBGSelected;
    BOOL isBPSelected;
    BOOL isWeightSelected;
    UIButton *BGButtonChart;
    UIButton *weightButtonChart;
    UIButton *BPButtonChart;
    UIView *BGAlertView;
    UIView *BPAlertView;
    UIView *weightAlertView;
    UIView *heightAlertView;
    UITextField *BGTextField;
    UITextField *BPTextFieldup;
    UITextField *BPTextFielddown;
    UITextField *weightTextField;
    UITextField *heightTextField;
    UIView *galleryCameraView;
    UILabel *nameLabelTop;
    UILabel *ageLabelTop;
    UILabel *bloodLabelTop;
    UILabel *sexLabelTop;
    UILabel *BMILabelTop;
    UILabel *weightLabelTop;
    UIButton *bloodGlucoseButtonIcon;
    UIButton *bloodPressureButtonIcon;
    UIButton *weightButtonIcon;
    UILabel *heightLabelMedicalInfo;
    UILabel *weightLabelMedicalInfo;
    UILabel *BPLabelMedicalInfo;
    UILabel *BGLabelMedicalInfo;
    UIImage *chosenImage;
}
@end

@implementation HealthStatusViewController

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = YES;
    [super viewWillAppear:YES];
    
     
    [self loadProfileDictionary];
    
    //[self deleteUnnecessaryImagesInDocuments];
    
    //NSLog(@"%@", profileDictionary);
    [self makeTopBar];
    [self makeScrollView];
    
    if ([self hasConnectivity]) {
        [self fetchProfileFromServer];
    } else {
         
    }
    /*
    CGFloat a = [self addTwoPoints:100.32135 point2:200.35434555 withCompletionHandler:^CGFloat(CGFloat result) {
        return result;
    }];
    
    
    
    NSString *testStr = [self methodNameWithParams:@"arash" lastname:@"ZJ" andCompletionHandler:^NSString *(NSString *nameAndFamily) {
        return nameAndFamily;
    }];
    
    NSString *str1 = [self methodNameWithParams:@"A" lastname:@"ZJ" andCompletionHandler:^NSString *(NSString *nameAndFamily) {
        return nameAndFamily;
    }];
    
    [self addNumber:2 withNumber:5 andCompletionHandler:^(int result) {
        //NSLog(@"%d", result);
    }];
     */
}

-(void)addNumber:(int)number1 withNumber:(int)number2 andCompletionHandler:(void (^)(int result))completionHandler{
    int result = number1 + number2;
    completionHandler(result);
}
-(NSString *)methodNameWithParams:(NSString *)firstname lastname:(NSString *)lastname
             andCompletionHandler:(NSString *(^)(NSString *nameAndFamily))completionHandler{
    
    // When the callback should happen:
    NSString *nAndF = [NSString stringWithFormat:@"%@ %@", firstname, lastname];
    return completionHandler(nAndF);
}

- (CGFloat)addTwoPoints:(CGFloat)point1 point2:(CGFloat)point2
  withCompletionHandler:(CGFloat (^)(CGFloat result))completionHandler{
    
    CGFloat point = point2 + point1;
    
    return completionHandler(point);
    
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
    titleLabel.text = NSLocalizedString(@"healthStatus", @"");
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    //[topView addSubview:titleLabel];
    //54 × 39
    UIButton *menuButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - 60, topViewHeight/2 - 20, 54, 54)];
    //menuButton.backgroundColor = [UIColor redColor];
    UIImage *img = [UIImage imageNamed:@"menu side"];
    [menuButton setImage:[img imageByScalingProportionallyToSize:CGSizeMake(54/2,39/2)] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(menuButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:menuButton];
    
    UIButton *editButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - 140/*90*/, 29 , 20, 20)];
    [editButton setBackgroundImage:[UIImage imageNamed:@"edit.png"] forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(editButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:editButton];
    
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

- (void)makeScrollView{
    
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 70, screenWidth, screenHeight - 70)];
    scrollView.backgroundColor = [UIColor whiteColor];
    scrollView.contentSize = CGSizeMake(screenWidth, 2000);
    scrollView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideAllViews)];
    [scrollView addGestureRecognizer:tap];
    [self.view addSubview:scrollView];
    
    profileImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 40, 50, 50)];
    profileImageView.layer.cornerRadius = 25;
    profileImageView.clipsToBounds = YES;
    profileImageView.image = [UIImage imageNamed:@"icon upload ax"];
    profileImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(profileImageViewAction)];
    [profileImageView addGestureRecognizer:tap2];
    [self.view addSubview:profileImageView];
    
    [self loadImageFileFromDocument];
    
    
    nameLabelTop =[[UILabel alloc]initWithFrame:CGRectMake(10, profileImageView.frame.size.height + 40, 150, 25)];
    nameLabelTop.font = FONT_NORMAL(15);
    if ([profileDictionary count] == 0) {
        nameLabelTop.text = NSLocalizedString(@"noName", @"");
    } else {
        nameLabelTop.text = [NSString stringWithFormat:@"%@ %@", profileDictionary.first_nameProfile, profileDictionary.last_nameProfile];
    }
    
    nameLabelTop.textColor = [UIColor blackColor];
    nameLabelTop.textAlignment = NSTextAlignmentLeft;
    nameLabelTop.minimumScaleFactor = 0.5;
    nameLabelTop.backgroundColor = [UIColor clearColor];
    nameLabelTop.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:nameLabelTop];
    
    CGFloat yPostOFLabel = 10;
    UILabel *ageLabelTitle =[[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 100, yPostOFLabel, 95, 25)];
    ageLabelTitle.font = FONT_NORMAL(15);
    ageLabelTitle.text = NSLocalizedString(@"age", @"");
    ageLabelTitle.textColor = [UIColor blackColor];
    ageLabelTitle.textAlignment = NSTextAlignmentRight;
    [scrollView addSubview:ageLabelTitle];
    
    ageLabelTop =[[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 150, yPostOFLabel, 40, 25)];
    ageLabelTop.font = FONT_NORMAL(15);
    if (profileDictionary.ageProfile == -1 || [profileDictionary count] == 0)
        ageLabelTop.text = @"?";
    else
        ageLabelTop.text = [NSString stringWithFormat:@"%ld", (long)profileDictionary.ageProfile];
    ageLabelTop.textColor = [UIColor blackColor];
    ageLabelTop.textAlignment = NSTextAlignmentRight;
    [scrollView addSubview:ageLabelTop];
    
    UILabel *bloodLabelTitle =[[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 100, yPostOFLabel + 30, 95, 25)];
    bloodLabelTitle.font = FONT_NORMAL(15);
    bloodLabelTitle.text = NSLocalizedString(@"bloodGroup", @"");
    bloodLabelTitle.textColor = [UIColor blackColor];
    bloodLabelTitle.textAlignment = NSTextAlignmentRight;
    [scrollView addSubview:bloodLabelTitle];
    
    bloodLabelTop =[[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 150, yPostOFLabel + 30, 45, 25)];
    bloodLabelTop.font = FONT_NORMAL(15);
    if ([profileDictionary.blood_typeProfile isEqualToString:@"n"] || [profileDictionary count] == 0) {
        bloodLabelTop.text = @"?";
    } else {
        bloodLabelTop.text = profileDictionary.blood_typeProfile;
    }
    
    bloodLabelTop.textColor = [UIColor blackColor];
    bloodLabelTop.textAlignment = NSTextAlignmentRight;
    [scrollView addSubview:bloodLabelTop];
    
    UILabel *sexLabelTitle =[[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 100, yPostOFLabel + 60, 95, 25)];
    sexLabelTitle.font = FONT_NORMAL(15);
    sexLabelTitle.text = NSLocalizedString(@"sex", @"");
    sexLabelTitle.textColor = [UIColor blackColor];
    sexLabelTitle.textAlignment = NSTextAlignmentRight;
    [scrollView addSubview:sexLabelTitle];
    
    sexLabelTop =[[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 150, yPostOFLabel + 60, 45, 25)];
    sexLabelTop.font = FONT_NORMAL(15);
    NSString *sex = @"?";//NSLocalizedString(@"unknown", @"");
    if (profileDictionary.sexProfile != (id)[NSNull null]) {
        if ([profileDictionary.sexProfile isEqualToString:@"f"]) {
            sex = NSLocalizedString(@"woman", @"");
        }else if ([profileDictionary.sexProfile isEqualToString:@"m"]){
            sex = NSLocalizedString(@"man", @"");
        }
    }
    sexLabelTop.text = sex;
    sexLabelTop.textColor = [UIColor blackColor];
    sexLabelTop.minimumScaleFactor = 0.5;
    sexLabelTop.adjustsFontSizeToFitWidth = YES;
    sexLabelTop.textAlignment = NSTextAlignmentRight;
    [scrollView addSubview:sexLabelTop];
    
    UILabel *BMILabelTitle =[[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 100, yPostOFLabel + 90, 95, 25)];
    BMILabelTitle.font = FONT_NORMAL(15);
    BMILabelTitle.text = NSLocalizedString(@"BMI", @"");
    BMILabelTitle.textColor = [UIColor blackColor];
    BMILabelTitle.textAlignment = NSTextAlignmentRight;
    BMILabelTitle.minimumScaleFactor = 0.5;
    BMILabelTitle.adjustsFontSizeToFitWidth = YES;
    [scrollView addSubview:BMILabelTitle];
    
    [self initValuesFromProfile];
    
    BMILabelTop =[[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 150, yPostOFLabel + 90, 45, 25)];
    BMILabelTop.font = FONT_NORMAL(15);
    if ([self calculateBMIWithWeight:lastWeight Height:lastHeight] == 0 || [profileDictionary count] == 0) {
        BMILabelTop.text = @"?";
    } else {
        BMILabelTop.text = [NSString stringWithFormat:@"%2.2f", [self calculateBMIWithWeight:lastWeight Height:lastHeight]];
    }
    
    BMILabelTop.textColor = [UIColor blackColor];
    BMILabelTop.textAlignment = NSTextAlignmentRight;
    BMILabelTop.minimumScaleFactor = 0.5;
    BMILabelTop.adjustsFontSizeToFitWidth = YES;
    [scrollView addSubview:BMILabelTop];
    
    UILabel *weightLabelTitle =[[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 100, yPostOFLabel + 120, 95, 25)];
    weightLabelTitle.font = FONT_NORMAL(15);
    weightLabelTitle.text = NSLocalizedString(@"weight", @"");
    weightLabelTitle.textColor = [UIColor blackColor];
    weightLabelTitle.textAlignment = NSTextAlignmentRight;
    [scrollView addSubview:weightLabelTitle];
    
    weightLabelTop =[[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 200, yPostOFLabel + 120, 120, 25)];
    weightLabelTop.font = FONT_NORMAL(15);
    CGFloat idealWeight = [profileDictionary.ideal_weightProfile floatValue];
    if (idealWeight == -90 || [profileDictionary count] == 0) {
        weightLabelTop.text = @"?";
    } else {
        weightLabelTop.text = [NSString stringWithFormat:@"%@ %2.0f %@ %2.0f",NSLocalizedString(@"between", @""),idealWeight - 3,NSLocalizedString(@"till", @""),idealWeight + 3];
    }
    
    weightLabelTop.textColor = [UIColor blackColor];
    weightLabelTop.textAlignment = NSTextAlignmentRight;
    [scrollView addSubview:weightLabelTop];
    
    UIView *horizontalLineView = [[UIView alloc]initWithFrame:CGRectMake(100, weightLabelTop.frame.origin.y + 50, screenWidth - 100, 1)];
    horizontalLineView.backgroundColor = [UIColor lightGrayColor];
    [scrollView addSubview:horizontalLineView];
    
    UIButton *newQuestionButton = [[UIButton alloc]initWithFrame:CGRectMake(20, weightLabelTop.frame.origin.y, 80, 80)];
    [newQuestionButton addTarget:self action:@selector(newQuestionButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [newQuestionButton setBackgroundImage:[UIImage imageNamed:@"Porsesh"] forState:UIControlStateNormal];
    [scrollView addSubview:newQuestionButton];

    
    [self drawHealthIconsWithYPos:weightLabelTop.frame.origin.y + 70];
}

- (void)initValuesFromProfile{
    weightsArray = [[NSMutableArray alloc]initWithArray:[self sortArray:profileDictionary.weightsArrayProfile]];
    BPArray = [[NSMutableArray alloc]initWithArray:[self sortArray:profileDictionary.BPArrayProfile]];
    BGArray = [[NSMutableArray alloc]initWithArray:[self sortArray:profileDictionary.BGArrayProfile]];
    lastWeight = [[[weightsArray firstObject]objectForKey:@"value"] floatValue];
    lastHeight = profileDictionary.heightProfile;
    lastBPUp = [[[BPArray firstObject]objectForKey:@"up_value"] floatValue];
    lastBPLow = [[[BPArray lastObject]objectForKey:@"down_value"] floatValue];
    lastBG = [[[BGArray firstObject]objectForKey:@"value"] floatValue];
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
- (void)drawHealthIconsWithYPos:(CGFloat)ypos{
    NSString *imageName = [self AdjustBloodSugerIcon:[NSString stringWithFormat:@"%2.2f", lastBG]];
    //250 × 320
    bloodGlucoseButtonIcon = [[UIButton alloc]initWithFrame:CGRectMake(2 * screenWidth/3 + 50, ypos , 250 * 0.2, 320 * 0.2)];
    [bloodGlucoseButtonIcon setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [bloodGlucoseButtonIcon addTarget:self action:@selector(bloodGlucoseButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:bloodGlucoseButtonIcon];
    
    //250 × 320
    imageName = [self AdjustBloodPressureIconWithDownValue:[NSString stringWithFormat:@"%2.2f", lastBPLow]
                                                   upValue:[NSString stringWithFormat:@"%2.2f", lastBPUp]];
    bloodPressureButtonIcon = [[UIButton alloc]initWithFrame:CGRectMake( screenWidth/2 - 20, ypos , 250 * 0.2, 320 * 0.2)];
    [bloodPressureButtonIcon setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [bloodPressureButtonIcon addTarget:self action:@selector(bloodPressureButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:bloodPressureButtonIcon];
    
    //250 × 320
    imageName = [self AdjustWeightIcon:[NSString stringWithFormat:@"%2.2f", [self calculateBMIWithWeight:lastWeight Height:lastHeight]]];
    weightButtonIcon = [[UIButton alloc]initWithFrame:CGRectMake(20, ypos , 250 * 0.2, 320 * 0.2)];
    [weightButtonIcon setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [weightButtonIcon addTarget:self action:@selector(weightButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:weightButtonIcon];
    
    [self drawMedicalInfoWithYpos: weightButtonIcon.frame.size.height+weightButtonIcon.frame.origin.y + 20];
}

- (void)drawMedicalInfoWithYpos:(CGFloat)yPos{
    UILabel *infoLabel =[[UILabel alloc]initWithFrame:CGRectMake(screenWidth/2 - 150, yPos, 300, 25)];
    infoLabel.font = FONT_NORMAL(20);
    infoLabel.text = NSLocalizedString(@"medicalInfo", @"");
    infoLabel.textColor = [UIColor blueColor];
    infoLabel.textAlignment = NSTextAlignmentCenter;
    [scrollView addSubview:infoLabel];
    
    //Height
    UILabel *heightLabelTitle =[[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 100, yPos + 50, 95, 25)];
    heightLabelTitle.font = FONT_NORMAL(15);
    heightLabelTitle.text = NSLocalizedString(@"height", @"");
    heightLabelTitle.textColor = [UIColor blackColor];
    heightLabelTitle.textAlignment = NSTextAlignmentRight;
    [scrollView addSubview:heightLabelTitle];
    
    heightLabelMedicalInfo =[[UILabel alloc]initWithFrame:CGRectMake(100, yPos + 50, screenWidth - 120, 25)];
    heightLabelMedicalInfo.font = FONT_NORMAL(15);
    if (lastHeight == -1 || [profileDictionary count] == 0) {
        heightLabelMedicalInfo.text = @"?";
    } else {
        heightLabelMedicalInfo.text = [NSString stringWithFormat:@"%2.2f           سانتی متر", lastHeight];
    }
    heightLabelMedicalInfo.textColor = [UIColor blackColor];
    heightLabelMedicalInfo.textAlignment = NSTextAlignmentCenter;
    [scrollView addSubview:heightLabelMedicalInfo];
    
    NSString *imageName = @"update";
    UIButton *heightButton = [[UIButton alloc]initWithFrame:CGRectMake(20, yPos + 50 , 73*0.4, 73*0.4)];
    [heightButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [heightButton addTarget:self action:@selector(heightButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:heightButton];
    
    //weight
    UILabel *weightLabelTitle =[[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 100, yPos + 100, 95, 25)];
    weightLabelTitle.font = FONT_NORMAL(15);
    weightLabelTitle.text = NSLocalizedString(@"weight2", @"");
    weightLabelTitle.textColor = [UIColor blackColor];
    weightLabelTitle.textAlignment = NSTextAlignmentRight;
    [scrollView addSubview:weightLabelTitle];
    
    weightLabelMedicalInfo =[[UILabel alloc]initWithFrame:CGRectMake(100, yPos + 100, screenWidth - 120, 25)];
    weightLabelMedicalInfo.font = FONT_NORMAL(15);
    if (lastWeight == 0 || [profileDictionary count] == 0) {
        weightLabelMedicalInfo.text = @"?";
    } else {
        weightLabelMedicalInfo.text = [NSString stringWithFormat:@"%2.2f           کیلوگرم", lastWeight];
    }
    
    weightLabelMedicalInfo.textColor = [UIColor blackColor];
    weightLabelMedicalInfo.textAlignment = NSTextAlignmentCenter;
    [scrollView addSubview:weightLabelMedicalInfo];
    
    UIButton *weightButton = [[UIButton alloc]initWithFrame:CGRectMake(20, yPos + 100 , 73*0.4, 73*0.4)];
    [weightButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [weightButton addTarget:self action:@selector(weightButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:weightButton];
    
    //BP
    UILabel *BPLabelTitle =[[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 100, yPos + 150, 95, 25)];
    BPLabelTitle.font = FONT_NORMAL(15);
    BPLabelTitle.text = NSLocalizedString(@"BP", @"");
    BPLabelTitle.textColor = [UIColor blackColor];
    BPLabelTitle.textAlignment = NSTextAlignmentRight;
    [scrollView addSubview:BPLabelTitle];
    
    BPLabelMedicalInfo =[[UILabel alloc]initWithFrame:CGRectMake(70, yPos + 150, screenWidth - 120, 25)];
    BPLabelMedicalInfo.font = FONT_NORMAL(15);
    if (lastBPUp == 0 || [profileDictionary count] == 0) {
        BPLabelMedicalInfo.text = @"?";
    }else{
        BPLabelMedicalInfo.text = [NSString stringWithFormat:@"%2.2f   میلی مترجیوه", lastBPUp];
    }

    BPLabelMedicalInfo.textColor = [UIColor blackColor];
    BPLabelMedicalInfo.textAlignment = NSTextAlignmentCenter;
    [scrollView addSubview:BPLabelMedicalInfo];
    
    UIButton *bloodPressureButton = [[UIButton alloc]initWithFrame:CGRectMake( 20, yPos + 150 , 73*0.4, 73*0.4)];
    [bloodPressureButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [bloodPressureButton addTarget:self action:@selector(bloodPressureButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:bloodPressureButton];
    
    //BG
    UILabel *BGLabelTitle =[[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 100, yPos + 200, 95, 25)];
    BGLabelTitle.font = FONT_NORMAL(15);
    BGLabelTitle.text = NSLocalizedString(@"BG", @"");
    BGLabelTitle.textColor = [UIColor blackColor];
    BGLabelTitle.textAlignment = NSTextAlignmentRight;
    [scrollView addSubview:BGLabelTitle];
    
    BGLabelMedicalInfo =[[UILabel alloc]initWithFrame:CGRectMake(70, yPos + 200, screenWidth - 120, 25)];
    BGLabelMedicalInfo.font = FONT_NORMAL(13);
    if (lastBG == 0 || [profileDictionary count] == 0) {
        BGLabelMedicalInfo.text = @"?";
    } else {
        BGLabelMedicalInfo.text = [NSString stringWithFormat:@"%2.2f   میلی گرم بر دسی لیتر", lastBG];
    }
    BGLabelMedicalInfo.textColor = [UIColor blackColor];
    BGLabelMedicalInfo.textAlignment = NSTextAlignmentCenter;
    [scrollView addSubview:BGLabelMedicalInfo];
    
    UIButton *bloodGlucoseButton = [[UIButton alloc]initWithFrame:CGRectMake(20, yPos + 200 , 73*0.4, 73*0.4)];
    [bloodGlucoseButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [bloodGlucoseButton addTarget:self action:@selector(bloodGlucoseButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:bloodGlucoseButton];
    
    [self drawChartButtonsWithYPos:bloodGlucoseButton.frame.origin.y + bloodGlucoseButton.frame.size.height + 30];
}

- (void)drawChartButtonsWithYPos:(CGFloat)yPos{
    BGButtonChart = [CustomButton initButtonWithTitle:NSLocalizedString(@"BGChart", @"") withTitleColor:[UIColor whiteColor] withBackColor:COLOR_1 withFrame:CGRectMake(20, yPos, screenWidth/4, 30)];
    [BGButtonChart addTarget:self action:@selector(BGChartAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:BGButtonChart];
    
    weightButtonChart = [CustomButton initButtonWithTitle:NSLocalizedString(@"weightChart", @"") withTitleColor:[UIColor whiteColor] withBackColor:COLOR_1 withFrame:CGRectMake(screenWidth/2 - (screenWidth/8), yPos, screenWidth/4, 30)];
    [weightButtonChart addTarget:self action:@selector(weightChartAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:weightButtonChart];
    
    BPButtonChart = [CustomButton initButtonWithTitle:NSLocalizedString(@"BPChart", @"") withTitleColor:[UIColor whiteColor] withBackColor:COLOR_1 withFrame:CGRectMake(screenWidth - (screenWidth/4) - 20, yPos, screenWidth/4 + 10, 30)];
    [BPButtonChart addTarget:self action:@selector(BPChartAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:BPButtonChart];
    
    isBGSelected = YES;
    [self initChartWithStyle:UUChartLineStyle];
    
    [BGButtonChart setBackgroundColor:[UIColor colorWithRed:7/255.0 green:125/255.0 blue:195/255.0 alpha:1.0]];
    [BPButtonChart setBackgroundColor:[UIColor colorWithRed:7/255.0 green:125/255.0 blue:95/255.0 alpha:0.5]];
    [weightButtonChart setBackgroundColor:[UIColor colorWithRed:7/255.0 green:125/255.0 blue:95/255.0 alpha:0.5]];
    
    
    //    if (IS_IPHONE_4_AND_OLDER_IOS7 || IS_IPHONE_4_AND_OLDER_IOS8) {
    //        scrollView.contentSize = CGSizeMake(screenWidth, screenHeight * 1.5);
    //    }else{
    scrollView.contentSize = CGSizeMake(screenWidth, BPButtonChart.frame.origin.y + 300);
    //}
    
    
}

- (void)bloodGlucoseButtonAction{
    [self hideAllViews];
    CGFloat viewSize = 200;
    BGAlertView =[[UIView alloc]initWithFrame:CGRectMake(screenWidth/2 - viewSize/2, screenHeight/2 - viewSize/2, viewSize, viewSize)];
    BGAlertView.layer.cornerRadius = 5;
    BGAlertView.clipsToBounds = NO;
    BGAlertView.layer.shadowOffset = CGSizeMake(0, 0);
    BGAlertView.layer.shadowRadius = 20;
    BGAlertView.layer.shadowOpacity = 0.1;
    BGAlertView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:BGAlertView];
    
    UILabel *titleLabel =[[UILabel alloc]initWithFrame:CGRectMake(10, 10, viewSize - 20, 25)];
    titleLabel.font = FONT_NORMAL(13);
    titleLabel.text = NSLocalizedString(@"updateBG", @"");
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [BGAlertView addSubview:titleLabel];
    
    UILabel *titleLabel2 =[[UILabel alloc]initWithFrame:CGRectMake(10, 50, viewSize - 20, 25)];
    titleLabel2.font = FONT_NORMAL(13);
    titleLabel2.text = NSLocalizedString(@"currBG", @"");
    titleLabel2.textColor = [UIColor grayColor];
    titleLabel2.textAlignment = NSTextAlignmentCenter;
    [BGAlertView addSubview:titleLabel2];
    
    BGTextField = [[UITextField alloc]initWithFrame:CGRectMake(20, 90, viewSize - 100, 25)];
    BGTextField.backgroundColor = [UIColor whiteColor];
    BGTextField.tag = 321;
    BGTextField.delegate = self;
    BGTextField.font = FONT_NORMAL(15);
    BGTextField.layer.borderColor = [UIColor grayColor].CGColor;
    BGTextField.layer.borderWidth = 1.0;
    BGTextField.layer.cornerRadius = 12;
    BGTextField.clipsToBounds = YES;
    BGTextField.placeholder = [NSString stringWithFormat:@"%2.2f", lastBG];
    BGTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    BGTextField.textAlignment = NSTextAlignmentCenter;
    BGTextField.keyboardType = UIKeyboardTypeNumberPad;
    [BGAlertView addSubview:BGTextField];
    
    UIButton *okButton = [[UIButton alloc]initWithFrame:CGRectMake(viewSize - 50, 85, 35, 35)];
    [okButton setBackgroundImage:[UIImage imageNamed:@"ok"] forState:UIControlStateNormal];
    [okButton addTarget:self action:@selector(okButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    okButton.tag = 300;
    [BGAlertView addSubview:okButton];
    
    UILabel *lastupdateLabel =[[UILabel alloc]initWithFrame:CGRectMake(10, 130, BGAlertView.frame.size.width - 20, 45)];
    lastupdateLabel.font = FONT_NORMAL(13);
    if ([BGArray count] > 0) {
        NSString *lastupdate = [ConvertToPersianDate ConvertToPersianDate2:[NSString stringWithFormat:@"%@", [[BGArray objectAtIndex:0]objectForKey:@"created"]]];
        BGTextField.text = [NSString stringWithFormat:@"%@", [[BGArray objectAtIndex:0]objectForKey:@"value"]];
        lastupdateLabel.text = [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"lastupdate", @""), lastupdate];
    }
    lastupdateLabel.textColor = [UIColor grayColor];
    lastupdateLabel.numberOfLines = 2;
    lastupdateLabel.textAlignment = NSTextAlignmentCenter;
    [BGAlertView addSubview:lastupdateLabel];
    
    
}

- (void)bloodPressureButtonAction{
    [self hideAllViews];
    CGFloat viewSize = 200;
    BPAlertView =[[UIView alloc]initWithFrame:CGRectMake(screenWidth/2 - viewSize/2, screenHeight/2 - viewSize/2, viewSize, viewSize)];
    BPAlertView.layer.cornerRadius = 5;
    BPAlertView.clipsToBounds = NO;
    BPAlertView.layer.shadowOffset = CGSizeMake(0, 0);
    BPAlertView.layer.shadowRadius = 20;
    BPAlertView.layer.shadowOpacity = 0.1;
    BPAlertView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:BPAlertView];
    
    UILabel *titleLabel =[[UILabel alloc]initWithFrame:CGRectMake(10, 10, viewSize - 20, 25)];
    titleLabel.font = FONT_NORMAL(13);
    titleLabel.text = NSLocalizedString(@"updateBP", @"");
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [BPAlertView addSubview:titleLabel];
    
    UILabel *titleLabel2 =[[UILabel alloc]initWithFrame:CGRectMake(10, 50, viewSize - 20, 25)];
    titleLabel2.font = FONT_NORMAL(13);
    titleLabel2.text = NSLocalizedString(@"currBP", @"");
    titleLabel2.textColor = [UIColor grayColor];
    titleLabel2.textAlignment = NSTextAlignmentCenter;
    [BPAlertView addSubview:titleLabel2];
    
    BPTextFieldup = [[UITextField alloc]initWithFrame:CGRectMake(20, 70, viewSize - 100, 25)];
    BPTextFieldup.backgroundColor = [UIColor whiteColor];
    BPTextFieldup.placeholder = NSLocalizedString(@"up", @"");
    BPTextFieldup.tag = 421;
    BPTextFieldup.delegate = self;
    BPTextFieldup.font = FONT_NORMAL(15);
    BPTextFieldup.layer.borderColor = [UIColor grayColor].CGColor;
    BPTextFieldup.layer.borderWidth = 1.0;
    BPTextFieldup.layer.cornerRadius = 12;
    BPTextFieldup.clipsToBounds = YES;
    BPTextFieldup.autocorrectionType = UITextAutocorrectionTypeNo;
    BPTextFieldup.textAlignment = NSTextAlignmentCenter;
    BPTextFieldup.keyboardType = UIKeyboardTypeNumberPad;
    [BPAlertView addSubview:BPTextFieldup];
    
    BPTextFielddown = [[UITextField alloc]initWithFrame:CGRectMake(20, 100, viewSize - 100, 25)];
    BPTextFielddown.backgroundColor = [UIColor whiteColor];
    BPTextFielddown.placeholder = NSLocalizedString(@"down", @"");
    BPTextFielddown.tag = 422;
    BPTextFielddown.delegate = self;
    BPTextFielddown.font = FONT_NORMAL(15);
    BPTextFielddown.layer.borderColor = [UIColor grayColor].CGColor;
    BPTextFielddown.layer.borderWidth = 1.0;
    BPTextFielddown.layer.cornerRadius = 12;
    BPTextFielddown.clipsToBounds = YES;
    BPTextFielddown.autocorrectionType = UITextAutocorrectionTypeNo;
    BPTextFielddown.textAlignment = NSTextAlignmentCenter;
    BPTextFielddown.keyboardType = UIKeyboardTypeNumberPad;
    [BPAlertView addSubview:BPTextFielddown];
    
    UIButton *okButton = [[UIButton alloc]initWithFrame:CGRectMake(viewSize - 50, 70, 35, 35)];
    [okButton setBackgroundImage:[UIImage imageNamed:@"ok"] forState:UIControlStateNormal];
    [okButton addTarget:self action:@selector(okButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    okButton.tag = 400;
    [BPAlertView addSubview:okButton];
    
    UILabel *lastupdateLabel =[[UILabel alloc]initWithFrame:CGRectMake(10, 130, BPAlertView.frame.size.width - 20, 45)];
    lastupdateLabel.font = FONT_NORMAL(13);
    if ([BPArray count] > 0) {
        NSString *lastupdate = [ConvertToPersianDate ConvertToPersianDate2:[NSString stringWithFormat:@"%@", [[BPArray objectAtIndex:0]objectForKey:@"created"]]];
        BPTextFieldup.text = [NSString stringWithFormat:@"%@",[[BPArray objectAtIndex:0]objectForKey:@"up_value"]];
        BPTextFielddown.text = [NSString stringWithFormat:@"%@", [[BPArray objectAtIndex:0]objectForKey:@"down_value"]];
        lastupdateLabel.text = [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"lastupdate", @""), lastupdate];
    }
    lastupdateLabel.textColor = [UIColor grayColor];
    lastupdateLabel.numberOfLines = 2;
    lastupdateLabel.textAlignment = NSTextAlignmentCenter;
    [BPAlertView addSubview:lastupdateLabel];
    
    
    
}

- (void)weightButtonAction{
    [self hideAllViews];
    CGFloat viewSize = 200;
    weightAlertView =[[UIView alloc]initWithFrame:CGRectMake(screenWidth/2 - viewSize/2, screenHeight/2 - viewSize/2, viewSize, viewSize)];
    weightAlertView.layer.cornerRadius = 5;
    weightAlertView.clipsToBounds = NO;
    weightAlertView.layer.shadowOffset = CGSizeMake(0, 0);
    weightAlertView.layer.shadowRadius = 20;
    weightAlertView.layer.shadowOpacity = 0.1;
    weightAlertView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:weightAlertView];
    
    UILabel *titleLabel =[[UILabel alloc]initWithFrame:CGRectMake(10, 10, viewSize - 20, 25)];
    titleLabel.font = FONT_NORMAL(13);
    titleLabel.text = NSLocalizedString(@"updateweight", @"");
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [weightAlertView addSubview:titleLabel];
    
    UILabel *titleLabel2 =[[UILabel alloc]initWithFrame:CGRectMake(10, 50, viewSize - 20, 25)];
    titleLabel2.font = FONT_NORMAL(13);
    titleLabel2.text = NSLocalizedString(@"currweight", @"");
    titleLabel2.textColor = [UIColor grayColor];
    titleLabel2.textAlignment = NSTextAlignmentCenter;
    [weightAlertView addSubview:titleLabel2];
    
    weightTextField = [[UITextField alloc]initWithFrame:CGRectMake(20, 90, viewSize - 100, 25)];
    weightTextField.backgroundColor = [UIColor whiteColor];
    weightTextField.tag = 521;
    weightTextField.delegate = self;
    weightTextField.font = FONT_NORMAL(15);
    weightTextField.layer.borderColor = [UIColor grayColor].CGColor;
    weightTextField.layer.borderWidth = 1.0;
    weightTextField.placeholder = [NSString stringWithFormat:@"%2.2f", lastWeight];
    weightTextField.layer.cornerRadius = 12;
    weightTextField.clipsToBounds = YES;
    weightTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    weightTextField.textAlignment = NSTextAlignmentCenter;
    weightTextField.keyboardType = UIKeyboardTypeNumberPad;
    [weightAlertView addSubview:weightTextField];
    
    UIButton *okButton = [[UIButton alloc]initWithFrame:CGRectMake(viewSize - 50, 85, 35, 35)];
    [okButton setBackgroundImage:[UIImage imageNamed:@"ok"] forState:UIControlStateNormal];
    [okButton addTarget:self action:@selector(okButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    okButton.tag = 500;
    [weightAlertView addSubview:okButton];
    
    UILabel *lastupdateLabel =[[UILabel alloc]initWithFrame:CGRectMake(10, 130, weightAlertView.frame.size.width - 20, 45)];
    lastupdateLabel.font = FONT_NORMAL(13);
    if ([weightsArray count] > 0) {
        NSString *lastupdate = [ConvertToPersianDate ConvertToPersianDate2:[NSString stringWithFormat:@"%@", [[weightsArray objectAtIndex:0]objectForKey:@"created"]]];
        weightTextField.text = [NSString stringWithFormat:@"%@", [[weightsArray objectAtIndex:0]objectForKey:@"value"]];
        lastupdateLabel.text = [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"lastupdate", @""), lastupdate];
    }
    lastupdateLabel.textColor = [UIColor grayColor];
    lastupdateLabel.numberOfLines = 2;
    lastupdateLabel.textAlignment = NSTextAlignmentCenter;
    [weightAlertView addSubview:lastupdateLabel];
    
}

- (void)heightButtonAction{
    [self hideAllViews];
    CGFloat viewSize = 200;
    heightAlertView =[[UIView alloc]initWithFrame:CGRectMake(screenWidth/2 - viewSize/2, screenHeight/2 - viewSize/2, viewSize, viewSize)];
    heightAlertView.layer.cornerRadius = 5;
    heightAlertView.clipsToBounds = NO;
    heightAlertView.layer.shadowOffset = CGSizeMake(0, 0);
    heightAlertView.layer.shadowRadius = 20;
    heightAlertView.layer.shadowOpacity = 0.1;
    heightAlertView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:heightAlertView];
    
    UILabel *titleLabel =[[UILabel alloc]initWithFrame:CGRectMake(10, 10, viewSize - 20, 25)];
    titleLabel.font = FONT_NORMAL(13);
    titleLabel.text = NSLocalizedString(@"updateheight", @"");
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [heightAlertView addSubview:titleLabel];
    
    UILabel *titleLabel2 =[[UILabel alloc]initWithFrame:CGRectMake(10, 50, viewSize - 20, 25)];
    titleLabel2.font = FONT_NORMAL(13);
    titleLabel2.text = NSLocalizedString(@"currheight", @"");
    titleLabel2.textColor = [UIColor grayColor];
    titleLabel2.textAlignment = NSTextAlignmentCenter;
    [heightAlertView addSubview:titleLabel2];
    
    heightTextField = [[UITextField alloc]initWithFrame:CGRectMake(20, 90, viewSize - 100, 25)];
    heightTextField.backgroundColor = [UIColor whiteColor];
    heightTextField.tag = 621;
    heightTextField.placeholder = [NSString stringWithFormat:@"%2.2f", lastHeight];
    heightTextField.font = FONT_NORMAL(15);
    heightTextField.delegate = self;
    heightTextField.layer.borderColor = [UIColor grayColor].CGColor;
    heightTextField.layer.borderWidth = 1.0;
    heightTextField.layer.cornerRadius = 12;
    heightTextField.clipsToBounds = YES;
    heightTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    heightTextField.textAlignment = NSTextAlignmentCenter;
    heightTextField.keyboardType = UIKeyboardTypeNumberPad;
    [heightAlertView addSubview:heightTextField];
    
    UIButton *okButton = [[UIButton alloc]initWithFrame:CGRectMake(viewSize - 50, 85, 35, 35)];
    [okButton setBackgroundImage:[UIImage imageNamed:@"ok"] forState:UIControlStateNormal];
    [okButton addTarget:self action:@selector(okButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    okButton.tag = 600;
    [heightAlertView addSubview:okButton];
    
    UILabel *lastupdateLabel =[[UILabel alloc]initWithFrame:CGRectMake(10, 130, heightAlertView.frame.size.width - 20, 45)];
    lastupdateLabel.font = FONT_NORMAL(13);
    //NSString *lastupdate = [ConvertToPersianDate ConvertToPersianDate2:[NSString stringWithFormat:@"%@", [[ objectAtIndex:0]objectForKey:@"created"]]];
    heightTextField.text = [NSString stringWithFormat:@"%ld", (long)lastHeight];
    //lastupdateLabel.text = [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"lastupdate", @""), lastupdate];
    lastupdateLabel.textColor = [UIColor grayColor];
    lastupdateLabel.numberOfLines = 2;
    lastupdateLabel.textAlignment = NSTextAlignmentCenter;
    [heightAlertView addSubview:lastupdateLabel];
    
    
}

- (void)profileImageViewAction{
    [self showgalleryCameraView];
}

- (NSString *)getTodayDate{
    NSDate *currentDate = [[NSDate alloc] init];
    NSTimeZone *timeZone = [NSTimeZone defaultTimeZone];
    // or Timezone with specific name like
    [NSTimeZone timeZoneWithName:@"IRST"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
    NSString *localDateString = [dateFormatter stringFromDate:currentDate];
    return localDateString;
    //    NSDate *dateTemp = [[NSDate alloc] init];
    //    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    //    [dateFormat setDateFormat:@"yyyy-MM-dd HH:MM:ss"];
    //    //[dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"IRST"]];
    //    NSString *dateString = [dateFormat stringFromDate:dateTemp];
    //    return  dateString;
}

- (void)okButtonAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    //NSLog(@"%ld", (long)btn.tag);
    switch (btn.tag) {
        case 300:
            //BG,clucos
            if ([BGTextField.text length] == 0) {
                [ShakeAnimation startShake:BGTextField];
            }else{
                [self dismissTextField];
                [self hideAllViews];
                [self sendBloodSugarToServerWithValue:BGTextField.text];
            }
            
            break;
        case 400:
            //BP
            if ([BPTextFieldup.text length] == 0) {
                [ShakeAnimation startShake:BPTextFieldup];
                return;
            }
            
            if ([BPTextFielddown.text length] == 0) {
                [ShakeAnimation startShake:BPTextFielddown];
            }else{
                [self dismissTextField];
                [self hideAllViews];
                [self sendBloodPressureToServerWithValueUP:BPTextFieldup.text withValueDOWN:BPTextFielddown.text];
            }
            
            break;
        case 500:
            //weight
            if ([weightTextField.text length] == 0) {
                [ShakeAnimation startShake:weightTextField];
            }else{
                [self dismissTextField];
                [self hideAllViews];
                [self sendWeightToServerWithValue:weightTextField.text];
            }
            
            break;
        case 600:
            //height
            if ([heightTextField.text length] == 0) {
                [ShakeAnimation startShake:heightTextField];
            }else{
                [self dismissTextField];
                [self hideAllViews];
                [self sendheightToServerWithValue:heightTextField.text];
            }
            
            break;
        default:
            break;
    }
}

-(BOOL)isNumeric:(NSString*)inputString{
    BOOL isValid = NO;
    if ([inputString length] > 0) {
        NSCharacterSet *alphaNumbersSet = [NSCharacterSet decimalDigitCharacterSet];
        NSCharacterSet *stringSet = [NSCharacterSet characterSetWithCharactersInString:inputString];
        isValid = [alphaNumbersSet isSupersetOfSet:stringSet];
    }
    
    return isValid;
}

-(NSString *)AdjustBloodPressureIconWithDownValue:(NSString *)downValue
                                          upValue:(NSString *)upValue
{
    
    float up = [upValue floatValue];
    float down = [downValue floatValue];
    NSString *imgbloodPressureStr = @"blood_pressure.png";
    
    
    if ( up == 0 && down == 0) {
        imgbloodPressureStr = @"blood_pressure.png";
    }else if (up < down || up >= 280 || up <= 50 || down <= 40
              || down >= 180) {
        imgbloodPressureStr = @"BP4.png";
    } else if (up >= 180 && up < 280) {
        imgbloodPressureStr = @"BP4.png";
    } else if (up >= 140 || down > 90) {
        imgbloodPressureStr = @"BP4.png";
    } else if ((up > 120 && up <= 140) || (down > 80 && down <= 90)) {
        imgbloodPressureStr = @"BP3.png";
    } else if ((up > 90 && up <= 120) || (down > 60 && down <= 80)) {
        imgbloodPressureStr = @"BP2.png";
    } else if ((up > 50 && up <= 90) && (down > 40 && down <= 60)) {
        imgbloodPressureStr = @"BP1.png";
    }
    
    
    return imgbloodPressureStr;
}

// return Name of Proper Image for Adjusting the icon Of Weight
-(NSString *)AdjustWeightIcon : (NSString *) value
{
    
    
    float bmi = [value floatValue];
    NSString *imgWeightStr = @"weight_update.png";
    
    if (bmi == 0) {
        imgWeightStr = @"weight_update.png";
    } else if (bmi <= 16) {
        imgWeightStr = @"weight1.png";
    } else if (bmi > 16 && bmi <= 25){
        imgWeightStr = @"weight2.png";
    } else if (bmi > 25 && bmi <= 30) {
        imgWeightStr = @"weight4.png";
    } else if (bmi > 30) {
        imgWeightStr = @"weight5.png";
    }
    
    
    
    return imgWeightStr;
}


// return Name of Proper Image for Adjusting the icon Of BloodSuger
-(NSString *)AdjustBloodSugerIcon : (NSString *) value
{
    
    
    int bloodSuger = [value intValue];
    NSString *imgBloodSugerStr = @"blood_glucose.png";
    
    if (bloodSuger == 0) {
        imgBloodSugerStr = @"blood_glucose.png";
    } else if (bloodSuger >= 126) {
        imgBloodSugerStr = @"BG4.png";//red
    } else if (bloodSuger >= 110) {
        imgBloodSugerStr = @"BG3.png";//yellow
    } else if (bloodSuger >= 70) {
        imgBloodSugerStr = @"BG2.png";//normal
    } else if (bloodSuger >= 40) {
        imgBloodSugerStr = @"BG1.png";//blue
    }
    
    return imgBloodSugerStr;
}


-(CGFloat)calculateBMIWithWeight:(float) weight
                         Height :(float) Height
{
    //NSString *result = @"";
    CGFloat heightInmeter = (Height / 100);
    CGFloat bmi = (weight / (heightInmeter * heightInmeter));
    
    
    bmi = [self customRounding:bmi roundingValue:0.005];
    
    //result = [[NSNumber numberWithFloat:bmi] stringValue];
    
    return bmi;
}

-(float) customRounding:(float)value roundingValue:(float) roundingValue {
    //const float roundingValue = 0.5;
    int mulitpler = ceilf(value / roundingValue);
    return mulitpler * roundingValue;
}

- (void)menuButtonAction {
    //[self showHideRightMenu];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"toggleMenuVisibility" object:nil];
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

- (void)editButtonAction{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    EditProfileViewController *view = (EditProfileViewController *)[story instantiateViewControllerWithIdentifier:@"EditProfileViewController"];
    view.profileDictionary = profileDictionary;
    [self presentViewController:view animated:YES completion:nil];
    
}

- (void)hideAllViews{
    [BGAlertView removeFromSuperview];
    [BPAlertView removeFromSuperview];
    [weightAlertView removeFromSuperview];
    [heightAlertView removeFromSuperview];
    [self hideGalleryCameraView];
    
}

- (void)writeToFile{
    //KeychainWrapper *keychainWrapper = [[KeychainWrapper alloc]init];
    //save profile dic
    NSData *profileData = [NSKeyedArchiver archivedDataWithRootObject:profileDictionary];
    [[NSUserDefaults standardUserDefaults]setObject:profileData forKey:@"profileData"];
    //[keychainWrapper mySetObject:profileData forKey:(__bridge id)(kSecAttrAccount)];
    
    [self loadProfileDictionary];
    [self initValuesFromProfile];
}

- (void)loadProfileDictionary{
    //load profile dic
    profileDictionary = [[NSMutableDictionary alloc]initWithDictionary:[GetUsernamePassword getProfileData]];
}

- (void)loadImageProfileFromServer{
    //[self loadImageFileFromDocument];
    UIImage *defaultImage = [UIImage imageNamed:@"icon upload ax"];
    UIImage *currentImage = profileImageView.image;
    if ([UIImagePNGRepresentation(defaultImage) isEqualToData:UIImagePNGRepresentation(currentImage)]) {
        dispatch_async(kBgQueue, ^{
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/thumb_%@",BaseURL,[GetUsernamePassword getProfileId],profileDictionary.photoProfile]];
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

- (void)loadImageProfileFromServer2{
    dispatch_async(kBgQueue, ^{
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/thumb_%@",BaseURL,[GetUsernamePassword getProfileId],profileDictionary.photoProfile]];
        NSData *imgData = [NSData dataWithContentsOfURL:url];
        
        if (imgData) {
            UIImage *image = [UIImage imageWithData:imgData];
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    profileImageView.image  = image;
                    [self saveImageIntoDocumets];
                    //[self deleteUnnecessaryImagesInDocuments];
                });
            }
        }
    });
}

- (void)loadImageFileFromDocument{
    if (profileDictionary.photoProfile != (id)[NSNull null]){
        NSString *imageFileName = [NSString stringWithFormat:@"%@/%@", [DocumentDirectoy getDocuementsDirectory], [profileDictionary.photoProfile lastPathComponent]];
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

- (void)saveImageIntoDocumets{
    //convert image into .png format.
    NSData *imageData = UIImagePNGRepresentation(profileImageView.image);
    //create instance of NSFileManager
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *appDocumentsDirectory = [DocumentDirectoy getDocuementsDirectory];
    //add our image to the path
    NSString *fullPath = [appDocumentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", [profileDictionary.photoProfile lastPathComponent]]];
    //finally save the path (image)
    BOOL resultSave = [fileManager createFileAtPath:fullPath contents:imageData attributes:nil];
    if (resultSave) {
        //NSLog(@"image saved");
    }
}

- (BOOL)image:(UIImage *)image1 isEqualTo:(UIImage *)image2
{
    NSData *data1 = UIImagePNGRepresentation(image1);
    NSData *data2 = UIImagePNGRepresentation(image2);
    
    return [data1 isEqual:data2];
}

- (NSString *)encodeToBase64String:(UIImage *)image {
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:0];
}

- (void)deleteUnnecessaryImagesInDocuments{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *appDocumentsDirectory = [DocumentDirectoy getDocuementsDirectory];
    NSError *error;
    NSArray *directoryContents = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:appDocumentsDirectory
                                                                                    error:&error];
    for (NSInteger i = 0; i < [directoryContents count]; i++) {
        if ([[directoryContents objectAtIndex:i] containsString:@"png"]) {
            if (![[directoryContents objectAtIndex:i] isEqualToString:profileDictionary.photoProfile]) {
                NSError *error;
                [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@", appDocumentsDirectory, [directoryContents objectAtIndex:i]] error:&error];
            }
        }
    }
}

- (IntroViewController *)IntroViewController{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    IntroViewController *view = (IntroViewController *)[story instantiateViewControllerWithIdentifier:@"IntroViewController"];
    return view;
}
- (void)pushToLoginView{
    [self presentViewController:[self IntroViewController] animated:YES completion:nil];
}


- (void)newQuestionButtonAction{
    if (![self hasConnectivity]) {
         
    } else {
        NSString *isnotLoggedIn = [[NSUserDefaults standardUserDefaults]objectForKey:@"isNotLoggedin"];
        if ([isnotLoggedIn length] > 0) {
            //[[NSUserDefaults standardUserDefaults]removeObjectForKey:@"isNotLoggedin"];
            [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"isPasswordChanged"];
            
            //
        //
        //
        // = [[UIAlertView alloc] initWithTitle:@""
                                                                         //
        } else {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"GoToConsultationViewFromLandingPageDirectly" object:nil];
        }
    }
}

#pragma mark - textfield delegate
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    if (![self isNumeric:textField.text]) {
        [ShakeAnimation startShake:textField];
    }else{
        [self dismissTextField];
    }
    
    return YES;
}

- (void)dismissTextField{
    [BGTextField resignFirstResponder];
    [BPTextFieldup resignFirstResponder];
    [BPTextFielddown resignFirstResponder];
    [heightTextField resignFirstResponder];
    [weightTextField resignFirstResponder];
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
    chosenImage = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    [self sendPhotoToServer];
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
            NSString *message;
            if ([userpassDic count] == 0) {
                message = NSLocalizedString(@"notLogin", @"");
            } else {
                message = NSLocalizedString(@"passwordIsChanged", @"");
            }
             
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
            //insert into DB
            //save profile dic
            //KeychainWrapper *keychainWrapper = [[KeychainWrapper alloc]init];
            NSData *profileData = [NSKeyedArchiver archivedDataWithRootObject:profileDic];
            [[NSUserDefaults standardUserDefaults]setObject:profileData forKey:@"profileData"];
            //[keychainWrapper mySetObject:profileData forKey:(__bridge id)(kSecAttrAccount)];
            [self loadProfileDictionary];
            [self initValuesFromProfile];
            nameLabelTop.text = [NSString stringWithFormat:@"%@ %@", profileDic.first_nameProfile, profileDictionary.last_nameProfile];
            if (profileDictionary.ageProfile == -1 || [profileDictionary count] == 0)
                ageLabelTop.text = @"?";
            else
                ageLabelTop.text = [NSString stringWithFormat:@"%ld", (long)profileDictionary.ageProfile];

            if ([profileDictionary.blood_typeProfile isEqualToString:@"n"] || [profileDictionary count] == 0) {
                bloodLabelTop.text = @"?";
            } else {
                bloodLabelTop.text = profileDictionary.blood_typeProfile;
            }
            
            NSString *sex = @"?";//NSLocalizedString(@"unknown", @"");
            if (profileDictionary.sexProfile != (id)[NSNull null]) {
                if ([profileDictionary.sexProfile isEqualToString:@"f"]) {
                    sex = NSLocalizedString(@"woman", @"");
                }else if ([profileDictionary.sexProfile isEqualToString:@"m"]){
                    sex = NSLocalizedString(@"man", @"");
                }
            }
            
            sexLabelTop.text = sex;
            
            if ([self calculateBMIWithWeight:lastWeight Height:lastHeight] == 0 || [profileDictionary count] == 0) {
                BMILabelTop.text = @"?";
            } else {
                BMILabelTop.text = [NSString stringWithFormat:@"%2.2f", [self calculateBMIWithWeight:lastWeight Height:lastHeight]];
            }
            
            CGFloat idealWeight = [profileDictionary.ideal_weightProfile floatValue];
            if (idealWeight == -90 || [profileDictionary count] == 0) {
                weightLabelTop.text = @"?";
            } else {
                weightLabelTop.text = [NSString stringWithFormat:@"%@ %2.0f %@ %2.0f",NSLocalizedString(@"between", @""),idealWeight - 3,NSLocalizedString(@"till", @""),idealWeight + 3];
            }
            
            if (lastWeight == 0 || [profileDictionary count] == 0) {
                weightLabelMedicalInfo.text = @"?";
            } else {
                weightLabelMedicalInfo.text = [NSString stringWithFormat:@"%2.2f           کیلوگرم", lastWeight];
            }
            
            NSString *imageName = [self AdjustBloodSugerIcon:[NSString stringWithFormat:@"%2.2f", lastBG]];
            //250 × 320
            [bloodGlucoseButtonIcon setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
            imageName = [self AdjustBloodPressureIconWithDownValue:[NSString stringWithFormat:@"%2.2f", lastBPLow]
                                                           upValue:[NSString stringWithFormat:@"%2.2f", lastBPUp]];
            [bloodPressureButtonIcon setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
            imageName = [self AdjustWeightIcon:[NSString stringWithFormat:@"%2.2f", [self calculateBMIWithWeight:lastWeight Height:lastHeight]]];
            [weightButtonIcon setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
            
            if (lastHeight == -1 || [profileDictionary count] == 0) {
                heightLabelMedicalInfo.text = @"?";
            } else {
                heightLabelMedicalInfo.text = [NSString stringWithFormat:@"%2.2f           سانتی متر", lastHeight];
            }

            if (lastBPUp == 0 || [profileDictionary count] == 0) {
                BPLabelMedicalInfo.text = @"?";
            }else{
                BPLabelMedicalInfo.text = [NSString stringWithFormat:@"%2.2f   میلی مترجیوه", lastBPUp];
            }
            
            if (lastBG == 0 || [profileDictionary count] == 0) {
                BGLabelMedicalInfo.text = @"?";
            } else {
                BGLabelMedicalInfo.text = [NSString stringWithFormat:@"%2.2f   میلی گرم بر دسی لیتر", lastBG];
            }
            
            
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

-(void)sendBloodPressureToServerWithValueUP:(NSString *)valueUP withValueDOWN:(NSString *)valueDOWN
{
    //Arash
    if (([BPTextFielddown.text integerValue] >= 50) && ([BPTextFieldup.text integerValue] <= 280)) {
        [ProgressHUD show:@""];
        [BPTextFielddown resignFirstResponder];
        [BPTextFieldup resignFirstResponder];
        NSString *url = [NSString stringWithFormat:@"%@blood_pressure_update", BaseURL];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        manager.requestSerializer.timeoutInterval = 45;;
        NSDictionary *userpassDic = [GetUsernamePassword getUsernamePassword];
        /*
         - username
         - password
         - profile_id
         - value_up
         - value_down
         - debug
         */
        NSDictionary *params = @{@"username":[userpassDic objectForKey:@"username"],
                                 @"password":[userpassDic objectForKey:@"password"],
                                 @"profile_id":[GetUsernamePassword getProfileId],
                                 @"value_up":valueUP,
                                 @"value_down":valueDOWN,
                                 @"debug":@"1",
                                 @"unit_id": @"3"
                                 };
        [manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [ProgressHUD dismiss];
            NSDictionary *dict  =responseObject;
            if ([[dict objectForKey:@"success"]integerValue] == 1) {
                //success
                NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[self getTodayDate], @"created", BPTextFieldup.text, @"up_value", BPTextFielddown.text, @"down_value",  nil];
                [BPArray addObject:dic];
                [profileDictionary setObject:BPArray forKey:@"blood_pressures"];
                [self writeToFile];
                [self initValuesFromProfile];
                BPLabelMedicalInfo.text = [NSString stringWithFormat:@"%2.2f   میلی مترجیوه", lastBPUp];
                NSString *imageName = [self AdjustBloodPressureIconWithDownValue:[NSString stringWithFormat:@"%2.2f", lastBPLow]
                                                                         upValue:[NSString stringWithFormat:@"%2.2f", lastBPUp]];
                [bloodPressureButtonIcon setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
                [self loadProfileDictionary];
            }else{
                //unsuccessupdate
               
                
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
    } else {
           }
}

-(void)sendBloodSugarToServerWithValue:(NSString *)value
{
    //Arash
    if (([BGTextField.text integerValue] >= 40) && ([BGTextField.text integerValue] <= 250)) {
        [ProgressHUD show:@""];
        [BGTextField resignFirstResponder];
        NSString *url = [NSString stringWithFormat:@"%@blood_sugar_update", BaseURL];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        manager.requestSerializer.timeoutInterval = 45;;
        NSDictionary *userpassDic = [GetUsernamePassword getUsernamePassword];
        /*
         - username
         - password
         - profile_id
         - value
         - debug
         */
        NSDictionary *params = @{@"username":[userpassDic objectForKey:@"username"],
                                 @"password":[userpassDic objectForKey:@"password"],
                                 @"profile_id":[GetUsernamePassword getProfileId],
                                 @"value":value,
                                 @"debug":@"1",
                                 @"unit_id": @"3"
                                 };
        [manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [ProgressHUD dismiss];
            NSDictionary *dict  =responseObject;
            if ([[dict objectForKey:@"success"]integerValue] == 1) {
                //success
                NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[self getTodayDate], @"created", BGTextField.text, @"value", nil];
                [BGArray addObject:dic];
                [profileDictionary setObject:BGArray forKey:@"blood_sugars"];
                [self writeToFile];
                [self initValuesFromProfile];
                BGLabelMedicalInfo.text = [NSString stringWithFormat:@"%2.2f   میلی گرم بر دسی لیتر", lastBG];
                NSString *imageName = [self AdjustBloodSugerIcon:[NSString stringWithFormat:@"%2.2f", lastBG]];
                [bloodGlucoseButtonIcon setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
                [self loadProfileDictionary];
            }else{
                //unsuccessupdate
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
    }else {
           }
    
}

-(void)sendWeightToServerWithValue:(NSString *)value
{
    //Arash
    if (([weightTextField.text integerValue] >= 20) && ([weightTextField.text integerValue] <= 500)) {
        [ProgressHUD show:@""];
        [weightTextField resignFirstResponder];
        NSString *url = [NSString stringWithFormat:@"%@weight_update", BaseURL];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        manager.requestSerializer.timeoutInterval = 45;;
        NSDictionary *userpassDic = [GetUsernamePassword getUsernamePassword];
        NSDictionary *params = @{@"username":[userpassDic objectForKey:@"username"],
                                 @"password":[userpassDic objectForKey:@"password"],
                                 @"profile_id":[GetUsernamePassword getProfileId],
                                 @"value":value,
                                 @"debug":@"1",
                                 @"unit_id": @"3"
                                 };
        [manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [ProgressHUD dismiss];
            NSDictionary *dict  =responseObject;
            if ([[dict objectForKey:@"success"]integerValue] == 1) {
                //success
                NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[self getTodayDate], @"created", weightTextField.text, @"value",  nil];
                [weightsArray addObject:dic];
                [profileDictionary setObject:weightsArray forKey:@"weights"];
                [self writeToFile];
                [self initValuesFromProfile];
                weightLabelMedicalInfo.text = [NSString stringWithFormat:@"%2.2f           کیلوگرم", lastWeight];
                NSString *imageName = [self AdjustWeightIcon:[NSString stringWithFormat:@"%2.2f", [self calculateBMIWithWeight:lastWeight Height:lastHeight]]];
                [weightButtonIcon setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
                [self loadProfileDictionary];
            }else{
                //unsuccessupdate
               
                
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
    } else {
       
    }
}

-(void)sendheightToServerWithValue:(NSString *)value
{
    if (([heightTextField.text integerValue] >=100) && ([heightTextField.text integerValue] <=230) ) {
        [ProgressHUD show:@""];
        [heightTextField resignFirstResponder];
        NSString *url = [NSString stringWithFormat:@"%@update_height", BaseURL];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        manager.requestSerializer.timeoutInterval = 45;;
        NSDictionary *userpassDic = [GetUsernamePassword getUsernamePassword];
        NSDictionary *params = @{@"username":[userpassDic objectForKey:@"username"],
                                 @"password":[userpassDic objectForKey:@"password"],
                                 @"profile_id":[GetUsernamePassword getProfileId],
                                 @"value":value,
                                 @"debug":@"1",
                                 @"unit_id": @"3"
                                 };
        [manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [ProgressHUD dismiss];
            NSDictionary *dict  =responseObject;
            if ([[dict objectForKey:@"success"]integerValue] == 1) {
                //success
                lastHeight = [heightTextField.text floatValue];
                [profileDictionary setObject:[NSNumber numberWithFloat:lastHeight] forKey:@"height"];
                [self writeToFile];
                [self initValuesFromProfile];
                heightLabelMedicalInfo.text = [NSString stringWithFormat:@"%2.2f           سانتی متر", lastHeight];
                NSString *imageName = [self AdjustWeightIcon:[NSString stringWithFormat:@"%2.2f", [self calculateBMIWithWeight:lastWeight Height:lastHeight]]];
                [weightButtonIcon setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
                [self loadProfileDictionary];
            }else{
                //unsuccessupdate
               
                
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
        
    } else {
           }
    
}

-(void)sendPhotoToServer
{
    [ProgressHUD show:@""];
    NSString *url = [NSString stringWithFormat:@"%@update_profile_photo", BaseURL];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    manager.requestSerializer.timeoutInterval = 45;;
    NSDictionary *userpassDic = [GetUsernamePassword getUsernamePassword];
    NSString *file = [self encodeToBase64String:chosenImage];
    NSDictionary *params = @{@"username":[userpassDic objectForKey:@"username"],
                             @"password":[userpassDic objectForKey:@"password"],
                             @"profile_id":[GetUsernamePassword getProfileId],
                             @"value":file,
                             @"file_type":@"png",
                             @"debug":@"1",
                             @"unit_id": @"3"
                             };
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [ProgressHUD dismiss];
        NSDictionary *dict  =responseObject;
        if ([[dict objectForKey:@"success"]integerValue] == 1) {
            //success
            profileImageView.image = chosenImage;
            [self saveImageIntoDocumets];
            //[self loadImageProfileFromServer2];
            
        }else{
            profileImageView.image = [UIImage imageNamed:@"icon upload ax"];
            
            //unsuccessupdate
           
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

#pragma mark - chart methods

- (void)initChartWithStyle:(UUChartStyle)chartStyle{
    
    if (chartView) {
        [chartView removeFromSuperview];
        chartView = nil;
    }
    chartView = [[UUChart alloc]initwithUUChartDataFrame:CGRectMake(10, BPButtonChart.frame.origin.y + BPButtonChart.frame.size.height + 50, [UIScreen mainScreen].bounds.size.width-20, 150)
                                              withSource:self
                                               withStyle:chartStyle/*UUChartBarStyle,UUChartLineStyle*/];
    [chartView showInView:scrollView];
    
}

- (IBAction)BGChartAction {
    [BGButtonChart setBackgroundColor:[UIColor colorWithRed:7/255.0 green:125/255.0 blue:195/255.0 alpha:1.0]];
    [BPButtonChart setBackgroundColor:[UIColor colorWithRed:7/255.0 green:125/255.0 blue:95/255.0 alpha:0.5]];
    [weightButtonChart setBackgroundColor:[UIColor colorWithRed:7/255.0 green:125/255.0 blue:95/255.0 alpha:0.5]];
    isBGSelected = YES;
    isBPSelected = NO;
    isWeightSelected = NO;
    [self initChartWithStyle:UUChartLineStyle];
}

- (IBAction)weightChartAction {
    [weightButtonChart setBackgroundColor:[UIColor colorWithRed:7/255.0 green:125/255.0 blue:195/255.0 alpha:1.0]];
    [BPButtonChart setBackgroundColor:[UIColor colorWithRed:7/255.0 green:125/255.0 blue:95/255.0 alpha:0.5]];
    [BGButtonChart setBackgroundColor:[UIColor colorWithRed:7/255.0 green:125/255.0 blue:95/255.0 alpha:0.5]];
    isBGSelected = NO;
    isBPSelected = NO;
    isWeightSelected = YES;
    [self initChartWithStyle:UUChartLineStyle];
}

- (IBAction)BPChartAction {
    [BPButtonChart setBackgroundColor:[UIColor colorWithRed:7/255.0 green:125/255.0 blue:195/255.0 alpha:1.0]];
    [weightButtonChart setBackgroundColor:[UIColor colorWithRed:7/255.0 green:125/255.0 blue:95/255.0 alpha:0.5]];
    [BGButtonChart setBackgroundColor:[UIColor colorWithRed:7/255.0 green:125/255.0 blue:95/255.0 alpha:0.5]];
    isBGSelected = NO;
    isBPSelected = YES;
    isWeightSelected = NO;
    [self initChartWithStyle:UUChartBarStyle];
}

#pragma mark - @required
//Array abscissa(x-coordinate) title
- (NSArray *)UUChart_xLableArray:(UUChart *)chart
{
    NSMutableArray *xValues = [[NSMutableArray alloc]init];
    if (isBGSelected) {
        NSArray *tempArray = profileDictionary.BGArrayProfile;
        for (int i = 0; i < [tempArray count]; i++) {
            [xValues addObject:[NSString stringWithFormat:@"%@", [ConvertToPersianDate ConvertToPersianDate2:[[tempArray objectAtIndex:i]objectForKey:@"created"]]]];
        }
        return xValues;
    } else if (isWeightSelected) {
        NSArray *tempArray = profileDictionary.weightsArrayProfile;
        for (int i = 0; i < [tempArray count]; i++) {
            [xValues addObject:[NSString stringWithFormat:@"%@", [ConvertToPersianDate ConvertToPersianDate2:[[tempArray objectAtIndex:i]objectForKey:@"created"]]]];
        }
        return xValues;
        
    }else if (isBPSelected){
        NSArray *tempArray = profileDictionary.BPArrayProfile;
        for (int i = 0; i < [tempArray count]; i++) {
            [xValues addObject:[NSString stringWithFormat:@"%@", [ConvertToPersianDate ConvertToPersianDate2:[[tempArray objectAtIndex:i]objectForKey:@"created"]]]];
        }
        
        return xValues;
    }
    return xValues;
}
//Numerical multiple arrays
- (NSArray *)UUChart_yValueArray:(UUChart *)chart
{
    NSMutableArray *yValues = [[NSMutableArray alloc]init];
    if (isBGSelected) {
        NSArray *tempArray = profileDictionary.BGArrayProfile;
        for (int i = 0; i < [tempArray count]; i++) {
            [yValues addObject:[NSString stringWithFormat:@"%@", [[tempArray objectAtIndex:i]objectForKey:@"value"]]];
        }
        return @[yValues];
    } else if (isWeightSelected) {
        NSArray *tempArray = profileDictionary.weightsArrayProfile;
        for (int i = 0; i < [tempArray count]; i++) {
            [yValues addObject:[NSString stringWithFormat:@"%@", [[tempArray objectAtIndex:i]objectForKey:@"value"]]];
        }
        return @[yValues];
        
    }else if (isBPSelected){
        NSMutableArray *downValues = [[NSMutableArray alloc]init];
        NSMutableArray *upValues = [[NSMutableArray alloc]init];
        NSArray *tempArray = profileDictionary.BPArrayProfile;
        for (int i = 0; i < [tempArray count]; i++) {
            [downValues addObject:[NSString stringWithFormat:@"%@", [[tempArray objectAtIndex:i]objectForKey:@"down_value"]]];
            [upValues addObject:[NSString stringWithFormat:@"%@", [[tempArray objectAtIndex:i]objectForKey:@"up_value"]]];
        }
        return @[downValues,upValues];
        
    }
    return @[yValues];
    
}
#pragma mark - @optional
//Array of colors
- (NSArray *)UUChart_ColorArray:(UUChart *)chart
{
    return @[UUGreen,UURed,UUBrown];
}
//Display Value range
- (CGRange)UUChartChooseRangeInLineChart:(UUChart *)chart
{
    NSMutableArray *yValues = [[NSMutableArray alloc]init];
    if (isBGSelected) {
        
        NSArray *tempArray = profileDictionary.BGArrayProfile;
        for (int i = 0; i < [tempArray count]; i++) {
            [yValues addObject:[NSString stringWithFormat:@"%@", [[tempArray objectAtIndex:i]objectForKey:@"value"]]];
        }
        double max = [[yValues valueForKeyPath:@"@max.doubleValue"]doubleValue];
        double min = [[yValues valueForKeyPath:@"@min.doubleValue"]doubleValue];
        return CGRangeMake(max, min);
    } else if (isWeightSelected) {
        NSArray *tempArray = profileDictionary.weightsArrayProfile;
        for (int i = 0; i < [tempArray count]; i++) {
            [yValues addObject:[NSString stringWithFormat:@"%@", [[tempArray objectAtIndex:i]objectForKey:@"value"]]];
        }
        double max = [[yValues valueForKeyPath:@"@max.doubleValue"]doubleValue];
        double min = [[yValues valueForKeyPath:@"@min.doubleValue"]doubleValue];
        return CGRangeMake(max, min);
        
    }/*else if (isBPSelected){
      NSMutableArray *downValues = [[NSMutableArray alloc]init];
      NSMutableArray *upValues = [[NSMutableArray alloc]init];
      BloodPressure *bloodPressureInstant = [[ BloodPressure alloc] init];
      NSUserDefaults *defualt = [NSUserDefaults standardUserDefaults];
      NSString *profileId = [defualt objectForKey:@"profileId"];
      NSArray *tempArray = [bloodPressureInstant SelectAllByProfileId:profileId];
      for (int i = 0; i < [tempArray count]; i++) {
      [downValues addObject:[NSString stringWithFormat:@"%@", [[tempArray objectAtIndex:i]objectAtIndex:0]]];
      [upValues addObject:[NSString stringWithFormat:@"%@", [[tempArray objectAtIndex:i]objectAtIndex:1]]];
      }
      double maxUp = [[upValues valueForKeyPath:@"@max.doubleValue"]doubleValue];
      double minUp = [[upValues valueForKeyPath:@"@min.doubleValue"]doubleValue];
      double maxDown = [[downValues valueForKeyPath:@"@max.doubleValue"]doubleValue];
      double minDown = [[downValues valueForKeyPath:@"@min.doubleValue"]doubleValue];
      return CGRangeMake(MAX(maxDown, maxUp), MIN(minDown, minUp));
      }
      */
    
    return CGRangeMake(280, 40);
}

#pragma mark 折线图专享功能

//Label value region
- (CGRange)UUChartMarkRangeInLineChart:(UUChart *)chart
{
    return CGRangeZero;
}

//Analyzing display horizontal lines
- (BOOL)UUChart:(UUChart *)chart ShowHorizonLineAtIndex:(NSInteger)index
{
    return YES;
}

//Analyzing show maximum and minimum
//- (BOOL)UUChart:(UUChart *)chart ShowMaxMinAtIndex:(NSInteger)index
//{
//    return path.row==2;
//}
- (IBAction)questionButtonAction:(id)sender {
    [self performSegueWithIdentifier:@"askDocFromhealthStatus" sender:nil];
}


@end
