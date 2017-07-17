//
//  SafahatMozoeeViewController.m
//  MSN
//
//  Created by Yarima on 4/24/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "SafahatMozoeeViewController.h"
#import "Database.h"
#import <AFHTTPSessionManager.h>
#import <UIImageView+AFNetworking.h>
#import "Header.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import "KeychainWrapper.h"
#import "ProgressHUD.h"
#import "NSDictionary+LandingPage.h"
#import "PezeshkanCustomCell.h"
#import "LandingPageCustomCell.h"
#import "TimeAgoViewController.h"
#import "UIImage+AverageColor.h"
#import <MessageUI/MessageUI.h>
#import "DoctorPageViewController.h"
#import "GetUsernamePassword.h"
#import "GetUsernamePassword.h"
#import "UploadDocumentsViewController.h"
#import "ConsultationListViewController.h"
#import "HealthStatusViewController.h"
#import "LandingPageCustomCellAudio.h"
#import "LandingPageCustomCellVideo.h"
#import "DocumentDirectoy.h"
#import <AVFoundation/AVFoundation.h>
#import "VideoPlayerViewController.h"
#import "FavoritesViewController.h"
#import "AboutViewController.h"
#import "UIImage+Extra.h"
#import "DirectQuestionViewController.h"
#import "LandingPageDetailViewController.h"
#import "SafahatMozoeeCustomCell.h"
#import "SafahatMozoeeViewController.h"
#import "CustomButton.h"
#define loadingCellTag  1273

@interface SafahatMozoeeViewController()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, MFMailComposeViewControllerDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate, AVAudioPlayerDelegate>
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
    UILabel *pageDescLabel;
    
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
    NSInteger currentPage;
    NSInteger offsetPosts;
    NSInteger offsetDoctors;
    UIButton *matalebButton;
    UIButton *safahatMozoeeButton;
    UIButton *pezeshkanButton;
    NSString *documentsDirectory;
    AVAudioPlayer *audioPlayer;
    BOOL isPlayingTempVoice;
    NSInteger playingAudioRowNumber;
    NSInteger whichRowShouldBeReload;
    NSTimer *playbackTimer;
    NSTimer *myTimer;
    UILabel *noResultLabelDoctors;
    UILabel *noResultLabelMataleb;
    UIView *blurViewForMenu;
    BOOL disableTableView;
    NSString *tagID;
    NSString *typeOfDoctorForConnection;
    NSMutableArray *filteredArrayDoctors;
    UIButton *followingDoctorsButton;
    UIButton *coorporatingDoctorsButton;
    NSMutableArray *tagsArray;
    UIScrollView *tagsScrollView;
}
@property(nonatomic, retain)UITableView *tableViewMataleb;
@property(nonatomic, retain)NSMutableArray *tableArrayMataleb;
@property(nonatomic, retain)UITableView *tableViewDoctors;
@property(nonatomic, retain)NSMutableArray *tableArrayDoctors;
@property(nonatomic, retain)NSMutableArray *likeArray;
@property(nonatomic, retain)NSMutableArray *favArray;
@property(nonatomic, strong)UIScrollView *scrollView;
@property (strong, nonatomic) NSTimer *timerForProgress;
@property (strong, nonatomic) NSTimer *timerForProgressFinal;
@end

@implementation SafahatMozoeeViewController
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
- (void)viewDidDisappear:(BOOL)animated{
    [ProgressHUD dismiss];
}

- (void)viewWillDisappear:(BOOL)animated{
    self.tableViewMataleb.userInteractionEnabled = YES;
    self.tableViewDoctors.userInteractionEnabled = YES;
    self.scrollView.userInteractionEnabled = YES;
}

- (void)viewDidLoad {
    self.navigationController.navigationBar.hidden = YES;
    
    [super viewDidLoad];
    
    tagID = @"";
    typeOfDoctorForConnection = @"coorporating";
    [self fetchSafahatMozoeeDetailFromServerWithID:self.entityId];
    [self fetchPostsFromServer];
    [self fetchDoctorsFromServerWithTypeFollowing];
    [self fetchDoctorsFromServerWithTypeCoorporating];
    currentPage = 1;
    offsetPosts = 0;
    offsetDoctors = 0;
    //    [self fetchDoctorInfoWithEntityId:self.userEntityId];
    //    [self fetchPostsFromServerWithRequest:@"" WithDate:@""];
    //    [self fetchSimilarDoctorsWithDoctorId:self.userEntityId];
    //NSLog(@"id of doctor:%@", self.entityId);
    
    selectedRow = 1000;
    isBusyNow = NO;
    isPagingForCategories = NO;
    noMoreData = NO;
    self.tableArrayMataleb = [[NSMutableArray alloc]init];
    self.tableArrayDoctors = [[NSMutableArray alloc]init];
    self.likeArray = [[NSMutableArray alloc]init];
    self.favArray = [[NSMutableArray alloc]init];
    //make View
    [self makeTopBar];
    [self makeCover];
    
    //NSLog(@"self.navigationControllers: %@", [self.navigationController viewControllers]);
    
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
    titleLabel.text = _pageTitle;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.minimumScaleFactor = 0.5;
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
    
    UIButton *backButtonImg = [[UIButton alloc]initWithFrame:CGRectMake(0, 20 , 45, 45)];
    [backButtonImg setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButtonImg addTarget:self action:@selector(backButtonImgAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButtonImg];
}

- (void)makeCover{
    coverImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 70, screenWidth, screenWidth * 0.43)];
    coverImageView.image = [UIImage imageNamed:@"difualt cover"];
    [self.view addSubview:coverImageView];
    
    pageDescLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, screenWidth - 20, coverImageView.frame.size.height - 20)];
    pageDescLabel.font = FONT_MEDIUM(13);
    pageDescLabel.minimumScaleFactor = 0.4;
    pageDescLabel.adjustsFontSizeToFitWidth = YES;
    pageDescLabel.textColor = [UIColor whiteColor];
    pageDescLabel.numberOfLines = 10;
    pageDescLabel.textAlignment = NSTextAlignmentRight;
    [coverImageView addSubview:pageDescLabel];
    /*
     topic_page-->description
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
     [coverImageView addSubview:askDoctorButton];
     */
    [self makeTableViewWithYpos:coverImageView.frame.origin.y + coverImageView.frame.size.height];
}

- (void)makeTableViewWithYpos:(CGFloat )yPos{
    matalebButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth/2, yPos, screenWidth/2, 35)];
    [matalebButton setTitle:NSLocalizedString(@"mataleb", @"") forState:UIControlStateNormal];
    matalebButton.titleLabel.font = FONT_NORMAL(17);
    [matalebButton setBackgroundColor:COLOR_2];
    [matalebButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [matalebButton addTarget:self action:@selector(matalebButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:matalebButton];
    
    pezeshkanButton = [[UIButton alloc]initWithFrame:CGRectMake(0, yPos, screenWidth/2, 35)];
    [pezeshkanButton setTitle:NSLocalizedString(@"pezeshkan", @"") forState:UIControlStateNormal];
    pezeshkanButton.titleLabel.font = FONT_NORMAL(17);
    [pezeshkanButton setBackgroundColor:COLOR_1];
    [pezeshkanButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [pezeshkanButton addTarget:self action:@selector(pezeshkanButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pezeshkanButton];
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, yPos + 35, screenWidth, screenHeight - yPos)];
    self.scrollView.tag = 124;
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.directionalLockEnabled = YES;
    [self.view addSubview:self.scrollView];
    self.scrollView.contentSize = CGSizeMake(screenWidth * 2, screenHeight);
    [self.scrollView scrollRectToVisible:CGRectMake(screenWidth, 0, screenWidth, self.scrollView.frame.size.height) animated:YES];
    
    tagsScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(screenWidth, 0, screenWidth, 40)];
    tagsScrollView.showsVerticalScrollIndicator = NO;
    tagsScrollView.showsHorizontalScrollIndicator = NO;
    tagsScrollView.tag = 321;
    tagsScrollView.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:tagsScrollView];
    
    self.tableViewMataleb = [[UITableView alloc]initWithFrame:CGRectMake(screenWidth, 41, screenWidth, screenHeight - yPos - 41)];
    self.tableViewMataleb.delegate = self;
    self.tableViewMataleb.dataSource = self;
    self.tableViewMataleb.tag = 340;
    [self.scrollView addSubview:self.tableViewMataleb];
    self.tableViewMataleb.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    followingDoctorsButton = [CustomButton initButtonWithTitle:NSLocalizedString(@"followingDoctors", @"") withTitleColor:[UIColor whiteColor] withBackColor:COLOR_1 withFrame:CGRectMake(screenWidth - 130, 5, 120, 30)];
    followingDoctorsButton.layer.borderColor = COLOR_1.CGColor;
    followingDoctorsButton.layer.borderWidth = 1.0;
    [followingDoctorsButton addTarget:self action:@selector(followingDoctorsButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:followingDoctorsButton];
    
    coorporatingDoctorsButton = [CustomButton initButtonWithTitle:NSLocalizedString(@"coorporatingDoctors", @"") withTitleColor:COLOR_2 withBackColor:[UIColor whiteColor] withFrame:CGRectMake(10, 5, 120, 30)];
    coorporatingDoctorsButton.layer.borderColor = COLOR_1.CGColor;
    coorporatingDoctorsButton.layer.borderWidth = 1.0;
    [coorporatingDoctorsButton addTarget:self action:@selector(coorporatingDoctorsButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:coorporatingDoctorsButton];
    
    self.tableViewDoctors = [[UITableView alloc]initWithFrame:CGRectMake(0, 40, screenWidth, screenHeight - yPos - 40)];
    self.tableViewDoctors.delegate = self;
    self.tableViewDoctors.dataSource = self;
    self.tableViewDoctors.tag = 440;
    [self.scrollView addSubview:self.tableViewDoctors];
    self.tableViewDoctors.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
}

- (void)followingDoctorsButtonAction{
    typeOfDoctorForConnection = @"following";
    [followingDoctorsButton setBackgroundColor:COLOR_1];
    followingDoctorsButton.titleLabel.textColor = [UIColor whiteColor];
    
    [coorporatingDoctorsButton setBackgroundColor:[UIColor whiteColor]];
    coorporatingDoctorsButton.titleLabel.textColor = COLOR_1;
    
    filteredArrayDoctors = [[NSMutableArray alloc]init];
    for (NSInteger i = 0; i < [self.tableArrayDoctors count]; i++) {
        NSDictionary *dic = [self.tableArrayDoctors objectAtIndex:i];
        if ([[dic objectForKey:@"type"] isEqualToString:@"following"]) {
            [filteredArrayDoctors addObject:dic];
        }
    }
    
    [self.tableViewDoctors reloadData];
}

- (void)coorporatingDoctorsButtonAction{
    
    typeOfDoctorForConnection = @"coorporating";
    [followingDoctorsButton setBackgroundColor:[UIColor whiteColor]];
    followingDoctorsButton.titleLabel.textColor = COLOR_1;
    
    [coorporatingDoctorsButton setBackgroundColor:COLOR_1];
    //coorporatingDoctorsButton.titleLabel.textColor = [UIColor whiteColor];
    [coorporatingDoctorsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    filteredArrayDoctors = [[NSMutableArray alloc]init];
    for (NSInteger i = 0; i < [self.tableArrayDoctors count]; i++) {
        NSDictionary *dic = [self.tableArrayDoctors objectAtIndex:i];
        if ([[dic objectForKey:@"type"] isEqualToString:@"coorporating"]) {
            [filteredArrayDoctors addObject:dic];
        }
    }
    
    [self.tableViewDoctors reloadData];
}
- (void)matalebButtonAction{
    [self.scrollView scrollRectToVisible:CGRectMake(screenWidth, 0, screenWidth, self.scrollView.frame.size.height) animated:YES];
    /*
     [matalebButton setBackgroundColor:COLOR_2];
     [pezeshkanButton setBackgroundColor:COLOR_1];
     [safahatMozoeeButton setBackgroundColor:COLOR_1];
     */
}

- (void)pezeshkanButtonAction{
    [self.scrollView scrollRectToVisible:CGRectMake(0, 0, screenWidth, self.scrollView.frame.size.height) animated:YES];
    //[pezeshkanButton setBackgroundColor:COLOR_2];
    /*
     [matalebButton setBackgroundColor:COLOR_1];
     [safahatMozoeeButton setBackgroundColor:COLOR_1];
     */
}

- (void)backButtonImgAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)showProgressHUD {
    [ProgressHUD show:NSLocalizedString(@"retrievingdata", @"") Interaction:NO];
}

- (void)menuButtonAction {
    disableTableView = !disableTableView;
    self.tableViewMataleb.userInteractionEnabled = disableTableView;
    self.tableViewDoctors.userInteractionEnabled = disableTableView;
    self.scrollView.userInteractionEnabled = disableTableView;
    //[self showHideRightMenu];
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
    NSDictionary *landingPageDic = [self.tableArrayMataleb objectAtIndex:btn.tag];
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
    
    NSDictionary *landingPageDic = [self.tableArrayMataleb objectAtIndex:btn.tag];
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
    
    [self.tableArrayMataleb replaceObjectAtIndex:btn.tag withObject:landingPageDic2];
    [self.tableViewMataleb reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:btn.tag inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)shareButtonAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    
    NSDictionary *landingPageDic = [self.tableArrayMataleb objectAtIndex:btn.tag];
    
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
    NSDictionary *tempDic = [self.tableArrayMataleb objectAtIndex:tap.view.tag];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DoctorPageViewController *view = (DoctorPageViewController *)[story instantiateViewControllerWithIdentifier:@"DoctorPageViewController"];
    view.userEntityId = tempDic.LPUserEntityId;
    [self.navigationController pushViewController:view animated:YES];
}

- (void)popToMainMenu{
    [self.navigationController popToRootViewControllerAnimated:YES];
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

- (void)pushToDirectQuestion:(UITapGestureRecognizer *)tap{
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DirectQuestionViewController *view = (DirectQuestionViewController *)[story instantiateViewControllerWithIdentifier:@"DirectQuestionViewController"];
    NSDictionary *tempDic = [self.tableArrayDoctors objectAtIndex:tap.view.tag];
    view.userEntityId = [tempDic objectForKey:@"doctor_id"];
    view.userAvatar = [tempDic objectForKey:@"photo"];
    view.userTitle = [tempDic objectForKey:@"name"];
    view.userJobTitle = [tempDic objectForKey:@"experience"];
    view.isFromDoctorPage = YES;
    [self.navigationController pushViewController:view animated:YES];
}

- (void)tagLabelAction:(UITapGestureRecognizer *)tap{
    UILabel *label2 = (UILabel *)tap.view;
    //NSLog(@"%@", label2.text);
    tagID = [NSString stringWithFormat:@"%@", [[tagsArray objectAtIndex:tap.view.tag]objectForKey:@"id"]];
    self.tableArrayMataleb = [[NSMutableArray alloc]init];
    [self fetchPostsFromServer];
    
    NSArray *subviews = [tagsScrollView subviews];
    
    // Return if there are no subviews
    if ([subviews count] == 0) return;
    
    for (UIView *subview in subviews) {
        // Do what you want to do with the subview
        //NSLog(@"%ld", (long)subview.tag);
        UILabel *label = (UILabel *)subview;
        label.backgroundColor = [UIColor whiteColor];
        label.textColor = COLOR_1;
        if (label2.tag == label.tag) {
            label.backgroundColor = COLOR_1;
            label.textColor = [UIColor whiteColor];
        }
    }
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
                
                currentPage = 0;
                [self.tableViewDoctors reloadData];
                [UIView animateWithDuration:0.1 animations:^{
                    [pezeshkanButton setBackgroundColor:COLOR_2];
                    [matalebButton setBackgroundColor:COLOR_1];
                    [safahatMozoeeButton setBackgroundColor:COLOR_1];
                    CGRect rect = boxUnderButton.frame;
                    rect.origin.x = 0;
                    [boxUnderButton setFrame:rect];
                    scrollView.pagingEnabled = NO;
                }];
                
            }else if (page == 1){
                
                currentPage = 1;
                [self.tableViewMataleb reloadData];
                [UIView animateWithDuration:0.1 animations:^{
                    [matalebButton setBackgroundColor:COLOR_2];
                    [pezeshkanButton setBackgroundColor:COLOR_1];
                    [safahatMozoeeButton setBackgroundColor:COLOR_1];
                    scrollView.pagingEnabled = YES;
                }];
            }
            previousPage = page;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height - 50) {
        // we are at the end
        //NSLog(@"time to fetch new posts");
        NSString *type;
        if (currentPage == 0)/*doctors*/ {
            type = @"Doctor";
            offsetDoctors ++;
            
            if ([typeOfDoctorForConnection isEqualToString:@"following"]) {
                [self fetchDoctorsFromServerWithTypeFollowing];
            } else {
                [self fetchDoctorsFromServerWithTypeCoorporating];
            }
            
        }else if (currentPage == 1)/*posts*/{
            type = @"all";//@"POST";
            offsetPosts ++;
            [self fetchPostsFromServer];
        }
    }
}

#pragma mark - table view delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (currentPage == 0) {
        return [filteredArrayDoctors count];
    }else if (currentPage == 1) {
        return [self.tableArrayMataleb count];
    }else{
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (IS_IPAD) {
        if (currentPage == 0)/*doctors*/ {
            return 90;
        }else if (currentPage == 1)/*mataleb*/ {
            if (selectedRow == indexPath.row) {
                if (isExpand) {
                    NSDictionary *landingPageDic = [self.tableArrayMataleb objectAtIndex:indexPath.row];
                    return [self getHeightOfString:landingPageDic.LPContent];
                    
                } else {
                    return screenWidth + 10;
                }
            } else {
                return screenWidth + 10;
            }
            //return screenWidth * 0.8;
        }else{
            return 0;
        }
        
    } else {
        if (selectedRow == indexPath.row) {
            if (isExpand) {
                NSDictionary *landingPageDic = [self.tableArrayMataleb objectAtIndex:indexPath.row];
                return [self getHeightOfString:landingPageDic.LPContent];
                
            } else {
                if (currentPage == 0)/*doctor*/ {
                    return 90;
                }else if (currentPage == 1)/*mataleb*/ {
                    return screenWidth + 20;
                }else{
                    return 0;
                }
            }
        } else {
            if (currentPage == 0)/*doctor*/ {
                return 90;
            }else if (currentPage == 1)/*mataleb*/ {
                return screenWidth + 20;
            }else{
                return 0;
            }
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (currentPage == 1)//mataleb tab
    {
        id cellToReturn=nil;
        NSDictionary *landingPageDic = [self.tableArrayMataleb objectAtIndex:indexPath.row];
        NSString *postType = landingPageDic.LPPostType;
        
        //audio
        if ([postType isEqualToString:@"audio"]) {
            NSString *cellIdentifier = [NSString stringWithFormat:@"S%1ldR%1ld",(long)indexPath.section,(long)indexPath.row];
            LandingPageCustomCellAudio *cell = [tableView dequeueReusableCellWithIdentifier:@"cell1"];
            if (indexPath.row < [self.tableArrayMataleb count] - 1) {
                
                if (cell == nil)
                    cell = (LandingPageCustomCellAudio *)[[LandingPageCustomCellAudio alloc]
                                                          initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                if (indexPath.row < [self.tableArrayMataleb count] - 1) {
                    if ([self.tableArrayMataleb count] > 0) {
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
                            if (cell.largeProgressView.progress >= 1.0f) {
                                [self.tableViewMataleb reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
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
            NSString *cellIdentifier = [NSString stringWithFormat:@"S%1ldR%1ld",(long)indexPath.section,(long)indexPath.row];
            LandingPageCustomCellVideo *cell = [tableView dequeueReusableCellWithIdentifier:@"cell2"];
            if (indexPath.row < [self.tableArrayMataleb count] - 1) {
                
                if (cell == nil)
                    cell = (LandingPageCustomCellVideo *)[[LandingPageCustomCellVideo alloc]
                                                          initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                if (indexPath.row < [self.tableArrayMataleb count] - 1) {
                    if ([self.tableArrayMataleb count] > 0) {
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
            if (indexPath.row < [self.tableArrayMataleb count] - 1) {
                
                if (cell == nil)
                    cell = (LandingPageCustomCell *)[[LandingPageCustomCell alloc]
                                                     initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                if (indexPath.row < [self.tableArrayMataleb count] - 1) {
                    if ([self.tableArrayMataleb count] > 0) {
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
                            rect.size.height = [self getHeightOfString:landingPageDic.LPContentSummary];
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
    }else if (currentPage == 0)/*pezeshkan tab*/{
        PezeshkanCustomCell *cell = (PezeshkanCustomCell *)[[PezeshkanCustomCell alloc]
                                                            initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellSearch"];
        
        if (indexPath.row < [filteredArrayDoctors count]) {
            NSDictionary *searchDic = [filteredArrayDoctors objectAtIndex:indexPath.row];
            cell.nameLabel.text = [searchDic objectForKey:@"name"];
            cell.jobLabel.text = [searchDic objectForKey:@"job_title"];
            [cell.doctorimageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [searchDic objectForKey:@"avatar"]]] placeholderImage:[UIImage imageNamed:@"icon upload ax"]];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pushToDirectQuestion:)];
            cell.porseshimageView.userInteractionEnabled = YES;
            cell.porseshimageView.tag = indexPath.row;
            [cell.porseshimageView addGestureRecognizer:tap];
        }
        
        return cell;
    }else{
        PezeshkanCustomCell *cell = (PezeshkanCustomCell *)[[PezeshkanCustomCell alloc]
                                                            initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellSearch"];
        return cell;
    }
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self hasConnectivity]) {
        /*
         if (cell.tag == loadingCellTag) {
         //if (currentPage <= pageCount) {
         NSDictionary *landingPageDic = [self.tableArrayMataleb lastObject];
         NSInteger dateNumber = [landingPageDic.LPPublish_date integerValue];
         dateNumber -= 1;
         isPagingForCategories = NO;
         offset += 20;
         NSString *type = @"POST";
         if (currentPage == 0) {
         type = @"Doctor";
         }
         [self fetchSearchResultFromServerWithKeyword:searchTextField.text offset:[NSString stringWithFormat:@"%ld", (long)offset] type:type];
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
    }
    
}

- (UITableViewCell *)loadingCell {
    
    PezeshkanCustomCell *cell = (PezeshkanCustomCell *)[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    
    cell.backgroundColor = [UIColor whiteColor];
    //NSArray *imageNames = @[@"1.png", @"2.png", @"3.png", @"4.png"];
    /*
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
     */
    cell.tag = loadingCellTag;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableViewMataleb deselectRowAtIndexPath:indexPath animated:YES];
    [self.tableViewDoctors deselectRowAtIndexPath:indexPath animated:YES];
    if (currentPage == 1)/*mataleb tab*/ {
        NSDictionary *dic = [_tableArrayMataleb objectAtIndex:indexPath.row];
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LandingPageDetailViewController *view = (LandingPageDetailViewController *)[story instantiateViewControllerWithIdentifier:@"LandingPageDetailViewController"];
        view.dictionary = dic;
        [self.navigationController pushViewController:view animated:YES];
        
        /*
         selectedRow = indexPath.row;
         isExpand = !isExpand;
         if (!isExpand) {
         selectedRow = 1000;
         }
         
         [self.tableViewMataleb reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
         [self.tableViewMataleb scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
         */
    } else if (currentPage == 0)/*pezeshkan tab*/{
        NSDictionary *tempDic = [filteredArrayDoctors objectAtIndex:indexPath.row];
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        DoctorPageViewController *view = (DoctorPageViewController *)[story instantiateViewControllerWithIdentifier:@"DoctorPageViewController"];
        view.userEntityId = [tempDic objectForKey:@"id"];
        view.userAvatar = [tempDic objectForKey:@"avatar"];
        view.userTitle = [tempDic objectForKey:@"name"];
        view.userJobTitle = [tempDic objectForKey:@"job_title"];
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
        NSDictionary *dic = [self.tableArrayMataleb objectAtIndex:btn.tag];
        [self playAudioWithName:[dic.LPAudioUrl lastPathComponent]];
        playingAudioRowNumber = btn.tag;
        whichRowShouldBeReload = playingAudioRowNumber;
    }
    //NSIndexPath *indexpath = [NSIndexPath indexPathForRow:btn.tag inSection:0];
    [self.tableViewMataleb reloadData]; //RowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)playVideo:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSDictionary *dic = [self.tableArrayMataleb objectAtIndex:btn.tag];
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
    [self.tableViewMataleb reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)stopTimer {
    [myTimer invalidate];
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    playingAudioRowNumber = 10000;
    [self.tableViewMataleb reloadData];
    [self stopTimer];
}

- (void)downloadPlayButtonAction:(UITapGestureRecognizer *)sender{
    whichRowShouldBeReload = sender.view.tag;
    [self startAnimationProgress];
    NSDictionary *tempDic = [self.tableArrayMataleb objectAtIndex:sender.view.tag];
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

- (void)downloadPlayButtonActionVideo:(id)sender{
    UIButton *btn = (UIButton *)sender;
    whichRowShouldBeReload = btn.tag;
    [self startAnimationProgress];
    NSDictionary *tempDic = [self.tableArrayMataleb objectAtIndex:btn.tag];
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
    LandingPageCustomCellAudio *cell = (LandingPageCustomCellAudio *)[self.tableViewMataleb cellForRowAtIndexPath:indexpath];
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
    LandingPageCustomCellAudio *cell = (LandingPageCustomCellAudio *)[self.tableViewMataleb cellForRowAtIndexPath:indexpath];
    CGFloat progress = cell.largeProgressView.progress + 0.01f;
    [cell.largeProgressView setProgress:progress animated:YES];
    
    if (cell.largeProgressView.progress >= 1.0f && [_timerForProgressFinal isValid]) {
        //[progressView setProgress:0.f animated:YES];
        [self stopAnimationProgressFinal];
        [self.tableViewMataleb reloadData];
    }
    
}
- (void)stopAnimationProgressFinal
{
    [_timerForProgressFinal invalidate];
    _timerForProgressFinal = nil;
    
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

- (void)fetchSafahatMozoeeDetailFromServerWithID:(NSString *)idOfDetail{
    [ProgressHUD show:@""];
    NSDictionary *userpassDic = [GetUsernamePassword getUsernamePassword];
    NSDictionary *params = @{@"username":[userpassDic objectForKey:@"username"]/*@"09191234072"*/,
                             @"password":[userpassDic objectForKey:@"password"]/*@“123456”*/,
                             @"id":idOfDetail,
                             @"tag_id":@"",
                             @"unit_id": @"3"};
    /*http://213.233.175.250:8081/web_services/v3/search*/
    
    //    KeychainWrapper *keychainWrapper = [[KeychainWrapper alloc]init];
    //    NSString *username = [keychainWrapper myObjectForKey:(__bridge id)(kSecAttrDescription)];
    //    NSString *password = [keychainWrapper myObjectForKey:(__bridge id)(kSecAttrService)];
    NSString *url = [NSString stringWithFormat:@"%@topic_pages/detail", BaseURL];
    
    [refreshControl endRefreshing];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    manager.requestSerializer.timeoutInterval = 45;;
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        [ProgressHUD dismiss];
        NSDictionary *tempDic = (NSDictionary *)responseObject;
        for (NSDictionary *post in [tempDic objectForKey:@"Posts"]) {
            [self.tableArrayMataleb addObject:post];
        }
        
        for (NSDictionary *post in [tempDic objectForKey:@"Doctor"]) {
            [self.tableArrayDoctors addObject:post];
        }
        
        [noResultLabelDoctors removeFromSuperview];
        [noResultLabelMataleb removeFromSuperview];
        if ([self.tableArrayDoctors count] == 0) {
            noResultLabelDoctors = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 220, 10, 200,  25)];
            noResultLabelDoctors.font = FONT_MEDIUM(13);
            noResultLabelDoctors.text = NSLocalizedString(@"noResult", @"");
            noResultLabelDoctors.minimumScaleFactor = 0.7;
            noResultLabelDoctors.textColor = [UIColor blackColor];
            noResultLabelDoctors.textAlignment = NSTextAlignmentRight;
            noResultLabelDoctors.adjustsFontSizeToFitWidth = YES;
            [self.tableViewDoctors addSubview:noResultLabelDoctors];
        }
        
        if ([self.tableArrayMataleb count] == 0) {
            noResultLabelMataleb = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 220, 10, 200,  25)];
            noResultLabelMataleb.font = FONT_MEDIUM(13);
            noResultLabelMataleb.text = NSLocalizedString(@"noContent", @"");
            noResultLabelMataleb.minimumScaleFactor = 0.7;
            noResultLabelMataleb.textColor = [UIColor blackColor];
            noResultLabelMataleb.textAlignment = NSTextAlignmentRight;
            noResultLabelMataleb.adjustsFontSizeToFitWidth = YES;
            [self.tableViewMataleb addSubview:noResultLabelMataleb];
        }
        
        pageDescLabel.text = [[tempDic objectForKey:@"topic_page"]objectForKey:@"description"];
        
        [ProgressHUD dismiss];
        isBusyNow = NO;
        [self.tableViewMataleb reloadData];
        
        tagsArray = [[NSMutableArray alloc]init];
        for (NSDictionary *post in [[tempDic objectForKey:@"topic_page"]objectForKey:@"tags"]) {
            [tagsArray addObject:post];
        }
        
        tagsScrollView.contentSize = CGSizeMake([tagsArray count] * 120, tagsScrollView.frame.size.height);
        
        CGFloat xPOS = 10;
        for (NSInteger i = 0; i < [tagsArray count]; i++) {
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(xPOS, 10, 105, 25)];
            label.userInteractionEnabled = YES;
            label.tag = i;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tagLabelAction:)];
            [label addGestureRecognizer:tap];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = [[tagsArray objectAtIndex:i]objectForKey:@"name"];
            label.font = FONT_NORMAL(13);
            label.adjustsFontSizeToFitWidth = YES;
            label.minimumScaleFactor = 0.5;
            label.textColor = COLOR_1;
            label.layer.cornerRadius = 12;
            label.layer.borderColor = COLOR_1.CGColor;
            label.layer.borderWidth = 0.5;
            label.clipsToBounds = YES;
            [tagsScrollView addSubview:label];
            
            xPOS += 120;
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [ProgressHUD dismiss];
         
    }];
}

- (void)fetchPostsFromServer{
    NSDictionary *userpassDic = [GetUsernamePassword getUsernamePassword];
    NSDictionary *params;
    if ([userpassDic count] > 1) {
        //delete flag for Visit Without Login
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"VisitWithoutLogin"];
        
        params = @{@"username":[userpassDic objectForKey:@"username"]/*@"09191234072"*/,
                   @"password":[userpassDic objectForKey:@"password"]/*@“123456”*/,
                   @"entity":@"topicPage",
                   @"entity_id":self.entityId,
                   @"tag_id":tagID,
                   @"page":[NSNumber numberWithInteger:offsetPosts],
                   @"limit":@"20",
                   @"unit_id":@"3"};
    }else{
        params = @{@"username":@"",
                   @"password":@"",
                   @"unit_id":@"3"};
        
    }
    /*http://213.233.175.250:8081/web_services/v3/posts/timeline*/
    
    //    KeychainWrapper *keychainWrapper = [[KeychainWrapper alloc]init];
    //    NSString *username = [keychainWrapper myObjectForKey:(__bridge id)(kSecAttrDescription)];
    //    NSString *password = [keychainWrapper myObjectForKey:(__bridge id)(kSecAttrService)];
    NSString *url = [NSString stringWithFormat:@"%@posts/timeline", BaseURL];
    
    [refreshControl endRefreshing];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    manager.requestSerializer.timeoutInterval = 45;;
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        [ProgressHUD dismiss];
        noMoreData = NO;
        NSDictionary *tempDic = (NSDictionary *)responseObject;
        NSString *login =  [tempDic objectForKey:@"authorized"];
        if ([login integerValue]  == 0) {
            [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"isNotLoggedin"];
        }
        
        for (NSDictionary *post in [tempDic objectForKey:@"posts"]) {
            [self.tableArrayMataleb addObject:post];
        }
        
        for (NSDictionary *post in [tempDic objectForKey:@"Doctor"]) {
            [self.tableArrayDoctors addObject:post];
        }
        
        [noResultLabelDoctors removeFromSuperview];
        [noResultLabelMataleb removeFromSuperview];
        if ([self.tableArrayDoctors count] == 0) {
            noResultLabelDoctors = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 220, 10, 200,  25)];
            noResultLabelDoctors.font = FONT_MEDIUM(13);
            noResultLabelDoctors.text = NSLocalizedString(@"noResult", @"");
            noResultLabelDoctors.minimumScaleFactor = 0.7;
            noResultLabelDoctors.textColor = [UIColor blackColor];
            noResultLabelDoctors.textAlignment = NSTextAlignmentRight;
            noResultLabelDoctors.adjustsFontSizeToFitWidth = YES;
            [self.tableViewDoctors addSubview:noResultLabelDoctors];
        }
        
        if ([self.tableArrayMataleb count] == 0) {
            noResultLabelMataleb = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 220, 10, 200,  25)];
            noResultLabelMataleb.font = FONT_MEDIUM(13);
            noResultLabelMataleb.text = NSLocalizedString(@"noContent", @"");
            noResultLabelMataleb.minimumScaleFactor = 0.7;
            noResultLabelMataleb.textColor = [UIColor blackColor];
            noResultLabelMataleb.textAlignment = NSTextAlignmentRight;
            noResultLabelMataleb.adjustsFontSizeToFitWidth = YES;
            [self.tableViewMataleb addSubview:noResultLabelMataleb];
        }
        
        
        [ProgressHUD dismiss];
        isBusyNow = NO;
        [self.tableViewMataleb reloadData];
        //[self.tableViewMataleb scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];

        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
         
        [ProgressHUD dismiss];
    }];
}

- (void)fetchDoctorsFromServerWithTypeFollowing{
    
    NSDictionary *userpassDic = [GetUsernamePassword getUsernamePassword];
    NSDictionary *params;
    if ([userpassDic count] > 1) {
        //delete flag for Visit Without Login
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"VisitWithoutLogin"];
        
        params = @{@"username":[userpassDic objectForKey:@"username"]/*@"09191234072"*/,
                   @"password":[userpassDic objectForKey:@"password"]/*@“123456”*/,
                   @"id":self.entityId,
                   @"type":@"following",
                   @"page":[NSNumber numberWithInteger:offsetDoctors],
                   @"limit":@"20",
                   @"unit_id":@"3"};
    }else{
        params = @{@"username":@"",
                   @"password":@"",
                   @"unit_id":@"3"};
        
    }
    /*http://213.233.175.250:8081/web_services/v3/posts/timeline*/
    
    //    KeychainWrapper *keychainWrapper = [[KeychainWrapper alloc]init];
    //    NSString *username = [keychainWrapper myObjectForKey:(__bridge id)(kSecAttrDescription)];
    //    NSString *password = [keychainWrapper myObjectForKey:(__bridge id)(kSecAttrService)];
    NSString *url = [NSString stringWithFormat:@"%@topic_pages/doctors", BaseURL];
    
    [refreshControl endRefreshing];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    manager.requestSerializer.timeoutInterval = 45;;
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        [ProgressHUD dismiss];
        noMoreData = NO;
        NSDictionary *tempDic = (NSDictionary *)responseObject;
        NSString *login =  [tempDic objectForKey:@"authorized"];
        if ([login integerValue]  == 0) {
            [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"isNotLoggedin"];
        }
        
        for (NSDictionary *post in [tempDic objectForKey:@"doctors"]) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithDictionary:post];
            [dic setObject:@"following" forKey:@"type"];
            [self.tableArrayDoctors addObject:dic];
        }
        
        [noResultLabelDoctors removeFromSuperview];
        [noResultLabelMataleb removeFromSuperview];
        if ([self.tableArrayDoctors count] == 0) {
            noResultLabelDoctors = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 220, 10, 200,  25)];
            noResultLabelDoctors.font = FONT_MEDIUM(13);
            noResultLabelDoctors.text = NSLocalizedString(@"noResult", @"");
            noResultLabelDoctors.minimumScaleFactor = 0.7;
            noResultLabelDoctors.textColor = [UIColor blackColor];
            noResultLabelDoctors.textAlignment = NSTextAlignmentRight;
            noResultLabelDoctors.adjustsFontSizeToFitWidth = YES;
            [self.tableViewDoctors addSubview:noResultLabelDoctors];
        }
        
        if ([self.tableArrayMataleb count] == 0) {
            noResultLabelMataleb = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 220, 10, 200,  25)];
            noResultLabelMataleb.font = FONT_MEDIUM(13);
            noResultLabelMataleb.text = NSLocalizedString(@"noContent", @"");
            noResultLabelMataleb.minimumScaleFactor = 0.7;
            noResultLabelMataleb.textColor = [UIColor blackColor];
            noResultLabelMataleb.textAlignment = NSTextAlignmentRight;
            noResultLabelMataleb.adjustsFontSizeToFitWidth = YES;
            [self.tableViewMataleb addSubview:noResultLabelMataleb];
        }
        
        
        [ProgressHUD dismiss];
        isBusyNow = NO;
        [self.tableViewDoctors reloadData];
        
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
         
        [ProgressHUD dismiss];
    }];
}

- (void)fetchDoctorsFromServerWithTypeCoorporating{
    
    NSDictionary *userpassDic = [GetUsernamePassword getUsernamePassword];
    NSDictionary *params;
    if ([userpassDic count] > 1) {
        //delete flag for Visit Without Login
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"VisitWithoutLogin"];
        
        params = @{@"username":[userpassDic objectForKey:@"username"]/*@"09191234072"*/,
                   @"password":[userpassDic objectForKey:@"password"]/*@“123456”*/,
                   @"id":self.entityId,
                   @"type":@"cooperating",
                   @"page":[NSNumber numberWithInteger:offsetDoctors],
                   @"limit":@"20",
                   @"unit_id":@"3"};
    }else{
        params = @{@"username":@"",
                   @"password":@"",
                   @"unit_id":@"3"};
        
    }
    /*http://213.233.175.250:8081/web_services/v3/posts/timeline*/
    
    //    KeychainWrapper *keychainWrapper = [[KeychainWrapper alloc]init];
    //    NSString *username = [keychainWrapper myObjectForKey:(__bridge id)(kSecAttrDescription)];
    //    NSString *password = [keychainWrapper myObjectForKey:(__bridge id)(kSecAttrService)];
    NSString *url = [NSString stringWithFormat:@"%@topic_pages/doctors", BaseURL];
    
    [refreshControl endRefreshing];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    manager.requestSerializer.timeoutInterval = 45;;
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        [ProgressHUD dismiss];
        noMoreData = NO;
        NSDictionary *tempDic = (NSDictionary *)responseObject;
        NSString *login =  [tempDic objectForKey:@"authorized"];
        if ([login integerValue]  == 0) {
            [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"isNotLoggedin"];
        }
        
        for (NSDictionary *post in [tempDic objectForKey:@"doctors"]) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithDictionary:post];
            [dic setObject:@"coorporating" forKey:@"type"];
            [self.tableArrayDoctors addObject:dic];
        }
        
        [noResultLabelDoctors removeFromSuperview];
        [noResultLabelMataleb removeFromSuperview];
        if ([self.tableArrayDoctors count] == 0) {
            noResultLabelDoctors = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 220, 10, 200,  25)];
            noResultLabelDoctors.font = FONT_MEDIUM(13);
            noResultLabelDoctors.text = NSLocalizedString(@"noResult", @"");
            noResultLabelDoctors.minimumScaleFactor = 0.7;
            noResultLabelDoctors.textColor = [UIColor blackColor];
            noResultLabelDoctors.textAlignment = NSTextAlignmentRight;
            noResultLabelDoctors.adjustsFontSizeToFitWidth = YES;
            [self.tableViewDoctors addSubview:noResultLabelDoctors];
        }
        
        if ([self.tableArrayMataleb count] == 0) {
            noResultLabelMataleb = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 220, 10, 200,  25)];
            noResultLabelMataleb.font = FONT_MEDIUM(13);
            noResultLabelMataleb.text = NSLocalizedString(@"noContent", @"");
            noResultLabelMataleb.minimumScaleFactor = 0.7;
            noResultLabelMataleb.textColor = [UIColor blackColor];
            noResultLabelMataleb.textAlignment = NSTextAlignmentRight;
            noResultLabelMataleb.adjustsFontSizeToFitWidth = YES;
            [self.tableViewMataleb addSubview:noResultLabelMataleb];
        }
        
        
        [ProgressHUD dismiss];
        isBusyNow = NO;

        [self coorporatingDoctorsButtonAction];
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
         
        [ProgressHUD dismiss];
    }];
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
                   @"user_id": @"",
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
                
                [self.tableViewMataleb reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idOfRow inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                
                
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
                [self.tableViewMataleb reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idOfRow inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                
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
            NSDictionary *landingPageDic = [self.tableArrayMataleb objectAtIndex:idOfRow];
            NSMutableDictionary *landingPageDic2 = [[NSMutableDictionary alloc]initWithDictionary:landingPageDic];
            NSInteger likes = landingPageDic2.LPLikes_count;
            likes--;
            [landingPageDic2 setObject:[NSString stringWithFormat:@"%ld", (long)likes] forKey:@"likesCount"];
            [landingPageDic2 setObject:[NSString stringWithFormat:[NSString stringWithFormat:@"%d", 0], likes] forKey:@"liked"];
            [self.tableArrayMataleb replaceObjectAtIndex:idOfRow withObject:landingPageDic2];
            [self.tableViewMataleb reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idOfRow inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            
            //
            [Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:[NSString stringWithFormat:@"%ld", (long)likes] field:@"liked" postId:idOfPost];
            [self.tableViewMataleb reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idOfRow inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
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
            [self.tableViewMataleb reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idOfRow inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
        
    }];
}
@end
