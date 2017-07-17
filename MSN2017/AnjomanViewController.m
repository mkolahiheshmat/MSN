//
//  AnjomanViewController.m
//  MSN
//
//  Created by Yarima on 4/24/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "AnjomanViewController.h"
#import "Database.h"
#import <AFHTTPSessionManager.h>
#import <UIImageView+AFNetworking.h>
#import "Header.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import "KeychainWrapper.h"
#import "ProgressHUD.h"
#import "NSDictionary+LandingPage.h"
//#import "NSDictionary+LandingPageTableView.h"
#import "LandingPageCustomCell.h"
#import "TimeAgoViewController.h"
#import "UIImage+AverageColor.h"
#import <MessageUI/MessageUI.h>
#import "DirectQuestionViewController.h"
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
#import "UIImage+Extra.h"
#import "LoginViewController.h"
#import "IntroViewController.h"
#import "DoctorPageViewController.h"
#import "LandingPageDetailViewController.h"
#define loadingCellTag  1273

@interface AnjomanViewController()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, MFMailComposeViewControllerDelegate, UIGestureRecognizerDelegate, AVAudioPlayerDelegate>
{
     
    BOOL    isBusyNow;
    NSInteger  selectedRow;
    BOOL    isExpand;
    UIRefreshControl *refreshControl;
    UIImageView *menuImageView;
    NSMutableArray *menuItemsArray;
    UIScrollView *menuScrollView;
    UIImageView *selectImageView;
    NSInteger selectedItemNumber;
    UIButton *categoryButton;
    BOOL    isPagingForCategories;
    BOOL    noMoreData;
    UIImageView *coverImageView;
    UIImageView *doctorImageView;
    UILabel *authorNameLabel;
    UILabel *authorJobLabel;
    UIView *boxUnderButton;
    UILabel *noResultLabelMataleb;
    
    UILabel *aboutMeLabel;
    UILabel *madarekLabel;
    UILabel *savabeghLabel;
    UILabel *addressLabel;
    UILabel *madarekTitleLabel;
    UILabel *savabeghTitleLabel;
    UILabel *addressTitleLabel;
    NSString *doctrorTelephone;
    NSString *doctorEmail;
    NSString *doctorWebsite;
    UILabel *similarLabelOnBottom;
    UIScrollView *similarDoctorScrollView;
    NSMutableArray *similarDoctorsArray;
    UIActivityIndicatorView *activityIndicatorView;
    UIActivityIndicatorView *activityIndicatorViewForSimilarDoctors;
    NSInteger currentPage;
    UIButton *activityButton;
    UIButton *aboutDocButton;
    AVAudioPlayer *audioPlayer;
    BOOL isPlayingTempVoice;
    NSInteger playingAudioRowNumber;
    NSInteger whichRowShouldBeReload;
    NSTimer *playbackTimer;
    NSTimer *myTimer;
    BOOL disableTableView;
}
@property(nonatomic, retain)UITableView *tableView;
@property(nonatomic, retain)NSMutableArray *tableArray;
@property(nonatomic, retain)NSMutableArray *likeArray;
@property(nonatomic, retain)NSMutableArray *favArray;
@property(nonatomic, strong)UIScrollView *scrollView;
@property (strong, nonatomic) NSTimer *timerForProgress;
@property (strong, nonatomic) NSTimer *timerForProgressFinal;
@end

@implementation AnjomanViewController
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
- (void)viewDidDisappear:(BOOL)animated{
    [ProgressHUD dismiss];
}

- (void)viewWillDisappear:(BOOL)animated{
    self.tableView.userInteractionEnabled = YES;
}

- (void)viewDidLoad {
    self.navigationController.navigationBar.hidden = YES;
    
    [super viewDidLoad];
    [self fetchAnjomanInfoWithEntityId:self.userEntityId];
    [self fetchPostsFromServerWithRequest:@"" WithDate:@""];
    [self fetchDoctorOfAnjomanWithAnjomanId:self.userEntityId];
     
    selectedRow = 1000;
    currentPage = 1;
    isBusyNow = NO;
    isPagingForCategories = NO;
    noMoreData = NO;
    self.tableArray = [[NSMutableArray alloc]init];
    self.likeArray = [[NSMutableArray alloc]init];
    self.favArray = [[NSMutableArray alloc]init];
    //make View
    [self makeTopBar];
    [self makeCover];
    
    //NSLog(@"self.navigationControllers: %@", [self.navigationController viewControllers]);
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(backButtonImgAction) name:@"backToMainMenu" object:nil];
    
    disableTableView = YES;
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
    titleLabel.font = FONT_NORMAL(20);
    titleLabel.text = NSLocalizedString(@"anjomanPage", @"");
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
    
}

- (void)makeCover{
    coverImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 70, screenWidth, screenWidth * 0.43)];
    coverImageView.image = [UIImage imageNamed:@"difualt cover"];
    [self.view addSubview:coverImageView];
    
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
    
    authorJobLabel = [[UILabel alloc]initWithFrame:CGRectMake(doctorImageView.frame.origin.x - 150, authorNameLabel.frame.origin.y + 25, 130, 45)];
    authorJobLabel.font = FONT_NORMAL(11);
    authorJobLabel.numberOfLines = 2;
    //authorJobLabel.minimumScaleFactor = 0.7;
    authorJobLabel.textColor = [UIColor whiteColor];
    authorJobLabel.textAlignment = NSTextAlignmentRight;
    //authorJobLabel.adjustsFontSizeToFitWidth = YES;
    authorJobLabel.text = self.userJobTitle;
    [coverImageView addSubview:authorJobLabel];
    
    coverImageView.userInteractionEnabled = YES;
    UIButton *askDoctorButton = [[UIButton alloc]initWithFrame:CGRectMake(10, coverImageView.frame.size.height/2 - 40, 80, 80)];
    [askDoctorButton addTarget:self action:@selector(askDoctorButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [askDoctorButton setBackgroundImage:[UIImage imageNamed:@"Porsesh"] forState:UIControlStateNormal];
    //[coverImageView addSubview:askDoctorButton];
    
    [self makeTableViewWithYpos:coverImageView.frame.origin.y + coverImageView.frame.size.height];
}

- (void)makeAboutDoctorTexts{
    UILabel *aboutMeTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, screenWidth - 20, 25)];
    aboutMeTitleLabel.font = FONT_BOLD(15);
    aboutMeTitleLabel.text = NSLocalizedString(@"aboutme", @"");
    aboutMeTitleLabel.minimumScaleFactor = 0.7;
    aboutMeTitleLabel.textColor = [UIColor blackColor];
    aboutMeTitleLabel.textAlignment = NSTextAlignmentRight;
    aboutMeTitleLabel.adjustsFontSizeToFitWidth = YES;
    [self.scrollView addSubview:aboutMeTitleLabel];
    
    madarekTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 40, screenWidth - 20, 25)];
    madarekTitleLabel.font = FONT_BOLD(15);
    madarekTitleLabel.text = NSLocalizedString(@"madarek", @"");
    madarekTitleLabel.minimumScaleFactor = 0.7;
    madarekTitleLabel.textColor = [UIColor blackColor];
    madarekTitleLabel.textAlignment = NSTextAlignmentRight;
    madarekTitleLabel.adjustsFontSizeToFitWidth = YES;
    [self.scrollView addSubview:madarekTitleLabel];
    
    savabeghTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 100, screenWidth - 20, 25)];
    savabeghTitleLabel.font = FONT_BOLD(15);
    savabeghTitleLabel.text = NSLocalizedString(@"savabegh", @"");
    savabeghTitleLabel.minimumScaleFactor = 0.7;
    savabeghTitleLabel.textColor = [UIColor blackColor];
    savabeghTitleLabel.textAlignment = NSTextAlignmentRight;
    savabeghTitleLabel.adjustsFontSizeToFitWidth = YES;
    [self.scrollView addSubview:savabeghTitleLabel];
    
    addressTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 130, screenWidth - 20, 25)];
    addressTitleLabel.font = FONT_BOLD(15);
    addressTitleLabel.text = NSLocalizedString(@"address", @"");
    addressTitleLabel.minimumScaleFactor = 0.7;
    addressTitleLabel.textColor = [UIColor blackColor];
    addressTitleLabel.textAlignment = NSTextAlignmentRight;
    addressTitleLabel.adjustsFontSizeToFitWidth = YES;
    [self.scrollView addSubview:addressTitleLabel];
    
    
}

- (void)makeSimilarDoctorView{
    similarLabelOnBottom = [[UILabel alloc]initWithFrame:CGRectMake(0, screenHeight - 130, screenWidth, 20)];
    similarLabelOnBottom.font = FONT_BOLD(15);
    similarLabelOnBottom.backgroundColor = COLOR_1;
    similarLabelOnBottom.text = NSLocalizedString(@"similarAnjoman", @"");
    similarLabelOnBottom.textColor = [UIColor whiteColor];
    similarLabelOnBottom.textAlignment = NSTextAlignmentCenter;
    similarLabelOnBottom.hidden = YES;
    [self.view addSubview:similarLabelOnBottom];
    
    similarDoctorScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, screenHeight - 110, screenWidth, 110)];
    similarDoctorScrollView.tag = 545;
    similarDoctorScrollView.backgroundColor = [UIColor whiteColor];
    similarDoctorScrollView.hidden = YES;
    [self.view addSubview:similarDoctorScrollView];
    activityIndicatorViewForSimilarDoctors = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(screenWidth/2 - 25, screenHeight - 45, 50, 50)];
    activityIndicatorViewForSimilarDoctors.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [activityIndicatorViewForSimilarDoctors startAnimating];
    [self.view addSubview:activityIndicatorViewForSimilarDoctors];
    
}

- (void)makeTableViewWithYpos:(CGFloat )yPos{
    
    activityButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth/2, yPos, screenWidth/2, 50)];
    [activityButton setTitle:NSLocalizedString(@"activity", @"") forState:UIControlStateNormal];
    activityButton.titleLabel.font = FONT_NORMAL(17);
    //[activityButton setBackgroundColor:COLOR_1];
    [activityButton setBackgroundColor:COLOR_2];
    [activityButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [activityButton addTarget:self action:@selector(activityButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:activityButton];
    
    aboutDocButton = [[UIButton alloc]initWithFrame:CGRectMake(0, yPos, screenWidth/2, 50)];
    [aboutDocButton setTitle:NSLocalizedString(@"aboutAnjoman", @"") forState:UIControlStateNormal];
    aboutDocButton.titleLabel.font = FONT_NORMAL(17);
    [aboutDocButton setBackgroundColor:COLOR_1];
    [aboutDocButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [aboutDocButton addTarget:self action:@selector(aboutDocButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:aboutDocButton];
    
    boxUnderButton = [[UIView alloc]initWithFrame:CGRectMake(screenWidth/2, activityButton.frame.origin.y + 5 , screenWidth/2, activityButton.frame.size.height - 5)];
    boxUnderButton.backgroundColor = [UIColor colorWithRed:0.202 green:0.822 blue:0.806 alpha:0.4];
    //[self.view addSubview:boxUnderButton];
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, yPos + 50, screenWidth, screenHeight - yPos)];
    self.scrollView.tag = 124;
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = NO;
    self.scrollView.directionalLockEnabled = YES;
    //self.scrollView.scrollEnabled = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.directionalLockEnabled = YES;
    [self.view addSubview:self.scrollView];
    self.scrollView.contentSize = CGSizeMake(screenWidth, screenHeight);
    [self.scrollView scrollRectToVisible:CGRectMake(screenWidth, 0, screenWidth, self.scrollView.frame.size.height) animated:YES];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, yPos + 50, screenWidth, screenHeight - (yPos + 50))];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    activityIndicatorView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(screenWidth/2 - 25, 2 * screenHeight/3, 50, 50)];
    activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [activityIndicatorView startAnimating];
    [self.view addSubview:activityIndicatorView];
    
    [self makeSimilarDoctorView];
    //    refreshControl = [[UIRefreshControl alloc]init];
    //    [self.tableView addSubview:refreshControl];
    //    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    [self makeAboutDoctorTexts];
    
}

- (void)refreshTable{
        
}

- (void)activityButtonAction{
    //[self.scrollView scrollRectToVisible:CGRectMake(screenWidth, 0, screenWidth, self.scrollView.frame.size.height) animated:YES];
    similarLabelOnBottom.hidden = YES;
    similarDoctorScrollView.hidden = YES;
    self.tableView.hidden = NO;
    [activityButton setBackgroundColor:COLOR_2];
    [aboutDocButton setBackgroundColor:COLOR_1];
    //    [UIView animateWithDuration:0.2 animations:^{
    //        CGRect rect = boxUnderButton.frame;
    //        rect.origin.x = screenWidth/2;
    //        [boxUnderButton setFrame:rect];
    //    }];
    
}

- (void)aboutDocButtonAction{
    //[self.scrollView scrollRectToVisible:CGRectMake(0, 0, screenWidth, self.scrollView.frame.size.height) animated:YES];
    similarLabelOnBottom.hidden = NO;
    similarDoctorScrollView.hidden = NO;
    self.tableView.hidden = YES;
    
    [aboutDocButton setBackgroundColor:COLOR_2];
    [activityButton setBackgroundColor:COLOR_1];
    //    [UIView animateWithDuration:0.2 animations:^{
    //        CGRect rect = boxUnderButton.frame;
    //        rect.origin.x = 0;
    //        [boxUnderButton setFrame:rect];
    //    }];
    
}

- (void)backButtonImgAction{
    [self.navigationController popToRootViewControllerAnimated:YES];
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
    [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"inDoctorPage"];
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
//    CGFloat height = sizeOfText.height + 50;
//    if (height < screenWidth + 10)
//        height = screenWidth + 10;
    return sizeOfText.height;
    
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
    NSDictionary *landingPageDic = [self.tableArray objectAtIndex:btn.tag];
    NSDictionary *tempDic = [[NSDictionary alloc]initWithObjectsAndKeys:landingPageDic.LPPostID, @"id", [NSNumber numberWithInteger:btn.tag], @"index", nil];
    [_favArray addObject:tempDic];
    [self favOnServerWithID:landingPageDic.LPPostID];
    
}

- (void)likeButtonAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    
    UIImage *offImage = [UIImage imageNamed:@"like"];
    UIImage *onImage = [UIImage imageNamed:@"like on"];
    UIImage *currentImage = [btn imageForState:UIControlStateNormal];
    if ([UIImagePNGRepresentation(offImage) isEqualToData:UIImagePNGRepresentation(currentImage)]) {
        [btn setImage:onImage forState:UIControlStateNormal];
    }else{
        [btn setImage:offImage forState:UIControlStateNormal];
    }
    
    NSDictionary *landingPageDic = [self.tableArray objectAtIndex:btn.tag];
    NSMutableDictionary *landingPageDic2 = [[NSMutableDictionary alloc]initWithDictionary:landingPageDic];
    NSDictionary *tempDic = [[NSDictionary alloc]initWithObjectsAndKeys:landingPageDic2.LPPostID, @"id", [NSNumber numberWithInteger:btn.tag], @"index", nil];
    [_likeArray addObject:tempDic];
    [self likeOnServerWithID:landingPageDic2.LPPostID];
    
    NSInteger likes = landingPageDic2.LPLikes_count;
    if ([landingPageDic2.LPLiked integerValue] == 0) {
        likes++;
        [landingPageDic2 setObject:[NSString stringWithFormat:[NSString stringWithFormat:@"%d", 1], likes] forKey:@"liked"];
        [Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:@"1" field:@"liked" postId:landingPageDic2.LPPostID];
        
    }else{
        likes--;
        [landingPageDic2 setObject:[NSString stringWithFormat:[NSString stringWithFormat:@"%d", 0], likes] forKey:@"liked"];
        [Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:@"1" field:@"liked" postId:landingPageDic2.LPPostID];
        
    }
    
    [landingPageDic2 setObject:[NSString stringWithFormat:@"%ld", (long)likes] forKey:@"likes_count"];
    [Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:[NSString stringWithFormat:@"%@", [[tempDic objectForKey:@"data"] objectForKey:@"count"]] field:@"likes_count" postId:landingPageDic2.LPPostID];
    
    [self.tableArray replaceObjectAtIndex:btn.tag withObject:landingPageDic2];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:btn.tag inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)shareButtonAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    
    NSDictionary *landingPageDic = [self.tableArray objectAtIndex:btn.tag];
    
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

- (void)tapOnAuthorImage:(UITapGestureRecognizer *)tap{
    /*
    NSDictionary *tempDic = [self.tableArray objectAtIndex:tap.view.tag];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ClinicViewController *view = (ClinicViewController *)[story instantiateViewControllerWithIdentifier:@"ClinicViewController"];
    view.userEntityId = tempDic.LPUserEntityId;
    [self.navigationController pushViewController:view animated:YES];
     */
}

- (void)tapOnSilimilarDoctorImage:(UITapGestureRecognizer *)tap{
    //[self.navigationController popViewControllerAnimated:YES];
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DoctorPageViewController *view = (DoctorPageViewController *)[story instantiateViewControllerWithIdentifier:@"DoctorPageViewController"];
    view.userEntityId = [[similarDoctorsArray objectAtIndex:tap.view.tag]objectForKey:@"id"];
    view.userAvatar = [[similarDoctorsArray objectAtIndex:tap.view.tag]objectForKey:@"avatar"];
    view.userTitle = [[similarDoctorsArray objectAtIndex:tap.view.tag]objectForKey:@"name"];
    view.userJobTitle = [[similarDoctorsArray objectAtIndex:tap.view.tag]objectForKey:@"job_title"];
    [self.navigationController pushViewController:view animated:YES];
    
}

- (void)askDoctorButtonAction{
    NSString *isnotLoggedIn = [[NSUserDefaults standardUserDefaults]objectForKey:@"isNotLoggedin"];
    if ([isnotLoggedIn length] > 0) {
        //[[NSUserDefaults standardUserDefaults]removeObjectForKey:@"isNotLoggedin"];
        [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"isPasswordChanged"];
        
           }else{
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        DirectQuestionViewController *view = (DirectQuestionViewController *)[story instantiateViewControllerWithIdentifier:@"DirectQuestionViewController"];
        view.userEntityId = _userEntityId;
        view.userAvatar = _userAvatar;
        view.userTitle = _userTitle;
        view.userJobTitle = _userJobTitle;
        view.isFromDoctorPage = YES;
        [self.navigationController pushViewController:view animated:YES];
    }
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


#pragma mark - scrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.tag == 124) {
        static NSInteger previousPage = 0;
        CGFloat pageWidth = scrollView.frame.size.width;
        float fractionalPage = scrollView.contentOffset.x / pageWidth;
        NSInteger page = lround(fractionalPage);
        if (previousPage != page) {
            if (page == 0) {
                similarLabelOnBottom.hidden = NO;
                similarDoctorScrollView.hidden = NO;
                [UIView animateWithDuration:0.2 animations:^{
                    [aboutDocButton setBackgroundColor:COLOR_2];
                    [activityButton setBackgroundColor:COLOR_1];
                    CGRect rect = boxUnderButton.frame;
                    rect.origin.x = 0;
                    [boxUnderButton setFrame:rect];
                    scrollView.pagingEnabled = NO;
                }];
            }else{
                similarLabelOnBottom.hidden = YES;
                similarDoctorScrollView.hidden = YES;
                [UIView animateWithDuration:0.2 animations:^{
                    [activityButton setBackgroundColor:COLOR_2];
                    [aboutDocButton setBackgroundColor:COLOR_1];
                    
                    CGRect rect = boxUnderButton.frame;
                    rect.origin.x = screenWidth/2;
                    [boxUnderButton setFrame:rect];
                    scrollView.pagingEnabled = YES;
                }];
            }
            previousPage = page;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height) {
        // we are at the end
        if (currentPage == 1)/*posts*/{
            NSDictionary *landingPageDic = [self.tableArray lastObject];
            NSInteger dateNumber = [landingPageDic.LPPublish_date integerValue];
            dateNumber -= 1;
            [self fetchPostsFromServerWithRequest:@"old" WithDate:[NSString stringWithFormat:@"%ld", (long)dateNumber]];
        }
    }
}

#pragma mark - table view delegate

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    // Set expanded cell then tell tableView to redraw with animation
    selectedRow = indexPath.row;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.tableArray count];
}

//-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    //minimum size of your cell, it should be single line of label if you are not clear min. then return UITableViewAutomaticDimension;
//    return UITableViewAutomaticDimension;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
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
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    id cellToReturn=nil;
    NSDictionary *landingPageDic = [self.tableArray objectAtIndex:indexPath.row];
    NSString *postType = landingPageDic.LPPostType;
    
    //audio
    if ([postType isEqualToString:@"audio"]) {
        //NSString *cellIdentifier = [NSString stringWithFormat:@"S%1ldR%1ld",(long)indexPath.section,(long)indexPath.row];
        LandingPageCustomCellAudio *cell = [tableView dequeueReusableCellWithIdentifier:@"cell1"];
        if (indexPath.row < [self.tableArray count] - 1) {
            
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
                        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(downloadPlayButtonAction:)];
                        [cell.largeProgressView addGestureRecognizer:tap];
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
                        [cell.heartButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
                    }else{
                        [cell.heartButton setImage:[UIImage imageNamed:@"like on"] forState:UIControlStateNormal];
                    }
                }
            }
            cellToReturn = cell;
        }else{
            return [self loadingCell];
        }
        //video
    }else if ([postType isEqualToString:@"video"]){
        //NSString *cellIdentifier = [NSString stringWithFormat:@"S%1ldR%1ld",(long)indexPath.section,(long)indexPath.row];
        LandingPageCustomCellVideo *cell = [tableView dequeueReusableCellWithIdentifier:@"cell2"];
        if (indexPath.row < [self.tableArray count] - 1) {
            
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
                        [cell.heartButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
                    }else{
                        [cell.heartButton setImage:[UIImage imageNamed:@"like on"] forState:UIControlStateNormal];
                    }
                }
            }
            cellToReturn = cell;
        }else{
            return [self loadingCell];
        }
        
    }
    //other post types
    else{
        NSString *cellIdentifier = [NSString stringWithFormat:@"S%1ldR%1ld",(long)indexPath.section,(long)indexPath.row];
        LandingPageCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell3"];
        if (indexPath.row < [self.tableArray count] - 1) {
            
            if (cell == nil)
                cell = (LandingPageCustomCell *)[[LandingPageCustomCell alloc]
                                                 initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
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
                        [cell.heartButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
                    }else{
                        [cell.heartButton setImage:[UIImage imageNamed:@"like on"] forState:UIControlStateNormal];
                    }
                }
            }
            cellToReturn = cell;
        }else{
            return [self loadingCell];
        }
        
    }
    return cellToReturn;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row > 6) {
        [UIView animateWithDuration:0.5 animations:^{
            CGRect rect = activityButton.frame;
            rect.origin.y = 70;
            [activityButton setFrame:rect];
            
            rect = aboutDocButton.frame;
            rect.origin.y = 70;
            [aboutDocButton setFrame:rect];
            
            rect = self.tableView.frame;
            rect.origin.y = 120;
            rect.size.height = screenHeight - 120;
            [self.tableView setFrame:rect];
            
            rect = self.scrollView.frame;
            rect.origin.y = 120;
            rect.size.height = screenHeight - 120;
            [self.scrollView setFrame:rect];
            self.scrollView.backgroundColor = [UIColor whiteColor];
            
        }];
    }else{
        [UIView animateWithDuration:0.5 animations:^{
            CGRect rect = activityButton.frame;
            rect.origin.y = 70 +  screenWidth * 0.43;
            [activityButton setFrame:rect];
            
            rect = aboutDocButton.frame;
            rect.origin.y = 70 +  screenWidth * 0.43;
            [aboutDocButton setFrame:rect];
            
            rect = self.tableView.frame;
            rect.origin.y = aboutDocButton.frame.origin.y + 50;
            rect.size.height = screenHeight - (120 + screenWidth * 0.43);
            [self.tableView setFrame:rect];
            
            rect = self.scrollView.frame;
            rect.origin.y = aboutDocButton.frame.origin.y + 50;
            rect.size.height = screenHeight - (120 + screenWidth * 0.43);
            [self.scrollView setFrame:rect];
            self.scrollView.backgroundColor = [UIColor clearColor];
        }];
    }
    /*
     if ([self hasConnectivity]) {
     if (cell.tag == loadingCellTag) {
     //if (currentPage <= pageCount) {
     NSDictionary *landingPageDic = [self.tableArray lastObject];
     NSInteger dateNumber = [landingPageDic.LPPublish_date integerValue];
     dateNumber -= 1;
     isPagingForCategories = NO;
     [self fetchPostsFromServerWithRequest:@"old" WithDate:[NSString stringWithFormat:@"%ld", dateNumber]];
     }*//*else{
         NSString *showNoMoreData = [[NSUserDefaults standardUserDefaults]objectForKey:@"ShowNoMoreData"];
         if ([showNoMoreData length] == 0) {
         
         //
        //
        //
        // = [[UIAlertView alloc] initWithTitle:@""
         message:NSLocalizedString(@"NoMoreData", @"")
         delegate:nil
         cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
         //
         [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"ShowNoMoreData"];
         }
         }
         */
    //}
    
}

- (LandingPageCustomCell *)loadingCell {
    
    LandingPageCustomCell *cell = (LandingPageCustomCell *)[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    
    cell.backgroundColor = [UIColor whiteColor];
    NSArray *imageNames = @[@"1.png", @"2.png", @"3.png", @"4.png"];
    
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (int i = 0; i < imageNames.count; i++) {
        [images addObject:[UIImage imageNamed:[imageNames objectAtIndex:i]]];
    }
    
    // Normal Animation
    //animationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth/2 - 50, screenHeight - 30 , 100, 30)];
    UIImageView *animationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth/2 - 50, TABLEVIEW_CELL_HEIGHT/2 - 15 , 100, 30)];
    animationImageView.animationImages = images;
    animationImageView.animationDuration = 0.9;
    
    [animationImageView startAnimating];
    [cell addSubview:animationImageView];
    
    cell.tag = loadingCellTag;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = [_tableArray objectAtIndex:indexPath.row];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LandingPageDetailViewController *view = (LandingPageDetailViewController *)[story instantiateViewControllerWithIdentifier:@"LandingPageDetailViewController"];
    view.dictionary = dic;
    [self.navigationController pushViewController:view animated:YES];

    /*
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    selectedRow = indexPath.row;
    isExpand = !isExpand;
    if (!isExpand) {
        selectedRow = 1000;
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
     */
    //[self.tableView reloadData];
}

#pragma mark - progress view for download
- (void)startAnimationProgress
{
    _timerForProgress = [NSTimer scheduledTimerWithTimeInterval:0.03
                                                         target:self
                                                       selector:@selector(progressChange)
                                                       userInfo:nil
                                                        repeats:YES];
}
- (void)progressChange
{
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:whichRowShouldBeReload inSection:0];
    LandingPageCustomCellAudio *cell = (LandingPageCustomCellAudio *)[self.tableView cellForRowAtIndexPath:indexpath];
    CGFloat progress = cell.largeProgressView.progress + 0.0001f;
    [cell.largeProgressView setProgress:progress animated:YES];
    
    if (cell.largeProgressView.progress >= 1.0f && [_timerForProgress isValid]) {
        //[progressView setProgress:0.f animated:YES];
        [self stopAnimationProgress];
    }
    
}
- (void)stopAnimationProgress
{
    [_timerForProgress invalidate];
    _timerForProgress = nil;
    //NSLog(@"stopAnimationProgress");
    [self startAnimationProgressFinal];
    
}

- (void)startAnimationProgressFinal
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _timerForProgressFinal = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                                  target:self
                                                                selector:@selector(progressChangeFinal)
                                                                userInfo:nil
                                                                 repeats:YES];
        
    });
}
- (void)progressChangeFinal
{
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:whichRowShouldBeReload inSection:0];
    LandingPageCustomCellAudio *cell = (LandingPageCustomCellAudio *)[self.tableView cellForRowAtIndexPath:indexpath];
    CGFloat progress = cell.largeProgressView.progress + 0.01f;
    [cell.largeProgressView setProgress:progress animated:YES];
    
    if (cell.largeProgressView.progress >= 1.0f && [_timerForProgressFinal isValid]) {
        //[progressView setProgress:0.f animated:YES];
        [self stopAnimationProgressFinal];
        [self.tableView reloadData];
    }
    
}
- (void)stopAnimationProgressFinal
{
    [_timerForProgressFinal invalidate];
    _timerForProgressFinal = nil;
    
}

- (void)downloadPlayButtonActionVideo:(id)sender{
    UIButton *btn = (UIButton *)sender;
    whichRowShouldBeReload = btn.tag;
    [self startAnimationProgress];
    NSDictionary *tempDic = [self.tableArray objectAtIndex:btn.tag];
    NSString *fileUrl;
    NSString *fileName;
    if ([tempDic.LPPostType isEqualToString:@"audio"]) {
        fileUrl = tempDic.LPAudioUrl;
    } else if ([tempDic.LPPostType isEqualToString:@"video"]){
        fileUrl = tempDic.LPVideoUrl;
    }
    fileName = [fileUrl lastPathComponent];
    dispatch_async(kBgQueue, ^{
        NSData *fileData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",fileUrl]]];
        if (fileData) {
            NSString *appDocumentsDirectory = [DocumentDirectoy getDocuementsDirectory];
            NSString *filePath = [appDocumentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", fileName]];
            [fileData writeToFile:filePath atomically:YES];
            //[self.tableView reloadData];
            [self stopAnimationProgress];
            //NSLog(@"download %@ completed", fileName);
            //            NSIndexPath *indexpath = [NSIndexPath indexPathForRow:btn.tag inSection:0];
            //            [self.tableView reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationNone];
        }
    });
    
}

- (void)downloadPlayButtonAction:(UITapGestureRecognizer *)sender{
    whichRowShouldBeReload = sender.view.tag;
    [self startAnimationProgress];
    NSDictionary *tempDic = [self.tableArray objectAtIndex:sender.view.tag];
    NSString *fileUrl;
    NSString *fileName;
    if ([tempDic.LPPostType isEqualToString:@"audio"]) {
        fileUrl = tempDic.LPAudioUrl;
    } else if ([tempDic.LPPostType isEqualToString:@"video"]){
        fileUrl = tempDic.LPVideoUrl;
    }
    fileName = [fileUrl lastPathComponent];
    dispatch_async(kBgQueue, ^{
        NSData *fileData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",fileUrl]]];
        if (fileData) {
            NSString *appDocumentsDirectory = [DocumentDirectoy getDocuementsDirectory];
            NSString *filePath = [appDocumentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", fileName]];
            [fileData writeToFile:filePath atomically:YES];
            //[self.tableView reloadData];
            [self stopAnimationProgress];
            //NSLog(@"download %@ completed", fileName);
            //            NSIndexPath *indexpath = [NSIndexPath indexPathForRow:btn.tag inSection:0];
            //            [self.tableView reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationNone];
        }
    });
    
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
        NSDictionary *dic = [self.tableArray objectAtIndex:btn.tag];
        [self playAudioWithName:[dic.LPAudioUrl lastPathComponent]];
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
    }
}

-(void)playbackTimerAction:(NSTimer*)timer {
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:whichRowShouldBeReload inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)stopTimer {
    [myTimer invalidate];
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

- (void)fetchPostsFromServerWithRequest:(NSString *)request WithDate:(NSString *)date{
    NSDictionary *userpassDic = [GetUsernamePassword getUsernamePassword];
    NSDictionary *params;
    if ([userpassDic count] > 1) {
        
        params = @{@"username":[userpassDic objectForKey:@"username"]/*@"09191234072"*/,
                   @"password":[userpassDic objectForKey:@"password"]/*@“123456”*/,
                   @"date":date,
                   @"entity_id":self.userEntityId,
                   @"unit_id": @"3"};
    }else{
        params = @{@"username":@"",
                   @"password":@"",
                   @"date":date,
                   @"entity_id":self.userEntityId,
                   @"unit_id": @"3"};
    }
    /*http://213.233.175.250:8081/web_services/v3/posts/timeline*/
    
    //    KeychainWrapper *keychainWrapper = [[KeychainWrapper alloc]init];
    //    NSString *username = [keychainWrapper myObjectForKey:(__bridge id)(kSecAttrDescription)];
    //    NSString *password = [keychainWrapper myObjectForKey:(__bridge id)(kSecAttrService)];
    NSString *url = [NSString stringWithFormat:@"%@posts/timeline", BaseURL];
    
    if (!isBusyNow) {
        isBusyNow = YES;
        [refreshControl endRefreshing];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        manager.requestSerializer.timeoutInterval = 45;
        [manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
            NSInteger countOfPosts = [self.tableArray count];
            NSDictionary *tempDic = (NSDictionary *)responseObject;
            NSString *login =  [tempDic objectForKey:@"authorized"];
            if ([login integerValue]  == 0) {
                [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"isNotLoggedin"];
            }
            
            for (NSDictionary *post in [tempDic objectForKey:@"posts"]) {
                [self.tableArray addObject:post];
            }
            
            [noResultLabelMataleb removeFromSuperview];
            if ([self.tableArray count] == 0) {
                noResultLabelMataleb = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 220, 10, 200,  25)];
                noResultLabelMataleb.font = FONT_MEDIUM(13);
                noResultLabelMataleb.text = NSLocalizedString(@"noContent", @"");
                noResultLabelMataleb.minimumScaleFactor = 0.7;
                noResultLabelMataleb.textColor = [UIColor blackColor];
                noResultLabelMataleb.textAlignment = NSTextAlignmentRight;
                noResultLabelMataleb.adjustsFontSizeToFitWidth = YES;
                [self.tableView addSubview:noResultLabelMataleb];
            }
            
            [activityIndicatorView stopAnimating];
            [ProgressHUD dismiss];
            isBusyNow = NO;
            [self.tableView reloadData];
            if ([[tempDic objectForKey:@"posts"]count] > 0 && countOfPosts > 0) {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:countOfPosts-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }
        } failure:^(NSURLSessionTask *operation, NSError *error) {
             
            [ProgressHUD dismiss];
            isBusyNow = NO;
        }];
    }
}

- (void)fetchAnjomanInfoWithEntityId:(NSString *)entityId{
    NSDictionary *userpassDic = [GetUsernamePassword getUsernamePassword];
    NSDictionary *params = @{@"username":[userpassDic objectForKey:@"username"]/*@"09191234072"*/,
                             @"password":[userpassDic objectForKey:@"password"]/*@“123456”*/,
                             @"unit_id":@"3",
                             @"entity":@"Community",
                             @"entity_id":entityId};
    /*http://213.233.175.250:8081/web_services/v3/page/aboutDoctor*/
    
    NSString *url = [NSString stringWithFormat:@"%@entities/detail", BaseURL];
    
    if (!isBusyNow) {
        [refreshControl endRefreshing];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        manager.requestSerializer.timeoutInterval = 45;;
        [manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
            NSDictionary *tempDic = (NSDictionary *)responseObject;
            NSMutableDictionary *tempDic2 = [[NSMutableDictionary alloc]initWithDictionary:[tempDic objectForKey:@"entity"]];
            if ([[tempDic2 objectForKey:@"about"] length] == 0) {
                [tempDic2 setObject:[NSString stringWithFormat:@"%@", NSLocalizedString(@"noData", @"")] forKey:@"about"];
            }
            if ([[tempDic2 objectForKey:@"degree"] length] == 0) {
                [tempDic2 setObject:[NSString stringWithFormat:@"%@", NSLocalizedString(@"noData", @"")] forKey:@"degree"];
            }
            if ([[tempDic2 objectForKey:@"experience"] length] == 0) {
                [tempDic2 setObject:[NSString stringWithFormat:@"%@", NSLocalizedString(@"noData", @"")] forKey:@"experience"];
            }
            if ([[tempDic2 objectForKey:@"address"] length] == 0) {
                [tempDic2 setObject:[NSString stringWithFormat:@"%@", NSLocalizedString(@"noData", @"")] forKey:@"address"];
            }
            /*
             dispatch_async(dispatch_get_global_queue(0,0), ^{
             NSData * data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [tempDic2 objectForKey:@"cover"]]]];
             if ( data == nil )
             return;
             dispatch_async(dispatch_get_main_queue(), ^{
             coverImageView.image = [UIImage imageWithData: data];
             CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
             [[coverImageView.image averageColor]getRed:&red green:&green blue:&blue alpha:&alpha];
             CGFloat threshold = 2.3;
             CGFloat sumOfColors = red + green + blue;
             UIColor *textColor = (sumOfColors < threshold) ? [UIColor whiteColor] : [UIColor blackColor];
             authorNameLabel.textColor = textColor;
             authorJobLabel.textColor = textColor;
             });
             });
             */
            //coverImageView.contentMode = UIViewContentModeScaleAspectFit;
            //coverImageView.clipsToBounds = YES;
            CGFloat yPosOfElement = [self getHeightOfString:[tempDic2 objectForKey:@"about"]];
            aboutMeLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 25, screenWidth - 20, [self getHeightOfString:[tempDic2 objectForKey:@"about"]])];
            aboutMeLabel.font = FONT_NORMAL(15);
            aboutMeLabel.text = [tempDic2 objectForKey:@"about"];
            aboutMeLabel.minimumScaleFactor = 0.7;
            aboutMeLabel.numberOfLines = 0;
            aboutMeLabel.textColor = [UIColor blackColor];
            aboutMeLabel.textAlignment = NSTextAlignmentRight;
            aboutMeLabel.adjustsFontSizeToFitWidth = YES;
            [self.scrollView addSubview:aboutMeLabel];
            
            CGRect rect = madarekTitleLabel.frame;
            rect.origin.y = yPosOfElement + 20;
            [madarekTitleLabel setFrame:rect];
            
            yPosOfElement += [self getHeightOfString:[tempDic2 objectForKey:@"degree"]] + 20;
            madarekLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, madarekTitleLabel.frame.origin.y + madarekTitleLabel.frame.size.height, screenWidth - 20, [self getHeightOfString:[tempDic2 objectForKey:@"degree"]])];
            madarekLabel.font = FONT_NORMAL(15);
            madarekLabel.text = [tempDic2 objectForKey:@"degree"];
            madarekLabel.minimumScaleFactor = 0.7;
            madarekLabel.numberOfLines = 0;
            madarekLabel.textColor = [UIColor blackColor];
            madarekLabel.textAlignment = NSTextAlignmentRight;
            madarekLabel.adjustsFontSizeToFitWidth = YES;
            [self.scrollView addSubview:madarekLabel];
            
            rect = savabeghTitleLabel.frame;
            rect.origin.y = yPosOfElement + 20;
            [savabeghTitleLabel setFrame:rect];
            
            yPosOfElement += [self getHeightOfString:[tempDic2 objectForKey:@"experience"]] + 20;
            savabeghLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, savabeghTitleLabel.frame.origin.y + savabeghTitleLabel.frame.size.height, screenWidth - 20, [self getHeightOfString:[tempDic2 objectForKey:@"experience"]])];
            savabeghLabel.font = FONT_NORMAL(15);
            savabeghLabel.text = [tempDic2 objectForKey:@"experience"];
            savabeghLabel.minimumScaleFactor = 0.7;
            savabeghLabel.numberOfLines = 0;
            savabeghLabel.textColor = [UIColor blackColor];
            savabeghLabel.textAlignment = NSTextAlignmentRight;
            savabeghLabel.adjustsFontSizeToFitWidth = YES;
            [self.scrollView addSubview:savabeghLabel];
            
            rect = addressTitleLabel.frame;
            rect.origin.y = yPosOfElement + 20;
            [addressTitleLabel setFrame:rect];
            
            yPosOfElement += [self getHeightOfString:[tempDic2 objectForKey:@"address"]] + 20;
            addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, addressTitleLabel.frame.origin.y + addressTitleLabel.frame.size.height, screenWidth - 60, [self getHeightOfString:[tempDic2 objectForKey:@"address"]])];
            addressLabel.font = FONT_NORMAL(15);
            addressLabel.text = [tempDic2 objectForKey:@"address"];
            addressLabel.minimumScaleFactor = 0.7;
            addressLabel.textColor = [UIColor blackColor];
            addressLabel.numberOfLines = 0;
            addressLabel.textAlignment = NSTextAlignmentRight;
            addressLabel.adjustsFontSizeToFitWidth = YES;
            [self.scrollView addSubview:addressLabel];
            
            UIImageView *addressImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 40, addressLabel.frame.origin.y + addressLabel.frame.size.height/4, 20, 31)];
            addressImageView.image = [UIImage imageNamed:@"map_icon"];
            [self.scrollView addSubview:addressImageView];
            
            /*
             //87 × 125
             doctrorTelephone = [tempDic2 objectForKey:@"phone"];
             UIButton *mobileButton = [[UIButton alloc]initWithFrame:CGRectMake(50, yPosOfElement + 40, 43, 62)];
             [mobileButton setImage:[UIImage imageNamed:@"ic_dr_tel"] forState:UIControlStateNormal];
             [mobileButton addTarget:self action:@selector(mobileButtonAction) forControlEvents:UIControlEventTouchUpInside];
             [self.scrollView addSubview:mobileButton];
             
             //112 × 74
             doctorEmail = [tempDic2 objectForKey:@"email"];
             UIButton *emailButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth/2 - 28, yPosOfElement + 55, 56, 37)];
             [emailButton setImage:[UIImage imageNamed:@"ic_dr_mail"] forState:UIControlStateNormal];
             [emailButton addTarget:self action:@selector(emailButtonAction) forControlEvents:UIControlEventTouchUpInside];
             [self.scrollView addSubview:emailButton];
             
             //104 × 122
             doctorWebsite = [tempDic2 objectForKey:@"website"];
             UIButton *websiteButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - 102, yPosOfElement + 40, 52, 61)];
             [websiteButton setImage:[UIImage imageNamed:@"ic_dr_website"] forState:UIControlStateNormal];
             [websiteButton addTarget:self action:@selector(websiteButtonAction) forControlEvents:UIControlEventTouchUpInside];
             [self.scrollView addSubview:websiteButton];
             */
            
            [self.scrollView setContentSize:CGSizeMake(screenWidth, yPosOfElement + 200)];
            
            if (_isFromPushNotif) {
                [doctorImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[tempDic objectForKey:@"entity"]objectForKey:@"avatar"]]] placeholderImage:[UIImage imageNamed:@"icon upload ax"]];
                
                authorNameLabel.text = [[tempDic objectForKey:@"entity"]objectForKey:@"name"];
                authorJobLabel.text = [[tempDic objectForKey:@"entity"]objectForKey:@"job_title"];
                
            }

        } failure:^(NSURLSessionTask *operation, NSError *error) {
             
            [ProgressHUD dismiss];
        }];
    }
}

- (void)fetchDoctorOfAnjomanWithAnjomanId:(NSString *)anjomanId{
    NSDictionary *userpassDic = [GetUsernamePassword getUsernamePassword];
    NSDictionary *params = @{@"username":[userpassDic objectForKey:@"username"]/*@"09191234072"*/,
                             @"password":[userpassDic objectForKey:@"password"]/*@“123456”*/,
                             @"unit_id":@"3",
                             @"entity":@"Community",
                             @"entity_id":anjomanId,
                             @"limit":@"",
                             @"page":@"0"};
    /*http://213.233.175.250:8081/web_services/v3/expertises/sameExpertise*/
    
    NSString *url = [NSString stringWithFormat:@"%@entities/doctors", BaseURL];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    manager.requestSerializer.timeoutInterval = 45;;
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        
        NSDictionary *tempDic = (NSDictionary *)responseObject;
        similarDoctorsArray = [[NSMutableArray alloc]init];
        CGFloat xPos = 0;
        for (NSDictionary *doctorDic in [tempDic objectForKey:@"entities"]) {
            [similarDoctorsArray addObject:doctorDic];
            UIView *doctorView = [[UIView alloc]initWithFrame:CGRectMake(xPos, 0, 100, 90)];
            [similarDoctorScrollView addSubview:doctorView];
            
            UIImageView *docImageView = [[UIImageView alloc]initWithFrame:CGRectMake(doctorView.frame.size.width/2 - doctorView.frame.size.width/4, 5, doctorView.frame.size.width/2, doctorView.frame.size.width/2)];
            docImageView.layer.cornerRadius = docImageView.frame.size.width / 2;
            [docImageView setImageWithURL:[NSURL URLWithString:[doctorDic objectForKey:@"avatar"]] placeholderImage:[UIImage imageNamed:@"icon upload ax"]];
            docImageView.tag = [similarDoctorsArray count] - 1;
            docImageView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapOnSilimilarDoctorImage:)];
            [docImageView addGestureRecognizer:tap];
            docImageView.clipsToBounds = YES;
            [doctorView addSubview:docImageView];
            
            UILabel *nameLabel =[[UILabel alloc]initWithFrame:CGRectMake(0, docImageView.frame.origin.y + docImageView.frame.size.height, doctorView.frame.size.width, 30)];
            nameLabel.font = FONT_NORMAL(15);
            nameLabel.adjustsFontSizeToFitWidth = YES;
            nameLabel.minimumScaleFactor = 0.5;
            nameLabel.text = [doctorDic objectForKey:@"name"];
            nameLabel.textColor = [UIColor blackColor];
            nameLabel.textAlignment = NSTextAlignmentCenter;
            nameLabel.minimumScaleFactor = 0.7;
            nameLabel.adjustsFontSizeToFitWidth = YES;
            [doctorView addSubview:nameLabel];
            
            UILabel *jobLabel =[[UILabel alloc]initWithFrame:CGRectMake(0, docImageView.frame.origin.y + docImageView.frame.size.height + 20, doctorView.frame.size.width, 25)];
            jobLabel.font = FONT_NORMAL(11);
            jobLabel.text = [doctorDic objectForKey:@"job_title"];
            jobLabel.textColor = [UIColor grayColor];
            jobLabel.textAlignment = NSTextAlignmentCenter;
            jobLabel.minimumScaleFactor = 0.7;
            jobLabel.adjustsFontSizeToFitWidth = YES;
            [doctorView addSubview:jobLabel];
            
            xPos +=100;
        }
        [activityIndicatorViewForSimilarDoctors stopAnimating];
        similarDoctorScrollView.contentSize = CGSizeMake(screenWidth * ([similarDoctorsArray count]/(screenWidth/100)), 90);
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
         
    }];
}

- (void)mobileButtonAction{
    NSString *tele = doctrorTelephone;
    if (![tele containsString:@"021"]) {
        tele = [NSString stringWithFormat:@"021%@", doctrorTelephone];
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:tele]];
}

- (void)emailButtonAction{
    [self showEmailComposor];
}

- (void)websiteButtonAction{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:doctorWebsite]];
}

- (void)likeOnServerWithID:(NSString *)idOfPost{
    /*http://213.233.175.250:8081/web_services/v3/social_activities/countLike*/
    
    NSDictionary *userpassDic = [GetUsernamePassword getUsernamePassword];
    NSDictionary *params;
    if ([userpassDic count] > 1) {
        
        params = @{@"username":[userpassDic objectForKey:@"username"]/*@"09191234072"*/,
                   @"password":[userpassDic objectForKey:@"password"]/*@“123456”*/,
                   @"model": @"POST",
                   @"foreign_key": idOfPost,
                   @"user_id": [GetUsernamePassword getUserId]/*@"6144"*/,
                   @"unit_id": @"3"
                   };
    }else{
        params = @{@"username":@"",
                   @"password":@"",
                   @"model": @"POST",
                   @"foreign_key": idOfPost,
                   @"user_id": [GetUsernamePassword getUserId]/*@"6144"*/,
                   @"unit_id": @"3"
                   };
        
    }
    
    //    KeychainWrapper *keychainWrapper = [[KeychainWrapper alloc]init];
    //    NSString *username = [keychainWrapper myObjectForKey:(__bridge id)(kSecAttrDescription)];
    //    NSString *password = [keychainWrapper myObjectForKey:(__bridge id)(kSecAttrService)];
    NSString *url = [NSString stringWithFormat:@"%@social_activities/setLike", BaseURL];
    
    [refreshControl endRefreshing];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    manager.requestSerializer.timeoutInterval = 45;;
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        NSDictionary *tempDic = (NSDictionary *)responseObject;
        
        NSString *isnotLoggedIn = [[NSUserDefaults standardUserDefaults]objectForKey:@"isNotLoggedin"];
        if ([isnotLoggedIn length] > 0) {
            NSString *message;
            if ([userpassDic count] == 0) {
                message = NSLocalizedString(@"notLogin", @"");
            } else {
                message = NSLocalizedString(@"passwordIsChanged", @"");
            }

             
            return;
        }

        if ([[tempDic objectForKey:@"status"] isEqualToString:@"+"]) {
            NSInteger idOfTargetDelete = 1000;
            NSInteger idOfRow = 1000;
            for (int i = 0; i < [_likeArray count]; i++) {
                NSDictionary *likeDic = [_likeArray objectAtIndex:i];
                if ([idOfPost integerValue] == [[likeDic objectForKey:@"id"]integerValue]) {
                    idOfTargetDelete = i;
                    idOfRow = [[likeDic objectForKey:@"index"]integerValue];
                    break;
                }
            }
            if (idOfTargetDelete < [_likeArray count]) {
                [_likeArray removeObjectAtIndex:idOfTargetDelete];
                [Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:@"1" field:@"liked" postId:idOfPost];
                [Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:[NSString stringWithFormat:@"%@", [[tempDic objectForKey:@"data"] objectForKey:@"count"]] field:@"likes_count" postId:idOfPost];
                
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idOfRow inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                
                
            }
        }else{//status = "-"
            NSInteger idOfTargetDelete = 1000;
            NSInteger idOfRow = 1000;
            for (int i = 0; i < [_likeArray count]; i++) {
                NSDictionary *likeDic = [_likeArray objectAtIndex:i];
                if ([idOfPost integerValue] == [[likeDic objectForKey:@"id"]integerValue]) {
                    idOfTargetDelete = i;
                    idOfRow = [[likeDic objectForKey:@"index"]integerValue];
                    break;
                }
            }
            if (idOfTargetDelete < [_likeArray count]) {
                [_likeArray removeObjectAtIndex:idOfTargetDelete];
                [Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:@"0" field:@"liked" postId:idOfPost];
                [Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:[NSString stringWithFormat:@"%@", [[tempDic objectForKey:@"data"] objectForKey:@"count"]] field:@"likes_count" postId:idOfPost];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idOfRow inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                
            }
            
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSInteger idOfTargetDelete = 1000;
        NSInteger idOfRow = 1000;
        for (int i = 0; i < [_likeArray count]; i++) {
            NSDictionary *likeDic = [_likeArray objectAtIndex:i];
            if ([idOfPost integerValue] == [[likeDic objectForKey:@"id"]integerValue]) {
                idOfTargetDelete = i;
                idOfRow = [[likeDic objectForKey:@"index"]integerValue];
                break;
            }
        }
        if (idOfTargetDelete < [_likeArray count]) {
            [_likeArray removeObjectAtIndex:idOfTargetDelete];
            //
            NSDictionary *landingPageDic = [self.tableArray objectAtIndex:idOfRow];
            NSMutableDictionary *landingPageDic2 = [[NSMutableDictionary alloc]initWithDictionary:landingPageDic];
            NSInteger likes = landingPageDic2.LPLikes_count;
            likes--;
            [landingPageDic2 setObject:[NSString stringWithFormat:@"%ld", (long)likes] forKey:@"likesCount"];
            [landingPageDic2 setObject:[NSString stringWithFormat:[NSString stringWithFormat:@"%d", 0], likes] forKey:@"liked"];
            [self.tableArray replaceObjectAtIndex:idOfRow withObject:landingPageDic2];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idOfRow inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            
            //
            [Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:[NSString stringWithFormat:@"%ld", (long)likes] field:@"liked" postId:idOfPost];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idOfRow inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
        
    }];
}

- (void)favOnServerWithID:(NSString *)idOfPost{
    /*http://213.233.175.250:8081/web_services/v3/social_activities/setFavorite*/
    NSDictionary *userpassDic = [GetUsernamePassword getUsernamePassword];
    NSDictionary *params;
    if ([userpassDic count] > 1) {
        
        params = @{@"username":[userpassDic objectForKey:@"username"]/*@"09191234072"*/,
                   @"password":[userpassDic objectForKey:@"password"]/*@“123456”*/,
                   @"model": @"POST",
                   @"foreign_key": idOfPost,
                   @"user_id": [GetUsernamePassword getUserId]/*@"6144"*/,
                   @"unit_id": @"3"
                   };
    }else{
        params = @{@"username":@"",
                   @"password":@"",
                   @"model": @"POST",
                   @"foreign_key": idOfPost,
                   @"user_id": @"",
                   @"unit_id": @"3"
                   };
    }
    
    //    KeychainWrapper *keychainWrapper = [[KeychainWrapper alloc]init];
    //    NSString *username = [keychainWrapper myObjectForKey:(__bridge id)(kSecAttrDescription)];
    //    NSString *password = [keychainWrapper myObjectForKey:(__bridge id)(kSecAttrService)];
    NSString *url = [NSString stringWithFormat:@"%@social_activities/setFavorite", BaseURL];
    
    [refreshControl endRefreshing];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    manager.requestSerializer.timeoutInterval = 45;;
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        NSDictionary *tempDic = (NSDictionary *)responseObject;
        
        NSString *isnotLoggedIn = [[NSUserDefaults standardUserDefaults]objectForKey:@"isNotLoggedin"];
        if ([isnotLoggedIn length] > 0) {
            NSString *message;
            if ([userpassDic count] == 0) {
                message = NSLocalizedString(@"notLogin", @"");
            } else {
                message = NSLocalizedString(@"passwordIsChanged", @"");
            }

             
            
            return;
        }
        if ([[tempDic objectForKey:@"status"] isEqualToString:@"+"]) {
            NSInteger idOfTargetDelete = 1000;
            NSInteger idOfRow = 1000;
            for (int i = 0; i < [_favArray count]; i++) {
                NSDictionary *likeDic = [_favArray objectAtIndex:i];
                if ([idOfPost integerValue] == [[likeDic objectForKey:@"id"]integerValue]) {
                    idOfTargetDelete = i;
                    idOfRow = [[likeDic objectForKey:@"index"]integerValue];
                    break;
                }
            }
            if (idOfTargetDelete < [_favArray count]) {
                [_favArray removeObjectAtIndex:idOfTargetDelete];
                [Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:@"1" field:@"favorite" postId:idOfPost];
            }
        }else{//status = "-"
            NSInteger idOfTargetDelete = 1000;
            NSInteger idOfRow = 1000;
            for (int i = 0; i < [_favArray count]; i++) {
                NSDictionary *likeDic = [_favArray objectAtIndex:i];
                if ([idOfPost integerValue] == [[likeDic objectForKey:@"id"]integerValue]) {
                    idOfTargetDelete = i;
                    idOfRow = [[likeDic objectForKey:@"index"]integerValue];
                    break;
                }
            }
            if (idOfTargetDelete < [_favArray count]) {
                [_favArray removeObjectAtIndex:idOfTargetDelete];
                [Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:@"0" field:@"favorite" postId:idOfPost];
            }
            
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSInteger idOfTargetDelete = 1000;
        NSInteger idOfRow = 1000;
        for (int i = 0; i < [_favArray count]; i++) {
            NSDictionary *likeDic = [_favArray objectAtIndex:i];
            if ([idOfPost integerValue] == [[likeDic objectForKey:@"id"]integerValue]) {
                idOfTargetDelete = i;
                idOfRow = [[likeDic objectForKey:@"index"]integerValue];
                break;
            }
        }
        if (idOfTargetDelete < [_favArray count]) {
            [_favArray removeObjectAtIndex:idOfTargetDelete];
            [Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:@"0" field:@"favorite" postId:idOfPost];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idOfRow inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
        
    }];
}
#pragma mark Mail Composer
- (void)showEmailComposor {
    
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:@""];
        [mail setMessageBody:@"" isHTML:NO];
        [mail setToRecipients:@[doctorEmail]];
        
        [self presentViewController:mail animated:YES completion:NULL];
    }
    else
    {
        //NSLog(@"This device cannot send email");
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultSent:
            //NSLog(@"You sent the email.");
            break;
        case MFMailComposeResultSaved:
            //NSLog(@"You saved a draft of this email");
            break;
        case MFMailComposeResultCancelled:
            //NSLog(@"You cancelled sending this email.");
            break;
        case MFMailComposeResultFailed:
            //NSLog(@"Mail failed:  An error occurred when trying to compose this email");
            break;
        default:
            //NSLog(@"An error occurred when trying to compose this email");
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}
@end
