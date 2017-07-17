//
//  DoctorPageViewController.m
//  MSN
//
//  Created by Yarima on 4/24/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "SearchViewController.h"
#import "ShakeAnimation.h"
#import "Database.h"
#import <AFHTTPSessionManager.h>
#import <UIImageView+AFNetworking.h>
#import "Header.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import "KeychainWrapper.h"
#import "ProgressHUD.h"
#import "NSDictionary+LandingPage.h"
#import "SearchViewCustomCell.h"
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
#import "ClinicViewController.h"
#import "AnjomanViewController.h"
#import "CustomButton.h"
#import "UserProfileViewController.h"
#import "CompanyProfileViewController.h"
#import "ProjectProfileViewController.h"
#import "TopicPageViewController.h"

#define loadingCellTag  1273
/*
 clinic->company
 anjoman->mozoee
 mataleb->projects
 safahatMozoee->tags
 pezeshkan->user
 post->post
 */
@interface SearchViewController()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, MFMailComposeViewControllerDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate, AVAudioPlayerDelegate>
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
    UITextField *searchTextField;
    UIButton *searchButton;
    NSInteger currentPage;
    NSInteger offsetProject;
    NSInteger offsetUser;
    NSInteger offsetPost;
    NSInteger offsetTag;
    NSInteger offsetMozoee;
    NSInteger offsetCompany;
    UIButton *projectButton;
    UIButton *postButton;
    UIButton *tagButton;
    UIButton *userButton;
    UIButton *companyButton;
    UIButton *mozoeeButton;
    NSString *documentsDirectory;
    AVAudioPlayer *audioPlayer;
    BOOL isPlayingTempVoice;
    NSInteger playingAudioRowNumber;
    NSInteger whichRowShouldBeReload;
    NSTimer *playbackTimer;
    NSTimer *myTimer;
    UILabel *noResultLabelUser;
    UILabel *noResultLabelPost;
    UILabel *noResultLabelProject;
    UILabel *noResultLabelTag;
    UILabel *noResultLabelCompany;
    UILabel *noResultLabelMozoee;
    UILabel *searchUserLabel;
    UILabel *searchPostLabel;
    UILabel *searchProjectLabel;
    UILabel *searchTagLabel;
    UILabel *searchCompanyLabel;
    UILabel *searchMozoeeLabel;
    
    UIView *blurViewForMenu;
    BOOL disableTableView;
    UIScrollView *buttonsScrollView;
    NSInteger page;
    NSString *type;
}
@property(nonatomic, retain)UITableView *tableViewProject;
@property(nonatomic, retain)NSMutableArray *tableArrayProject;
@property(nonatomic, retain)UITableView *tableViewTag;
@property(nonatomic, retain)NSMutableArray *tableArrayTag;
@property(nonatomic, retain)UITableView *tableViewUser;
@property(nonatomic, retain)NSMutableArray *tableArrayUser;
@property(nonatomic, retain)UITableView *tableViewCompany;
@property(nonatomic, retain)NSMutableArray *tableArrayCompany;
@property(nonatomic, retain)UITableView *tableViewMozoee;
@property(nonatomic, retain)NSMutableArray *tableArrayMozoee;
@property(nonatomic, retain)UITableView *tableViewPost;
@property(nonatomic, retain)NSMutableArray *tableArrayPost;
@property(nonatomic, retain)NSMutableArray *likeArray;
@property(nonatomic, retain)NSMutableArray *favArray;
@property(nonatomic, strong)UIScrollView *scrollView;
@property (strong, nonatomic) NSTimer *timerForProgress;
@property (strong, nonatomic) NSTimer *timerForProgressFinal;
@property (nonatomic) CGFloat lastContentOffset;

@end

@implementation SearchViewController
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
- (void)viewDidDisappear:(BOOL)animated{
    [ProgressHUD dismiss];
}

- (void)viewWillDisappear:(BOOL)animated{
    self.tableViewProject.userInteractionEnabled = YES;
    self.tableViewUser.userInteractionEnabled = YES;
    self.tableViewTag.userInteractionEnabled = YES;
    self.tableViewMozoee.userInteractionEnabled = YES;
    self.tableViewCompany.userInteractionEnabled = YES;
    self.scrollView.userInteractionEnabled = YES;
}

- (void)viewDidLoad {
    self.navigationController.navigationBar.hidden = YES;
    
    [super viewDidLoad];
    
    [self resetValues];
    //make View
    [self makeTopBar];
    
    //NSLog(@"self.navigationControllers: %@", [self.navigationController viewControllers]);
    
    disableTableView = YES;
    page = 1;
    [self fetchSearchResultFromServerWithKeyword:@"" page:page type:type];
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
    
    //54 × 39
    UIButton *menuButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - 60, topViewHeight/2 - 20, 54, 54)];
    //menuButton.backgroundColor = [UIColor redColor];
    UIImage *img = [UIImage imageNamed:@"menu side"];
    [menuButton setImage:[img imageByScalingProportionallyToSize:CGSizeMake(54/2,39/2)] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(menuButtonAction) forControlEvents:UIControlEventTouchUpInside];
    //[topView addSubview:menuButton];
    
    searchTextField = [[UITextField alloc]initWithFrame:
                       CGRectMake(60, topViewHeight/2 - 6, screenWidth - 175, 30)];
    searchTextField.delegate = self;
    searchTextField.layer.cornerRadius = 15.0;
    searchTextField.textAlignment = NSTextAlignmentRight;
    searchTextField.font = FONT_NORMAL(15);
    searchTextField.tag = 12;
    searchTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    searchTextField.clipsToBounds = YES;
    searchTextField.backgroundColor = [UIColor whiteColor];
    [searchTextField addTarget:self
                        action:@selector(textFieldDidChange:)
              forControlEvents:UIControlEventEditingChanged];
    
    [topView addSubview:searchTextField];
    
    searchButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - 80, topViewHeight/2 - 4, 54 *0.3, 69 * 0.3)];
    [searchButton setBackgroundImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(searchButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:searchButton];
    
    UIButton *backButtonImg = [[UIButton alloc]initWithFrame:CGRectMake(0, 20 , 45, 45)];
    [backButtonImg setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButtonImg addTarget:self action:@selector(backButtonImgAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButtonImg];
    
    [self makeTableViewWithYpos:70];
    
}

- (void)scrollButtonsScrollview{
    [buttonsScrollView scrollRectToVisible:CGRectMake(0, 1, 1, 1) animated:YES];
}

- (void)scrollButtonsScrollview2{
    [buttonsScrollView scrollRectToVisible:CGRectMake((5*(screenWidth/3)), 1, 1, 1) animated:YES];
    [postButton setBackgroundColor:COLOR_3];
}
- (void)makeTableViewWithYpos:(CGFloat )yPos{
    
    buttonsScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, yPos, screenWidth, 35)];
    buttonsScrollView.tag = 224;
    buttonsScrollView.delegate = self;
    buttonsScrollView.pagingEnabled = NO;
    buttonsScrollView.showsVerticalScrollIndicator = NO;
    buttonsScrollView.showsHorizontalScrollIndicator = NO;
    [buttonsScrollView setBackgroundColor:COLOR_5];
    buttonsScrollView.directionalLockEnabled = YES;
    [self.view addSubview:buttonsScrollView];
    buttonsScrollView.contentSize = CGSizeMake(6 * (screenWidth/3), 35);
    [buttonsScrollView scrollRectToVisible:CGRectMake((5*(screenWidth/3)), 1, 1, 1) animated:YES];
    [self performSelector:@selector(scrollButtonsScrollview) withObject:nil afterDelay:2.0];
    [self performSelector:@selector(scrollButtonsScrollview2) withObject:nil afterDelay:1.0];
    
    //clinic->company
    companyButton = [[UIButton alloc]initWithFrame:CGRectMake(5 * (screenWidth/3), 0, screenWidth/3, 35)];
    [companyButton setTitle:NSLocalizedString(@"company", @"") forState:UIControlStateNormal];
    companyButton.titleLabel.font = FONT_NORMAL(17);
    [companyButton setBackgroundColor:COLOR_5];
    [companyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [companyButton addTarget:self action:@selector(companyButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [buttonsScrollView addSubview:companyButton];
    
    //anjoman->mozoee
    mozoeeButton = [[UIButton alloc]initWithFrame:CGRectMake(4 * (screenWidth/3), 0, screenWidth/3, 35)];
    [mozoeeButton setTitle:NSLocalizedString(@"mozoee", @"") forState:UIControlStateNormal];
    mozoeeButton.titleLabel.font = FONT_NORMAL(17);
    [mozoeeButton setBackgroundColor:COLOR_5];
    [mozoeeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [mozoeeButton addTarget:self action:@selector(mozoeeButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [buttonsScrollView addSubview:mozoeeButton];
    
    //mataleb->projects
    projectButton = [[UIButton alloc]initWithFrame:CGRectMake(3 * (screenWidth/3), 0, screenWidth/3, 35)];
    [projectButton setTitle:NSLocalizedString(@"projects", @"") forState:UIControlStateNormal];
    projectButton.titleLabel.font = FONT_NORMAL(17);
    [projectButton setBackgroundColor:COLOR_5];
    [projectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [projectButton addTarget:self action:@selector(projectButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [buttonsScrollView addSubview:projectButton];
    
    //safahatMozoee->tags
    tagButton = [[UIButton alloc]initWithFrame:CGRectMake(2 * (screenWidth/3), 0, screenWidth/3, 35)];
    [tagButton setTitle:NSLocalizedString(@"tags", @"") forState:UIControlStateNormal];
    tagButton.titleLabel.font = FONT_NORMAL(13);
    [tagButton setBackgroundColor:COLOR_5];
    [tagButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [tagButton addTarget:self action:@selector(tagButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [buttonsScrollView addSubview:tagButton];
    
    //pezeshkan->user
    userButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth/3, 0, screenWidth/3, 35)];
    [userButton setTitle:NSLocalizedString(@"user", @"") forState:UIControlStateNormal];
    userButton.titleLabel.font = FONT_NORMAL(17);
    [userButton setBackgroundColor:COLOR_5];
    [userButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [userButton addTarget:self action:@selector(userButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [buttonsScrollView addSubview:userButton];
    
    postButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, screenWidth/3, 35)];
    [postButton setTitle:NSLocalizedString(@"post", @"") forState:UIControlStateNormal];
    postButton.titleLabel.font = FONT_NORMAL(17);
    [postButton setBackgroundColor:COLOR_5];
    [postButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [postButton addTarget:self action:@selector(postButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [buttonsScrollView addSubview:postButton];
    
    boxUnderButton = [[UIView alloc]initWithFrame:CGRectMake(2 * (screenWidth/3), projectButton.frame.origin.y + projectButton.frame.size.height, screenWidth/2, 20)];
    boxUnderButton.backgroundColor = COLOR_1;
    //[self.view addSubview:boxUnderButton];
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, yPos + 35, screenWidth, screenHeight - yPos)];
    self.scrollView.tag = 124;
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.directionalLockEnabled = YES;
    [self.view addSubview:self.scrollView];
    //self.scrollView.contentSize = CGSizeMake(screenWidth * 6, screenHeight);
    [self.scrollView scrollRectToVisible:CGRectMake(1/*screenWidth * 2*/, 0, screenWidth, self.scrollView.frame.size.height) animated:YES];
    
    self.tableViewCompany = [[UITableView alloc]initWithFrame:CGRectMake(0 * screenWidth * 5, 0, screenWidth, screenHeight - yPos - 85)];
    self.tableViewCompany.delegate = self;
    self.tableViewCompany.dataSource = self;
    self.tableViewCompany.tag = 840;
    [self.scrollView addSubview:self.tableViewCompany];
    self.tableViewCompany.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.tableViewCompany.hidden = YES;
    
    self.tableViewMozoee = [[UITableView alloc]initWithFrame:CGRectMake(0 * screenWidth * 4, 0, screenWidth, screenHeight - yPos - 85)];
    self.tableViewMozoee.delegate = self;
    self.tableViewMozoee.dataSource = self;
    self.tableViewMozoee.tag = 740;
    [self.scrollView addSubview:self.tableViewMozoee];
    self.tableViewMozoee.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.tableViewMozoee.hidden = YES;
    
    self.tableViewProject = [[UITableView alloc]initWithFrame:CGRectMake(0 * screenWidth * 3, 0, screenWidth, screenHeight - yPos - 85)];
    self.tableViewProject.delegate = self;
    self.tableViewProject.dataSource = self;
    self.tableViewProject.tag = 640;
    [self.scrollView addSubview:self.tableViewProject];
    self.tableViewProject.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.tableViewProject.hidden = YES;
    
    self.tableViewTag = [[UITableView alloc]initWithFrame:CGRectMake(0 * screenWidth * 2, 0, screenWidth, screenHeight - yPos - 85)];
    self.tableViewTag.delegate = self;
    self.tableViewTag.dataSource = self;
    self.tableViewTag.tag = 540;
    [self.scrollView addSubview:self.tableViewTag];
    self.tableViewTag.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.tableViewTag.hidden = YES;
    
    self.tableViewUser = [[UITableView alloc]initWithFrame:CGRectMake(0 * screenWidth, 0, screenWidth, screenHeight - yPos - 85)];
    self.tableViewUser.delegate = self;
    self.tableViewUser.dataSource = self;
    self.tableViewUser.tag = 440;
    [self.scrollView addSubview:self.tableViewUser];
    self.tableViewUser.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.tableViewUser.hidden = YES;
    
    self.tableViewPost = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - yPos - 85)];
    self.tableViewPost.delegate = self;
    self.tableViewPost.dataSource = self;
    self.tableViewPost.tag = 340;
    [self.scrollView addSubview:self.tableViewPost];
    self.tableViewPost.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    searchProjectLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 200, screenWidth - 40,  25)];
    searchProjectLabel.font = FONT_MEDIUM(13);
    searchProjectLabel.text = NSLocalizedString(@"searchMataleb", @"");
    searchProjectLabel.minimumScaleFactor = 0.7;
    searchProjectLabel.textColor = [UIColor blackColor];
    searchProjectLabel.textAlignment = NSTextAlignmentCenter;
    searchProjectLabel.adjustsFontSizeToFitWidth = YES;
    [self.tableViewProject addSubview:searchProjectLabel];
    
    
    searchUserLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 200, screenWidth - 40,  25)];
    searchUserLabel.font = FONT_MEDIUM(13);
    searchUserLabel.text = NSLocalizedString(@"searchDoctor", @"");
    searchUserLabel.minimumScaleFactor = 0.7;
    searchUserLabel.textColor = [UIColor blackColor];
    searchUserLabel.textAlignment = NSTextAlignmentCenter;
    searchUserLabel.adjustsFontSizeToFitWidth = YES;
    [self.tableViewUser addSubview:searchUserLabel];
    
    searchTagLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 200, screenWidth - 40,  25)];
    searchTagLabel.font = FONT_MEDIUM(13);
    searchTagLabel.text = NSLocalizedString(@"searchSafahtMozoee", @"");
    searchTagLabel.minimumScaleFactor = 0.7;
    searchTagLabel.textColor = [UIColor blackColor];
    searchTagLabel.textAlignment = NSTextAlignmentCenter;
    searchTagLabel.adjustsFontSizeToFitWidth = YES;
    [self.tableViewTag addSubview:searchTagLabel];
    
    searchMozoeeLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 200, screenWidth - 40,  25)];
    searchMozoeeLabel.font = FONT_MEDIUM(13);
    searchMozoeeLabel.text = NSLocalizedString(@"searchAnjoman", @"");
    searchMozoeeLabel.minimumScaleFactor = 0.7;
    searchMozoeeLabel.textColor = [UIColor blackColor];
    searchMozoeeLabel.textAlignment = NSTextAlignmentCenter;
    searchMozoeeLabel.adjustsFontSizeToFitWidth = YES;
    [self.tableViewMozoee addSubview:searchMozoeeLabel];
    
    searchCompanyLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 200, screenWidth - 40,  25)];
    searchCompanyLabel.font = FONT_MEDIUM(13);
    searchCompanyLabel.text = NSLocalizedString(@"searchClinic", @"");
    searchCompanyLabel.minimumScaleFactor = 0.7;
    searchCompanyLabel.textColor = [UIColor blackColor];
    searchCompanyLabel.textAlignment = NSTextAlignmentCenter;
    searchCompanyLabel.adjustsFontSizeToFitWidth = YES;
    [self.tableViewCompany addSubview:searchCompanyLabel];
    
    searchPostLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 200, screenWidth - 40,  25)];
    searchPostLabel.font = FONT_MEDIUM(13);
    searchPostLabel.text = NSLocalizedString(@"searchPost", @"");
    searchPostLabel.minimumScaleFactor = 0.7;
    searchPostLabel.textColor = [UIColor blackColor];
    searchPostLabel.textAlignment = NSTextAlignmentCenter;
    searchPostLabel.adjustsFontSizeToFitWidth = YES;
    [self.tableViewPost addSubview:searchPostLabel];
    
}

- (void)companyButtonAction{
    [searchTextField resignFirstResponder];
    currentPage = 5;
    [self.tableViewCompany reloadData];
    [UIView animateWithDuration:0.1 animations:^{
        [postButton setBackgroundColor:COLOR_5];
        [companyButton setBackgroundColor:COLOR_3];
        [projectButton setBackgroundColor:COLOR_5];
        [userButton setBackgroundColor:COLOR_5];
        [tagButton setBackgroundColor:COLOR_5];
        [mozoeeButton setBackgroundColor:COLOR_5];
        CGRect rect = boxUnderButton.frame;
        rect.origin.x = 5 * (screenWidth/3);
        [boxUnderButton setFrame:rect];
        _scrollView.pagingEnabled = YES;
    }];

    //[self.scrollView scrollRectToVisible:CGRectMake(screenWidth * 5, 0, screenWidth, self.scrollView.frame.size.height) animated:YES];
    
    self.tableViewPost.hidden = YES;
    self.tableViewUser.hidden = YES;
    self.tableViewTag.hidden = YES;
    self.tableViewProject.hidden = YES;
    self.tableViewMozoee.hidden = YES;
    self.tableViewCompany.hidden = NO;
    
    [self connectionMaker:currentPage];
}

- (void)mozoeeButtonAction{
    [searchTextField resignFirstResponder];
    currentPage = 4;
    [self.tableViewMozoee reloadData];
    [UIView animateWithDuration:0.1 animations:^{
        [postButton setBackgroundColor:COLOR_5];
        [mozoeeButton setBackgroundColor:COLOR_3];
        [projectButton setBackgroundColor:COLOR_5];
        [userButton setBackgroundColor:COLOR_5];
        [tagButton setBackgroundColor:COLOR_5];
        [companyButton setBackgroundColor:COLOR_5];
        CGRect rect = boxUnderButton.frame;
        rect.origin.x = 4 * (screenWidth/3);
        [boxUnderButton setFrame:rect];
        _scrollView.pagingEnabled = YES;
    }];

    //[self.scrollView scrollRectToVisible:CGRectMake(screenWidth * 4, 0, screenWidth, self.scrollView.frame.size.height) animated:YES];
    self.tableViewPost.hidden = YES;
    self.tableViewUser.hidden = YES;
    self.tableViewTag.hidden = YES;
    self.tableViewProject.hidden = YES;
    self.tableViewMozoee.hidden = NO;
    self.tableViewCompany.hidden = YES;

    [buttonsScrollView scrollRectToVisible:CGRectMake(screenWidth, 0, screenWidth, self.scrollView.frame.size.height) animated:YES];
    
    [self connectionMaker:currentPage];
}

- (void)projectButtonAction{
    [searchTextField resignFirstResponder];
    currentPage = 3;
    [self.tableViewProject reloadData];
    [UIView animateWithDuration:0.1 animations:^{
        [postButton setBackgroundColor:COLOR_5];
        [projectButton setBackgroundColor:COLOR_3];
        [userButton setBackgroundColor:COLOR_5];
        [tagButton setBackgroundColor:COLOR_5];
        [companyButton setBackgroundColor:COLOR_5];
        [mozoeeButton setBackgroundColor:COLOR_5];
        CGRect rect = boxUnderButton.frame;
        rect.origin.x = 3 * (screenWidth/3);
        [boxUnderButton setFrame:rect];
        _scrollView.pagingEnabled = YES;
    }];

    //[self.scrollView scrollRectToVisible:CGRectMake(screenWidth * 3, 0, screenWidth, self.scrollView.frame.size.height) animated:YES];
    self.tableViewPost.hidden = YES;
    self.tableViewUser.hidden = YES;
    self.tableViewTag.hidden = YES;
    self.tableViewProject.hidden = NO;
    self.tableViewMozoee.hidden = YES;
    self.tableViewCompany.hidden = YES;
    
    [buttonsScrollView scrollRectToVisible:CGRectMake((screenWidth/2) + 100, 0, screenWidth, self.scrollView.frame.size.height) animated:YES];
    
    [self connectionMaker:currentPage];
}

- (void)tagButtonAction{
    [searchTextField resignFirstResponder];
    currentPage = 2;
    [self.tableViewTag reloadData];
    [UIView animateWithDuration:0.1 animations:^{
        [postButton setBackgroundColor:COLOR_5];
        [tagButton setBackgroundColor:COLOR_3];
        [userButton setBackgroundColor:COLOR_5];
        [projectButton setBackgroundColor:COLOR_5];
        [companyButton setBackgroundColor:COLOR_5];
        [mozoeeButton setBackgroundColor:COLOR_5];
        CGRect rect = boxUnderButton.frame;
        rect.origin.x = 2 * (screenWidth/3);
        [boxUnderButton setFrame:rect];
        _scrollView.pagingEnabled = YES;
    }];

    //[self.scrollView scrollRectToVisible:CGRectMake(screenWidth * 2, 0, screenWidth, self.scrollView.frame.size.height) animated:YES];
    self.tableViewPost.hidden = YES;
    self.tableViewUser.hidden = YES;
    self.tableViewTag.hidden = NO;
    self.tableViewProject.hidden = YES;
    self.tableViewMozoee.hidden = YES;
    self.tableViewCompany.hidden = YES;
    
    [buttonsScrollView scrollRectToVisible:CGRectMake(screenWidth/2, 0, screenWidth, self.scrollView.frame.size.height) animated:YES];
    
    [self connectionMaker:currentPage];
}

- (void)userButtonAction{
    [searchTextField resignFirstResponder];
    currentPage = 1;
    [self.tableViewUser reloadData];
    [UIView animateWithDuration:0.1 animations:^{
        [postButton setBackgroundColor:COLOR_5];
        [userButton setBackgroundColor:COLOR_3];
        [projectButton setBackgroundColor:COLOR_5];
        [tagButton setBackgroundColor:COLOR_5];
        [companyButton setBackgroundColor:COLOR_5];
        [mozoeeButton setBackgroundColor:COLOR_5];
        CGRect rect = boxUnderButton.frame;
        rect.origin.x = 1 * (screenWidth/3);
        [boxUnderButton setFrame:rect];
        _scrollView.pagingEnabled = NO;
    }];

    //[self.scrollView scrollRectToVisible:CGRectMake(screenWidth, 0, screenWidth, self.scrollView.frame.size.height) animated:YES];
    self.tableViewPost.hidden = YES;
    self.tableViewUser.hidden = NO;
    self.tableViewTag.hidden = YES;
    self.tableViewProject.hidden = YES;
    self.tableViewMozoee.hidden = YES;
    self.tableViewCompany.hidden = YES;
    [buttonsScrollView scrollRectToVisible:CGRectMake(0, 0, screenWidth, self.scrollView.frame.size.height) animated:YES];
    
    [self connectionMaker:currentPage];
}

- (void)postButtonAction{
    [searchTextField resignFirstResponder];
    currentPage = 0;
    [self.tableViewPost reloadData];
    [UIView animateWithDuration:0.1 animations:^{
        [postButton setBackgroundColor:COLOR_3];
        [userButton setBackgroundColor:COLOR_5];
        [projectButton setBackgroundColor:COLOR_5];
        [tagButton setBackgroundColor:COLOR_5];
        [companyButton setBackgroundColor:COLOR_5];
        [mozoeeButton setBackgroundColor:COLOR_5];
        CGRect rect = boxUnderButton.frame;
        rect.origin.x = 0;
        [boxUnderButton setFrame:rect];
        _scrollView.pagingEnabled = NO;
    }];

    //[self.scrollView scrollRectToVisible:CGRectMake(0, 0, screenWidth, self.scrollView.frame.size.height) animated:YES];
    self.tableViewPost.hidden = NO;
    self.tableViewUser.hidden = YES;
    self.tableViewTag.hidden = YES;
    self.tableViewProject.hidden = YES;
    self.tableViewMozoee.hidden = YES;
    self.tableViewCompany.hidden = YES;
    
    [self connectionMaker:currentPage];
}

- (void)backButtonImgAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)searchButtonAction{
    [searchTextField resignFirstResponder];
    
//    self.tableArrayProject = [[NSMutableArray alloc]init];
//    self.tableArrayUser = [[NSMutableArray alloc]init];
//    offsetProject = 0;
//    offsetUser = 0;
//    offsetCompany = 0;
//    offsetTag = 0;
//    offsetMozoee = 0;
    [self fetchSearchResultFromServerWithKeyword:searchTextField.text page:page type:type];
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
    self.tableViewProject.userInteractionEnabled = disableTableView;
    self.tableViewUser.userInteractionEnabled = disableTableView;
    self.scrollView.userInteractionEnabled = disableTableView;
    //[self showHideRightMenu];
    [searchTextField resignFirstResponder];
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
    NSDictionary *landingPageDic = [self.tableArrayProject objectAtIndex:btn.tag];
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
    
    NSDictionary *landingPageDic = [self.tableArrayProject objectAtIndex:btn.tag];
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
    
    [self.tableArrayProject replaceObjectAtIndex:btn.tag withObject:landingPageDic2];
    [self.tableViewProject reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:btn.tag inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)shareButtonAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    
    NSDictionary *landingPageDic = [self.tableArrayProject objectAtIndex:btn.tag];
    
    NSString *textToShare = landingPageDic.LPTitle;
    NSString *textToShare2 = landingPageDic.LPContentSummary;
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
    NSDictionary *tempDic = [self.tableArrayProject objectAtIndex:tap.view.tag];
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
    NSDictionary *tempDic = [self.tableArrayUser objectAtIndex:tap.view.tag];
    view.userEntityId = [tempDic objectForKey:@"doctor_id"];
    view.userAvatar = [tempDic objectForKey:@"photo"];
    view.userTitle = [tempDic objectForKey:@"name"];
    view.userJobTitle = [tempDic objectForKey:@"experience"];
    view.isFromDoctorPage = YES;
    [self.navigationController pushViewController:view animated:YES];
}

- (void)resetValues{
    //currentPage = 0;
    offsetPost = 0;
    offsetProject = 0;
    offsetUser = 0;
    offsetTag = 0;
    offsetMozoee = 0;
    offsetCompany = 0;
    
    //NSLog(@"id of doctor:%@", self.userEntityId);
    
    selectedRow = 1000;
    isBusyNow = NO;
    isPagingForCategories = NO;
    noMoreData = NO;
    self.tableArrayPost = [[NSMutableArray alloc]init];
    self.tableArrayProject = [[NSMutableArray alloc]init];
    self.tableArrayUser = [[NSMutableArray alloc]init];
    self.tableArrayTag = [[NSMutableArray alloc]init];
    self.tableArrayCompany = [[NSMutableArray alloc]init];
    self.tableArrayMozoee = [[NSMutableArray alloc]init];
    self.likeArray = [[NSMutableArray alloc]init];
    self.favArray = [[NSMutableArray alloc]init];
    type = @"";
    
}

- (void)followButtonActionUser:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSInteger idx = [[[self.tableArrayUser objectAtIndex:btn.tag]objectForKey:@"id"]integerValue];
    NSDictionary *dic = [self.tableArrayUser objectAtIndex:btn.tag];
    [self followUnfollowUserConnection:idx withdic:dic];
}

- (void)followButtonActionProj:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSInteger idx = [[[self.tableArrayProject objectAtIndex:btn.tag]objectForKey:@"id"]integerValue];
    NSDictionary *dic = [self.tableArrayProject objectAtIndex:btn.tag];
    [self followUnfollowProjConnection:idx withdic:dic];
}

- (void)followButtonActionCom:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSInteger idx = [[[self.tableArrayCompany objectAtIndex:btn.tag]objectForKey:@"id"]integerValue];
    NSDictionary *dic = [self.tableArrayCompany objectAtIndex:btn.tag];
    [self followUnfollowCompanyConnection:idx withdic:dic];
}

- (void)followButtonActionMozoee:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSInteger idx = [[[self.tableArrayMozoee objectAtIndex:btn.tag]objectForKey:@"id"]integerValue];
    NSDictionary *dic = [self.tableArrayMozoee objectAtIndex:btn.tag];
    [self followUnfollowMozoeeConnection:idx withdic:dic];
}

#pragma mark - textfield delegate

-(void)textFieldDidChange :(UITextField *)textField{
    if (textField.tag == 12) {
        if ([textField.text length] == 0) {
            [self resetValues];
        }
       
        if ([textField.text length] > 1) {
            searchButton.userInteractionEnabled = YES;
        }else{
            searchButton.userInteractionEnabled = NO;
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [searchTextField resignFirstResponder];
    if ([textField.text length] == 0) {
        [self resetValues];
        //[ShakeAnimation startShake:textField];
        [self searchButtonAction];
    }else{
        [self resetValues];
        [self searchButtonAction];
    }
    return NO;
}

#pragma mark - scrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    /*
    if (scrollView.tag == 124) {
        [searchTextField resignFirstResponder];
        static NSInteger previousPage = 0;
        CGFloat pageWidth = scrollView.frame.size.width;
        float fractionalPage = scrollView.contentOffset.x / pageWidth;
        NSInteger pagei = lround(fractionalPage);
        //if (previousPage != page) {
        switch (pagei) {
            case 0:
            {
                currentPage = 0;
                [self.tableViewPost reloadData];
                [UIView animateWithDuration:0.1 animations:^{
                    [postButton setBackgroundColor:COLOR_3];
                    [userButton setBackgroundColor:COLOR_5];
                    [projectButton setBackgroundColor:COLOR_5];
                    [tagButton setBackgroundColor:COLOR_5];
                    [companyButton setBackgroundColor:COLOR_5];
                    [mozoeeButton setBackgroundColor:COLOR_5];
                    CGRect rect = boxUnderButton.frame;
                    rect.origin.x = 0;
                    [boxUnderButton setFrame:rect];
                    scrollView.pagingEnabled = NO;
                }];
            }
                break;
            case 1:
            {
                currentPage = 1;
                [self.tableViewUser reloadData];
                [UIView animateWithDuration:0.1 animations:^{
                    [postButton setBackgroundColor:COLOR_5];
                    [userButton setBackgroundColor:COLOR_3];
                    [projectButton setBackgroundColor:COLOR_5];
                    [tagButton setBackgroundColor:COLOR_5];
                    [companyButton setBackgroundColor:COLOR_5];
                    [mozoeeButton setBackgroundColor:COLOR_5];
                    CGRect rect = boxUnderButton.frame;
                    rect.origin.x = 1 * (screenWidth/3);
                    [boxUnderButton setFrame:rect];
                    scrollView.pagingEnabled = NO;
                }];
            }
                break;
            case 2:
            {
                currentPage = 2;
                [self.tableViewTag reloadData];
                [UIView animateWithDuration:0.1 animations:^{
                    [postButton setBackgroundColor:COLOR_5];
                    [tagButton setBackgroundColor:COLOR_3];
                    [userButton setBackgroundColor:COLOR_5];
                    [projectButton setBackgroundColor:COLOR_5];
                    [companyButton setBackgroundColor:COLOR_5];
                    [mozoeeButton setBackgroundColor:COLOR_5];
                    CGRect rect = boxUnderButton.frame;
                    rect.origin.x = 2 * (screenWidth/3);
                    [boxUnderButton setFrame:rect];
                    scrollView.pagingEnabled = YES;
                }];
            }
                break;
            case 3:
            {
                currentPage = 3;
                [self.tableViewProject reloadData];
                [UIView animateWithDuration:0.1 animations:^{
                    [postButton setBackgroundColor:COLOR_5];
                    [projectButton setBackgroundColor:COLOR_3];
                    [userButton setBackgroundColor:COLOR_5];
                    [tagButton setBackgroundColor:COLOR_5];
                    [companyButton setBackgroundColor:COLOR_5];
                    [mozoeeButton setBackgroundColor:COLOR_5];
                    CGRect rect = boxUnderButton.frame;
                    rect.origin.x = 3 * (screenWidth/3);
                    [boxUnderButton setFrame:rect];
                    scrollView.pagingEnabled = YES;
                }];
                
            }
                break;
            case 4:
            {
                currentPage = 4;
                [self.tableViewMozoee reloadData];
                [UIView animateWithDuration:0.1 animations:^{
                    [postButton setBackgroundColor:COLOR_5];
                    [mozoeeButton setBackgroundColor:COLOR_3];
                    [projectButton setBackgroundColor:COLOR_5];
                    [userButton setBackgroundColor:COLOR_5];
                    [tagButton setBackgroundColor:COLOR_5];
                    [companyButton setBackgroundColor:COLOR_5];
                    CGRect rect = boxUnderButton.frame;
                    rect.origin.x = 4 * (screenWidth/3);
                    [boxUnderButton setFrame:rect];
                    scrollView.pagingEnabled = YES;
                }];
                
            }
                break;
            case 5:
            {
                currentPage = 5;
                [self.tableViewCompany reloadData];
                [UIView animateWithDuration:0.1 animations:^{
                    [postButton setBackgroundColor:COLOR_5];
                    [companyButton setBackgroundColor:COLOR_3];
                    [projectButton setBackgroundColor:COLOR_5];
                    [userButton setBackgroundColor:COLOR_5];
                    [tagButton setBackgroundColor:COLOR_5];
                    [mozoeeButton setBackgroundColor:COLOR_5];
                    CGRect rect = boxUnderButton.frame;
                    rect.origin.x = 5 * (screenWidth/3);
                    [boxUnderButton setFrame:rect];
                    scrollView.pagingEnabled = YES;
                }];
                
            }
                break;
                
            default:
                break;
        }
        previousPage = page;
        
        //detect scroll direction
        ScrollDirection scrollDirection;
        if (self.lastContentOffset > scrollView.contentOffset.x){
            scrollDirection = ScrollDirectionRight;
            if (currentPage == 1) {
                [buttonsScrollView setContentOffset:CGPointMake(1, 1) animated:YES];
            } else if (currentPage == 2) {
                [buttonsScrollView setContentOffset:CGPointMake(1 * (screenWidth/3), 1) animated:YES];
            }else if (currentPage == 3) {
                [buttonsScrollView setContentOffset:CGPointMake(2 * (screenWidth/3), 1) animated:YES];
            }else if (currentPage == 4) {
                [buttonsScrollView setContentOffset:CGPointMake(3 * (screenWidth/3), 1) animated:YES];
            }
            
            
        }else if (self.lastContentOffset < scrollView.contentOffset.x){
            scrollDirection = ScrollDirectionLeft;
            if (currentPage == 1) {
                [buttonsScrollView setContentOffset:CGPointMake(1, 1) animated:YES];
            } else if (currentPage == 2) {
                [buttonsScrollView setContentOffset:CGPointMake(1 * (screenWidth/3), 1) animated:YES];
            }else if (currentPage == 3) {
                [buttonsScrollView setContentOffset:CGPointMake(2 * (screenWidth/3), 1) animated:YES];
            }else if (currentPage == 4) {
                [buttonsScrollView setContentOffset:CGPointMake(3 * (screenWidth/3), 1) animated:YES];
            }
        }
    }
    */
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView.tag == 124) {
        //self.lastContentOffset = scrollView.contentOffset.x;
    }
}

- (void)connectionMaker:(NSInteger)pagey{
    switch (pagey) {
        case 0:
        {
        type = @"post";
        offsetPost += 1;
        [self fetchSearchResultFromServerWithKeyword:searchTextField.text page:offsetUser type:type];
        }
            break;
        case 1:
        {
        type = @"profile";
        offsetUser += 1;
        [self fetchSearchResultFromServerWithKeyword:searchTextField.text page:offsetUser type:type];
        }
            break;
        case 2:
        {
        type = @"tag";
        offsetTag += 1;
        [self fetchSearchResultFromServerWithKeyword:searchTextField.text page:offsetTag type:type];
        }
            break;
        case 3:
        {
        type = @"project";
        offsetProject += 1;
        [self fetchSearchResultFromServerWithKeyword:searchTextField.text page:offsetProject type:type];
        }
            break;
        case 4:
        {
        type = @"topic";
        offsetMozoee += 1;
        [self fetchSearchResultFromServerWithKeyword:searchTextField.text page:offsetMozoee type:type];
        }
            break;
        case 5:
        {
        type = @"company";
        offsetCompany += 1;
        [self fetchSearchResultFromServerWithKeyword:searchTextField.text page:offsetCompany type:type];
        }
            break;
            
        default:
            break;
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //if (scrollView.tag == 124) {
        float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
        if (bottomEdge >= scrollView.contentSize.height) {
            // we are at the end
            //NSLog(@"time to fetch new posts");
            //profile(user), company, project, tag, topic
            /*
             clinic->company
             anjoman->mozoee(topic)
             mataleb->projects
             safahatMozoee->tags
             pezeshkan->user
             */
            switch (currentPage) {
                case 0:
                {
                    type = @"post";
                    offsetPost += 1;
                    [self fetchSearchResultFromServerWithKeyword:searchTextField.text page:offsetUser type:type];
                }
                    break;
                case 1:
                {
                    type = @"profile";
                    offsetUser += 1;
                    [self fetchSearchResultFromServerWithKeyword:searchTextField.text page:offsetUser type:type];
                }
                    break;
                case 2:
                {
                    type = @"tag";
                    offsetTag += 1;
                    [self fetchSearchResultFromServerWithKeyword:searchTextField.text page:offsetTag type:type];
                }
                    break;
                case 3:
                {
                    type = @"project";
                    offsetProject += 1;
                    [self fetchSearchResultFromServerWithKeyword:searchTextField.text page:offsetProject type:type];
                }
                    break;
                case 4:
                {
                    type = @"topic";
                    offsetMozoee += 1;
                    [self fetchSearchResultFromServerWithKeyword:searchTextField.text page:offsetMozoee type:type];
                }
                    break;
                case 5:
                {
                    type = @"company";
                    offsetCompany += 1;
                    [self fetchSearchResultFromServerWithKeyword:searchTextField.text page:offsetCompany type:type];
                }
                    break;
                    
                default:
                    break;
            }
        }
        
        if (self.lastContentOffset < scrollView.contentOffset.x) {
            // moved right
            if (currentPage == 3) {
                [buttonsScrollView scrollRectToVisible:CGRectMake(buttonsScrollView.contentSize.width/2, 1, 1, 1) animated:YES];
            }
            
        } else if (self.lastContentOffset > scrollView.contentOffset.x) {
            // moved left
            if (currentPage == 2) {
                [buttonsScrollView scrollRectToVisible:CGRectMake(0, 1, 1, 1) animated:YES];
            }
            
        }
    //}
}

#pragma mark - table view delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (currentPage == 0)/*post*/ {
        return [self.tableArrayPost count];
    } else if (currentPage == 1)/*user*/ {
        return [self.tableArrayUser count];
    } else if (currentPage == 2)/*tag*/ {
        return [self.tableArrayTag count];
    } else if (currentPage == 3)/*project*/ {
        return [self.tableArrayProject count];
    }else if (currentPage == 4)/*mozoee*/ {
        return [self.tableArrayMozoee count];
    }else if (currentPage == 5)/*Company*/ {
        return [self.tableArrayCompany count];
    }else{
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (IS_IPAD) {
        if (currentPage == 0)/*post*/ {
            if (selectedRow == indexPath.row) {
                if (isExpand) {
                    NSDictionary *landingPageDic = [self.tableArrayProject objectAtIndex:indexPath.row];
                    return [self getHeightOfString:landingPageDic.LPContentSummary];
                    
                } else {
                    return screenWidth + 10;
                }
            } else {
                return screenWidth + 10;
            }
            //return screenWidth * 0.8;
        }else{
            return 90;
        }
        
    } else {
        if (selectedRow == indexPath.row) {
            if (isExpand) {
                NSDictionary *landingPageDic = [self.tableArrayProject objectAtIndex:indexPath.row];
                return [self getHeightOfString:landingPageDic.LPContentSummary];
                
            } else {
                if (currentPage == 0)/*post*/ {
                    return screenWidth + 10;
                } else {
                    return 90;
                }
            }
        } else {
            if (currentPage == 0)/*post*/ {
                
                return 90;
            } else  {
                return 90;
            }
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (currentPage == 0)//POST tab
    {
        SearchViewCustomCell *cell = (SearchViewCustomCell *)[[SearchViewCustomCell alloc]
                                                              initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellSafahatMozoee"];
        
        if (indexPath.row < [self.tableArrayPost count]) {
            NSDictionary *searchDic = [self.tableArrayPost objectAtIndex:indexPath.row];
            cell.nameLabel.text = [[self.tableArrayPost objectAtIndex:indexPath.row]objectForKey:@"title"];
            if ([[searchDic objectForKey:@"entity"]count] > 0) {
                // contains key
                cell.jobLabel.text = [[[self.tableArrayPost objectAtIndex:indexPath.row]objectForKey:@"entity"]objectForKey:@"name"];
                [cell.myImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [searchDic objectForKey:@"cover"]]] placeholderImage:[UIImage imageNamed:@"icon upload ax"]];
            }
            
        }
        
        return cell;
    }else if (currentPage == 1)/*user*/{
        SearchViewCustomCell *cell = (SearchViewCustomCell *)[[SearchViewCustomCell alloc]
                                                              initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellSafahatMozoee"];
        
        if (indexPath.row < [self.tableArrayUser count]) {
            NSDictionary *searchDic = [self.tableArrayUser objectAtIndex:indexPath.row];
            cell.nameLabel.text = [[self.tableArrayUser objectAtIndex:indexPath.row]objectForKey:@"name"];
            cell.jobLabel.text = [[self.tableArrayUser objectAtIndex:indexPath.row]objectForKey:@"work_experience"];
            [cell.myImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [searchDic objectForKey:@"avatar"]]] placeholderImage:[UIImage imageNamed:@"icon upload ax"]];
            
            if ([[searchDic objectForKey:@"can_edit"]integerValue] == 0) {
                UIButton *followButton;
                if ([searchDic.LPFollow isEqualToString:@"not_followed"]) {
                    followButton = [CustomButton initButtonWithTitle:@"دنبال می کنم" withTitleColor:COLOR_5 withBackColor:WHITE_COLOR isRounded:YES withFrame:CGRectMake(10, 25, 80, 35)];
                    followButton.tag = indexPath.row;
                    [followButton addTarget:self action:@selector(followButtonActionUser:) forControlEvents:UIControlEventTouchUpInside];
                    
                } else if ([searchDic.LPFollow isEqualToString:@"followed"]){
                    followButton = [CustomButton initButtonWithTitle:@"دنبال می کنم" withTitleColor:WHITE_COLOR withBackColor:COLOR_5 isRounded:YES withFrame:CGRectMake(10, 25, 80, 35)];
                    followButton.tag = indexPath.row;
                    [followButton addTarget:self action:@selector(followButtonActionUser:) forControlEvents:UIControlEventTouchUpInside];
                }else if ([searchDic.LPFollow isEqualToString:@"pending_approve"]){
                    followButton = [CustomButton initButtonWithTitle:@"منتظر تایید" withTitleColor:WHITE_COLOR withBackColor:COLOR_5 isRounded:YES withFrame:CGRectMake(10, 25, 80, 35)];
                    followButton.tag = indexPath.row;
                    [followButton addTarget:self action:@selector(followButtonActionUser:) forControlEvents:UIControlEventTouchUpInside];
                }
                
                followButton.titleLabel.font = FONT_NORMAL(13);
                [cell addSubview:followButton];
                
                if ([cell.nameLabel.text length] > 24) {
                    NSMutableString *str = [[NSMutableString alloc]initWithString:cell.nameLabel.text];
                    cell.nameLabel.text = [str substringWithRange:NSMakeRange(0, 24)];
                }

            }
        }
        
        return cell;
    }else if (currentPage == 2)/*tag tab*/{
        SearchViewCustomCell *cell = (SearchViewCustomCell *)[[SearchViewCustomCell alloc]
                                                              initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellSearch"];
        
        if (indexPath.row < [self.tableArrayTag count]) {
            NSDictionary *searchDic = [self.tableArrayTag objectAtIndex:indexPath.row];
            cell.nameLabel.text = [searchDic objectForKey:@"name"];
            CGRect rect = cell.nameLabel.frame;
            rect.origin.x = 20;
            rect.size.width = screenWidth - 40;
            cell.nameLabel.frame = rect;
            cell.nameLabel.textAlignment = NSTextAlignmentRight;
            cell.jobLabel.text = [searchDic objectForKey:@"experience"];
            //[cell.myImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [searchDic objectForKey:@"avatar"]]] placeholderImage:[UIImage imageNamed:@"icon upload ax"]];
            
        }
        
        return cell;
    }else if (currentPage == 3)/*project tab*/{
        SearchViewCustomCell *cell = (SearchViewCustomCell *)[[SearchViewCustomCell alloc]
                                                              initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellSearch"];
        
        if (indexPath.row < [self.tableArrayProject count]) {
            NSDictionary *searchDic = [self.tableArrayProject objectAtIndex:indexPath.row];
            cell.nameLabel.text = [searchDic objectForKey:@"name"];
            cell.jobLabel.text = [searchDic objectForKey:@"job_title"];
            [cell.myImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [searchDic objectForKey:@"avatar"]]] placeholderImage:[UIImage imageNamed:@"icon upload ax"]];
            
            UIButton *followButton;
            if ([searchDic.LPFollow isEqualToString:@"not_followed"]) {
                followButton = [CustomButton initButtonWithTitle:@"دنبال می کنم" withTitleColor:COLOR_5 withBackColor:WHITE_COLOR isRounded:YES withFrame:CGRectMake(10, 25, 80, 35)];
                followButton.tag = indexPath.row;
                [followButton addTarget:self action:@selector(followButtonActionProj:) forControlEvents:UIControlEventTouchUpInside];
                
            } else if ([searchDic.LPFollow isEqualToString:@"followed"]){
                followButton = [CustomButton initButtonWithTitle:@"دنبال می کنم" withTitleColor:WHITE_COLOR withBackColor:COLOR_5 isRounded:YES withFrame:CGRectMake(10, 25, 80, 35)];
                followButton.tag = indexPath.row;
                [followButton addTarget:self action:@selector(followButtonActionProj:) forControlEvents:UIControlEventTouchUpInside];
                
            }else if ([searchDic.LPFollow isEqualToString:@"pending_approve"]){
                followButton = [CustomButton initButtonWithTitle:@"منتظر تایید" withTitleColor:WHITE_COLOR withBackColor:COLOR_5 isRounded:YES withFrame:CGRectMake(10, 25, 80, 35)];
                followButton.tag = indexPath.row;
                [followButton addTarget:self action:@selector(followButtonActionProj:) forControlEvents:UIControlEventTouchUpInside];
                
            }
            
            followButton.titleLabel.font = FONT_NORMAL(13);
            [cell addSubview:followButton];
            
            if ([cell.nameLabel.text length] > 24) {
                NSMutableString *str = [[NSMutableString alloc]initWithString:cell.nameLabel.text];
                cell.nameLabel.text = [str substringWithRange:NSMakeRange(0, 24)];
            }
            
        }
        
        return cell;
    }else if (currentPage == 4)/*mozoee tab*/{
        SearchViewCustomCell *cell = (SearchViewCustomCell *)[[SearchViewCustomCell alloc]
                                                              initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellSearch"];
        
        if (indexPath.row < [self.tableArrayMozoee count]) {
            NSDictionary *searchDic = [self.tableArrayMozoee objectAtIndex:indexPath.row];
            cell.nameLabel.text = [searchDic objectForKey:@"name"];
            cell.jobLabel.text = [searchDic objectForKey:@"job_title"];
            [cell.myImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [searchDic objectForKey:@"avatar"]]] placeholderImage:[UIImage imageNamed:@"icon upload ax"]];
            
            UIButton *followButton;
            if ([searchDic.LPFollow isEqualToString:@"not_followed"]) {
                followButton = [CustomButton initButtonWithTitle:@"دنبال می کنم" withTitleColor:COLOR_5 withBackColor:WHITE_COLOR isRounded:YES withFrame:CGRectMake(10, 25, 80, 35)];
                followButton.tag = indexPath.row;
                [followButton addTarget:self action:@selector(followButtonActionMozoee:) forControlEvents:UIControlEventTouchUpInside];
                
            } else if ([searchDic.LPFollow isEqualToString:@"followed"]){
                followButton = [CustomButton initButtonWithTitle:@"دنبال می کنم" withTitleColor:WHITE_COLOR withBackColor:COLOR_5 isRounded:YES withFrame:CGRectMake(10, 25, 80, 35)];
                followButton.tag = indexPath.row;
                [followButton addTarget:self action:@selector(followButtonActionMozoee:) forControlEvents:UIControlEventTouchUpInside];
            }else if ([searchDic.LPFollow isEqualToString:@"pending_approve"]){
                followButton = [CustomButton initButtonWithTitle:@"منتظر تایید" withTitleColor:WHITE_COLOR withBackColor:COLOR_5 isRounded:YES withFrame:CGRectMake(10, 25, 80, 35)];
                followButton.tag = indexPath.row;
                [followButton addTarget:self action:@selector(followButtonActionMozoee:) forControlEvents:UIControlEventTouchUpInside];
            }
            
            followButton.titleLabel.font = FONT_NORMAL(13);
            [cell addSubview:followButton];

        }
        
        return cell;
    }else if (currentPage == 5)/*company tab*/{
        SearchViewCustomCell *cell = (SearchViewCustomCell *)[[SearchViewCustomCell alloc]
                                                              initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellSearch"];
        
        if (indexPath.row < [self.tableArrayCompany count]) {
            NSDictionary *searchDic = [self.tableArrayCompany objectAtIndex:indexPath.row];
            cell.nameLabel.text = [searchDic objectForKey:@"name"];
            cell.jobLabel.text = [searchDic objectForKey:@"job_title"];
            [cell.myImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [searchDic objectForKey:@"avatar"]]] placeholderImage:[UIImage imageNamed:@"icon upload ax"]];
            
            UIButton *followButton;
            if ([searchDic.LPFollow isEqualToString:@"not_followed"]) {
                followButton = [CustomButton initButtonWithTitle:@"دنبال می کنم" withTitleColor:COLOR_5 withBackColor:WHITE_COLOR isRounded:YES withFrame:CGRectMake(10, 25, 80, 35)];
                followButton.tag = indexPath.row;
                [followButton addTarget:self action:@selector(followButtonActionCom:) forControlEvents:UIControlEventTouchUpInside];
                
            } else if ([searchDic.LPFollow isEqualToString:@"followed"]){
                followButton = [CustomButton initButtonWithTitle:@"دنبال می کنم" withTitleColor:WHITE_COLOR withBackColor:COLOR_5 isRounded:YES withFrame:CGRectMake(10, 25, 80, 35)];
                followButton.tag = indexPath.row;
                [followButton addTarget:self action:@selector(followButtonActionCom:) forControlEvents:UIControlEventTouchUpInside];
                
            }else if ([searchDic.LPFollow isEqualToString:@"pending_approve"]){
                followButton = [CustomButton initButtonWithTitle:@"منتظر تایید" withTitleColor:WHITE_COLOR withBackColor:COLOR_5 isRounded:YES withFrame:CGRectMake(10, 25, 80, 35)];
                followButton.tag = indexPath.row;
                [followButton addTarget:self action:@selector(followButtonActionCom:) forControlEvents:UIControlEventTouchUpInside];
            }
            
            followButton.titleLabel.font = FONT_NORMAL(13);
            [cell addSubview:followButton];
            
            if ([cell.nameLabel.text length] > 24) {
                NSMutableString *str = [[NSMutableString alloc]initWithString:cell.nameLabel.text];
                cell.nameLabel.text = [str substringWithRange:NSMakeRange(0, 24)];
            }
            
        }
        
        return cell;
    }else{
        SearchViewCustomCell *cell = (SearchViewCustomCell *)[[SearchViewCustomCell alloc]
                                                              initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellSearch"];
        return cell;
    }
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self hasConnectivity]) {
        /*
         if (cell.tag == loadingCellTag) {
         //if (currentPage <= pageCount) {
         NSDictionary *landingPageDic = [self.tableArrayProject lastObject];
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
    
    SearchViewCustomCell *cell = (SearchViewCustomCell *)[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    
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
    //[self.tableViewProject deselectRowAtIndexPath:indexPath animated:YES];
    [self.tableViewTag deselectRowAtIndexPath:indexPath animated:YES];
    [self.tableViewUser deselectRowAtIndexPath:indexPath animated:YES];
    [self.tableViewCompany deselectRowAtIndexPath:indexPath animated:YES];
    [self.tableViewMozoee deselectRowAtIndexPath:indexPath animated:YES];
    if (currentPage == 2)/*tag*/ {
        NSDictionary *dic = [self.tableArrayTag objectAtIndex:indexPath.row];
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        TopicPageViewController *view = (TopicPageViewController *)[story instantiateViewControllerWithIdentifier:@"TopicPageViewController"];
        view.dictionary = dic;
        view.tagName = [NSString stringWithFormat:@"%@",[dic objectForKey:@"name"]];
        view.isComingFromTags = YES;//first call entity detail with tagId then call
        view.tagIDx = [[dic objectForKey:@"id"]integerValue];
        [self.navigationController pushViewController:view animated:YES];

    } else if (currentPage == 1)/*user*/{
        
        NSDictionary *tempDic = [self.tableArrayUser objectAtIndex:indexPath.row];
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UserProfileViewController *view = (UserProfileViewController *)[story instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
        view.entityID = [[tempDic objectForKey:@"id"]integerValue];
        view.dictionary = tempDic;
        [self.navigationController pushViewController:view animated:YES];
        
    } else if (currentPage == 0)/*pezeshkan tab*/{
        NSDictionary *dic = [self.tableArrayPost objectAtIndex:indexPath.row];
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LandingPageDetailViewController *view = (LandingPageDetailViewController *)[story instantiateViewControllerWithIdentifier:@"LandingPageDetailViewController"];
        view.dictionary = dic;
        [self.navigationController pushViewController:view animated:YES];
    }else if (currentPage == 3)/*anjoman tab*/{
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        NSDictionary *dic = [_tableArrayProject objectAtIndex:indexPath.row];
        ProjectProfileViewController *view = (ProjectProfileViewController *)[story instantiateViewControllerWithIdentifier:@"ProjectProfileViewController"];
        view.dictionary = dic;
        view.postId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]];
        [self.navigationController pushViewController:view animated:YES];

    }else if (currentPage == 5)/*clinic tab*/{
        NSDictionary *dic = [self.tableArrayCompany objectAtIndex:indexPath.row];
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CompanyProfileViewController *view = (CompanyProfileViewController *)[story instantiateViewControllerWithIdentifier:@"CompanyProfileViewController"];
        view.dictionary = dic;
        view.postId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]];
        [self.navigationController pushViewController:view animated:YES];
    }else if (currentPage == 4)/*topic page tab*/{
        NSDictionary *dic = [self.tableArrayMozoee objectAtIndex:indexPath.row];
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        TopicPageViewController *view = (TopicPageViewController *)[story instantiateViewControllerWithIdentifier:@"TopicPageViewController"];
        view.dictionary = dic;
        view.postId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]];
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
        NSDictionary *dic = [self.tableArrayProject objectAtIndex:btn.tag];
        [self playAudioWithName:[dic.LPAudioUrl lastPathComponent]];
        playingAudioRowNumber = btn.tag;
        whichRowShouldBeReload = playingAudioRowNumber;
    }
    //NSIndexPath *indexpath = [NSIndexPath indexPathForRow:btn.tag inSection:0];
    [self.tableViewProject reloadData]; //RowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)playVideo:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSDictionary *dic = [self.tableArrayProject objectAtIndex:btn.tag];
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
    [self.tableViewProject reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)stopTimer {
    [myTimer invalidate];
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    playingAudioRowNumber = 10000;
    [self.tableViewProject reloadData];
    [self stopTimer];
}

- (void)downloadPlayButtonAction:(UITapGestureRecognizer *)sender{
    whichRowShouldBeReload = sender.view.tag;
    [self startAnimationProgress];
    NSDictionary *tempDic = [self.tableArrayProject objectAtIndex:sender.view.tag];
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
    NSDictionary *tempDic = [self.tableArrayProject objectAtIndex:btn.tag];
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
    LandingPageCustomCellAudio *cell = (LandingPageCustomCellAudio *)[self.tableViewProject cellForRowAtIndexPath:indexpath];
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
    LandingPageCustomCellAudio *cell = (LandingPageCustomCellAudio *)[self.tableViewProject cellForRowAtIndexPath:indexpath];
    CGFloat progress = cell.largeProgressView.progress + 0.01f;
    [cell.largeProgressView setProgress:progress animated:YES];
    
    if (cell.largeProgressView.progress >= 1.0f && [_timerForProgressFinal isValid]) {
        //[progressView setProgress:0.f animated:YES];
        [self stopAnimationProgressFinal];
        [self.tableViewProject reloadData];
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

- (void)fetchSearchResultFromServerWithKeyword:(NSString *)keyword page:(NSInteger)pagey type:(NSString *)typey{
    [searchUserLabel removeFromSuperview];
    [searchProjectLabel removeFromSuperview];
    [searchCompanyLabel removeFromSuperview];
    [searchMozoeeLabel removeFromSuperview];
    [searchTagLabel removeFromSuperview];
    
    [ProgressHUD show:@""];
    keyword = [keyword stringByReplacingOccurrencesOfString:@"ي" withString:@"ی" options:2 range:NSMakeRange(0, [keyword length])];
    keyword = [keyword stringByReplacingOccurrencesOfString:@"ك" withString:@"ک" options:2 range:NSMakeRange(0, [keyword length])];
    keyword = [keyword stringByReplacingOccurrencesOfString:@"ين" withString:@"ین" options:2 range:NSMakeRange(0, [keyword length])];
    
    NSDictionary *params = @{@"keyword":keyword,
                             @"type":typey,
                             @"page":[NSNumber numberWithInteger:pagey],
                             @"limit":[NSNumber numberWithInteger:20]
                             };
    NSString *url = [NSString stringWithFormat:@"%@api/search", BaseURL];
    
    if (!isBusyNow) {
        isBusyNow = YES;
        [refreshControl endRefreshing];
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
            //            NSInteger countOfMatalbs = [self.tableArrayProject count];
            //            NSInteger countOfDoctors = [self.tableArrayUser count];
            //            NSInteger countOfSafahatMozoee = [self.tableArrayTag count];
            //            NSInteger countOfClinic = [self.tableArrayCompany count];
            //            NSInteger countOfAnjoman = [self.tableArrayMozoee count];
            
            /*
             clinic->company
             anjoman->mozoee
             mataleb->projects
             safahatMozoee->tags
             pezeshkan->user
             */
            
            NSDictionary *tempDic = [[NSDictionary alloc]initWithDictionary:(NSDictionary *)responseObject];//(NSDictionary *)responseObject;
            for (NSDictionary *post in [[tempDic objectForKey:@"data"]objectForKey:@"post"]) {
                [self.tableArrayPost addObject:post];
            }
            
            for (NSDictionary *post in [[tempDic objectForKey:@"data"]objectForKey:@"project"]) {
                [self.tableArrayProject addObject:post];
            }
            
            for (NSDictionary *post in [[tempDic objectForKey:@"data"] objectForKey:@"profile"]) {
                [self.tableArrayUser addObject:post];
            }
            
            for (NSDictionary *post in [[tempDic objectForKey:@"data"]objectForKey:@"tag"]) {
                [self.tableArrayTag addObject:post];
            }
            
            for (NSDictionary *post in [[tempDic objectForKey:@"data"]objectForKey:@"company"]) {
                [self.tableArrayCompany addObject:post];
            }
            
            for (NSDictionary *post in [[tempDic objectForKey:@"data"]objectForKey:@"topic"]) {
                [self.tableArrayMozoee addObject:post];
            }
            
            [searchPostLabel removeFromSuperview];
            [searchTagLabel removeFromSuperview];
            [searchUserLabel removeFromSuperview];
            [searchCompanyLabel removeFromSuperview];
            [searchMozoeeLabel removeFromSuperview];
            [searchProjectLabel removeFromSuperview];
            
            [noResultLabelPost removeFromSuperview];
            [noResultLabelUser removeFromSuperview];
            [noResultLabelProject removeFromSuperview];
            [noResultLabelCompany removeFromSuperview];
            [noResultLabelMozoee removeFromSuperview];
            [noResultLabelTag removeFromSuperview];
            
            if ([self.tableArrayPost count] == 0) {
                noResultLabelPost = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 220, 10, 200,  25)];
                noResultLabelPost.font = FONT_MEDIUM(13);
                noResultLabelPost.text = NSLocalizedString(@"noContent", @"");
                noResultLabelPost.minimumScaleFactor = 0.7;
                noResultLabelPost.textColor = [UIColor blackColor];
                noResultLabelPost.textAlignment = NSTextAlignmentRight;
                noResultLabelPost.adjustsFontSizeToFitWidth = YES;
                [self.tableViewPost addSubview:noResultLabelPost];
            }
            
            if ([self.tableArrayUser count] == 0) {
                noResultLabelUser = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 220, 10, 200,  25)];
                noResultLabelUser.font = FONT_MEDIUM(13);
                noResultLabelUser.text = NSLocalizedString(@"noResult", @"");
                noResultLabelUser.minimumScaleFactor = 0.7;
                noResultLabelUser.textColor = [UIColor blackColor];
                noResultLabelUser.textAlignment = NSTextAlignmentRight;
                noResultLabelUser.adjustsFontSizeToFitWidth = YES;
                [self.tableViewUser addSubview:noResultLabelUser];
            }
            
            if ([self.tableArrayProject count] == 0) {
                noResultLabelProject = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 220, 10, 200,  25)];
                noResultLabelProject.font = FONT_MEDIUM(13);
                noResultLabelProject.text = NSLocalizedString(@"noResult", @"");
                noResultLabelProject.minimumScaleFactor = 0.7;
                noResultLabelProject.textColor = [UIColor blackColor];
                noResultLabelProject.textAlignment = NSTextAlignmentRight;
                noResultLabelProject.adjustsFontSizeToFitWidth = YES;
                [self.tableViewProject addSubview:noResultLabelProject];
            }
            
            if ([self.tableArrayCompany count] == 0) {
                noResultLabelCompany = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 220, 10, 200,  25)];
                noResultLabelCompany.font = FONT_MEDIUM(13);
                noResultLabelCompany.text = NSLocalizedString(@"noResult", @"");
                noResultLabelCompany.minimumScaleFactor = 0.7;
                noResultLabelCompany.textColor = [UIColor blackColor];
                noResultLabelCompany.textAlignment = NSTextAlignmentRight;
                noResultLabelCompany.adjustsFontSizeToFitWidth = YES;
                [self.tableViewCompany addSubview:noResultLabelCompany];
            }
            
            if ([self.tableArrayMozoee count] == 0) {
                noResultLabelMozoee = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 220, 10, 200,  25)];
                noResultLabelMozoee.font = FONT_MEDIUM(13);
                noResultLabelMozoee.text = NSLocalizedString(@"noResult", @"");
                noResultLabelMozoee.minimumScaleFactor = 0.7;
                noResultLabelMozoee.textColor = [UIColor blackColor];
                noResultLabelMozoee.textAlignment = NSTextAlignmentRight;
                noResultLabelMozoee.adjustsFontSizeToFitWidth = YES;
                [self.tableViewMozoee addSubview:noResultLabelMozoee];
            }
            
            if ([self.tableArrayTag count] == 0) {
                noResultLabelTag = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 220, 10, 200,  25)];
                noResultLabelTag.font = FONT_MEDIUM(13);
                noResultLabelTag.text = NSLocalizedString(@"noResult", @"");
                noResultLabelTag.minimumScaleFactor = 0.7;
                noResultLabelTag.textColor = [UIColor blackColor];
                noResultLabelTag.textAlignment = NSTextAlignmentRight;
                noResultLabelTag.adjustsFontSizeToFitWidth = YES;
                [self.tableViewTag addSubview:noResultLabelTag];
            }
            
            
            [ProgressHUD dismiss];
            isBusyNow = NO;
            
            //delete duplicate data from Array
            NSMutableArray *filteredArray = [[[[NSOrderedSet alloc] initWithArray:self.tableArrayProject] array] mutableCopy];
            self.tableArrayProject = [[NSMutableArray alloc]initWithArray:filteredArray];
            
            NSMutableArray *filteredArray2 = [[[[NSOrderedSet alloc] initWithArray:self.tableArrayUser] array] mutableCopy];
            self.tableArrayUser = [[NSMutableArray alloc]initWithArray:filteredArray2];
            
            NSMutableArray *filteredArray3 = [[[[NSOrderedSet alloc] initWithArray:self.tableArrayTag] array] mutableCopy];
            self.tableArrayTag = [[NSMutableArray alloc]initWithArray:filteredArray3];
            
            NSMutableArray *filteredArray4 = [[[[NSOrderedSet alloc] initWithArray:self.tableArrayCompany] array] mutableCopy];
            self.tableArrayCompany = [[NSMutableArray alloc]initWithArray:filteredArray4];
            
            NSMutableArray *filteredArray5 = [[[[NSOrderedSet alloc] initWithArray:self.tableArrayMozoee] array] mutableCopy];
            self.tableArrayMozoee = [[NSMutableArray alloc]initWithArray:filteredArray5];
            
            NSMutableArray *filteredArray6 = [[[[NSOrderedSet alloc] initWithArray:self.tableArrayPost] array] mutableCopy];
            self.tableArrayPost = [[NSMutableArray alloc]initWithArray:filteredArray6];
            
            [self.tableViewPost reloadData];
            [self.tableViewProject reloadData];
            [self.tableViewUser reloadData];
            [self.tableViewTag reloadData];
            [self.tableViewCompany reloadData];
            [self.tableViewMozoee reloadData];
            
            /*
             if (offsetProject > 0 && [[tempDic objectForKey:@"Post"]count] > 0 && countOfMatalbs > 0) {
             [self.tableViewProject scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:countOfMatalbs-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
             }else{
             if (countOfMatalbs == 0 && [self.tableArrayProject count] > 0) {
             [self.tableViewProject scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
             }
             }
             
             if (offsetUser > 0 && [[tempDic objectForKey:@"Doctor"]count] > 0 && countOfDoctors > 0) {
             [self.tableViewUser scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:countOfDoctors-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
             }else{
             if (countOfDoctors && [self.tableArrayUser count] > 0) {
             [self.tableViewUser scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
             }
             }
             
             if (offsetTag > 0 && [[tempDic objectForKey:@"TopicPage"]count] > 0 && countOfSafahatMozoee > 0) {
             [self.tableViewTag scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:countOfSafahatMozoee-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
             }else{
             if (countOfSafahatMozoee && [self.tableArrayTag count] > 0) {
             [self.tableViewTag scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
             }
             }
             
             if (offsetCompany > 0 && [[tempDic objectForKey:@"Clinic"]count] > 0 && countOfClinic > 0) {
             [self.tableViewCompany scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:countOfClinic-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
             }else{
             if (countOfClinic && [self.tableArrayCompany count] > 0) {
             [self.tableViewCompany scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
             }
             }
             
             if (offsetMozoee > 0 && [[tempDic objectForKey:@"Community"]count] > 0 && countOfAnjoman > 0) {
             [self.tableViewMozoee scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:countOfAnjoman-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
             }else{
             if (countOfAnjoman && [self.tableArrayMozoee count] > 0) {
             [self.tableViewMozoee scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
             }
             }
             */
            
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            [ProgressHUD dismiss];
            
            isBusyNow = NO;
        }];
    }
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
                
                [self.tableViewProject reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idOfRow inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                
                
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
                [self.tableViewProject reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idOfRow inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                
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
            NSDictionary *landingPageDic = [self.tableArrayProject objectAtIndex:idOfRow];
            NSMutableDictionary *landingPageDic2 = [[NSMutableDictionary alloc]initWithDictionary:landingPageDic];
            NSInteger likes = landingPageDic2.LPLikes_count;
            likes--;
            [landingPageDic2 setObject:[NSString stringWithFormat:@"%ld", (long)likes] forKey:@"likesCount"];
            [landingPageDic2 setObject:[NSString stringWithFormat:[NSString stringWithFormat:@"%d", 0], likes] forKey:@"liked"];
            [self.tableArrayProject replaceObjectAtIndex:idOfRow withObject:landingPageDic2];
            [self.tableViewProject reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idOfRow inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            
            //
            [Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:[NSString stringWithFormat:@"%ld", (long)likes] field:@"liked" postId:idOfPost];
            [self.tableViewProject reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idOfRow inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
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
            [self.tableViewProject reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idOfRow inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
        
    }];
}

-(void)followUnfollowUserConnection:(NSInteger)profileId withdic:(NSDictionary *)dic
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
        
        NSDictionary *resDic = responseObject;
        if ([[resDic objectForKey:@"success"]integerValue] == 1) {
            NSInteger row = [self.tableArrayUser indexOfObject:dic];
            NSDictionary *searchDic = [self.tableArrayUser objectAtIndex:row];
            
            if ([searchDic.LPFollow isEqualToString:@"not_followed"]) {
                NSMutableDictionary *tempDic = [[NSMutableDictionary alloc]initWithDictionary:searchDic];
                [tempDic setObject:@"pending_approve" forKey:@"follow"];
                [self.tableArrayUser replaceObjectAtIndex:row withObject:tempDic];
                
            } else if ([searchDic.LPFollow isEqualToString:@"followed"]){
                NSMutableDictionary *tempDic = [[NSMutableDictionary alloc]initWithDictionary:searchDic];
                [tempDic setObject:@"not_followed" forKey:@"follow"];
                [self.tableArrayUser replaceObjectAtIndex:row withObject:tempDic];
                
            }else if ([searchDic.LPFollow isEqualToString:@"pending_approve"]){
                NSMutableDictionary *tempDic = [[NSMutableDictionary alloc]initWithDictionary:searchDic];
                [tempDic setObject:@"not_followed" forKey:@"follow"];
                [self.tableArrayUser replaceObjectAtIndex:row withObject:tempDic];
            }
            
            NSIndexPath *indexpath = [NSIndexPath indexPathForRow:row inSection:0];
            [self.tableViewUser reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationNone];
        }
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[resDic objectForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
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

-(void)followUnfollowProjConnection:(NSInteger)profileId withdic:(NSDictionary *)dic
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
        
        NSDictionary *resDic = responseObject;
        if ([[resDic objectForKey:@"success"]integerValue] == 1) {
            NSInteger row = [self.tableArrayProject indexOfObject:dic];
            NSDictionary *searchDic = [self.tableArrayProject objectAtIndex:row];
            
            if ([searchDic.LPFollow isEqualToString:@"not_followed"]) {
                NSMutableDictionary *tempDic = [[NSMutableDictionary alloc]initWithDictionary:searchDic];
                [tempDic setObject:@"pending_approve" forKey:@"follow"];
                [self.tableArrayProject replaceObjectAtIndex:row withObject:tempDic];
                
            } else if ([searchDic.LPFollow isEqualToString:@"followed"]){
                NSMutableDictionary *tempDic = [[NSMutableDictionary alloc]initWithDictionary:searchDic];
                [tempDic setObject:@"not_followed" forKey:@"follow"];
                [self.tableArrayProject replaceObjectAtIndex:row withObject:tempDic];
                
            }else if ([searchDic.LPFollow isEqualToString:@"pending_approve"]){
                NSMutableDictionary *tempDic = [[NSMutableDictionary alloc]initWithDictionary:searchDic];
                [tempDic setObject:@"not_followed" forKey:@"follow"];
                [self.tableArrayProject replaceObjectAtIndex:row withObject:tempDic];
            }
            
            NSIndexPath *indexpath = [NSIndexPath indexPathForRow:row inSection:0];
            [self.tableViewProject reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationNone];
        }
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[resDic objectForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
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


-(void)followUnfollowCompanyConnection:(NSInteger)profileId withdic:(NSDictionary *)dic
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
        
        NSDictionary *resDic = responseObject;
        if ([[resDic objectForKey:@"success"]integerValue] == 1) {
            NSInteger row = [self.tableArrayCompany indexOfObject:dic];
            NSDictionary *searchDic = [self.tableArrayCompany objectAtIndex:row];
            
            if ([searchDic.LPFollow isEqualToString:@"not_followed"]) {
                NSMutableDictionary *tempDic = [[NSMutableDictionary alloc]initWithDictionary:searchDic];
                [tempDic setObject:@"pending_approve" forKey:@"follow"];
                [self.tableArrayCompany replaceObjectAtIndex:row withObject:tempDic];
                
            } else if ([searchDic.LPFollow isEqualToString:@"followed"]){
                NSMutableDictionary *tempDic = [[NSMutableDictionary alloc]initWithDictionary:searchDic];
                [tempDic setObject:@"not_followed" forKey:@"follow"];
                [self.tableArrayCompany replaceObjectAtIndex:row withObject:tempDic];
                
            }else if ([searchDic.LPFollow isEqualToString:@"pending_approve"]){
                NSMutableDictionary *tempDic = [[NSMutableDictionary alloc]initWithDictionary:searchDic];
                [tempDic setObject:@"not_followed" forKey:@"follow"];
                [self.tableArrayCompany replaceObjectAtIndex:row withObject:tempDic];
            }
            
            NSIndexPath *indexpath = [NSIndexPath indexPathForRow:row inSection:0];
            [self.tableViewCompany reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationNone];
        }
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[resDic objectForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
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

-(void)followUnfollowMozoeeConnection:(NSInteger)profileId withdic:(NSDictionary *)dic
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
        
        NSDictionary *resDic = responseObject;
        if ([[resDic objectForKey:@"success"]integerValue] == 1) {
            NSInteger row = [self.tableArrayMozoee indexOfObject:dic];
            NSDictionary *searchDic = [self.tableArrayMozoee objectAtIndex:row];
            NSMutableDictionary *tempDic = [[NSMutableDictionary alloc]initWithDictionary:searchDic];
            [tempDic setObject:[[resDic objectForKey:@"data"]objectForKey:@"follow_status"] forKey:@"follow"];
            
            if ([searchDic.LPFollow isEqualToString:@"not_followed"]) {
                
                [self.tableArrayMozoee replaceObjectAtIndex:row withObject:tempDic];
                
            } else if ([searchDic.LPFollow isEqualToString:@"followed"]){
                //NSMutableDictionary *tempDic = [[NSMutableDictionary alloc]initWithDictionary:searchDic];
                //[tempDic setObject:@"not_followed" forKey:@"follow"];
                [self.tableArrayMozoee replaceObjectAtIndex:row withObject:tempDic];
                
            }else if ([searchDic.LPFollow isEqualToString:@"pending_approve"]){
                //NSMutableDictionary *tempDic = [[NSMutableDictionary alloc]initWithDictionary:searchDic];
                //[tempDic setObject:@"not_followed" forKey:@"follow"];
                [self.tableArrayMozoee replaceObjectAtIndex:row withObject:tempDic];
            }
            
            NSIndexPath *indexpath = [NSIndexPath indexPathForRow:row inSection:0];
            [self.tableViewMozoee reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationNone];
        }
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[resDic objectForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
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

@end
