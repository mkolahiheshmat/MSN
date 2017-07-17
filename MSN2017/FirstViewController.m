//
//  FirstViewController.m
//  MSN
//
//  Created by Yarima on 11/5/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "FirstViewController.h"
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
#import "CompanyProfileViewController.h"
#import "ProjectProfileViewController.h"
#import "EmkanatViewController.h"
#import "ReportAbuseViewController.h"
#import "FolloweeViewController.h"
#import "NSDictionary+LandingPage.h"
#import "CommentViewController.h"
#import "EditProjectViewController.h"
#import "EditCompanyViewController.h"
#define loadingCellTag  1273
#define   DEGREES_TO_RADIANS(degrees)  ((M_PI * degrees)/ 180)

@interface FirstViewController ()<UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, AVAudioPlayerDelegate, UIWebViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
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
    UITableView *companyTableView;//972
    NSMutableArray *companyTableArray;
    UITableView *projectTableView;//973
    NSMutableArray *projectTableArray;
    UIButton *postButton;
    UIButton *followeeButton;
    UIButton *followersButton;
    UITextField *nameTextField;
    UITextField *birthdateTextField;
    UITextField *emailTextField;
    UITextField *mobileTextField;
    UITextField *jobPositionTextField;
    UITextField *educationTextField;
    UITextField *savabeghTextField;
    UIView *savabeghView;
    UILabel *savabeghLabel;
    NSInteger page;
    UIButton *editProfileButton;
    UILabel *titleLabel;
    BOOL canEdit;
    UIView *settingMenuView;
    UIView *reportView;
    NSInteger profileIdCurrent;
    UIButton *postButton1;
    UIButton *infoButton;
    UIButton *showProjectButton;
    UIButton *showCompanyButton;
    UILabel *noResultLabelPost;
    UILabel *noResultLabelCompany;
    UILabel *noResultLabelProject;
    UIImageView *postButtonImageView;
    UIImageView *infoButtonImageView;
    UIImageView *showProjButtonImageView;
    UIImageView *showCompanyButtonImageView;
    BOOL isSettingMenuShown;
    UIScrollView *namesScrollView;
    NSMutableArray *selectedTagsArray;
    NSInteger selectedJobTileID;
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

@implementation FirstViewController
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

- (void)viewWillAppear:(BOOL)animated {
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
    UIRefreshControl *refreshControl2 = [[UIRefreshControl alloc] init];
    [refreshControl2 addTarget:self action:@selector(testRefresh:) forControlEvents:UIControlEventValueChanged];
    [scrollView addSubview:refreshControl2];
    [self.view addSubview:scrollView];
    
    selectedRow = 1000;
    //[self makeEmtyazView];
    [self makeImageAndButtons];
    [self makeTabBarButtons];
    
    /*
     UIView *myv = [[UIView alloc]initWithFrame:CGRectMake(screenWidth/2 - 10, 100, 20, 20)];
     myv.backgroundColor = [UIColor clearColor];
     [self.view addSubview:myv];
     CAShapeLayer *circle = [[CAShapeLayer alloc]init];
     circle.frame = CGRectMake(0, 0, myv.frame.size.width, myv.frame.size.height);
     circle.lineWidth = 2.0;
     circle.strokeColor = [UIColor redColor].CGColor;
     circle.fillColor = nil;
     circle.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(myv.frame.size.width/2, myv.frame.size.height/2)
     radius:10
     startAngle:0
     endAngle:DEGREES_TO_RADIANS(340)
     clockwise:YES].CGPath;
     [myv.layer addSublayer:circle];
     CABasicAnimation *spinAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
     spinAnimation.byValue = [NSNumber numberWithFloat:2.0f*M_PI];
     spinAnimation.duration = 1.3;
     spinAnimation.repeatCount = HUGE_VALF;
     [myv.layer addAnimation:spinAnimation forKey:@"indeterminateAnimation"];
     */
    
    //NSLog(@"%@", [DocumentDirectoy getDocuementsDirectory]);
    self.tableArray = [[NSMutableArray alloc]init];
    page = 1;
    [self fetchPostsFromServer:page];
    
    [self getProfileDataFromServer];
    [self getProfileDetailFromServer];
    self.tableArray = [[NSMutableArray alloc]init];
    page = 1;
    [self fetchPostsFromServer:page];
    
    NSInteger has_profile = [[[NSUserDefaults standardUserDefaults]objectForKey:@"has_profile"]integerValue];
        //NSString *isProfileCompleted = [[NSUserDefaults standardUserDefaults]objectForKey:@"isProfileCompleted"];
    if (has_profile == 0) {
        [self editProfileButtonAction];
    }

}

- (void)testRefresh:(UIRefreshControl *)refreshControl2
{
    refreshControl2.attributedTitle = [[NSAttributedString alloc] initWithString:@""];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [NSThread sleepForTimeInterval:3];
        
        dispatch_async(dispatch_get_main_queue(), ^{
                //NSLog(@"%@", [DocumentDirectoy getDocuementsDirectory]);
            self.tableArray = [[NSMutableArray alloc]init];
            page = 1;
            [self fetchPostsFromServer:page];
            
            [self getProfileDataFromServer];
            [self getProfileDetailFromServer];
            self.tableArray = [[NSMutableArray alloc]init];
            page = 1;
            [self fetchPostsFromServer:page];

            [refreshControl2 endRefreshing];
            
            NSLog(@"refresh end");
        });
    });
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
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissTextView)];
    [topView addGestureRecognizer:tap];
    [self.view addSubview:topView];
    
    CGFloat topViewHeight = topView.frame.size.height;
    
    titleLabel =[[UILabel alloc]initWithFrame:CGRectMake(10, topViewHeight/2 - 15, screenWidth - 110, 40)];
    titleLabel.font = FONT_NORMAL(16);
    titleLabel.minimumScaleFactor = 0.5;
    titleLabel.text = NSLocalizedString(@"profileTitle", @"");
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentRight;
    [topView addSubview:titleLabel];
    
    //45x69
    UIButton *searchButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - 80, topViewHeight/2 - 4, 54 *0.3, 69 * 0.3)];
    [searchButton setBackgroundImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(searchButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:searchButton];
    
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
    
    
    editProfileButton = [CustomButton initButtonWithTitle:NSLocalizedString(@"editProfile", @"") withTitleColor:[UIColor whiteColor] withBackColor:[UIColor colorWithRed:64/255.0 green:139/255.0 blue:222/255.0 alpha:1.0] withFrame:CGRectMake(screenWidth/2 + 10, profileImageView.frame.origin.y + 25, 110, 30)];
    [editProfileButton addTarget:self action:@selector(editProfileButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:editProfileButton];
    
    postButton = [CustomButton initButtonWithTitle:@"0" withTitleColor:[UIColor blueColor] withBackColor:[UIColor whiteColor] withFrame:CGRectMake(10, usernameLabel.frame.origin.y + 50, 110, 30)];
    [postButton addTarget:self action:@selector(postButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:postButton];
    
    followeeButton = [CustomButton initButtonWithTitle:@"0" withTitleColor:[UIColor blueColor] withBackColor:[UIColor whiteColor] withFrame:CGRectMake(screenWidth/3, usernameLabel.frame.origin.y + 50, 110, 30)];
    [followeeButton addTarget:self action:@selector(followeeButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:followeeButton];
    
    followersButton = [CustomButton initButtonWithTitle:@"0" withTitleColor:[UIColor blueColor] withBackColor:[UIColor whiteColor] withFrame:CGRectMake(2*screenWidth/3, usernameLabel.frame.origin.y + 50, 110, 30)];
    [followersButton addTarget:self action:@selector(followersButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:followersButton];
    
    UILabel *postLabel =[[UILabel alloc]initWithFrame:CGRectMake(10, postButton.frame.origin.y + 20, 110, 40)];
    postLabel.font = FONT_NORMAL(16);
    //postLabel.minimumScaleFactor = 0.5;
    postLabel.adjustsFontSizeToFitWidth = YES;
    postLabel.text = @"پست\nposts";
    postLabel.numberOfLines = 2;
    postLabel.textColor = [UIColor blackColor];
    postLabel.textAlignment = NSTextAlignmentCenter;
    postLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(postButtonAction)];
    [postLabel addGestureRecognizer:tap];
    [scrollView addSubview:postLabel];
    
    UILabel *followeeLabel =[[UILabel alloc]initWithFrame:CGRectMake(screenWidth/3, postButton.frame.origin.y + 20, 110, 40)];
    followeeLabel.font = FONT_NORMAL(16);
    //followeeLabel.minimumScaleFactor = 0.5;
    followeeLabel.numberOfLines = 2;
    followeeLabel.adjustsFontSizeToFitWidth = YES;
    followeeLabel.text = @"دنبال شونده\nfollowing";
    followeeLabel.textColor = [UIColor blackColor];
    followeeLabel.textAlignment = NSTextAlignmentCenter;
    followeeLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(followeeButtonAction)];
    [followeeLabel addGestureRecognizer:tap2];
    [scrollView addSubview:followeeLabel];
    
    UILabel *followersLabel =[[UILabel alloc]initWithFrame:CGRectMake(2 * screenWidth/3, postButton.frame.origin.y + 20, 110, 40)];
    followersLabel.font = FONT_NORMAL(16);
    //followersLabel.minimumScaleFactor = 0.5;
    followersLabel.numberOfLines = 2;
    followersLabel.adjustsFontSizeToFitWidth = YES;
    followersLabel.text = @"دنبال کننده\nfollowers";
    followersLabel.textColor = [UIColor blackColor];
    followersLabel.textAlignment = NSTextAlignmentCenter;
    followersLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(followersButtonAction)];
    [followersLabel addGestureRecognizer:tap3];
    [scrollView addSubview:followersLabel];
}

- (void)makeTabBarButtons{
    
    //postButton1 = [CustomButton initButtonWithImage:[UIImage imageNamed:@"icon_tab_timeline_unselected "] withFrame:CGRectMake(0, usernameLabel.frame.origin.y + 110, screenWidth / 4, 30)];
    postButton1 = [CustomButton initButtonWithTitle:@"" withTitleColor:[UIColor clearColor] withBackColor:TABBAR isRounded:NO withFrame:CGRectMake(0, usernameLabel.frame.origin.y + 110, screenWidth / 4, 30)];
    [postButton1 addTarget:self action:@selector(showPostButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:postButton1];
    
    //213 × 100
    postButtonImageView = [[UIImageView alloc]initWithFrame:CGRectMake(postButton1.frame.size.width/2 - (213/8), 0, 213 / 4, 100 / 4)];
    postButtonImageView.image = [UIImage imageNamed:@"icon_tab_timeline_unselected"];
    [postButton1 addSubview:postButtonImageView];
    
    //infoButton = [CustomButton initButtonWithImage:[UIImage imageNamed:@"icon_tab_info "] withFrame:CGRectMake(screenWidth / 4, usernameLabel.frame.origin.y + 110, screenWidth / 4, 30)];
    infoButton = [CustomButton initButtonWithTitle:@"" withTitleColor:[UIColor clearColor] withBackColor:TABBAR isRounded:NO withFrame:CGRectMake(screenWidth / 4, usernameLabel.frame.origin.y + 110, screenWidth / 4, 30)];
    [infoButton addTarget:self action:@selector(showUserInfoButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:infoButton];
    
    //213 × 100
    infoButtonImageView = [[UIImageView alloc]initWithFrame:CGRectMake(infoButton.frame.size.width/2 - (213/8), 0, 213 / 4, 100 / 4)];
    infoButtonImageView.image = [UIImage imageNamed:@"icon_tab_info"];
    [infoButton addSubview:infoButtonImageView];
    
    //showProjectButton = [CustomButton initButtonWithImage:[UIImage imageNamed:@"icon_tab_company_unselected "] withFrame:CGRectMake(2 * screenWidth / 4 , usernameLabel.frame.origin.y + 110, screenWidth / 4, 30)];
    showProjectButton = [CustomButton initButtonWithTitle:@"" withTitleColor:[UIColor clearColor] withBackColor:TABBAR isRounded:NO withFrame:CGRectMake(2 * screenWidth / 4 , usernameLabel.frame.origin.y + 110, screenWidth / 4, 30)];
    [showProjectButton addTarget:self action:@selector(showProjectButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:showProjectButton];
    
    showProjButtonImageView = [[UIImageView alloc]initWithFrame:CGRectMake(showProjectButton.frame.size.width/2 - (213/8), 0, 213 / 4, 100 / 4)];
    showProjButtonImageView.image = [UIImage imageNamed:@"icon_tab_project_unselected"];
    [showProjectButton addSubview:showProjButtonImageView];
    
    //showCompanyButton = [CustomButton initButtonWithImage:[UIImage imageNamed:@"icon_tab_project_unselected "] withFrame:CGRectMake(3 * screenWidth / 4, usernameLabel.frame.origin.y + 110, screenWidth / 4, 30)];
    showCompanyButton = [CustomButton initButtonWithTitle:@"" withTitleColor:[UIColor clearColor] withBackColor:TABBAR isRounded:NO withFrame:CGRectMake(3 * screenWidth / 4, usernameLabel.frame.origin.y + 110, screenWidth / 4, 30)];
    [showCompanyButton addTarget:self action:@selector(showCompanyButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:showCompanyButton];
    
    showCompanyButtonImageView = [[UIImageView alloc]initWithFrame:CGRectMake(showCompanyButton.frame.size.width/2 - (213/8), 0, 213 / 4, 100 / 4)];
    showCompanyButtonImageView.image = [UIImage imageNamed:@"icon_tab_company_unselected"];
    [showCompanyButton addSubview:showCompanyButtonImageView];
    
    [self makeTabbarElementsWithYpos:postButton1.frame.origin.y + 30];
}

- (void)makeTabbarElementsWithYpos:(CGFloat)yPos{
    NSArray *array = [Database selectFromLandingPageWithFilePath:[Database getDbFilePath]];
    _tableArray = [[NSMutableArray alloc]initWithArray:array];
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, yPos, screenWidth, screenHeight)];
    self.tableView.delegate = self;
    self.tableView.tag = 971;
    self.tableView.dataSource = self;
    [scrollView addSubview:self.tableView];
    
    userInfoView = [[UIView alloc]initWithFrame:CGRectMake(0, yPos, screenWidth, 300)];
    userInfoView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:userInfoView];
    [self makeUserInfoView:userInfoView];
    
    //companyTableArray = [[NSMutableArray alloc]initWithArray:array];
    companyTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, yPos, screenWidth, screenHeight - yPos)];
    companyTableView.delegate = self;
    companyTableView.tag = 972;
    companyTableView.dataSource = self;
    [scrollView addSubview:companyTableView];
    
    //projectTableArray = [[NSMutableArray alloc]initWithArray:array];
    projectTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, yPos, screenWidth, screenHeight - yPos)];
    projectTableView.delegate = self;
    projectTableView.tag = 973;
    projectTableView.dataSource = self;
    [scrollView addSubview:projectTableView];
    
    [self makeSavabeghViewWithYpos:yPos + 370];
    
    [self showUserInfoButtonAction];
}

- (void)makeSavabeghViewWithYpos:(CGFloat)yPos{
    savabeghLabel =[[UILabel alloc]initWithFrame:CGRectMake(0, yPos, screenWidth, 30)];
    savabeghLabel.font = FONT_NORMAL(16);
    savabeghLabel.minimumScaleFactor = 0.5;
    savabeghLabel.adjustsFontSizeToFitWidth = YES;
    savabeghLabel.text = NSLocalizedString(@"savabegh", @"");
    savabeghLabel.textColor = [UIColor whiteColor];
    savabeghLabel.backgroundColor = [UIColor colorWithRed:47/255.0 green:197/255.0 blue:137/255.0 alpha:1.0];
    savabeghLabel.textAlignment = NSTextAlignmentCenter;
    [scrollView addSubview:savabeghLabel];
    
    savabeghView = [[UIView alloc]initWithFrame:CGRectMake(0, yPos + 30, screenWidth, 150)];
    savabeghView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:savabeghView];
    
    educationTextField = [[UITextField alloc]initWithFrame:CGRectMake(screenWidth/2 - 80, 10, 160, 25)];
    educationTextField.backgroundColor = [UIColor whiteColor];
    educationTextField.placeholder = NSLocalizedString(@"education", @"");
    educationTextField.text = _profileDictionary.first_nameProfile;
    educationTextField.tag = 201;
    educationTextField.font = FONT_NORMAL(15);
    educationTextField.layer.borderColor = [UIColor clearColor].CGColor;
    educationTextField.layer.borderWidth = 1.0;
    educationTextField.layer.cornerRadius = 5;
    educationTextField.clipsToBounds = YES;
    educationTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    educationTextField.textAlignment = NSTextAlignmentCenter;
    [savabeghView addSubview:educationTextField];
    educationTextField.userInteractionEnabled = NO;
    
    //63 × 30
    UIImageView *nameImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 40, 10, 63 / 3, 30 / 3)];
    nameImageView.image = [UIImage imageNamed:@"icon_education"];
    nameImageView.userInteractionEnabled = YES;
    [savabeghView addSubview:nameImageView];
    
    UIView *horizontalLine = [[UIView alloc]initWithFrame:CGRectMake(20, educationTextField.frame.origin.y + 25, screenWidth - 40, 0.5)];
    horizontalLine.backgroundColor = [UIColor lightGrayColor];
    [savabeghView addSubview:horizontalLine];
    
    savabeghTextField = [[UITextField alloc]initWithFrame:CGRectMake(screenWidth/2 - 80, horizontalLine.frame.origin.y + horizontalLine.frame.size.height + 30, 160, 25)];
    savabeghTextField.backgroundColor = [UIColor whiteColor];
    savabeghTextField.placeholder = NSLocalizedString(@"savabeghShogli", @"");
    savabeghTextField.text = _profileDictionary.first_nameProfile;
    savabeghTextField.tag = 202;
    savabeghTextField.font = FONT_NORMAL(15);
    savabeghTextField.layer.borderColor = [UIColor clearColor].CGColor;
    savabeghTextField.layer.borderWidth = 1.0;
    savabeghTextField.layer.cornerRadius = 5;
    savabeghTextField.clipsToBounds = YES;
    savabeghTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    savabeghTextField.textAlignment = NSTextAlignmentCenter;
    [savabeghView addSubview:savabeghTextField];
    savabeghTextField.userInteractionEnabled = NO;
    
    //56x46
    UIImageView *savabeghImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 40, horizontalLine.frame.origin.y + horizontalLine.frame.size.height + 30, 56 / 3, 46 / 3)];
    savabeghImageView.image = [UIImage imageNamed:@"icon_job"];
    savabeghImageView.userInteractionEnabled = YES;
    [savabeghView addSubview:savabeghImageView];
    
    UIView *horizontalLine2 = [[UIView alloc]initWithFrame:CGRectMake(20, savabeghTextField.frame.origin.y + 25, screenWidth - 40, 0.5)];
    horizontalLine2.backgroundColor = [UIColor lightGrayColor];
    [savabeghView addSubview:horizontalLine2];
    
    scrollView.contentSize = CGSizeMake(screenWidth, savabeghView.frame.origin.y + 200);
    
}
- (void)profileImageViewAction{
    [self showgalleryCameraView];
}

- (void)editProfileButtonAction{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    EditProfileViewController *view = (EditProfileViewController *)[story instantiateViewControllerWithIdentifier:@"EditProfileViewController"];
    NSInteger has_profile = [[[NSUserDefaults standardUserDefaults]objectForKey:@"has_profile"]integerValue];
    if (has_profile == 1)
        view.isFromEditProfile = YES;
    view.selectedTagsArray1 = selectedTagsArray;
    view.selectedJobTileID = selectedJobTileID;
    [self presentViewController:view animated:YES completion:nil];
}

- (void)postButtonAction{
    [self showPostButtonAction];
}

- (void)followersButtonAction{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FolloweeViewController *view = (FolloweeViewController *)[story instantiateViewControllerWithIdentifier:@"FolloweeViewController"];
    view.isFollowee = YES;
    [self.navigationController pushViewController:view animated:YES];
}

- (void)followeeButtonAction{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FolloweeViewController *view = (FolloweeViewController *)[story instantiateViewControllerWithIdentifier:@"FolloweeViewController"];
    view.isFollowee = NO;
    [self.navigationController pushViewController:view animated:YES];
}

- (void)showPostButtonAction{
    scrollView.contentSize = CGSizeMake(screenWidth, savabeghView.frame.origin.y + 200);
    CGRect rect = _tableView.frame;
    rect.size.height = savabeghView.frame.origin.y - 100;
    _tableView.frame = rect;
    
    _tableView.hidden = NO;
    userInfoView.hidden = YES;
    companyTableView.hidden = YES;
    projectTableView.hidden = YES;
    savabeghView.hidden = YES;
    savabeghLabel.hidden = YES;
    
    postButtonImageView.image = [UIImage imageNamed:@"icon_tab_timeline"];
    [postButton1 setBackgroundColor:TABBAR_SELECTED];
    
    infoButtonImageView.image =  [UIImage imageNamed:@"icon_tab_info_unselected"];
    [infoButton setBackgroundColor:TABBAR];
    
    showProjButtonImageView.image = [UIImage imageNamed:@"icon_tab_project_unselected"];
    [showProjectButton setBackgroundColor:TABBAR];
    
    showCompanyButtonImageView.image = [UIImage imageNamed:@"icon_tab_company_unselected"];
    [showCompanyButton setBackgroundColor:TABBAR];
}

- (void)showUserInfoButtonAction{
    scrollView.contentSize = CGSizeMake(screenWidth, savabeghView.frame.origin.y + 200);
    _tableView.hidden = YES;
    userInfoView.hidden = NO;
    companyTableView.hidden = YES;
    projectTableView.hidden = YES;
    savabeghView.hidden = NO;
    savabeghLabel.hidden = NO;
    
    postButtonImageView.image = [UIImage imageNamed:@"icon_tab_timeline_unselected"];
    [postButton1 setBackgroundColor:TABBAR];
    
    infoButtonImageView.image =  [UIImage imageNamed:@"icon_tab_info"];
    [infoButton setBackgroundColor:TABBAR_SELECTED];
    
    showProjButtonImageView.image = [UIImage imageNamed:@"icon_tab_project_unselected"];
    [showProjectButton setBackgroundColor:TABBAR];
    
    showCompanyButtonImageView.image = [UIImage imageNamed:@"icon_tab_company_unselected"];
    [showCompanyButton setBackgroundColor:TABBAR];
    
}

- (void)showProjectButtonAction{
    scrollView.contentSize = CGSizeMake(screenWidth, savabeghView.frame.origin.y + 200);
    _tableView.hidden = YES;
    userInfoView.hidden = YES;
    companyTableView.hidden = YES;
    projectTableView.hidden = NO;
    savabeghView.hidden = YES;
    savabeghLabel.hidden = YES;
    
    postButtonImageView.image = [UIImage imageNamed:@"icon_tab_timeline_unselected"];
    [postButton1 setBackgroundColor:TABBAR];
    
    infoButtonImageView.image =  [UIImage imageNamed:@"icon_tab_info_unselected"];
    [infoButton setBackgroundColor:TABBAR];
    
    showProjButtonImageView.image = [UIImage imageNamed:@"icon_tab_project"];
    [showProjectButton setBackgroundColor:TABBAR_SELECTED];
    
    showCompanyButtonImageView.image = [UIImage imageNamed:@"icon_tab_company_unselected"];
    [showCompanyButton setBackgroundColor:TABBAR];
}

- (void)showCompanyButtonAction{
    scrollView.contentSize = CGSizeMake(screenWidth, savabeghView.frame.origin.y + 200);
    _tableView.hidden = YES;
    userInfoView.hidden = YES;
    companyTableView.hidden = NO;
    projectTableView.hidden = YES;
    savabeghView.hidden = YES;
    savabeghLabel.hidden = YES;
    
    postButtonImageView.image = [UIImage imageNamed:@"icon_tab_timeline_unselected"];
    [postButton1 setBackgroundColor:TABBAR];
    
    infoButtonImageView.image =  [UIImage imageNamed:@"icon_tab_info_unselected"];
    [infoButton setBackgroundColor:TABBAR];
    
    showProjButtonImageView.image = [UIImage imageNamed:@"icon_tab_project_unselected"];
    [showProjectButton setBackgroundColor:TABBAR];
    
    showCompanyButtonImageView.image = [UIImage imageNamed:@"icon_tab_company"];
    [showCompanyButton setBackgroundColor:TABBAR_SELECTED];
    
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
    
    //birthdate
    birthdateTextField = [[UITextField alloc]initWithFrame:CGRectMake(screenWidth/2 - 80, horizontalLine.frame.origin.y + 40, 160, 25)];
    birthdateTextField.backgroundColor = [UIColor clearColor];
    birthdateTextField.placeholder = NSLocalizedString(@"birthdate", @"");
    birthdateTextField.tag = 102;
    birthdateTextField.font = FONT_NORMAL(15);
    birthdateTextField.layer.borderColor = [UIColor clearColor].CGColor;
    birthdateTextField.layer.borderWidth = 1.0;
    birthdateTextField.layer.cornerRadius = 5;
    birthdateTextField.clipsToBounds = YES;
    birthdateTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    birthdateTextField.textAlignment = NSTextAlignmentCenter;
    birthdateTextField.keyboardType = UIKeyboardTypeNumberPad;
    [view addSubview:birthdateTextField];
    birthdateTextField.userInteractionEnabled = NO;
    
    //33x34
    UIImageView *birthdateImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 40, horizontalLine.frame.origin.y + 40, 33 / 2, 34 / 2)];
    birthdateImageView.image = [UIImage imageNamed:@"icon_birthday"];
    birthdateImageView.userInteractionEnabled = YES;
    [view addSubview:birthdateImageView];
    
    UIView *horizontalLine2 = [[UIView alloc]initWithFrame:CGRectMake(20, birthdateTextField.frame.origin.y + 25, screenWidth - 40, 0.5)];
    horizontalLine2.backgroundColor = [UIColor lightGrayColor];
    [view addSubview:horizontalLine2];
    
    //email
    emailTextField = [[UITextField alloc]initWithFrame:CGRectMake(10, horizontalLine2.frame.origin.y + 40, screenWidth - 60, 25)];
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
    [view addSubview:emailTextField];
    emailTextField.userInteractionEnabled = NO;
    
    //44x31
    UIImageView *emailImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 40, horizontalLine2.frame.origin.y + 40, 44 / 2, 31 / 2)];
    emailImageView.image = [UIImage imageNamed:@"icon_email"];
    emailImageView.userInteractionEnabled = YES;
    [view addSubview:emailImageView];
    
    UIView *horizontalLine3 = [[UIView alloc]initWithFrame:CGRectMake(20, emailTextField.frame.origin.y + 25, screenWidth - 40, 0.5)];
    horizontalLine3.backgroundColor = [UIColor lightGrayColor];
    [view addSubview:horizontalLine3];
    
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
    [view addSubview:mobileTextField];
    mobileTextField.userInteractionEnabled = NO;
    
    //36x36
    UIImageView *mobileImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 40, horizontalLine3.frame.origin.y + 40, 33 / 2, 34 / 2)];
    mobileImageView.image = [UIImage imageNamed:@"icon_tel"];
    mobileImageView.userInteractionEnabled = YES;
    [view addSubview:mobileImageView];
    
    UIView *horizontalLine4 = [[UIView alloc]initWithFrame:CGRectMake(20, mobileTextField.frame.origin.y + 25, screenWidth - 40, 0.5)];
    horizontalLine4.backgroundColor = [UIColor lightGrayColor];
    [view addSubview:horizontalLine4];
    
    //mobile
    jobPositionTextField = [[UITextField alloc]initWithFrame:CGRectMake(screenWidth/2 - 80, horizontalLine4.frame.origin.y + 40, 160, 25)];
    jobPositionTextField.placeholder = @"سمت شغلی";
    jobPositionTextField.backgroundColor = [UIColor clearColor];
    jobPositionTextField.font = FONT_NORMAL(15);
    jobPositionTextField.layer.borderColor = [UIColor clearColor].CGColor;
    jobPositionTextField.layer.borderWidth = 1.0;
    jobPositionTextField.layer.cornerRadius = 5;
    jobPositionTextField.clipsToBounds = YES;
    jobPositionTextField.keyboardType = UIKeyboardTypeNumberPad;
    jobPositionTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    jobPositionTextField.textAlignment = NSTextAlignmentCenter;
    jobPositionTextField.keyboardType = UIKeyboardTypeNumberPad;
    [view addSubview:jobPositionTextField];
    jobPositionTextField.userInteractionEnabled = NO;

    //60x60
    UIImageView *jobImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 40, horizontalLine4.frame.origin.y + 40, 60 / 4, 60 / 4)];
    jobImageView.image = [UIImage imageNamed:@"shoghl"];
    jobImageView.userInteractionEnabled = YES;
    [view addSubview:jobImageView];
    
    UIView *horizontalLine5 = [[UIView alloc]initWithFrame:CGRectMake(20, jobPositionTextField.frame.origin.y + 25, screenWidth - 40, 0.5)];
    horizontalLine5.backgroundColor = [UIColor lightGrayColor];
    [view addSubview:horizontalLine5];
    
    //60x24
    UIImageView *takhasosImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 40, horizontalLine5.frame.origin.y + 28, 60 / 3, 24 / 3)];
    takhasosImageView.image = [UIImage imageNamed:@"takhasos"];
    takhasosImageView.userInteractionEnabled = YES;
    [view addSubview:takhasosImageView];
    
    UILabel *takhasosLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, horizontalLine5.frame.origin.y + 20, screenWidth - 50,  25)];
    takhasosLabel.font = FONT_MEDIUM(13);
    takhasosLabel.text = @"تخصص ها";
    takhasosLabel.minimumScaleFactor = 0.7;
    takhasosLabel.textColor = [UIColor lightGrayColor];
    takhasosLabel.textAlignment = NSTextAlignmentRight;
    takhasosLabel.adjustsFontSizeToFitWidth = YES;
    [view addSubview:takhasosLabel];
    
    namesScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, takhasosLabel.frame.origin.y + 15, screenWidth, 40)];
    namesScrollView.contentSize = CGSizeMake(screenWidth * 2, 40);
    [view addSubview:namesScrollView];
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
        NSString *tagName = [[selectedTagsArray myObjectAtIndex:i]myObjectForKey:@"name"];
        CGSize size = [self getSizeOfString:tagName];
        if (countOfTags == 1)
            //xPOS = screenWidth/2 - size.width/2;
            if (xPOS + size.width+10 > screenWidth) {
                xPOS = 10;
                yPOS += 30;
            }
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(xPOS, yPOS, size.width + 15, 25)];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [NSString stringWithFormat:@"%@", tagName];
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
    if (height < screenWidth + 10)
        height = screenWidth + 10;
    return height;
}

- (void)followimageViewActionForCompany:(UITapGestureRecognizer *)tap{
    //NSLog(@"%d", tap.view.tag);
    NSDictionary *dic = [companyTableArray myObjectAtIndex:tap.view.tag];
    //NSLog(@"%@", [dic myObjectForKey:@"id"]);
    [self followCompanyConnection:[[dic myObjectForKey:@"id"]integerValue] row:tap.view.tag];
}

- (void)followimageViewActionForProject:(UITapGestureRecognizer *)tap{
    //NSLog(@"%d", tap.view.tag);
    NSDictionary *dic = [projectTableArray myObjectAtIndex:tap.view.tag];
    //NSLog(@"%@", [dic myObjectForKey:@"id"]);
    [self followProjectConnection:[[dic myObjectForKey:@"id"]integerValue] row:tap.view.tag];
}

- (void)settingButtonAction{
    if (canEdit) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        EmkanatViewController *view = (EmkanatViewController *)[story instantiateViewControllerWithIdentifier:@"EmkanatViewController"];
        [self.navigationController pushViewController:view animated:YES];
    } else {
        if (isSettingMenuShown) {
            [settingMenuView removeFromSuperview];
            isSettingMenuShown = NO;
            return;
        } else {
            isSettingMenuShown = YES;
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
        }
    }
    
}

- (void)dismissTextView{
    [settingMenuView removeFromSuperview];
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

- (void)commentImageViewAction:(UITapGestureRecognizer *)tap{
    NSLog(@"%ld", (long)tap.view.tag);
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CommentViewController *view = (CommentViewController *)[story instantiateViewControllerWithIdentifier:@"CommentViewController"];
    view.postId = [[[_tableArray myObjectAtIndex:tap.view.tag]myObjectForKey:@"id"]integerValue];
    view.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:view animated:YES];
}
- (void)videoButtonAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSDictionary *dic = [self.tableArray myObjectAtIndex:btn.tag];
    //NSLog(@"%@", [dic myObjectForKey:@"videoUrl"]);
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    VideoPlayerViewController *view = (VideoPlayerViewController *)[story instantiateViewControllerWithIdentifier:@"VideoPlayerViewController"];
    view.urlString = [dic myObjectForKey:@"videoUrl"];
    view.titleString = [dic myObjectForKey:@"title"];
    [self presentViewController:view animated:YES completion:nil];
}

- (void)audioButtonAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSDictionary *dic = [self.tableArray myObjectAtIndex:btn.tag];
    //NSLog(@"%@", [dic myObjectForKey:@"audioUrl"]);
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    VideoPlayerViewController *view = (VideoPlayerViewController *)[story instantiateViewControllerWithIdentifier:@"VideoPlayerViewController"];
    view.urlString = [dic myObjectForKey:@"audioUrl"];
    [self presentViewController:view animated:YES completion:nil];
}

- (void)favButtonAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    
    UIImage *offImage = [UIImage imageNamed:@"fav off"];
    UIImage *onImage = [UIImage imageNamed:@"fav on"];
    UIImage *currentImage = [btn imageForState:UIControlStateNormal];
    if ([UIImagePNGRepresentation(offImage) isEqualToData:UIImagePNGRepresentation(currentImage)]) {
        [btn setImage:onImage forState:UIControlStateNormal];
    }else{
        [btn setImage:offImage forState:UIControlStateNormal];
    }
    NSDictionary *landingPageDic = [self.tableArray myObjectAtIndex:btn.tag];
    NSDictionary *tempDic = [[NSDictionary alloc]initWithObjectsAndKeys:landingPageDic.LPPostID, @"id", [NSNumber numberWithInteger:btn.tag], @"index", nil];
    [_favArray addObject:tempDic];
    [self favOnServerWithID:landingPageDic.LPPostID];
    
}

- (void)likeButtonAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    
    UIImage *offImage = [UIImage imageNamed:@"like icon"];
    UIImage *onImage = [UIImage imageNamed:@"like"];
    UIImage *currentImage = [btn imageForState:UIControlStateNormal];
    
    NSDictionary *landingPageDic = [self.tableArray myObjectAtIndex:btn.tag];
    NSMutableDictionary *landingPageDic2 = [[NSMutableDictionary alloc]initWithDictionary:landingPageDic];
    NSDictionary *tempDic = [[NSDictionary alloc]initWithObjectsAndKeys:landingPageDic2.LPPostID, @"id", [NSNumber numberWithInteger:btn.tag], @"index", nil];
    [_likeArray addObject:tempDic];
    [self likeOnServerWithID:landingPageDic2.LPPostID];
    
    NSInteger likes = [landingPageDic2.LPTVLikes_count integerValue];
    if ([landingPageDic2.LPLiked integerValue] == 0) {
        likes++;
        //[Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:@"1" field:@"liked" postId:landingPageDic2.LPPostID];
        
    }else{
        if (likes == 0) {
            likes = 0;
        }else{
            likes--;
        }
        
        //[Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:@"1" field:@"liked" postId:landingPageDic2.LPPostID];
        
    }
    
    [landingPageDic2 setObject:[NSString stringWithFormat:@"%ld", (long)likes] forKey:@"likesCount"];
    
    if ([UIImagePNGRepresentation(offImage) isEqualToData:UIImagePNGRepresentation(currentImage)]) {
        [btn setImage:onImage forState:UIControlStateNormal];
        [landingPageDic2 setObject:[NSString stringWithFormat:@"%d",1] forKey:@"liked"];
        
    }else{
        [btn setImage:offImage forState:UIControlStateNormal];
        [landingPageDic2 setObject:[NSString stringWithFormat:@"%d", 0] forKey:@"liked"];
    }
    
    //[Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:[NSString stringWithFormat:@"%@", [[tempDic myObjectForKey:@"data"] myObjectForKey:@"count"]] field:@"likes_count" postId:landingPageDic2.LPPostID];
    
    [self.tableArray replaceObjectAtIndex:btn.tag withObject:landingPageDic2];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:btn.tag inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)shareButtonAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    
    NSDictionary *landingPageDic = [self.tableArray myObjectAtIndex:btn.tag];
    if ([[landingPageDic objectForKey:@"type"]isEqualToString:@"question"]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"اشتراک گذاری" message:@"امکان اشتراک گذاری محتوی نظرسنجی وجود ندارد" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
    
    NSString *textToShare = landingPageDic.LPTitle;
    NSString *textToShare2 = landingPageDic.LPContent;
    //NSURL *myWebsite = [NSURL URLWithString:@"http://www.msn.com/"];
    
    NSArray *objectsToShare = @[textToShare, textToShare2];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:activityVC animated:YES completion:nil];
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
        return [companyTableArray count];
    } else if (tableView.tag == 973) {
        return [projectTableArray count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (IS_IPAD) {
        if (selectedRow == indexPath.row) {
            if (isExpand) {
                NSDictionary *landingPageDic = [self.tableArray myObjectAtIndex:indexPath.row];
                return [self getHeightOfString:landingPageDic.LPTVContent];
                
            } else {
                return screenWidth + 10;
            }
        } else {
            return screenWidth + 10;
        }
        
    } else {
        if (tableView.tag == 971) {
            if (selectedRow == indexPath.row) {
                if (isExpand) {
                    NSDictionary *landingPageDic = [self.tableArray myObjectAtIndex:indexPath.row];
                    return [self getHeightOfString:landingPageDic.LPContent];
                    
                } else {
                    return screenWidth + 25;
                }
            } else if ([_tableArray count] > 0){
                NSDictionary *landingPageDic = [self.tableArray myObjectAtIndex:indexPath.row];
                NSString *postType = landingPageDic.LPPostType;
                if (([postType isEqualToString:@"question"])) {
                    NSArray *arr = landingPageDic.LPvotingOptions;
                    NSInteger countOf = [arr count];
                    if (countOf-1 > 4) countOf = 4;
                    
                    if ([landingPageDic.LPImageUrl length] == 0 || (([landingPageDic.LPImageUrl isEqualToString:@"(null)"]) && ([landingPageDic.LPVideoUrl length] <= 6)) ) {
                        return 180 + (countOf * 55);
                    }
                    
                    return screenWidth + (countOf * 55);
                }
                
                if (([postType isEqualToString:@"video"])) {
                    //NSLog(@"postType:%@", postType);
                    return screenWidth + 25;;
                }
                
                if (([postType isEqualToString:@"audio"])) {
                    //NSLog(@"postType:%@", postType);
                    return 280;
                }
                if (([postType isEqualToString:@"document"]) && ([landingPageDic.LPImageUrl length] <= 6)) {
                    //NSLog(@"postType:%@", postType);
                    return 200;
                }
                
                if ([landingPageDic.LPImageUrl length] == 0 || (([landingPageDic.LPImageUrl isEqualToString:@"(null)"]) && ([landingPageDic.LPVideoUrl length] <= 6)) ) {
                    return 210;
                }
                return screenWidth + 25;
            }
            
        }else if (tableView.tag == 972 || tableView.tag == 973){
            return 80;
        }
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
        
        NSDictionary *landingPageDic = [self.tableArray myObjectAtIndex:indexPath.row];
        NSString *postType;
        postType = landingPageDic.LPPostType;
        
        
        //audio
        if ([postType isEqualToString:@"audio"]) {
            //NSString *cellIdentifier = [NSString stringWithFormat:@"S%1ldR%1ld",(long)indexPath.section,(long)indexPath.row];
            LandingPageCustomCellAudio *cell = [tableView dequeueReusableCellWithIdentifier:@"cell1"];
            //if (indexPath.row < [self.tableArray count] - 1) {
            
            if (cell == nil)
                cell = (LandingPageCustomCellAudio *)[[LandingPageCustomCellAudio alloc]
                                                      initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell1"];
            //if (indexPath.row < [self.tableArray count] - 1) {
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
                
                cell.downloadPlayButton.tag = indexPath.row;
                [cell.downloadPlayButton addTarget:self action:@selector(audioButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                //category
                cell.categoryLabel.text = landingPageDic.LPCategoryName;
                if ([cell.categoryLabel.text length] == 0) {
                    cell.categoryLabel.text = landingPageDic.LPCategoryName;
                }
                //seen label
                cell.commentCountLabel.text = landingPageDic.LPRecommends_count;
                
                //like label
                cell.likeCountLabel.text = [NSString stringWithFormat:@"%ld", (long)landingPageDic.LPLikes_count];
                cell.likeCountLabel.tag = indexPath.row;
                //author image
                [cell.authorImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", landingPageDic.LPUserAvatarUrl]] placeholderImage:[UIImage imageNamed:@"icon upload ax"]];
                cell.authorImageView.userInteractionEnabled = YES;
                cell.authorImageView.tag = indexPath.row;
                //UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]init];
                //[tap addTarget:self action:@selector(tapOnAuthorImage:)];
                //[cell.authorImageView addGestureRecognizer:tap];
                
                //author name
                cell.authorNameLabel.text = landingPageDic.LPUserTitle;
                
                //author job title
                cell.authorJobLabel.text = landingPageDic.LPUserJobTitle;
                
                //content
                cell.contentLabel.text = landingPageDic.LPContent;
                //cell.contentLabel.text = [[cell.contentLabel.text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
                /*
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
                 */
                cell.commentImageView.tag = indexPath.row;
                cell.commentImageView.userInteractionEnabled = YES;
                UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(commentImageViewAction:)];
                [cell.commentImageView addGestureRecognizer:tap2];
                
                cell.favButton.tag = indexPath.row;
                [cell.favButton addTarget:self action:@selector(favButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                
                cell.heartButton.tag = indexPath.row;
                [cell.heartButton addTarget:self action:@selector(likeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                
                cell.shareButton.tag = indexPath.row;
                [cell.shareButton addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                
                if ([landingPageDic.LPFavorite integerValue] == 0) {
                    [cell.favButton setImage:[UIImage imageNamed:@"fav off"] forState:UIControlStateNormal];
                }else{
                    [cell.favButton setImage:[UIImage imageNamed:@"fav on"] forState:UIControlStateNormal];
                }
                
                if ([landingPageDic.LPLiked integerValue] == 0) {
                    [cell.heartButton setImage:[UIImage imageNamed:@"like icon"] forState:UIControlStateNormal];
                }else{
                    [cell.heartButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
                }
            }
            //}
            cellToReturn = cell;
            //        }else{
            //            return [self loadingCell];
            //        }
            //video
        }else if ([postType isEqualToString:@"video"]){
            //NSString *cellIdentifier = [NSString stringWithFormat:@"S%1ldR%1ld",(long)indexPath.section,(long)indexPath.row];
            LandingPageCustomCellVideo *cell = [tableView dequeueReusableCellWithIdentifier:@"cell2"];
            //if (indexPath.row < [self.tableArray count] - 1) {
            
            if (cell == nil)
                cell = (LandingPageCustomCellVideo *)[[LandingPageCustomCellVideo alloc]
                                                      initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell2"];
            //if (indexPath.row < [self.tableArray count] - 1) {
            if ([self.tableArray count] > 0) {
                cell.tag = indexPath.row;
                
                //title
                cell.titleLabel.text = landingPageDic.LPTitle;
                
                //action for video
                cell.videoButton.tag = indexPath.row;
                [cell.videoButton addTarget:self action:@selector(videoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                
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
                [cell.postImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [landingPageDic myObjectForKey:@"video_snapshot"]]] placeholderImage:[UIImage imageNamed:@"broken_image"]];
                
                //category
                cell.categoryLabel.text = landingPageDic.LPCategoryName;
                if ([cell.categoryLabel.text length] == 0) {
                    cell.categoryLabel.text = landingPageDic.LPCategoryName;
                }
                //seen label
                cell.commentCountLabel.text = landingPageDic.LPRecommends_count;
                
                //like label
                cell.likeCountLabel.text = [NSString stringWithFormat:@"%ld", (long)landingPageDic.LPLikes_count];
                cell.likeCountLabel.tag = indexPath.row;
                //author image
                [cell.authorImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", landingPageDic.LPUserAvatarUrl]] placeholderImage:[UIImage imageNamed:@"icon upload ax"]];
                cell.authorImageView.userInteractionEnabled = YES;
                cell.authorImageView.tag = indexPath.row;
                //UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]init];
                //[tap addTarget:self action:@selector(tapOnAuthorImage:)];
                //[cell.authorImageView addGestureRecognizer:tap];
                
                //author name
                cell.authorNameLabel.text = landingPageDic.LPUserTitle;
                
                //author job title
                cell.authorJobLabel.text = landingPageDic.LPUserJobTitle;
                
                //content
                cell.contentLabel.text = landingPageDic.LPContent;
                //cell.contentLabel.text = [[cell.contentLabel.text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
                /*
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
                 */
                cell.commentImageView.tag = indexPath.row;
                cell.commentImageView.userInteractionEnabled = YES;
                UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(commentImageViewAction:)];
                [cell.commentImageView addGestureRecognizer:tap2];
                
                cell.favButton.tag = indexPath.row;
                [cell.favButton addTarget:self action:@selector(favButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                
                cell.heartButton.tag = indexPath.row;
                [cell.heartButton addTarget:self action:@selector(likeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                
                cell.shareButton.tag = indexPath.row;
                [cell.shareButton addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                
                if ([landingPageDic.LPFavorite integerValue] == 0) {
                    [cell.favButton setImage:[UIImage imageNamed:@"fav off"] forState:UIControlStateNormal];
                }else{
                    [cell.favButton setImage:[UIImage imageNamed:@"fav on"] forState:UIControlStateNormal];
                }
                
                if ([landingPageDic.LPLiked integerValue] == 0) {
                    [cell.heartButton setImage:[UIImage imageNamed:@"like icon"] forState:UIControlStateNormal];
                }else{
                    [cell.heartButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
                }
            }
            //}
            cellToReturn = cell;
            //        }else{
            //            return [self loadingCell];
            //        }
            
        }else if ([postType isEqualToString:@"question"]){//question
            NSString *cellIdentifier = [NSString stringWithFormat:@"S%1ldR%1ld",(long)indexPath.section,(long)indexPath.row];
            LandingPageCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell3"];
            //if (indexPath.row < [self.tableArray count] - 1) {
            
            if (cell == nil){
                if (([landingPageDic.LPImageUrl length] > 10) || ([landingPageDic.LPImageUrl length] > 10)) {
                    cell = (LandingPageCustomCell *)[[LandingPageCustomCell alloc]
                                                     initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier isPostImage:YES];
                }else{
                    cell = (LandingPageCustomCell *)[[LandingPageCustomCell alloc]
                                                     initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier isPostImage:NO];
                }
                
            }
            // if (indexPath.row < [self.tableArray count] - 1) {
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
                if ([landingPageDic.LPImageUrl length] > 10) {
                    [cell.postImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", landingPageDic.LPImageUrl]] placeholderImage:[UIImage imageNamed:@"broken_image"]];
                }else{
                    [cell.postImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", landingPageDic.LPImageUrl]]];
                }
                
                NSArray *optionsArr = landingPageDic.LPvotingOptions;
                
                CGFloat yPos = cell.postImageView.frame.origin.y + cell.postImageView.frame.size.height + 5;
//                if ([optionsArr count] < 4) {
//                    if (!cell.postImageView.image) {
//                        yPos -= 65;
//                    }
//                }
                
                for (NSInteger i = 0; i < [optionsArr count]; i++) {
                    NSString *str = [NSString stringWithFormat:@"%@", [[optionsArr myObjectAtIndex:i]myObjectForKey:@"text"]];
                    if (i == 3) {
                        str = @"+ گزینه های بیشتر";
                    }
                    UIButton *btn = [CustomButton initButtonWithTitle:str withTitleColor:COLOR_5 withBackColor:WHITE_COLOR isRounded:YES withFrame:CGRectMake(20, yPos, screenWidth - 40, 30)];
                    [cell addSubview:btn];
                    CGFloat percent = [[[optionsArr myObjectAtIndex:i]myObjectForKey:@"answers_percent"]integerValue];
                    CGFloat width = btn.frame.size.width;
                    CGFloat height = btn.frame.size.height;
                    CGFloat xpos = ((100 - percent)/100) * width;
                    //                    if (xpos > 50) {
                    //                        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    //                    }
                    UIView *coloredView = [[UIView alloc]initWithFrame:CGRectMake(xpos, 0, width - xpos, height)];
                    coloredView.backgroundColor = [COLOR_5 colorWithAlphaComponent:0.4];
                    if ([[[optionsArr myObjectAtIndex:i]myObjectForKey:@"answered"]integerValue] == 1) {
                        coloredView.backgroundColor = [GREEN_COLOR colorWithAlphaComponent:0.4];
                    }
                    [btn addSubview:coloredView];
                    yPos += 35;
                    if (i == 3) {
                        break;
                    }
                }
                //category
                cell.categoryLabel.text = landingPageDic.LPCategoryName;
                if ([cell.categoryLabel.text length] == 0) {
                    cell.categoryLabel.text = landingPageDic.LPCategoryName;
                }
                //seen label
                cell.commentCountLabel.text = landingPageDic.LPRecommends_count;
                
                //like label
                cell.likeCountLabel.text = landingPageDic.LPTVLikes_count;
                cell.likeCountLabel.tag = indexPath.row;
                //author image
                [cell.authorImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", landingPageDic.LPUserAvatarUrl]] placeholderImage:[UIImage imageNamed:@"icon upload ax"]];
                cell.authorImageView.userInteractionEnabled = YES;
                cell.authorImageView.tag = indexPath.row;
                //UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]init];
                //[tap addTarget:self action:@selector(tapOnAuthorImage:)];
                //[cell.authorImageView addGestureRecognizer:tap];
                
                //author name
                cell.authorNameLabel.text = landingPageDic.LPUserTitle;
                
                //author job title
                cell.authorJobLabel.text = landingPageDic.LPUserJobTitle;
                
                //content
                cell.contentLabel.text = landingPageDic.LPContent;
                //cell.contentLabel.text = [[cell.contentLabel.text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
                
                cell.commentImageView.tag = indexPath.row;
                cell.commentImageView.userInteractionEnabled = YES;
                UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(commentImageViewAction:)];
                [cell.commentImageView addGestureRecognizer:tap2];
                
                cell.favButton.tag = indexPath.row;
                [cell.favButton addTarget:self action:@selector(favButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                
                cell.heartButton.tag = indexPath.row;
                [cell.heartButton addTarget:self action:@selector(likeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                
                cell.shareButton.tag = indexPath.row;
                [cell.shareButton addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                
                if ([landingPageDic.LPFavorite integerValue] == 0) {
                    [cell.favButton setImage:[UIImage imageNamed:@"fav off"] forState:UIControlStateNormal];
                }else{
                    [cell.favButton setImage:[UIImage imageNamed:@"fav on"] forState:UIControlStateNormal];
                }
                
                if ([landingPageDic.LPLiked integerValue] == 0) {
                    [cell.heartButton setImage:[UIImage imageNamed:@"like icon"] forState:UIControlStateNormal];
                }else{
                    [cell.heartButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
                }
                
                //update fram of comment, fav, like
                CGRect rect = cell.heartButton.frame;
                rect.origin.y = yPos + 15;
                cell.heartButton.frame = rect;
                
                rect = cell.likeCountLabel.frame;
                rect.origin.y = yPos + 15;
                cell.likeCountLabel.frame = rect;
                
                rect = cell.commentImageView.frame;
                rect.origin.y = yPos + 15;
                cell.commentImageView.frame = rect;
                
                rect = cell.commentCountLabel.frame;
                rect.origin.y = yPos + 15;
                cell.commentCountLabel.frame = rect;
                
                rect = cell.favButton.frame;
                rect.origin.y = yPos + 15;
                cell.favButton.frame = rect;
                
                rect = cell.dateLabel.frame;
                rect.origin.y = yPos + 15;
                cell.dateLabel.frame = rect;
            }
            //}
            cellToReturn = cell;
            //        }else{
            //            return [self loadingCell];
            //        }
            
            
        }else{//other post types
            NSString *cellIdentifier = [NSString stringWithFormat:@"S%1ldR%1ld",(long)indexPath.section,(long)indexPath.row];
            LandingPageCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell3"];
            //if (indexPath.row < [self.tableArray count] - 1) {
            
            if (cell == nil){
                if (([landingPageDic.LPImageUrl length] > 10) || ([landingPageDic.LPImageUrl length] > 10)) {
                    cell = (LandingPageCustomCell *)[[LandingPageCustomCell alloc]
                                                     initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier isPostImage:YES];
                }else{
                    cell = (LandingPageCustomCell *)[[LandingPageCustomCell alloc]
                                                     initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier isPostImage:NO];
                }
                
            }
            // if (indexPath.row < [self.tableArray count] - 1) {
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
                if (([landingPageDic.LPImageUrl length] > 10) || ([landingPageDic.LPImageUrl length] > 10)) {
                    [cell.postImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", landingPageDic.LPImageUrl]] placeholderImage:[UIImage imageNamed:@"broken_image"]];
                }else{
                    [cell.postImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", landingPageDic.LPImageUrl]]];
                }
                
                //category
                cell.categoryLabel.text = landingPageDic.LPCategoryName;
                if ([cell.categoryLabel.text length] == 0) {
                    cell.categoryLabel.text = landingPageDic.LPCategoryName;
                }
                //seen label
                cell.commentCountLabel.text = landingPageDic.LPRecommends_count;
                
                //like label
                cell.likeCountLabel.text = [NSString stringWithFormat:@"%ld", (long)landingPageDic.LPLikes_count];
                cell.likeCountLabel.tag = indexPath.row;
                //author image
                [cell.authorImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", landingPageDic.LPUserAvatarUrl]] placeholderImage:[UIImage imageNamed:@"icon upload ax"]];
                cell.authorImageView.userInteractionEnabled = YES;
                cell.authorImageView.tag = indexPath.row;
                //UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]init];
                //[tap addTarget:self action:@selector(tapOnAuthorImage:)];
                //[cell.authorImageView addGestureRecognizer:tap];
                
                //author name
                cell.authorNameLabel.text = landingPageDic.LPUserTitle;
                
                //author job title
                cell.authorJobLabel.text = landingPageDic.LPUserJobTitle;
                
                //content
                cell.contentLabel.text = landingPageDic.LPContent;
                //cell.contentLabel.text = [[cell.contentLabel.text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
                
                /*
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
                 */
                
                cell.commentImageView.tag = indexPath.row;
                cell.commentImageView.userInteractionEnabled = YES;
                UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(commentImageViewAction:)];
                [cell.commentImageView addGestureRecognizer:tap2];
                
                cell.favButton.tag = indexPath.row;
                [cell.favButton addTarget:self action:@selector(favButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                
                cell.heartButton.tag = indexPath.row;
                [cell.heartButton addTarget:self action:@selector(likeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                
                cell.shareButton.tag = indexPath.row;
                [cell.shareButton addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                
                if ([landingPageDic.LPFavorite integerValue] == 0) {
                    [cell.favButton setImage:[UIImage imageNamed:@"fav off"] forState:UIControlStateNormal];
                }else{
                    [cell.favButton setImage:[UIImage imageNamed:@"fav on"] forState:UIControlStateNormal];
                }
                
                if ([landingPageDic.LPLiked integerValue] == 0) {
                    [cell.heartButton setImage:[UIImage imageNamed:@"like icon"] forState:UIControlStateNormal];
                }else{
                    [cell.heartButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
                }
            }
            //}
            cellToReturn = cell;
            //        }else{
            //            return [self loadingCell];
            //        }
            
        }
        return cellToReturn;
    } else if (tableView.tag == 972){
        ProjectCompanyCustomCell *cell = (ProjectCompanyCustomCell *)[[ProjectCompanyCustomCell alloc]
                                                                      initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellSearch"];
        
        if (indexPath.row < [companyTableArray count]) {
            NSDictionary *searchDic = [companyTableArray myObjectAtIndex:indexPath.row];
            cell.nameLabel.text = [searchDic myObjectForKey:@"name"];
            //cell.jobLabel.text = [searchDic myObjectForKey:@"experience"];
            [cell.avatarimageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [searchDic myObjectForKey:@"avatar"]]] placeholderImage:[UIImage imageNamed:@"icon upload ax"]];
            
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
            NSDictionary *searchDic = [projectTableArray myObjectAtIndex:indexPath.row];
            cell.nameLabel.text = [searchDic myObjectForKey:@"name"];
            //cell.jobLabel.text = [searchDic myObjectForKey:@"experience"];
            [cell.avatarimageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [searchDic myObjectForKey:@"avatar"]]] placeholderImage:[UIImage imageNamed:@"icon upload ax"]];
            
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
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    if (tableView.tag == 971) {
        NSDictionary *dic = [_tableArray myObjectAtIndex:indexPath.row];
        LandingPageDetailViewController *view = (LandingPageDetailViewController *)[story instantiateViewControllerWithIdentifier:@"LandingPageDetailViewController"];
        view.dictionary = dic;
        [self.navigationController pushViewController:view animated:YES];
        
    } else if (tableView.tag == 972){
        NSDictionary *dic = [companyTableArray myObjectAtIndex:indexPath.row];
        CompanyProfileViewController *view = (CompanyProfileViewController *)[story instantiateViewControllerWithIdentifier:@"CompanyProfileViewController"];
        view.dictionary = dic;
        view.postId = [NSString stringWithFormat:@"%@",[dic myObjectForKey:@"id"]];
        [self.navigationController pushViewController:view animated:YES];
        
    }else if (tableView.tag == 973){
        NSDictionary *dic = [projectTableArray myObjectAtIndex:indexPath.row];
        ProjectProfileViewController *view = (ProjectProfileViewController *)[story instantiateViewControllerWithIdentifier:@"ProjectProfileViewController"];
        view.dictionary = dic;
        [self.navigationController pushViewController:view animated:YES];
        
    }
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
        NSDictionary *dic = [self.tableArray myObjectAtIndex:btn.tag];
        [self playAudioWithName:[dic.LPAudioUrl lastPathComponent]];
        playingAudioRowNumber = btn.tag;
        whichRowShouldBeReload = playingAudioRowNumber;
    }
    //NSIndexPath *indexpath = [NSIndexPath indexPathForRow:btn.tag inSection:0];
    [self.tableView reloadData]; //RowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)playVideo:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSDictionary *dic = [self.tableArray myObjectAtIndex:btn.tag];
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
    NSDictionary *params = @{@"username":[userpassDic myObjectForKey:@"username"],
                             @"password":[userpassDic myObjectForKey:@"password"],
                             @"profile_id":[GetUsernamePassword getProfileId],
                             @"value":file,
                             @"file_type":@"png",
                             @"debug":@"1",
                             @"unit_id": @"3"
                             };
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [ProgressHUD dismiss];
        NSDictionary *dict  =responseObject;
        if ([[dict myObjectForKey:@"success"]integerValue] == 1) {
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
    //NSLog(@"token: %@", [GetUsernamePassword getAccessToken]);
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [GetUsernamePassword getAccessToken]] forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    [manager POST:url parameters:nil progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        [ProgressHUD dismiss];
        NSDictionary *resDic  =responseObject;
        projectTableArray = [[NSMutableArray alloc]init];
        companyTableArray = [[NSMutableArray alloc]init];
        if ([[resDic myObjectForKey:@"success"]integerValue] == 1) {
            NSMutableArray *responseArray = [[NSMutableArray alloc]init];
            for (NSDictionary *dic in [resDic myObjectForKey:@"data"]) {
                if ([[dic myObjectForKey:@"entity_type_id"]integerValue] == 1)/*user profile = 1*/ {
                    [responseArray addObject:dic];
                } else if ([[dic myObjectForKey:@"entity_type_id"]integerValue] == 3)/*company profile = 2*/ {
                    [companyTableArray addObject:dic];
                } else if ([[dic myObjectForKey:@"entity_type_id"]integerValue] == 2)/*project profile = 3*/ {
                    [projectTableArray addObject:dic];
                }
            }
            
            [noResultLabelProject removeFromSuperview];
            [noResultLabelPost removeFromSuperview];
            [noResultLabelCompany removeFromSuperview];
            [companyTableView reloadData];
            [projectTableView reloadData];
            
            if ([companyTableArray count] == 0) {
                [noResultLabelCompany removeFromSuperview];
                noResultLabelCompany = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 220, 10, 200,  25)];
                noResultLabelCompany.font = FONT_MEDIUM(13);
                noResultLabelCompany.text = @"هیچ شرکتی وجود ندارد";
                noResultLabelCompany.minimumScaleFactor = 0.7;
                noResultLabelCompany.textColor = [UIColor blackColor];
                noResultLabelCompany.textAlignment = NSTextAlignmentRight;
                noResultLabelCompany.adjustsFontSizeToFitWidth = YES;
                [companyTableView addSubview:noResultLabelCompany];
            }
            
            if ([projectTableArray count] == 0) {
                [noResultLabelProject removeFromSuperview];
                noResultLabelProject = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 220, 10, 200,  25)];
                noResultLabelProject.font = FONT_MEDIUM(13);
                noResultLabelProject.text = @"هیچ پروژه ای وجود ندارد";
                noResultLabelProject.minimumScaleFactor = 0.7;
                noResultLabelProject.textColor = [UIColor blackColor];
                noResultLabelProject.textAlignment = NSTextAlignmentRight;
                noResultLabelProject.adjustsFontSizeToFitWidth = YES;
                [projectTableView addSubview:noResultLabelProject];
            }
            
            
            if ([responseArray count] > 0) {
                usernameLabel.text = [[responseArray firstObject]myObjectForKey:@"name"];
                //NSLog(@"%@", [[responseArray lastObject]myObjectForKey:@"avatar"]);
                [profileImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[responseArray lastObject]myObjectForKey:@"avatar"]]]];// = [[responseArray lastObject]myObjectForKey:@"avatar"];
                nameTextField.text = [[responseArray lastObject]myObjectForKey:@"name"];
                birthdateTextField.text = [[responseArray lastObject]myObjectForKey:@"birth_date"];
                emailTextField.text = [[responseArray lastObject]myObjectForKey:@"email"];
                mobileTextField.text = [[responseArray lastObject]myObjectForKey:@"mobile"];
                educationTextField.text = [[responseArray lastObject]myObjectForKey:@"education"];
                savabeghTextField.text = [[responseArray lastObject]myObjectForKey:@"work_experience"];
            }
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
    [ProgressHUD show:@""];
    NSInteger profileId = [[[NSUserDefaults standardUserDefaults]objectForKey:@"profileID"]integerValue];
    NSDictionary *params = @{@"id":[NSNumber numberWithInteger:profileId]
                             };
    NSString *url = [NSString stringWithFormat:@"%@api/entity/detail", BaseURL];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"application/json"];
    manager.requestSerializer.timeoutInterval = 45;
    NSLog(@"%@", [GetUsernamePassword getAccessToken]);
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [GetUsernamePassword getAccessToken]] forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    [manager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
    } progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [ProgressHUD dismiss];
        NSDictionary *resDic  =responseObject;
        if ([[resDic myObjectForKey:@"success"]integerValue] == 1) {
            NSInteger postCount = [[[resDic myObjectForKey:@"data"]myObjectForKey:@"post_count"]integerValue];
            [postButton setTitle:[NSString stringWithFormat:@"%ld", (long)postCount] forState:UIControlStateNormal];
            
            NSInteger followersCount = [[[resDic myObjectForKey:@"data"]myObjectForKey:@"follower_count"]integerValue];
            [followersButton setTitle:[NSString stringWithFormat:@"%ld", (long)followersCount] forState:UIControlStateNormal];
            
            NSInteger followeeCount = [[[resDic myObjectForKey:@"data"]myObjectForKey:@"following_count"]integerValue];
            [followeeButton setTitle:[NSString stringWithFormat:@"%ld", (long)followeeCount] forState:UIControlStateNormal];
            
            canEdit = YES;
            if ([[[resDic myObjectForKey:@"data"]myObjectForKey:@"can_edit"]integerValue] == 0) {
                [editProfileButton setTitle:@"دنبال می کنم" forState:UIControlStateNormal];
                canEdit = NO;
            }
            
            titleLabel.text = [[resDic myObjectForKey:@"data"]myObjectForKey:@"name"];
            profileIdCurrent = [[[resDic myObjectForKey:@"data"]myObjectForKey:@"id"]integerValue];
            
            jobPositionTextField.text = [[[resDic valueForKey:@"data"]valueForKey:@"job_title"]valueForKey:@"name"];
            selectedJobTileID = [[[[resDic valueForKey:@"data"]valueForKey:@"job_title"]valueForKey:@"id"]integerValue];
            selectedTagsArray = [[NSMutableArray alloc]init];
            for (NSDictionary *dic in [[resDic valueForKey:@"data"]valueForKey:@"expertises"]) {
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
        if ([[resDic myObjectForKey:@"success"]integerValue] == 1) {
            //reload related cell
            NSIndexPath *indexpath = [NSIndexPath indexPathForRow:row inSection:0];
            ProjectCompanyCustomCell *cell = (ProjectCompanyCustomCell *)[companyTableView cellForRowAtIndexPath:indexpath];//[companyTableArray myObjectAtIndex:row];
            cell.followimageView.image = [UIImage imageNamed:@"IWillUnfollow"];
            
        }
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[resDic myObjectForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            // ////NSLog(@"You pressed button OK");
        }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
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

-(void)followProjectConnection:(NSInteger)profileId row:(NSInteger)row
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
        if ([[resDic myObjectForKey:@"success"]integerValue] == 1) {
            //reload related cell
            NSIndexPath *indexpath = [NSIndexPath indexPathForRow:row inSection:0];
            ProjectCompanyCustomCell *cell = (ProjectCompanyCustomCell *)[projectTableView cellForRowAtIndexPath:indexpath];//[companyTableArray myObjectAtIndex:row];
            cell.followimageView.image = [UIImage imageNamed:@"IWillUnfollow"];
        }
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[resDic myObjectForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            // ////NSLog(@"You pressed button OK");
        }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
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

- (void)fetchPostsFromServer:(NSInteger)pageOf{
    if (!isBusyNow) {
        isBusyNow = YES;
        [refreshControl endRefreshing];
        [ProgressHUD show:@""];
        NSInteger profileId = [[[NSUserDefaults standardUserDefaults]objectForKey:@"profileID"]integerValue];
        NSDictionary *params = @{@"entity_id":[NSNumber numberWithInteger:profileId],
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
                noResultLabelPost = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, screenWidth - 40,  25)];
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
