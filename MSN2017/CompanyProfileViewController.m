//
//  FirstViewController.m
//  MSN
//
//  Created by Yarima on 11/5/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "CompanyProfileViewController.h"
#import "Database.h"
#import <AFHTTPSessionManager.h>
#import <UIImageView+AFNetworking.h>
#import "Header.h"
#import <sys/socket.h>
#import <netinet/in.h>

#import "ProgressHUD.h"
#import "NSDictionary+profile.h"
#import "NSDictionary+LandingPageTableView.h"
#import "LandingPageCustomCell.h"
#import "TimeAgoViewController.h"
#import "DoctorPageViewController.h"
#import "SearchViewController.h"
#import "UploadDocumentsViewController.h"
#import "ConsultationListViewController.h"
#import "GetUsernamePassword.h"
#import "HealthStatusViewController.h"
#import "LandingPageCustomCellAudio.h"
#import "LandingPageCustomCellVideo.h"
#import "DocumentDirectoy.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "LandingPageCustomCellVideo.h"
#import "VideoPlayerViewController.h"
#import "FavoritesViewController.h"
#import "AboutViewController.h"
#import "DirectQuestionViewController.h"
#import "UIImage+Extra.h"
#import "LoginViewController.h"
#import "IntroViewController.h"
#import "LandingPageDetailViewController.h"
#import "CustomPageViewController.h"
#import "ClinicViewController.h"
#import "AnjomanViewController.h"
#import "CustomButton.h"
#import "ProjectCompanyCustomCell.h"
#import "EditProfileViewController.h"
#import "ConvertToPersianDate.h"
#import "EmkanatViewController.h"
#import "ReportAbuseViewController.h"
#import "EditCompanyViewController.h"
#import "FolloweeViewController.h"
#import "NSDictionary+LandingPage.h"
#import "UserProfileViewController.h"
#define loadingCellTag  1273


@interface CompanyProfileViewController ()<UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, AVAudioPlayerDelegate, UIWebViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    BOOL    isBusyNow;
    NSInteger  selectedRow;
    BOOL    isExpand;
    UIRefreshControl *refreshControl;
    BOOL isMenuOpen;
    UIView *menuView;
    UIImageView *menuImageView;
    NSMutableArray *menuItemsArray;
    UIScrollView *menuScrollView;
    UIImageView *selectImageView;
    NSInteger selectedItemNumber;
    UIButton *categoryButton;
    BOOL    isPagingForCategories;
    BOOL    noMoreData;
    BOOL    isRightMenuAppears;
    BOOL    isDownloadingAudio;
    BOOL    isDownloadingVideo;
    UIButton *menubuttons;
    UIView *rightMenuView;
    NSString *documentsDirectory;
    AVAudioPlayer *audioPlayer;
    BOOL isPlayingTempVoice;
    NSInteger playingAudioRowNumber;
    NSInteger whichRowShouldBeReload;
    NSTimer *playbackTimer;
    NSTimer *myTimer;
    UIView *blurViewForMenu;
    CGFloat waveformProgressNumber;
    BOOL disableTableView;
    UIImageView *profileImageView;
    UIView *galleryCameraView;
    UIView *emtyazView;
    UILabel *usernameLabel;
    UIScrollView *scrollView;
    UIView *userInfoView;
    UITableView *membersTableView;//972
    NSMutableArray *membersTableArray;
    UITableView *projectTableView;//973
    NSMutableArray *projectTableArray;
    UIButton *postButton;
    UIButton *followeeButton;
    UIButton *followersButton;
    UITextField *nameTextField;
    UITextField *emailTextField;
    UITextField *mobileTextField;
    UITextField *websiteTextField;
    UITextField *educationTextField;
    UITextField *savabeghTextField;
    UITextField *ostanTextField;
    UITextField *cityTextField;
    UIView *contactView;
    UILabel *contactTitleLabel;
    UILabel *titleLabel;
    BOOL canEdit;
    UIButton *editProfileButton;
    UIView *settingMenuView;
    NSInteger profileIdCurrent;
    //UILabel *aboutLabel;
    UITextView *aboutTextView;
    UIImageView *postButtonImageView;
    UIImageView *infoButtonImageView;
    UIImageView *showProjButtonImageView;
    UIImageView *showCompanyButtonImageView;
    UIButton *postButton1;
    UIButton *infoButton;
    UIButton *showProjectButton;
    UIButton *showCompanyButton;
    BOOL isSettingMenuShown;
    UIScrollView *namesScrollView;
    NSMutableArray *selectedTagsArray;
    NSMutableArray *selectedTagsArrayForExpertise;
    UIScrollView *namesScrollViewForExpertise;
    UIView *horizontalLineForAbout;
    UILabel *takhasosLabel;
    UIImageView *takhasosImageView;
    UILabel *noResultLabelPost;
    UILabel *noResultLabelCompany;
    UILabel *noResultLabelProject;
    NSInteger page;
    NSInteger entityID;
}
@property(nonatomic, retain)UITableView *tableView;//971
@property(nonatomic, retain)NSMutableArray *tableArray;
@property(nonatomic, retain)NSMutableArray *likeArray;
@property(nonatomic, retain)NSMutableArray *favArray;
@property(nonatomic, strong)NSIndexPath *currentIndexPath;
@property (strong, nonatomic) NSTimer *timerForProgress;
@property (strong, nonatomic) NSTimer *timerForProgressFinal;
@property(nonatomic, retain)NSDictionary *profileDictionary;
@end

@implementation CompanyProfileViewController
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

- (void)viewWillAppear:(BOOL)animated {
    [self getProfileDataFromServer];
    [self getProfileDetailFromServer];
}

- (void)viewWillDisappear:(BOOL)animated{
    self.tableView.userInteractionEnabled = YES;
}
- (void)viewDidLoad{
    self.navigationController.navigationBar.hidden = YES;
    
    [self makeTopBar];
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 70, screenWidth, screenHeight - 70)];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    
    //[self makeEmtyazView];
    [self makeImageAndButtons];
    [self makeTabBarButtons];
    
    self.tableArray = [[NSMutableArray alloc]init];
    page = 1;
    [self fetchPostsFromServer:page];
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
    
    titleLabel =[[UILabel alloc]initWithFrame:CGRectMake(screenWidth/2 - 75, topViewHeight/2 - 15, 150, 40)];
    titleLabel.font = FONT_NORMAL(16);
    titleLabel.text = NSLocalizedString(@"companyProfile", @"");
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.minimumScaleFactor = 0.5;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    [topView addSubview:titleLabel];
    
    //45x69
    UIButton *searchButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - 80, topViewHeight/2 - 4, 54 *0.3, 69 * 0.3)];
    [searchButton setBackgroundImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(searchButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:searchButton];
    
    UIButton *backButtonImg = [[UIButton alloc]initWithFrame:CGRectMake(0, 16 , 45, 45)];
    [backButtonImg setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButtonImg addTarget:self action:@selector(backButtonImgAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButtonImg];
    
    //11 × 51
    UIButton *settingButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - 50, topViewHeight/2 - 20, 50, 50)];
    [settingButton setBackgroundImage:[UIImage imageNamed:@"setting menu"] forState:UIControlStateNormal];
    [settingButton addTarget:self action:@selector(settingButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:settingButton];

}
- (void)searchButtonAction {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SearchViewController *view = (SearchViewController *)[story instantiateViewControllerWithIdentifier:@"SearchViewController"];
    [self.navigationController pushViewController:view animated:YES];
}

- (void)makeEmtyazView{
    emtyazView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 25)];
    emtyazView.backgroundColor = [UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:1.0];
    [scrollView addSubview:emtyazView];
    
    CGFloat progress = 0.9;
    UIView *progressView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth * progress, 25)];
    [emtyazView addSubview:progressView];
    
    
    // startColor Color - RED
    float red = 1.0;
    float green = 0.0;
    float blue = 0.0;
    
    //Destination Color - Green
    float finalRed = 0.0;
    float finalGreen = 1.0;
    float finalBlue = 0.0;
    CGFloat newRed   = (1.0 - progress) * red   + progress * finalRed;
    CGFloat newGreen = (1.0 - progress) * green + progress * finalGreen;
    CGFloat newBlue  = (1.0 - progress) * blue  + progress * finalBlue;
    UIColor *color = [UIColor colorWithRed:newRed green:newGreen blue:newBlue alpha:1.0];
    progressView.backgroundColor = color;
    
    UILabel *titleLabel2 =[[UILabel alloc]initWithFrame:CGRectMake(0, 0, progressView.frame.size.width, 25)];
    titleLabel2.font = FONT_NORMAL(16);
    titleLabel2.minimumScaleFactor = 0.5;
    titleLabel2.adjustsFontSizeToFitWidth = YES;
    titleLabel2.text = @"امتیاز ۲۳۰";
    titleLabel2.textColor = [UIColor whiteColor];
    titleLabel2.textAlignment = NSTextAlignmentCenter;
    [progressView addSubview:titleLabel2];
}

- (void)makeImageAndButtons{
    profileImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth/2 - 120, emtyazView.frame.origin.y + emtyazView.frame.size.height + 15, 100, 100)];
    profileImageView.layer.cornerRadius = 50;
    profileImageView.clipsToBounds = YES;
    profileImageView.image = [UIImage imageNamed:@"icon upload ax"];
    profileImageView.userInteractionEnabled = YES;
    //UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(profileImageViewAction)];
    //[profileImageView addGestureRecognizer:tap2];
    [scrollView addSubview:profileImageView];
    
    usernameLabel =[[UILabel alloc]initWithFrame:CGRectMake(profileImageView.frame.origin.x, profileImageView.frame.origin.y + profileImageView.frame.size.height - 5, profileImageView.frame.size.width, 50)];
    usernameLabel.numberOfLines = 2;
    usernameLabel.font = FONT_NORMAL(16);
    usernameLabel.minimumScaleFactor = 0.5;
    usernameLabel.adjustsFontSizeToFitWidth = YES;
    //usernameLabel.text = @"آرش جهانگیری";
    usernameLabel.textColor = [UIColor blackColor];
    usernameLabel.textAlignment = NSTextAlignmentCenter;
    [scrollView addSubview:usernameLabel];
    
    editProfileButton = [CustomButton initButtonWithTitle:@"ویرایش" withTitleColor:[UIColor whiteColor] withBackColor:[UIColor colorWithRed:64/255.0 green:139/255.0 blue:222/255.0 alpha:1.0] withFrame:CGRectMake(screenWidth/2 + 10, profileImageView.frame.origin.y + 25, 110, 30)];
    [editProfileButton addTarget:self action:@selector(editProfileButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:editProfileButton];
    
    postButton = [CustomButton initButtonWithTitle:@"0" withTitleColor:[UIColor blueColor] withBackColor:[UIColor whiteColor] withFrame:CGRectMake(screenWidth/2 - 110, usernameLabel.frame.origin.y + 50, 110, 30)];
    [postButton addTarget:self action:@selector(postButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:postButton];
    
    followeeButton = [CustomButton initButtonWithTitle:@"0" withTitleColor:[UIColor blueColor] withBackColor:[UIColor whiteColor] withFrame:CGRectMake(screenWidth/2, usernameLabel.frame.origin.y + 50, 110, 30)];
    [followeeButton addTarget:self action:@selector(followeeButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:followeeButton];
    
    followersButton = [CustomButton initButtonWithTitle:@"0" withTitleColor:[UIColor blueColor] withBackColor:[UIColor whiteColor] withFrame:CGRectMake(screenWidth/2 + 30, usernameLabel.frame.origin.y + 50, 110, 30)];
    [followersButton addTarget:self action:@selector(followersButtonAction) forControlEvents:UIControlEventTouchUpInside];
    //[scrollView addSubview:followersButton];
    
    UILabel *postLabel =[[UILabel alloc]initWithFrame:CGRectMake(screenWidth/2 - 110, postButton.frame.origin.y + 20, 110, 40)];
    postLabel.font = FONT_NORMAL(16);
    postLabel.numberOfLines = 2;
    //postLabel.minimumScaleFactor = 0.5;
    postLabel.adjustsFontSizeToFitWidth = YES;
    postLabel.text = @"پست\npost";
    postLabel.textColor = [UIColor blackColor];
    postLabel.textAlignment = NSTextAlignmentCenter;
    postLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(postButtonAction)];
    [postLabel addGestureRecognizer:tap];
    [scrollView addSubview:postLabel];
    
    UILabel *followeeLabel =[[UILabel alloc]initWithFrame:CGRectMake( screenWidth/2, postButton.frame.origin.y + 20, 110, 40)];
    followeeLabel.font = FONT_NORMAL(16);
    followeeLabel.numberOfLines = 2;
    //followeeLabel.minimumScaleFactor = 0.5;
    followeeLabel.adjustsFontSizeToFitWidth = YES;
    followeeLabel.text = @"دنبال کننده\nfollower";
    followeeLabel.textColor = [UIColor blackColor];
    followeeLabel.textAlignment = NSTextAlignmentCenter;
    followeeLabel.textAlignment = NSTextAlignmentCenter;
    followeeLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(followeeButtonAction)];
    [followeeLabel addGestureRecognizer:tap2];
    [scrollView addSubview:followeeLabel];
    
    UILabel *followersLabel =[[UILabel alloc]initWithFrame:CGRectMake(screenWidth/2 + 30, postButton.frame.origin.y + 20, 110, 40)];
    followersLabel.font = FONT_NORMAL(16);
    followersLabel.numberOfLines = 2;
    //followersLabel.minimumScaleFactor = 0.5;
    followersLabel.adjustsFontSizeToFitWidth = YES;
    followersLabel.text = @"دنبال کننده\nfollower";
    followersLabel.textColor = [UIColor blackColor];
    followersLabel.textAlignment = NSTextAlignmentCenter;
    //[scrollView addSubview:followersLabel];
}

- (void)makeTabBarButtons{
    
    //UIButton *postButton1 = [CustomButton initButtonWithImage:[UIImage imageNamed:@"icon_tab_timeline_unselected"] withFrame:CGRectMake(0, usernameLabel.frame.origin.y + 110, screenWidth / 2, 30)];
    postButton1 = [CustomButton initButtonWithTitle:@"" withTitleColor:[UIColor clearColor] withBackColor:TABBAR isRounded:NO withFrame:CGRectMake(0, usernameLabel.frame.origin.y + 110, screenWidth / 2, 30)];
    [postButton1 addTarget:self action:@selector(showPostButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:postButton1];
    
    //213 × 100
    postButtonImageView = [[UIImageView alloc]initWithFrame:CGRectMake(postButton1.frame.size.width/2 - (213/8), 0, 213 / 4, 100 / 4)];
    postButtonImageView.image = [UIImage imageNamed:@"icon_tab_timeline_unselected"];
    [postButton1 addSubview:postButtonImageView];

    
    //UIButton *infoButton = [CustomButton initButtonWithImage:[UIImage imageNamed:@"icon_tab_info"] withFrame:CGRectMake(screenWidth / 2, usernameLabel.frame.origin.y + 110, screenWidth / 2, 30)];
    infoButton = [CustomButton initButtonWithTitle:@"" withTitleColor:[UIColor clearColor] withBackColor:TABBAR isRounded:NO withFrame:CGRectMake(screenWidth / 2, usernameLabel.frame.origin.y + 110, screenWidth / 2, 30)];
    [infoButton addTarget:self action:@selector(showUserInfoButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:infoButton];
    
    //213 × 100
    infoButtonImageView = [[UIImageView alloc]initWithFrame:CGRectMake(infoButton.frame.size.width/2 - (213/8), 0, 213 / 4, 100 / 4)];
    infoButtonImageView.image = [UIImage imageNamed:@"icon_tab_info"];
    [infoButton addSubview:infoButtonImageView];
    
    [self makeTabbarElementsWithYpos:postButton1.frame.origin.y + 30];
    
}

- (void)makeTabbarElementsWithYpos:(CGFloat)yPos{
    NSArray *array = [Database selectFromLandingPageWithFilePath:[Database getDbFilePath]];
    _tableArray = [[NSMutableArray alloc]initWithArray:array];
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, yPos, screenWidth, screenHeight - yPos)];
    self.tableView.delegate = self;
    self.tableView.tag = 971;
    self.tableView.dataSource = self;
    [scrollView addSubview:self.tableView];
    
    userInfoView = [[UIView alloc]initWithFrame:CGRectMake(0, yPos, screenWidth, 300)];
    userInfoView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:userInfoView];
    [self makeUserInfoView:userInfoView];
    
    //membersTableArray = [[NSMutableArray alloc]initWithArray:array];
    membersTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, yPos, screenWidth, screenHeight - yPos)];
    membersTableView.delegate = self;
    membersTableView.tag = 972;
    membersTableView.dataSource = self;
    [scrollView addSubview:membersTableView];
    
    //projectTableArray = [[NSMutableArray alloc]initWithArray:array];
    projectTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, yPos, screenWidth, screenHeight - yPos)];
    projectTableView.delegate = self;
    projectTableView.tag = 973;
    projectTableView.dataSource = self;
    //[scrollView addSubview:projectTableView];
    
//    [self makeContactViewWithYpos:yPos + 180];
//    
//    [self showUserInfoButtonAction];
}

- (void)makeContactViewWithYpos:(CGFloat)yPos{
    [contactTitleLabel removeFromSuperview];
    contactTitleLabel =[[UILabel alloc]initWithFrame:CGRectMake(0, yPos, screenWidth, 30)];
    contactTitleLabel.font = FONT_NORMAL(16);
    contactTitleLabel.minimumScaleFactor = 0.5;
    contactTitleLabel.adjustsFontSizeToFitWidth = YES;
    contactTitleLabel.text = @"راه های تماس";
    contactTitleLabel.textColor = [UIColor whiteColor];
    contactTitleLabel.backgroundColor = [UIColor colorWithRed:47/255.0 green:197/255.0 blue:137/255.0 alpha:1.0];
    contactTitleLabel.textAlignment = NSTextAlignmentCenter;
    [scrollView addSubview:contactTitleLabel];
    
    [contactView removeFromSuperview];
    contactView = [[UIView alloc]initWithFrame:CGRectMake(0, yPos + 30, screenWidth, 150)];
    contactView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:contactView];
    
    //email
    emailTextField = [[UITextField alloc]initWithFrame:CGRectMake(10, 10, screenWidth - 60, 25)];
    emailTextField.backgroundColor = [UIColor whiteColor];
    emailTextField.placeholder = NSLocalizedString(@"email", @"");
    emailTextField.text = _profileDictionary.emailProfile;
    emailTextField.tag = 103;
    emailTextField.font = FONT_NORMAL(12);
    emailTextField.layer.borderColor = [UIColor clearColor].CGColor;
    emailTextField.layer.borderWidth = 1.0;
    emailTextField.layer.cornerRadius = 5;
    emailTextField.clipsToBounds = YES;
    emailTextField.minimumFontSize = 0.5;
    emailTextField.adjustsFontSizeToFitWidth = YES;
    emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    emailTextField.textAlignment = NSTextAlignmentCenter;
    emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    [contactView addSubview:emailTextField];
    emailTextField.userInteractionEnabled = NO;
    
    //44x31
    UIImageView *emailImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 40, 10, 44 / 2, 31 / 2)];
    emailImageView.image = [UIImage imageNamed:@"icon_email"];
    emailImageView.userInteractionEnabled = YES;
    [contactView addSubview:emailImageView];
    
    UIView *horizontalLine3 = [[UIView alloc]initWithFrame:CGRectMake(20, emailTextField.frame.origin.y + 25, screenWidth - 40, 0.5)];
    horizontalLine3.backgroundColor = [UIColor lightGrayColor];
    [contactView addSubview:horizontalLine3];
    
    //mobile
    mobileTextField = [[UITextField alloc]initWithFrame:CGRectMake(screenWidth/2 - 80, horizontalLine3.frame.origin.y + 40, 160, 25)];
    mobileTextField.placeholder = NSLocalizedString(@"mobile", @"");
    mobileTextField.backgroundColor = [UIColor clearColor];
    mobileTextField.tag = 104;
    mobileTextField.font = FONT_NORMAL(15);
    mobileTextField.layer.borderColor = [UIColor clearColor].CGColor;
    mobileTextField.layer.borderWidth = 1.0;
    mobileTextField.layer.cornerRadius = 5;
    mobileTextField.clipsToBounds = YES;
    mobileTextField.keyboardType = UIKeyboardTypeNumberPad;
    mobileTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    mobileTextField.textAlignment = NSTextAlignmentCenter;
    mobileTextField.keyboardType = UIKeyboardTypeNumberPad;
    [contactView addSubview:mobileTextField];
    mobileTextField.userInteractionEnabled = NO;
    
    //36x36
    UIImageView *mobileImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 40, horizontalLine3.frame.origin.y + 40, 33 / 2, 34 / 2)];
    mobileImageView.image = [UIImage imageNamed:@"icon_tel"];
    mobileImageView.userInteractionEnabled = YES;
    [contactView addSubview:mobileImageView];
    
    UIView *horizontalLine4 = [[UIView alloc]initWithFrame:CGRectMake(20, mobileTextField.frame.origin.y + 25, screenWidth - 40, 0.5)];
    horizontalLine4.backgroundColor = [UIColor lightGrayColor];
    [contactView addSubview:horizontalLine4];
    
    //website
    websiteTextField = [[UITextField alloc]initWithFrame:CGRectMake(screenWidth/2 - 80, horizontalLine4.frame.origin.y + 40, 160, 25)];
    websiteTextField.placeholder = NSLocalizedString(@"website", @"");
    websiteTextField.backgroundColor = [UIColor clearColor];
    websiteTextField.tag = 104;
    websiteTextField.font = FONT_NORMAL(15);
    websiteTextField.layer.borderColor = [UIColor clearColor].CGColor;
    websiteTextField.layer.borderWidth = 1.0;
    websiteTextField.layer.cornerRadius = 5;
    websiteTextField.clipsToBounds = YES;
    websiteTextField.keyboardType = UIKeyboardTypeNumberPad;
    websiteTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    websiteTextField.textAlignment = NSTextAlignmentCenter;
    websiteTextField.keyboardType = UIKeyboardTypeNumberPad;
    [contactView addSubview:websiteTextField];
    websiteTextField.userInteractionEnabled = NO;
    
    //36x36
    UIImageView *websiteImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 40, horizontalLine4.frame.origin.y + 40, 33 / 2, 34 / 2)];
    websiteImageView.image = [UIImage imageNamed:@"icon_website"];
    websiteImageView.userInteractionEnabled = YES;
    [contactView addSubview:websiteImageView];
    
    UIView *horizontalLine5 = [[UIView alloc]initWithFrame:CGRectMake(20, websiteTextField.frame.origin.y + 25, screenWidth - 40, 0.5)];
    horizontalLine5.backgroundColor = [UIColor lightGrayColor];
    [contactView addSubview:horizontalLine5];
    
    scrollView.contentSize = CGSizeMake(screenWidth, contactView.frame.origin.y + 250);
}
- (void)profileImageViewAction{
    [self showgalleryCameraView];
    //[self dismissTextField];
}

- (void)editProfileButtonAction{
    if (canEdit) {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    EditCompanyViewController *view = (EditCompanyViewController *)[story instantiateViewControllerWithIdentifier:@"EditCompanyViewController"];
    view.isFromEditCompany = YES;
    view.profileDictionary = _dictionary;
        view.selectedTagsArray1 = selectedTagsArrayForExpertise;
    [self presentViewController:view animated:YES completion:nil];
    } else {
        [self followProjectConnection:[[_dictionary objectForKey:@"id"]integerValue]];
    }
}

- (void)postButtonAction{
    [self showPostButtonAction];
}
- (void)followersButtonAction{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FolloweeViewController *view = (FolloweeViewController *)[story instantiateViewControllerWithIdentifier:@"FolloweeViewController"];
    view.isFollowee = NO;
    view.isFromComORProj = YES;
    [self.navigationController pushViewController:view animated:YES];
}

- (void)followeeButtonAction{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FolloweeViewController *view = (FolloweeViewController *)[story instantiateViewControllerWithIdentifier:@"FolloweeViewController"];
    view.isFromComORProj = YES;
    view.isFollowee = YES;
    view.entityID = [[_dictionary objectForKey:@"id"]integerValue];
    [self.navigationController pushViewController:view animated:YES];
}

- (void)showPostButtonAction{
    scrollView.contentSize = CGSizeMake(screenWidth, contactView.frame.origin.y + 200);
    CGRect rect = _tableView.frame;
    rect.size.height = contactView.frame.origin.y - 100;
    _tableView.frame = rect;

    _tableView.hidden = NO;
    userInfoView.hidden = YES;
    membersTableView.hidden = YES;
    projectTableView.hidden = YES;
    contactTitleLabel.hidden = YES;
    contactView.hidden = YES;
    
    postButtonImageView.image = [UIImage imageNamed:@"icon_tab_timeline"];
    [postButton1 setBackgroundColor:TABBAR_SELECTED];
    
    infoButtonImageView.image =  [UIImage imageNamed:@"icon_tab_info_unselected"];
    [infoButton setBackgroundColor:TABBAR];

}

- (void)showUserInfoButtonAction{
    _tableView.hidden = YES;
    userInfoView.hidden = NO;
    membersTableView.hidden = YES;
    projectTableView.hidden = YES;
    contactTitleLabel.hidden = NO;
    contactView.hidden = NO;
    
    postButtonImageView.image = [UIImage imageNamed:@"icon_tab_timeline_unselected"];
    [postButton1 setBackgroundColor:TABBAR];
    
    infoButtonImageView.image =  [UIImage imageNamed:@"icon_tab_info"];
    [infoButton setBackgroundColor:TABBAR_SELECTED];

}

- (void)showMembersButtonAction{
    _tableView.hidden = YES;
    userInfoView.hidden = YES;
    membersTableView.hidden = NO;
    projectTableView.hidden = YES;
    contactTitleLabel.hidden = YES;
    contactView.hidden = YES;
}

- (void)showCompanyButtonAction{
    _tableView.hidden = YES;
    userInfoView.hidden = YES;
    membersTableView.hidden = YES;
    projectTableView.hidden = NO;
}

- (void)makeUserInfoView:(UIView *)view{
    
    //name
    nameTextField = [[UITextField alloc]initWithFrame:CGRectMake(10, 15, screenWidth - 60, 25)];
    nameTextField.backgroundColor = [UIColor whiteColor];
    nameTextField.placeholder = NSLocalizedString(@"name", @"");
    nameTextField.text = _profileDictionary.first_nameProfile;
    nameTextField.tag = 101;
    nameTextField.font = FONT_NORMAL(15);
    nameTextField.layer.borderColor = [UIColor clearColor].CGColor;
    nameTextField.layer.borderWidth = 1.0;
    nameTextField.layer.cornerRadius = 5;
    nameTextField.clipsToBounds = YES;
    nameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    nameTextField.textAlignment = NSTextAlignmentCenter;
    [view addSubview:nameTextField];
    nameTextField.userInteractionEnabled = NO;
    
    //29x40
    UIImageView *nameImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 40, 15, 29 / 2, 40 / 2)];
    nameImageView.image = [UIImage imageNamed:@"icon upload ax"];
    nameImageView.userInteractionEnabled = YES;
    [view addSubview:nameImageView];
    
    UIView *horizontalLine = [[UIView alloc]initWithFrame:CGRectMake(20, nameTextField.frame.origin.y + 25, screenWidth - 40, 0.5)];
    horizontalLine.backgroundColor = [UIColor lightGrayColor];
    [view addSubview:horizontalLine];
    
    aboutTextView = [[UITextView alloc]initWithFrame:CGRectMake(screenWidth/2 - 80, horizontalLine.frame.origin.y + 20, 160, 45)];
    aboutTextView.editable = NO;
    aboutTextView.selectable = NO;
    aboutTextView.font = FONT_NORMAL(15);
    [view addSubview:aboutTextView];
//    aboutLabel =[[UILabel alloc]initWithFrame:CGRectMake(screenWidth/2 - 80, horizontalLine.frame.origin.y + 20, 160, 45)];
//    aboutLabel.font = FONT_NORMAL(15);
//    aboutLabel.numberOfLines = 2;
//    aboutLabel.adjustsFontSizeToFitWidth = YES;
//    aboutLabel.minimumScaleFactor = 0.5;
//    aboutLabel.textColor = [UIColor blackColor];
//    aboutLabel.textAlignment = NSTextAlignmentCenter;
//    [view addSubview:aboutLabel];

    //33x34
    UIImageView *abouteImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 40, horizontalLine.frame.origin.y + 35, 33 / 2, 34 / 2)];
    abouteImageView.image = [UIImage imageNamed:@"icon_job"];
    abouteImageView.userInteractionEnabled = YES;
    [view addSubview:abouteImageView];
    
    horizontalLineForAbout = [[UIView alloc]initWithFrame:CGRectMake(20, aboutTextView.frame.origin.y + 45, screenWidth - 40, 0.5)];
    horizontalLineForAbout.backgroundColor = [UIColor lightGrayColor];
    [view addSubview:horizontalLineForAbout];
    
    //60x24
    takhasosImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 40, horizontalLineForAbout.frame.origin.y + 28, 60 / 3, 24 / 3)];
    takhasosImageView.image = [UIImage imageNamed:@"takhasos"];
    takhasosImageView.userInteractionEnabled = YES;
    [view addSubview:takhasosImageView];
    
    takhasosLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, horizontalLineForAbout.frame.origin.y + 20, screenWidth - 50,  25)];
    takhasosLabel.font = FONT_MEDIUM(13);
    takhasosLabel.text = @"تخصص ها";
    takhasosLabel.minimumScaleFactor = 0.7;
    takhasosLabel.textColor = [UIColor lightGrayColor];
    takhasosLabel.textAlignment = NSTextAlignmentRight;
    takhasosLabel.adjustsFontSizeToFitWidth = YES;
    [view addSubview:takhasosLabel];
    
    namesScrollViewForExpertise = [[UIScrollView alloc]initWithFrame:CGRectMake(0, takhasosLabel.frame.origin.y + 15, screenWidth, 40)];
    namesScrollViewForExpertise.contentSize = CGSizeMake(screenWidth * 2, 40);
    [view addSubview:namesScrollViewForExpertise];
}

- (CGFloat)getHeightOfString:(NSString *)labelText{
    
    UIFont *font = FONT_NORMAL(16);
    if (IS_IPAD) {
        font = FONT_NORMAL(26);
    }
    CGSize sizeOfText = [labelText boundingRectWithSize: CGSizeMake( self.view.bounds.size.width - 30,CGFLOAT_MAX)
                                                options: (NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                             attributes: [NSDictionary dictionaryWithObject:font
                                                                                     forKey:NSFontAttributeName]
                                                context: nil].size;
    CGFloat height = sizeOfText.height + 50;
//    if (height < screenWidth + 10)
//        height = screenWidth + 10;
    return height;
}

- (void)followimageViewActionForCompany:(UITapGestureRecognizer *)tap{
    //NSLog(@"%d", tap.view.tag);
    NSDictionary *dic = [membersTableArray objectAtIndex:tap.view.tag];
    //NSLog(@"%@", [dic objectForKey:@"id"]);
    [self followCompanyConnection:[[dic objectForKey:@"id"]integerValue] row:tap.view.tag];
}

- (void)followimageViewActionForProject:(UITapGestureRecognizer *)tap{
    //NSLog(@"%d", tap.view.tag);
    NSDictionary *dic = [projectTableArray objectAtIndex:tap.view.tag];
    //NSLog(@"%@", [dic objectForKey:@"id"]);
    [self followProjectConnection:[[dic objectForKey:@"id"]integerValue]];
}
- (void)backButtonImgAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)settingButtonAction{
    if (canEdit) {
        if (isSettingMenuShown) {
            [settingMenuView removeFromSuperview];
            isSettingMenuShown = NO;
            return;
        } else {
            [settingMenuView removeFromSuperview];
            settingMenuView = [[UIView alloc]initWithFrame:CGRectMake(screenWidth - 100, 70, 100, 100)];
            settingMenuView.backgroundColor = [UIColor whiteColor];
            [self.view addSubview:settingMenuView];
            
            UIButton *deleteButton = [CustomButton initButtonWithTitle:@"حذف" withTitleColor:[UIColor blackColor] withBackColor:[UIColor clearColor] withFrame:CGRectMake(20, 10, settingMenuView.frame.size.width - 20, 30)];
            [deleteButton addTarget:self action:@selector(deleteButtonAction) forControlEvents:UIControlEventTouchUpInside];
            [settingMenuView addSubview:deleteButton];
            
            UIButton *editButton = [CustomButton initButtonWithTitle:@"ویرایش" withTitleColor:[UIColor blackColor] withBackColor:[UIColor clearColor] withFrame:CGRectMake(20, 50, settingMenuView.frame.size.width - 20, 30)];
            [editButton addTarget:self action:@selector(editButtonAction) forControlEvents:UIControlEventTouchUpInside];
            [settingMenuView addSubview:editButton];
            isSettingMenuShown = YES;
        }
        
    } else {
        if (isSettingMenuShown) {
            [settingMenuView removeFromSuperview];
            isSettingMenuShown = NO;
            return;
        } else {
            [settingMenuView removeFromSuperview];
            settingMenuView = [[UIView alloc]initWithFrame:CGRectMake(screenWidth - 100, 70, 100, 100)];
            settingMenuView.backgroundColor = [UIColor whiteColor];
            [self.view addSubview:settingMenuView];
            
            UIButton *reportButton = [CustomButton initButtonWithTitle:@"گزارش خطا" withTitleColor:[UIColor blackColor] withBackColor:[UIColor clearColor] withFrame:CGRectMake(20, 10, settingMenuView.frame.size.width - 20, 30)];
            [reportButton addTarget:self action:@selector(reportButtonAction) forControlEvents:UIControlEventTouchUpInside];
            [settingMenuView addSubview:reportButton];
            
            UIButton *messageButton = [CustomButton initButtonWithTitle:@"ارسال پیام" withTitleColor:[UIColor blackColor] withBackColor:[UIColor clearColor] withFrame:CGRectMake(20, 50, settingMenuView.frame.size.width - 20, 30)];
            [messageButton addTarget:self action:@selector(messageButtonAction) forControlEvents:UIControlEventTouchUpInside];
            //[settingMenuView addSubview:messageButton];
            isSettingMenuShown = YES;
        }
        
        
    }
    
}

- (void)reportButtonAction{
    [self dismissTextView];
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ReportAbuseViewController *view = (ReportAbuseViewController *)[story instantiateViewControllerWithIdentifier:@"ReportAbuseViewController"];
    view.idOfProfile = profileIdCurrent;
    view.model = @"entity";
    [self presentViewController:view animated:YES completion:nil];
}

- (void)messageButtonAction{
    [self dismissTextView];
    [self.tabBarController setSelectedIndex:4];
    
}

- (void)editButtonAction{
    [self dismissTextView];
    [self editProfileButtonAction];
}

- (void)deleteButtonAction{
    [self dismissTextView];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"حذف پروفایل شرکت" message:@"آیا اطمینان دارید؟" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"حذف" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self deleteFromServer];
    }];
    [alert addAction:okAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"خیر" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)dismissTextView{
    [settingMenuView removeFromSuperview];
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

- (void)reloadTagsViewForExpertise{
    NSArray *viewsToRemove = [namesScrollViewForExpertise subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    
    //CGFloat yPosOfSelectTagsLabel = 10;
    NSInteger countOfTags = [selectedTagsArrayForExpertise count];
    CGFloat yPOS = 10;
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
        //        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(deleteTagImageForExpertiseAction:)];
        //        [label addGestureRecognizer:tap];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [NSString stringWithFormat:@"%@", tagName];
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

- (void)tapOnAuthorImage:(UITapGestureRecognizer *)tap{
    NSDictionary *tempDic = _dictionary;
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UserProfileViewController *view = (UserProfileViewController *)[story instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
    view.entityID = [[tempDic objectForKey:@"id"]integerValue];//[[[tempDic objectForKey:@"entity"]objectForKey:@"id"]integerValue];
    view.dictionary = tempDic;
    [self.navigationController pushViewController:view animated:YES];
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
    galleryCameraView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
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

- (NSString *)encodeToBase64String:(UIImage *)image {
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:0];
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

#pragma mark - table view delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag == 971) {
        return [self.tableArray count];
    } else if (tableView.tag == 972) {
        return [membersTableArray count];
    } else if (tableView.tag == 973) {
        return [projectTableArray count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == 971) {//posts table view
        if (IS_IPAD) {
            
            if (selectedRow == indexPath.row) {
                if (isExpand) {
                    NSDictionary *landingPageDic = [self.tableArray objectAtIndex:indexPath.row];
                    return [self getHeightOfString:landingPageDic.LPContent];
                    
                } else {
                    return screenWidth + 10;
                }
            } else {
                return screenWidth + 10;
            }
            
        } else {
            if (selectedRow == indexPath.row) {
                if (isExpand) {
                    NSDictionary *landingPageDic = [self.tableArray objectAtIndex:indexPath.row];
                    return [self getHeightOfString:landingPageDic.LPContent];
                    
                } else {
                    return screenWidth + 25;
                }
            } else {
                return screenWidth + 25;
            }
        }
    } else if (tableView.tag == 972){
        return 80;
    } else if (tableView.tag == 973){
        return 80;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    id cellToReturn=nil;
    
    if (tableView.tag == 971){
        if (_tableView.hidden == NO) {
            if (indexPath.row < 2) {
                [scrollView setContentOffset:CGPointZero animated:YES];
            }else{
                CGPoint bottomOffset = CGPointMake(0, scrollView.contentSize.height - scrollView.bounds.size.height);
                [scrollView setContentOffset:bottomOffset animated:YES];
            }
        }
        
        NSDictionary *landingPageDic = [self.tableArray objectAtIndex:indexPath.row];
        NSString *postType = landingPageDic.LPPostType;
        
            //audio
        if ([postType isEqualToString:@"audio"]) {
                //NSString *cellIdentifier = [NSString stringWithFormat:@"S%1ldR%1ld",(long)indexPath.section,(long)indexPath.row];
            LandingPageCustomCellAudio *cell = [tableView dequeueReusableCellWithIdentifier:@"cell1"];
            if (cell == nil)
                cell = (LandingPageCustomCellAudio *)[[LandingPageCustomCellAudio alloc]
                                                      initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell1"];
            if (indexPath.row < [self.tableArray count] - 1) {
                if ([self.tableArray count] > 0) {
                    cell.tag = indexPath.row;
                    
                        //title
                    cell.titleLabel.text = landingPageDic.LPTitle;
                    
                        //date
                    NSDateFormatter *currentDateFormatter = [[NSDateFormatter alloc]init];
                    [currentDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    NSDate *endDate = [NSDate date];
                    
                    double timestampval = [landingPageDic.LPPublish_date doubleValue];
                    NSTimeInterval timestamp = (NSTimeInterval)timestampval;
                    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
                    cell.dateLabel.text = [NSString stringWithFormat:@"%@",
                                           [TimeAgoViewController timeIntervalWithStartDate:startDate withEndDate:endDate]];
                    
                        //post image
                        //451 × 73
                    cell.postImageView.image = [UIImage imageNamed:@"progress play"];
                    
                        //play download icon
                        //UIButton *downloadPlayButton = [[UIButton alloc]initWithFrame:CGRectMake(10, cell.postImageView.frame.size.height + 80, 40, 40)];
                        //
                    BOOL isDirectory;
                    NSString *documentPath = [DocumentDirectoy getDocuementsDirectory];
                    NSString *pathOfAudio = [NSString stringWithFormat:@"%@/%@", documentPath, [landingPageDic.LPAudioUrl lastPathComponent]];
                    cell.downloadPlayButton.tag = indexPath.row;
                    if ([[NSFileManager defaultManager]fileExistsAtPath:pathOfAudio isDirectory:&isDirectory]) {
                        cell.largeProgressView.hidden = YES;
                        [cell.downloadPlayButton setImage:[UIImage imageNamed:@"play icon"] forState:UIControlStateNormal];
                        [cell.downloadPlayButton addTarget:self action:@selector(playAudio:) forControlEvents:UIControlEventTouchUpInside];
                        AVAudioPlayer *cellaudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:
                                                          [NSURL URLWithString:[NSString stringWithFormat:@"%@", pathOfAudio]]error:nil];
                            ////NSLog(@"%f", cellaudioPlayer.duration);
                        cell.totalDurationLabel.text = [NSString stringWithFormat:@"%@", [self formattedTime:cellaudioPlayer.duration]];
                        
                        
                        
                        
                    } else {
                        [cell.downloadPlayButton setImage:[UIImage imageNamed:@"download icon"] forState:UIControlStateNormal];
                            //[cell.downloadPlayButton addTarget:self action:@selector(downloadPlayButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                        cell.largeProgressView.tag = indexPath.row;
                        cell.largeProgressView.userInteractionEnabled = YES;
                            //UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(downloadPlayButtonAction:)];
                            //[cell.largeProgressView addGestureRecognizer:tap];
                        [cell.largeProgressView setNeedsDisplay];
                        if (cell.largeProgressView.progress >= 1.0f) {
                            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                        }
                        
                    }
                    
                    if (isPlayingTempVoice && playingAudioRowNumber == indexPath.row) {
                        [cell.downloadPlayButton setImage:[UIImage imageNamed:@"Stop"] forState:UIControlStateNormal];
                        cell.currentTimeLabel.text = [NSString stringWithFormat:@"%@", [self formattedTime:audioPlayer.currentTime]];
                    }else{
                        cell.currentTimeLabel.text = @"00:00";
                    }
                    
                        //category
                    cell.categoryLabel.text = landingPageDic.LPCategoryName;
                    
                        //seen label
                    cell.commentCountLabel.text = landingPageDic.LPRecommends_count;
                    
                        //like label
                    cell.likeCountLabel.text = [NSString stringWithFormat:@"%ld", (long)landingPageDic.LPLikes_count];
                    cell.likeCountLabel.tag = indexPath.row;
                        //author image
                    [cell.authorImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", landingPageDic.LPUserAvatarUrl]] placeholderImage:[UIImage imageNamed:@"icon upload ax"]];
                    cell.authorImageView.userInteractionEnabled = YES;
                    cell.authorImageView.tag = indexPath.row;
                        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]init];
                        [tap addTarget:self action:@selector(tapOnAuthorImage:)];
                        [cell.authorImageView addGestureRecognizer:tap];
                    
                        //author name
                    cell.authorNameLabel.text = landingPageDic.LPUserTitle;
                    
                        //author job title
                    cell.authorJobLabel.text = landingPageDic.LPUserJobTitle;
                    
                        //content
                    cell.contentLabel.text = landingPageDic.LPContent;
                        //cell.contentLabel.text = [[cell.contentLabel.text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
                    
                    if (selectedRow == indexPath.row) {
                        cell.commentImageView.image = [UIImage imageNamed:@"comment"];
                        CGRect rect = cell.contentLabel.frame;
                        rect.size.height = [self getHeightOfString:landingPageDic.LPContent];
                            //rect.origin.y = cell.authorImageView.frame.origin.y - 100;
                        if (rect.origin.y < cell.authorImageView.frame.origin.y) {
                            rect.origin.y = cell.authorImageView.frame.origin.y;
                        }
                        [cell.contentLabel setFrame:rect];
                        [cell.contentLabel sizeToFit];
                    }else{
                        cell.commentImageView.image = [UIImage imageNamed:@"comment"];
                    }
                    
                    cell.favButton.tag = indexPath.row;
                        //[cell.favButton addTarget:self action:@selector(favButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                    
                    cell.heartButton.tag = indexPath.row;
                        //[cell.heartButton addTarget:self action:@selector(likeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                    
                    cell.shareButton.tag = indexPath.row;
                        //[cell.shareButton addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                    
                    if ([landingPageDic.LPFavorite integerValue] == 0) {
                        [cell.favButton setImage:[UIImage imageNamed:@"fav off"] forState:UIControlStateNormal];
                    }else{
                        [cell.favButton setImage:[UIImage imageNamed:@"fav on"] forState:UIControlStateNormal];
                    }
                    
                    if ([landingPageDic.LPLiked integerValue] == 0) {
                        [cell.heartButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
                    }else{
                        [cell.heartButton setImage:[UIImage imageNamed:@"like on"] forState:UIControlStateNormal];
                    }
                }
            }
            cellToReturn = cell;
                //video
        }else if ([postType isEqualToString:@"video"]){
                //NSString *cellIdentifier = [NSString stringWithFormat:@"S%1ldR%1ld",(long)indexPath.section,(long)indexPath.row];
            LandingPageCustomCellVideo *cell = [tableView dequeueReusableCellWithIdentifier:@"cell2"];
            
            if (cell == nil)
                cell = (LandingPageCustomCellVideo *)[[LandingPageCustomCellVideo alloc]
                                                      initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell2"];
            if (indexPath.row < [self.tableArray count] - 1) {
                if ([self.tableArray count] > 0) {
                    cell.tag = indexPath.row;
                    
                        //title
                    cell.titleLabel.text = landingPageDic.LPTitle;
                    
                        //date
                    NSDateFormatter *currentDateFormatter = [[NSDateFormatter alloc]init];
                    [currentDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    NSDate *endDate = [NSDate date];
                    
                    double timestampval = [landingPageDic.LPPublish_date doubleValue];
                    NSTimeInterval timestamp = (NSTimeInterval)timestampval;
                    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
                    cell.dateLabel.text = [NSString stringWithFormat:@"%@",
                                           [TimeAgoViewController timeIntervalWithStartDate:startDate withEndDate:endDate]];
                    
                        //post image
                    [cell.postImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", landingPageDic.LPImageUrl]] placeholderImage:[UIImage imageNamed:@"broken_image"]];
                    
                        //category
                    cell.categoryLabel.text = landingPageDic.LPCategoryName;
                    
                        //seen label
                    cell.commentCountLabel.text = landingPageDic.LPRecommends_count;
                    
                        //like label
                    cell.likeCountLabel.text = [NSString stringWithFormat:@"%ld", (long)landingPageDic.LPLikes_count ];
                    cell.likeCountLabel.tag = indexPath.row;
                        //author image
                    [cell.authorImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", landingPageDic.LPUserAvatarUrl]] placeholderImage:[UIImage imageNamed:@"icon upload ax"]];
                    cell.authorImageView.userInteractionEnabled = YES;
                    cell.authorImageView.tag = indexPath.row;
                        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]init];
                        [tap addTarget:self action:@selector(tapOnAuthorImage:)];
                        [cell.authorImageView addGestureRecognizer:tap];
                    
                        //author name
                    cell.authorNameLabel.text = landingPageDic.LPUserTitle;
                    
                        //author job title
                    cell.authorJobLabel.text = landingPageDic.LPUserJobTitle;
                    
                        //content
                    cell.contentLabel.text = landingPageDic.LPContent;
                        //cell.contentLabel.text = [[cell.contentLabel.text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
                    
                    if (selectedRow == indexPath.row) {
                        cell.commentImageView.image = [UIImage imageNamed:@"comment"];
                        CGRect rect = cell.contentLabel.frame;
                        rect.size.height = [self getHeightOfString:landingPageDic.LPContent];
                            //rect.origin.y = cell.authorImageView.frame.origin.y - 100;
                        if (rect.origin.y < cell.authorImageView.frame.origin.y) {
                            rect.origin.y = cell.authorImageView.frame.origin.y;
                        }
                        [cell.contentLabel setFrame:rect];
                        [cell.contentLabel sizeToFit];
                    }else{
                        cell.commentImageView.image = [UIImage imageNamed:@"comment"];
                    }
                    
                    cell.favButton.tag = indexPath.row;
                        //[cell.favButton addTarget:self action:@selector(favButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                    
                    cell.heartButton.tag = indexPath.row;
                        //[cell.heartButton addTarget:self action:@selector(likeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                    
                    cell.shareButton.tag = indexPath.row;
                        //[cell.shareButton addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                    
                    if ([landingPageDic.LPFavorite integerValue] == 0) {
                        [cell.favButton setImage:[UIImage imageNamed:@"fav off"] forState:UIControlStateNormal];
                    }else{
                        [cell.favButton setImage:[UIImage imageNamed:@"fav on"] forState:UIControlStateNormal];
                    }
                    
                    if ([landingPageDic.LPLiked integerValue] == 0) {
                        [cell.heartButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
                    }else{
                        [cell.heartButton setImage:[UIImage imageNamed:@"like on"] forState:UIControlStateNormal];
                    }
                }
            }
            cellToReturn = cell;
        }
            //other post types
        else{
                //NSString *cellIdentifier = [NSString stringWithFormat:@"S%1ldR%1ld",(long)indexPath.section,(long)indexPath.row];
            LandingPageCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell3"];
            
            if (cell == nil){
                if (([landingPageDic.LPImageUrl length] > 10) || ([landingPageDic.LPImageUrl length] > 10)) {
                    cell = (LandingPageCustomCell *)[[LandingPageCustomCell alloc]
                                                     initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell3" isPostImage:YES];
                }else{
                    cell = (LandingPageCustomCell *)[[LandingPageCustomCell alloc]
                                                     initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell3" isPostImage:NO];
                }
            }
            
            if (indexPath.row < [self.tableArray count]) {
                if ([self.tableArray count] > 0) {
                    cell.tag = indexPath.row;
                    
                        //title
                    cell.titleLabel.text = landingPageDic.LPTitle;
                    
                        //date
                    NSDateFormatter *currentDateFormatter = [[NSDateFormatter alloc]init];
                    [currentDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    NSDate *endDate = [NSDate date];
                    
                    double timestampval = [landingPageDic.LPPublish_date doubleValue];
                    NSTimeInterval timestamp = (NSTimeInterval)timestampval;
                    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
                    cell.dateLabel.text = [NSString stringWithFormat:@"%@",
                                           [TimeAgoViewController timeIntervalWithStartDate:startDate withEndDate:endDate]];
                    
                        //post image
                    [cell.postImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", landingPageDic.LPImageUrl]] placeholderImage:[UIImage imageNamed:@"broken_image"]];
                    
                        //category
                    cell.categoryLabel.text = landingPageDic.LPCategoryName;
                    
                        //seen label
                    cell.commentCountLabel.text = landingPageDic.LPRecommends_count;
                    
                        //like label
                    cell.likeCountLabel.text = [NSString stringWithFormat:@"%ld", (long)landingPageDic.LPLikes_count];
                    cell.likeCountLabel.tag = indexPath.row;
                        //author image
                    [cell.authorImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", landingPageDic.LPUserAvatarUrl]] placeholderImage:[UIImage imageNamed:@"icon upload ax"]];
                    cell.authorImageView.userInteractionEnabled = YES;
                    cell.authorImageView.tag = indexPath.row;
                        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]init];
                        [tap addTarget:self action:@selector(tapOnAuthorImage:)];
                        [cell.authorImageView addGestureRecognizer:tap];
                    
                        //author name
                    cell.authorNameLabel.text = landingPageDic.LPUserTitle;
                    
                        //author job title
                    cell.authorJobLabel.text = landingPageDic.LPUserJobTitle;
                    
                        //content
                    cell.contentLabel.text = landingPageDic.LPContentSummary;
                        //cell.contentLabel.text = [[cell.contentLabel.text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
                    
                    if (selectedRow == indexPath.row) {
                        cell.commentImageView.image = [UIImage imageNamed:@"comment"];
                        CGRect rect = cell.contentLabel.frame;
                        rect.size.height = [self getHeightOfString:landingPageDic.LPContent];
                            //rect.origin.y = cell.authorImageView.frame.origin.y - 100;
                        if (rect.origin.y < cell.authorImageView.frame.origin.y) {
                            rect.origin.y = cell.authorImageView.frame.origin.y;
                        }
                        [cell.contentLabel setFrame:rect];
                        [cell.contentLabel sizeToFit];
                    }else{
                        cell.commentImageView.image = [UIImage imageNamed:@"comment"];
                    }
                    
                    cell.favButton.tag = indexPath.row;
                        //[cell.favButton addTarget:self action:@selector(favButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                    
                    cell.heartButton.tag = indexPath.row;
                        //[cell.heartButton addTarget:self action:@selector(likeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                    
                    cell.shareButton.tag = indexPath.row;
                        //[cell.shareButton addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                    
                    if ([landingPageDic.LPFavorite integerValue] == 0) {
                        [cell.favButton setImage:[UIImage imageNamed:@"fav off"] forState:UIControlStateNormal];
                    }else{
                        [cell.favButton setImage:[UIImage imageNamed:@"fav on"] forState:UIControlStateNormal];
                    }
                    
                    if ([landingPageDic.LPLiked integerValue] == 0) {
                        [cell.heartButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
                    }else{
                        [cell.heartButton setImage:[UIImage imageNamed:@"like on"] forState:UIControlStateNormal];
                    }
                }
            }
            cellToReturn = cell;
            
        }
        return cellToReturn;
    } else if (tableView.tag == 972){
        ProjectCompanyCustomCell *cell = (ProjectCompanyCustomCell *)[[ProjectCompanyCustomCell alloc]
                                                                      initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellSearch"];
        
        if (indexPath.row < [membersTableArray count]) {
            NSDictionary *searchDic = [membersTableArray objectAtIndex:indexPath.row];
            cell.nameLabel.text = [searchDic objectForKey:@"name"];
                //cell.jobLabel.text = [searchDic objectForKey:@"experience"];
            [cell.avatarimageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [searchDic objectForKey:@"avatar"]]] placeholderImage:[UIImage imageNamed:@"icon upload ax"]];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(followimageViewActionForCompany:)];
            cell.followimageView.userInteractionEnabled = YES;
            cell.followimageView.tag = indexPath.row;
            [cell.followimageView addGestureRecognizer:tap];
        }
        
        return cell;
        
    } else if (tableView.tag == 973){
        ProjectCompanyCustomCell *cell = (ProjectCompanyCustomCell *)[[ProjectCompanyCustomCell alloc]
                                                                      initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellSearch"];
        
        if (indexPath.row < [projectTableArray count]) {
            NSDictionary *searchDic = [projectTableArray objectAtIndex:indexPath.row];
            cell.nameLabel.text = [searchDic objectForKey:@"name"];
                //cell.jobLabel.text = [searchDic objectForKey:@"experience"];
            [cell.avatarimageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [searchDic objectForKey:@"avatar"]]] placeholderImage:[UIImage imageNamed:@"icon upload ax"]];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(followimageViewActionForProject:)];
            cell.followimageView.userInteractionEnabled = YES;
            cell.followimageView.tag = indexPath.row;
            [cell.followimageView addGestureRecognizer:tap];
        }
        
        return cell;
    }
    
    return cellToReturn;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = [_tableArray objectAtIndex:indexPath.row];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LandingPageDetailViewController *view = (LandingPageDetailViewController *)[story instantiateViewControllerWithIdentifier:@"LandingPageDetailViewController"];
    view.dictionary = dic;
    [self.navigationController pushViewController:view animated:YES];
    
    
    /*
     if ([dic.LPContent length] > 200) {
     selectedRow = indexPath.row;
     isExpand = !isExpand;
     if (!isExpand) {
     selectedRow = 1000;
     }
     
     [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
     [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
     }
     */
    //[self.tableView reloadData];
}

#pragma mark - play, delete, record audio
- (NSString *)formattedTime:(int)totalSeconds
{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

- (void)playAudio:(id)sender{
    UIButton *btn = (UIButton *)sender;
    isPlayingTempVoice = !isPlayingTempVoice;
    if (!isPlayingTempVoice) {
        playingAudioRowNumber = 10000;
        [self stopAudioPlayer];
    } else {
        [self stopAudioPlayer];
        NSDictionary *dic = [self.tableArray objectAtIndex:btn.tag];
        [self playAudioWithName:[dic.LPTVAudioUrl lastPathComponent]];
        playingAudioRowNumber = btn.tag;
        whichRowShouldBeReload = playingAudioRowNumber;
    }
    //NSIndexPath *indexpath = [NSIndexPath indexPathForRow:btn.tag inSection:0];
    [self.tableView reloadData]; //RowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)playVideo:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSDictionary *dic = [self.tableArray objectAtIndex:btn.tag];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    VideoPlayerViewController *view = (VideoPlayerViewController *)[story instantiateViewControllerWithIdentifier:@"VideoPlayerViewController"];
    view.dictionary = dic;
    [self presentViewController:view animated:YES completion:nil];
}

- (void)stopAudioPlayer{
    [audioPlayer stop];
    [self stopTimer];
    [playbackTimer invalidate];
}

- (void)playAudioWithName:(NSString *)nameOfVoice {
    NSError *error;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:
                   [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",
                                         [DocumentDirectoy getDocuementsDirectory], nameOfVoice]]error:nil];
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    NSError *setCategoryError = nil;
    //improve voice for playback
    if (![session setCategory:AVAudioSessionCategoryPlayback
                  withOptions:AVAudioSessionCategoryOptionMixWithOthers
                        error:&setCategoryError]) {
        // handle error
    }
    //    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    //    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
    //                             sizeof (audioRouteOverride),&audioRouteOverride);
    audioPlayer.delegate = self;
    [audioPlayer prepareToPlay];
    if (error){
        //////NSLog(@"Error: %@",[error localizedDescription]);
    }else{
        [audioPlayer play];
        playbackTimer=[NSTimer scheduledTimerWithTimeInterval:1.0
                                                       target:self
                                                     selector:@selector(playbackTimerAction:)
                                                     userInfo:nil
                                                      repeats:YES];
        waveformProgressNumber = 0.0;
    }
}

-(void)playbackTimerAction:(NSTimer*)timer {
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:whichRowShouldBeReload inSection:0];
    LandingPageCustomCellAudio *cell = (LandingPageCustomCellAudio *)[self.tableView cellForRowAtIndexPath:indexpath];
    if (audioPlayer.currentTime > 0) {
        
                
        
        
        cell.currentTimeLabel.text = [NSString stringWithFormat:@"%@", [self formattedTime:audioPlayer.currentTime]];
        
        //[self.tableView reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationNone];
    } else {
        [playbackTimer invalidate];
        [UIView animateWithDuration:1.0 animations:^{
            //cell.waveform.progressSamples = cell.waveform.totalSamples;
        }];
        
    }
    
}

- (void)stopTimer {
    [myTimer invalidate];
    [playbackTimer invalidate];
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    playingAudioRowNumber = 10000;
    [self.tableView reloadData];
    [self stopTimer];
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

-(void)sendPhotoToServer
{
    [ProgressHUD show:@""];
    NSString *url = [NSString stringWithFormat:@"%@update_profile_photo", BaseURL];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    manager.requestSerializer.timeoutInterval = 45;
    NSDictionary *userpassDic = [GetUsernamePassword getUsernamePassword];
    NSString *file = [self encodeToBase64String:profileImageView.image];
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
            [self saveImageIntoDocumets];
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

-(void)getProfileDataFromServer
{
    [ProgressHUD show:@""];
    NSString *url = [NSString stringWithFormat:@"%@api/entity/all", BaseURL];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"application/json"];
    manager.requestSerializer.timeoutInterval = 45;
    //NSLog(@"%@", [GetUsernamePassword getAccessToken]);
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [GetUsernamePassword getAccessToken]] forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    [manager POST:url parameters:nil progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        [ProgressHUD dismiss];
        NSDictionary *resDic  =responseObject;
        projectTableArray = [[NSMutableArray alloc]init];
        membersTableArray = [[NSMutableArray alloc]init];
        if ([[resDic objectForKey:@"success"]integerValue] == 1) {
            NSMutableArray *responseArray = [[NSMutableArray alloc]init];
            for (NSDictionary *dic in [resDic objectForKey:@"data"]) {
                if ([[dic objectForKey:@"entity_type_id"]integerValue] == 1)/*user profile = 1*/ {
                    [responseArray addObject:dic];
                } else if ([[dic objectForKey:@"entity_type_id"]integerValue] == 2)/*company profile = 2*/ {
                    [membersTableArray addObject:dic];
                } else if ([[dic objectForKey:@"entity_type_id"]integerValue] == 3)/*project profile = 3*/ {
                    [projectTableArray addObject:dic];
                }
            }
            
            [membersTableView reloadData];
            [projectTableView reloadData];
            
//            if ([responseArray count] > 0) {
//                usernameLabel.text = [[responseArray lastObject]objectForKey:@"full_name"];
//                usernameLabel.text = [[responseArray lastObject]objectForKey:@"name"];
//                //NSLog(@"%@", [[responseArray lastObject]objectForKey:@"avatar"]);
//                [profileImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[responseArray lastObject]objectForKey:@"avatar"]]]];// = [[responseArray lastObject]objectForKey:@"avatar"];
//                nameTextField.text = [[responseArray lastObject]objectForKey:@"name"];
//                aboutLabel.text = [[responseArray lastObject]objectForKey:@"about"];
//                emailTextField.text = [[responseArray lastObject]objectForKey:@"email"];
//                mobileTextField.text = [[responseArray lastObject]objectForKey:@"phone"];
//                educationTextField.text = [[responseArray lastObject]objectForKey:@"education"];
//                savabeghTextField.text = [[responseArray lastObject]objectForKey:@"website"];
//            }
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

-(void)getProfileDetailFromServer
{
    [ProgressHUD show:@"" Interaction:NO];;
    NSDictionary *params = @{@"id":[NSNumber numberWithInteger:[[_dictionary objectForKey:@"id"]integerValue]]
                             };
    NSString *url = [NSString stringWithFormat:@"%@api/entity/detail", BaseURL];
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
            entityID = [[[resDic objectForKey:@"data"]objectForKey:@"id"]integerValue];
            self.tableArray = [[NSMutableArray alloc]init];
            page = 1;
            [self fetchPostsFromServer:page];

        
            NSInteger postCount = [[[resDic objectForKey:@"data"]objectForKey:@"post_count"]integerValue];
            [postButton setTitle:[NSString stringWithFormat:@"%ld", (long)postCount] forState:UIControlStateNormal];
            
            NSInteger followersCount = [[[resDic objectForKey:@"data"]objectForKey:@"follower_count"]integerValue];
            [followersButton setTitle:[NSString stringWithFormat:@"%ld", (long)followersCount] forState:UIControlStateNormal];
            
            NSInteger followeeCount = [[[resDic objectForKey:@"data"]objectForKey:@"follower_count"]integerValue];
            [followeeButton setTitle:[NSString stringWithFormat:@"%ld", (long)followeeCount] forState:UIControlStateNormal];
            
            usernameLabel.text = [[resDic objectForKey:@"data"]objectForKey:@"name"];
            nameTextField.text = [[resDic objectForKey:@"data"]objectForKey:@"name"];
            titleLabel.text = [[resDic objectForKey:@"data"]objectForKey:@"name"];
            profileIdCurrent = [[[resDic objectForKey:@"data"]objectForKey:@"id"]integerValue];
            
            aboutTextView.text = [[resDic objectForKey:@"data"]objectForKey:@"about"];
            aboutTextView.textAlignment = NSTextAlignmentRight;
            CGFloat yPos = [self getHeightOfString:aboutTextView.text] - 30;
            CGRect rect = aboutTextView.frame;
            rect.size.height = yPos;
            rect.origin.x = 40;
            //rect.origin.y += 5;
            rect.size.width = screenWidth - 90;
            aboutTextView.frame = rect;
            
            yPos += aboutTextView.frame.origin.y;
            
            rect = horizontalLineForAbout.frame;
            rect.origin.y = yPos;
            horizontalLineForAbout.frame = rect;
            
            rect = takhasosImageView.frame;
            rect.origin.y = horizontalLineForAbout.frame.origin.y + 28;
            takhasosImageView.frame = rect;
            
            rect = takhasosLabel.frame;
            rect.origin.y = horizontalLineForAbout.frame.origin.y + 20;
            takhasosLabel.frame = rect;
            
            rect = namesScrollViewForExpertise.frame;
            rect.origin.y = horizontalLineForAbout.frame.origin.y + 30;
            namesScrollViewForExpertise.frame = rect;
            
            
            rect = userInfoView.frame;
            rect.size.height = aboutTextView.frame.size.height + 170;
            userInfoView.frame = rect;
            
            yPos = userInfoView.frame.size.height + 30;
            [contactTitleLabel removeFromSuperview];
            [self makeContactViewWithYpos:yPos + 180];
            [self showUserInfoButtonAction];

            
            mobileTextField.text = [[resDic objectForKey:@"data"]objectForKey:@"phone"];
            
            websiteTextField.text = [[resDic objectForKey:@"data"]objectForKey:@"website"];
            
            emailTextField.text = [[resDic objectForKey:@"data"]objectForKey:@"email"];
            
            [profileImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[resDic objectForKey:@"data"]objectForKey:@"avatar"]]]];// = [[responseArray lastObject]objectForKey:@"avatar"];
            
            selectedTagsArrayForExpertise = [[NSMutableArray alloc]init];
            for (NSDictionary *dic in [[resDic objectForKey:@"data"]objectForKey:@"expertises"]) {
                [selectedTagsArrayForExpertise addObject:dic];
            }
            
            [self reloadTagsViewForExpertise];

            canEdit = YES;
            if ([[[resDic objectForKey:@"data"]objectForKey:@"can_edit"]integerValue] == 0) {
                [editProfileButton setTitle:@"دنبال می کنم" forState:UIControlStateNormal];
                canEdit = NO;
                
                if ([[[resDic objectForKey:@"data"]objectForKey:@"follow"] isEqualToString:@"pending_approve"]) {
                    [editProfileButton removeFromSuperview];
                    editProfileButton = [CustomButton initButtonWithTitle:NSLocalizedString(@"editProfile", @"") withTitleColor:[UIColor whiteColor] withBackColor:COLOR_5 isRounded:YES withFrame:CGRectMake(screenWidth/2 + 10, profileImageView.frame.origin.y + 25, 110, 30)];
                    [editProfileButton addTarget:self action:@selector(editProfileButtonAction) forControlEvents:UIControlEventTouchUpInside];
                    [scrollView addSubview:editProfileButton];
                    [editProfileButton setTitle:@"منتظر تایید" forState:UIControlStateNormal];
                } else if ([[[resDic objectForKey:@"data"]objectForKey:@"follow"] isEqualToString:@"not_followed"]) {
                    [editProfileButton removeFromSuperview];
                    editProfileButton = [CustomButton initButtonWithTitle:NSLocalizedString(@"editProfile", @"") withTitleColor:COLOR_5 withBackColor:[UIColor whiteColor] isRounded:YES withFrame:CGRectMake(screenWidth/2 + 10, profileImageView.frame.origin.y + 25, 110, 30)];
                    [editProfileButton addTarget:self action:@selector(editProfileButtonAction) forControlEvents:UIControlEventTouchUpInside];
                    [scrollView addSubview:editProfileButton];
                    [editProfileButton setTitle:@"دنبال می کنم" forState:UIControlStateNormal];
                } else if ([[[resDic objectForKey:@"data"]objectForKey:@"follow"] isEqualToString:@"followed"]) {
                    [editProfileButton removeFromSuperview];
                    editProfileButton = [CustomButton initButtonWithTitle:NSLocalizedString(@"editProfile", @"") withTitleColor:[UIColor whiteColor] withBackColor:COLOR_5 isRounded:YES withFrame:CGRectMake(screenWidth/2 + 10, profileImageView.frame.origin.y + 25, 110, 30)];
                    [editProfileButton addTarget:self action:@selector(editProfileButtonAction) forControlEvents:UIControlEventTouchUpInside];
                    [scrollView addSubview:editProfileButton];
                    [editProfileButton setTitle:@"دنبال می کنم" forState:UIControlStateNormal];
                }
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [ProgressHUD dismiss];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%@", [error localizedDescription]] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            //NSLog(@"You pressed button OK");
        }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    }];
}

-(void)followCompanyConnection:(NSInteger)profileId row:(NSInteger)row
{
    [ProgressHUD show:@""];
    NSDictionary *params = @{@"model":@"entity",
                             @"foreign_key":[NSNumber numberWithInteger:profileId]
                             };
    NSString *url = [NSString stringWithFormat:@"%@api/social_activity/follow", BaseURL];
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
            [editProfileButton setTitle:@"منتظر تایید" forState:UIControlStateNormal];
        }

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[resDic objectForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            // ////NSLog(@"You pressed button OK");
        }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        [self getProfileDetailFromServer];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [ProgressHUD dismiss];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%@", [error localizedDescription]] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            // ////NSLog(@"You pressed button OK");
        }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    }];
}

-(void)followProjectConnection:(NSInteger)profileId
{
    [ProgressHUD show:@""];
    NSDictionary *params = @{@"model":@"entity",
                             @"foreign_key":[NSNumber numberWithInteger:profileId]
                             };
    NSString *url = [NSString stringWithFormat:@"%@api/social_activity/follow", BaseURL];
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
            [editProfileButton setTitle:@"منتظر تایید" forState:UIControlStateNormal];
        }
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[resDic objectForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            // ////NSLog(@"You pressed button OK");
        }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        [self getProfileDetailFromServer];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [ProgressHUD dismiss];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%@", [error localizedDescription]] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            // ////NSLog(@"You pressed button OK");
        }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    }];
}

- (void)deleteFromServer{
    [ProgressHUD show:@""];
    NSDictionary *params = @{@"id":[NSNumber numberWithInteger:[[_dictionary objectForKey:@"id"]integerValue]]
                             };
    NSString *url = [NSString stringWithFormat:@"%@api/entity/delete", BaseURL];
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
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@" حذف شرکت" message:[resDic objectForKey:@"message"]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
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

- (void)fetchPostsFromServer:(NSInteger)pageOf{
    if (!isBusyNow) {
        isBusyNow = YES;
        [refreshControl endRefreshing];
        [ProgressHUD show:@""];
        NSDictionary *params = @{@"entity_id":[NSNumber numberWithInteger:entityID],
                                 @"page":[NSNumber numberWithInteger:pageOf],
                                 @"limit":[NSNumber numberWithInteger:20]
                                 };
        NSString *url = [NSString stringWithFormat:@"%@api/timeline", BaseURL];
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
            [noResultLabelPost removeFromSuperview];
            for (NSDictionary *post in [tempDic myObjectForKey:@"data"]) {
                [self.tableArray addObject:post];
            }
            isBusyNow = NO;
            [self.tableView reloadData];
            
            if ([self.tableArray count] == 0) {
                [noResultLabelPost removeFromSuperview];
                noResultLabelPost = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 220, 10, 200,  25)];
                noResultLabelPost.font = FONT_MEDIUM(13);
                noResultLabelPost.text = NSLocalizedString(@"noContent", @"");
                noResultLabelPost.minimumScaleFactor = 0.7;
                noResultLabelPost.textColor = [UIColor blackColor];
                noResultLabelPost.textAlignment = NSTextAlignmentRight;
                noResultLabelPost.adjustsFontSizeToFitWidth = YES;
                [self.tableView addSubview:noResultLabelPost];
            }
            
            
            if ([self.tableArray count] == 0) {
                [noResultLabelPost removeFromSuperview];
                noResultLabelPost = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 220, 10, 200,  25)];
                noResultLabelPost.font = FONT_MEDIUM(13);
                noResultLabelPost.text = NSLocalizedString(@"noContent", @"");
                noResultLabelPost.minimumScaleFactor = 0.7;
                noResultLabelPost.textColor = [UIColor blackColor];
                noResultLabelPost.textAlignment = NSTextAlignmentRight;
                noResultLabelPost.adjustsFontSizeToFitWidth = YES;
                [self.tableView addSubview:noResultLabelPost];
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

- (void)likeOnServerWithID:(NSString *)idOfPost{
    NSDictionary *params = @{@"model":@"post",
                             @"foreign_key":[NSString stringWithFormat:@"%@", idOfPost]
                             };
    NSString *url = [NSString stringWithFormat:@"%@api/social_activity/like", BaseURL];
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
        
        if ([[[tempDic myObjectForKey:@"data"]myObjectForKey:@"status"] isEqualToString:@"+"]) {
            NSInteger idOfTargetDelete = 1000;
            NSInteger idOfRow = 1000;
            for (int i = 0; i < [_likeArray count]; i++) {
                NSDictionary *likeDic = [_likeArray myObjectAtIndex:i];
                if ([idOfPost integerValue] == [[likeDic myObjectForKey:@"id"]integerValue]) {
                    idOfTargetDelete = i;
                    idOfRow = [[likeDic myObjectForKey:@"index"]integerValue];
                    break;
                }
            }
            if (idOfTargetDelete < [_likeArray count]) {
                [_likeArray removeObjectAtIndex:idOfTargetDelete];
                [Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:@"1" field:@"liked" postId:idOfPost];
                [Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:[NSString stringWithFormat:@"%@", [[tempDic myObjectForKey:@"data"]myObjectForKey:@"count"]] field:@"likes_count" postId:idOfPost];
                
                    //[self populateTableViewArray];
            }
        }else{//status = "-"
            NSInteger idOfTargetDelete = 1000;
            NSInteger idOfRow = 1000;
            for (int i = 0; i < [_likeArray count]; i++) {
                NSDictionary *likeDic = [_likeArray myObjectAtIndex:i];
                if ([idOfPost integerValue] == [[likeDic myObjectForKey:@"id"]integerValue]) {
                    idOfTargetDelete = i;
                    idOfRow = [[likeDic myObjectForKey:@"index"]integerValue];
                    break;
                }
            }
                //NSIndexPath *indexpath = [NSIndexPath indexPathForRow:idOfRow inSection:0];
                //[self rollbackLikeButtonActionForIndexPath:indexpath];
            [_likeArray removeObjectAtIndex:idOfTargetDelete];
            /*
             if (idOfTargetDelete < [_likeArray count]) {
             [_likeArray removemyObjectAtIndex:idOfTargetDelete];
             [Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:@"0" field:@"liked" postId:idOfPost];
             [Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:[NSString stringWithFormat:@"%@", [[tempDic myObjectForKey:@"data"] myObjectForKey:@"count"]] field:@"likes_count" postId:idOfPost];
             [self populateTableViewArray];
             }
             */
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        
        NSInteger idOfTargetDelete = 1000;
        NSInteger idOfRow = 1000;
        for (int i = 0; i < [_likeArray count]; i++) {
            NSDictionary *likeDic = [_likeArray myObjectAtIndex:i];
            if ([idOfPost integerValue] == [[likeDic myObjectForKey:@"id"]integerValue]) {
                idOfTargetDelete = i;
                idOfRow = [[likeDic myObjectForKey:@"index"]integerValue];
                break;
            }
        }
            //NSIndexPath *indexpath = [NSIndexPath indexPathForRow:idOfRow inSection:0];
            //[self rollbackLikeButtonActionForIndexPath:indexpath];
        /*
         if (idOfTargetDelete < [_likeArray count]) {
         [_likeArray removemyObjectAtIndex:idOfTargetDelete];
         //
         NSDictionary *landingPageDic = [self.tableArray myObjectAtIndex:idOfRow];
         NSMutableDictionary *landingPageDic2 = [[NSMutableDictionary alloc]initWithDictionary:landingPageDic];
         NSInteger likes = [landingPageDic2.LPLikes_count integerValue];
         likes--;
         [landingPageDic2 setObject:[NSString stringWithFormat:@"%ld", (long)likes] forKey:@"likesCount"];
         [landingPageDic2 setObject:[NSString stringWithFormat:[NSString stringWithFormat:@"%d", 0], likes] forKey:@"liked"];
         [self.tableArray replacemyObjectAtIndex:idOfRow withObject:landingPageDic2];
         [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idOfRow inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
         
         */
            //[Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:[NSString stringWithFormat:@"%ld", (long)likes] field:@"liked" postId:idOfPost];
            //[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idOfRow inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            //}
        
    }];
}

- (void)favOnServerWithID:(NSString *)idOfPost{
    NSDictionary *params = @{@"model":@"post",
                             @"foreign_key":[NSString stringWithFormat:@"%@", idOfPost]
                             };
    NSString *url = [NSString stringWithFormat:@"%@api/social_activity/favorite", BaseURL];
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
        
        if ([[[tempDic myObjectForKey:@"data"]myObjectForKey:@"status"] isEqualToString:@"+"]) {
            NSInteger idOfTargetDelete = 1000;
            NSInteger idOfRow = 1000;
            for (int i = 0; i < [_favArray count]; i++) {
                NSDictionary *likeDic = [_favArray myObjectAtIndex:i];
                if ([idOfPost integerValue] == [[likeDic myObjectForKey:@"id"]integerValue]) {
                    idOfTargetDelete = i;
                    idOfRow = [[likeDic myObjectForKey:@"index"]integerValue];
                    break;
                }
            }
            if (idOfTargetDelete < [_favArray count]) {
                [_favArray removeObjectAtIndex:idOfTargetDelete];
                [Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:@"1" field:@"favorite" postId:idOfPost];
                    //copy fav items into favorite table
                [Database copyLandingPageIntoFavoriteWithFilePath:[Database getDbFilePath] postID:idOfPost];
                
                    //[self populateTableViewArray];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idOfRow inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            }
        }else if ([[[tempDic myObjectForKey:@"data"]myObjectForKey:@"status"] isEqualToString:@"-"]){//status = "-"
            NSInteger idOfTargetDelete = 1000;
            NSInteger idOfRow = 1000;
            for (int i = 0; i < [_favArray count]; i++) {
                NSDictionary *likeDic = [_favArray myObjectAtIndex:i];
                if ([idOfPost integerValue] == [[likeDic myObjectForKey:@"id"]integerValue]) {
                    idOfTargetDelete = i;
                    idOfRow = [[likeDic myObjectForKey:@"index"]integerValue];
                    break;
                }
            }
            if (idOfTargetDelete < [_favArray count]) {
                [_favArray removeObjectAtIndex:idOfTargetDelete];
                [Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:@"0" field:@"favorite" postId:idOfPost];
                    //delete fav item from favorite
                [Database deleteFavoriteWithFilePath:[Database getDbFilePath] withID:idOfPost];
                    //[self populateTableViewArray];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idOfRow inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            }
            
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSInteger idOfTargetDelete = 1000;
        NSInteger idOfRow = 1000;
        for (int i = 0; i < [_favArray count]; i++) {
            NSDictionary *likeDic = [_favArray myObjectAtIndex:i];
            if ([idOfPost integerValue] == [[likeDic myObjectForKey:@"id"]integerValue]) {
                idOfTargetDelete = i;
                idOfRow = [[likeDic myObjectForKey:@"index"]integerValue];
                break;
            }
        }
        if (idOfTargetDelete < [_favArray count]) {
            [_favArray removeObjectAtIndex:idOfTargetDelete];
            [Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:@"0" field:@"favorite" postId:idOfPost];
                //[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idOfRow inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
        
    }];
}


#pragma mark - scrollview delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    float bottomEdge = self.tableView.contentOffset.y + self.tableView.frame.size.height;
    if (bottomEdge >= _tableView.contentSize.height) {
            // we are at the end
        page++;
        [self fetchPostsFromServer:page];
    }
}

@end
