//
//  ViewController.m
//  MSN
//
//  Created by Yarima on 4/6/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "LandingPageViewController.h"
#import "Database.h"
#import <AFHTTPSessionManager.h>
#import <UIImageView+AFNetworking.h>
#import "Header.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import "KeychainWrapper.h"
#import "ProgressHUD.h"
#import "NSDictionary+LandingPage.h"
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
#define loadingCellTag  1273


@interface LandingPageViewController ()<UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, AVAudioPlayerDelegate, UIWebViewDelegate>
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
    //DACircularProgressView *largeProgressView;
    //double progressViewArray[1000];
    NSInteger page;
    NSInteger entityId;
}
@property(nonatomic, retain)UITableView *tableView;
@property(nonatomic, retain)NSMutableArray *tableArray;
@property(nonatomic, retain)NSMutableArray *likeArray;
@property(nonatomic, retain)NSMutableArray *favArray;
@property(nonatomic, strong)NSIndexPath *currentIndexPath;
@property (strong, nonatomic) NSTimer *timerForProgress;
@property (strong, nonatomic) NSTimer *timerForProgressFinal;
@end

@implementation LandingPageViewController
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
//http://docs.pushwoosh.com/docs/using-custom-data
- (void)showPromoPage:(NSString *)title imageURL:(NSString *)imageURL jsonData:(NSDictionary *)dataDic{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CustomPageViewController *view = (CustomPageViewController *)[story instantiateViewControllerWithIdentifier:@"CustomPageViewController"];
    view.bgColor = [UIColor whiteColor];
    view.titleStr = title;
    view.imageURL = imageURL;
    view.jsonData = dataDic;
    [self.navigationController pushViewController:view animated:YES];
    /*
    view.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    if (self.presentedViewController) {
        [self dismissViewControllerAnimated:YES
                                 completion:^{
                                     [self presentViewController:view animated:YES completion:nil];
                                 }];
    } else {
        [self presentViewController:view animated:YES completion:nil];
    }
     */
}

//user pressed OK on the push notification


- (void)viewWillAppear:(BOOL)animated {
    [self populateTableViewArray];
    disableTableView = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    self.tableView.userInteractionEnabled = YES;
}
- (void)viewDidLoad{
    self.navigationController.navigationBar.hidden = YES;
    
    //page for request
    page = 0;
    
    //entity id for request
    entityId = 1;

    [super viewWillAppear:YES];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"isFirstRun"];
    selectedRow = 1000;
    isBusyNow = NO;
    isPagingForCategories = NO;
    noMoreData = NO;
    self.tableArray = [[NSMutableArray alloc]init];
    self.likeArray = [[NSMutableArray alloc]init];
    self.favArray = [[NSMutableArray alloc]init];
    //make View
    [self makeTopBar];
    [self makeTableViewWithYpos:70];
    [self populateTableViewArray];
    NSString *devToken = [[NSUserDefaults standardUserDefaults]objectForKey:@"deviceToken"];
    if ([devToken length] > 10) {
        [self registerUserDeviceTokenOnServer];
    }
    //[self getNotificationsFromServer];
    
    //NSLog(@"self.navigationControllers: %@", [self.navigationController viewControllers]);
    
    NSDictionary *userpassDic = [GetUsernamePassword getUsernamePassword];
    NSString *username = [userpassDic objectForKey:@"username"];
    NSString *password = [userpassDic objectForKey:@"password"];
    if ([username length] == 0 || [password length] == 0) {
        [self pushToLoginView];
    }
    
    NSString *customDataString = [[NSUserDefaults standardUserDefaults]objectForKey:@"customDataStringFromPushWoosh"];
    if ([customDataString length] > 5) {
        NSDictionary *jsonData = nil;
            jsonData = [NSJSONSerialization JSONObjectWithData:[customDataString dataUsingEncoding:NSUTF8StringEncoding]
                                                       options:NSJSONReadingMutableContainers error:nil];
        sleep(2);
        [self showPromoPage:[jsonData objectForKey:@"text"] imageURL:[jsonData objectForKey:@"image_url"] jsonData:jsonData];
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
    titleLabel.font = FONT_NORMAL(20);
    titleLabel.text = NSLocalizedString(@"home", @"");
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
    
    //45x69
    UIButton *searchButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - 100, topViewHeight/2 - 10, 54 *0.4, 69 * 0.4)];
    [searchButton setBackgroundImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(searchButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:searchButton];
    
    //232 × 192
    categoryButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 232 * topViewHeight/232, 192 * topViewHeight/192)];
    [categoryButton setBackgroundImage:[UIImage imageNamed:@"daste bandi"] forState:UIControlStateNormal];
    [categoryButton addTarget:self action:@selector(categoryButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:categoryButton];
    categoryButton.userInteractionEnabled = NO;
    
}
- (void)makeTableViewWithYpos:(CGFloat )yPos{
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, yPos, screenWidth, screenHeight - yPos)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    //make menu items and view
    menuView = [[UIView alloc]initWithFrame:CGRectMake(0, 70, screenWidth ,0)];
    menuView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:menuView];
    menuScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(menuView.frame.origin.x, 0, menuView.frame.size.width, menuView.frame.size.height)];
    [menuView addSubview:menuScrollView];
    selectImageView = [[UIImageView alloc]initWithFrame:CGRectMake(menuView.frame.size.width - 40, 40, 25, 25)];
    selectImageView.image = [UIImage imageNamed:@"following.png"];
    [menuScrollView addSubview:selectImageView];
    
    UIButton *newQuestionButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - 90, screenHeight - 90, 80, 80)];
    [newQuestionButton addTarget:self action:@selector(newQuestionButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [newQuestionButton setBackgroundImage:[UIImage imageNamed:@"Porsesh"] forState:UIControlStateNormal];
    [self.view addSubview:newQuestionButton];
}

- (void)newQuestionButtonAction{
    if (![self hasConnectivity]) {
         
    } else {
        NSString *isnotLoggedIn = [[NSUserDefaults standardUserDefaults]objectForKey:@"isNotLoggedin"];
        if ([isnotLoggedIn length] > 0) {
            //[[NSUserDefaults standardUserDefaults]removeObjectForKey:@"isNotLoggedin"];
            [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"isPasswordChanged"];
            
            [self pushToLoginView];
        } else {
            //[[NSNotificationCenter defaultCenter]postNotificationName:@"GoToConsultationViewFromLandingPageDirectly" object:nil];
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ConsultationListViewController *view = (ConsultationListViewController *)[story instantiateViewControllerWithIdentifier:@"ConsultationListViewController"];
            [self.navigationController pushViewController:view animated:YES];
        }
    }
    
    //if ([questionCountButton.titleLabel.text integerValue] > 0) {
    //    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //    ConsultationListViewController *view = (ConsultationListViewController *)[story instantiateViewControllerWithIdentifier:@"ConsultationListViewController"];
    //view.isNewQuestion = YES;
    //[self.navigationController pushViewController:view animated:YES];
    
    //    } else {
    //        //
        //
        //
        // = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"newConsultation", @"")
    //                                                            message:NSLocalizedString(@"NoCredit", @"")
    //                                                           delegate:nil
    //                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
    //        //
    //
    //    }
    
}

- (IntroViewController *)IntroViewController{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    IntroViewController *view = (IntroViewController *)[story instantiateViewControllerWithIdentifier:@"IntroViewController"];
    return view;
}
- (void)pushToLoginView{
    [self presentViewController:[self IntroViewController] animated:YES completion:nil];
}

- (void)refreshTable{
    if ([self.tableArray count] > 0) {
        NSDictionary *landingPageDic = [self.tableArray objectAtIndex:0];
        NSInteger dateNumber = [landingPageDic.LPTVPublish_date integerValue];
        dateNumber += 1;
        
        if ([self hasConnectivity]) {
            [self performSelectorOnMainThread:@selector(showProgressHUD) withObject:nil waitUntilDone:NO];
            //[self fetchPostsFromServerWithRequest:@"new" WithDate:[NSString stringWithFormat:@"%ld", (long)dateNumber]];
            [self fetchPostsFromServerWithEntityId:entityId page:page];
        } else {
            [refreshControl endRefreshing];
             
        }
    }else{
        if ([self hasConnectivity]) {
            self.tableArray = [[NSMutableArray alloc]init];
            [self performSelectorOnMainThread:@selector(showProgressHUD) withObject:nil waitUntilDone:NO];
            //[self fetchPostsFromServerWithRequest:@"new" WithDate:@""];
            [self fetchPostsFromServerWithEntityId:entityId page:page];
        } else {
            [refreshControl endRefreshing];
             
        }
        
    }
    
}

- (void)populateTableViewArray{
    
    //datebase
    [Database initDB];
    self.tableArray = [[NSMutableArray alloc]init];
    //self.tableView.dataSource = nil;
    NSArray *array = [Database selectFromLandingPageWithFilePath:[Database getDbFilePath]];
    if ([array count] > 0) {
        //NSMutableArray *tagsArray = [[NSMutableArray alloc]init];
        //NSArray *nameArray = [[NSArray alloc]init];
        for (NSDictionary *dic in array) {
            //NSString *str = [dic objectForKey:@"tags"];
            //NSArray *idArray = [str componentsSeparatedByString:@","];
            //nameArray = [str componentsSeparatedByString:@",,,"];
            [self.tableArray addObject:dic];
        }
        [self.tableView reloadData];
        NSString *selectedRowFromPush = [[NSUserDefaults standardUserDefaults]objectForKey:@"selectedRow"];
        if ([selectedRowFromPush length] > 0) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[selectedRowFromPush integerValue] inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"selectedRow"];
        }
        self.tableView.scrollsToTop = YES;
        NSString *isFirstRun = [[NSUserDefaults standardUserDefaults]objectForKey:@"isFirstRun"];
        if ([isFirstRun length] == 0) {
            if ([self hasConnectivity]) {
                //[self performSelectorOnMainThread:@selector(showProgressHUD) withObject:nil waitUntilDone:NO];
                NSString *categoryId = [[NSUserDefaults standardUserDefaults]objectForKey:@"categoryId"];
                if ([categoryId length] > 0) {
                    //[self fetchPostsFromServerWithCategory:categoryId WithRequest:@"" WithDate:@""];
                    [self fetchPostsFromServerWithEntityId:entityId page:page];
                } else {
                    //[self fetchPostsFromServerWithRequest:@"" WithDate:@""];
                    [self fetchPostsFromServerWithEntityId:entityId page:page];
                }
            } else {
            }
        }else{
            [self.tableView reloadData];
            self.tableView.scrollsToTop = YES;
        }
    }else{
        if ([self hasConnectivity]) {
            [self performSelectorOnMainThread:@selector(showProgressHUD) withObject:nil waitUntilDone:NO];
            //[self fetchPostsFromServerWithRequest:@"new" WithDate:@""];
            [self fetchPostsFromServerWithEntityId:entityId page:page];
        } else {
             
        }
    }
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)showProgressHUD {
    //[ProgressHUD show:NSLocalizedString(@"retrievingdata", @"") Interaction:NO];
}

- (void)menuButtonAction {
    //[self showHideRightMenu];
    disableTableView = !disableTableView;
    self.tableView.userInteractionEnabled = disableTableView;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"toggleMenuVisibility" object:nil];
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

- (void)categoryButtonAction {
    
    [self openCloseMenu];
}

- (CGFloat)getHeightOfString:(NSString *)labelText{
    
    UIFont *font = FONT_NORMAL(16);
    if (IS_IPAD) {
        font = FONT_NORMAL(26);
    }
    CGSize sizeOfText = [labelText boundingRectWithSize: CGSizeMake(self.view.bounds.size.width - 30, CGFLOAT_MAX)
                                                options: (NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                             attributes: [NSDictionary dictionaryWithObject:font
                                                                                     forKey:NSFontAttributeName]
                                                context: nil].size;
    CGFloat height = sizeOfText.height + 50;
    if (height < screenWidth + 10)
        height = screenWidth + 10;
    return height;
    
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
    NSDictionary *tempDic = [[NSDictionary alloc]initWithObjectsAndKeys:landingPageDic.LPTVPostID, @"id", [NSNumber numberWithInteger:btn.tag], @"index", nil];
    [_favArray addObject:tempDic];
    [self favOnServerWithID:landingPageDic.LPTVPostID];
    
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
    NSDictionary *tempDic = [[NSDictionary alloc]initWithObjectsAndKeys:landingPageDic2.LPTVPostID, @"id", [NSNumber numberWithInteger:btn.tag], @"index", nil];
    [_likeArray addObject:tempDic];
    [self likeOnServerWithID:landingPageDic2.LPTVPostID];
    
    NSInteger likes = [landingPageDic2.LPTVLikes_count integerValue];
    if ([landingPageDic2.LPTVLiked integerValue] == 0) {
        likes++;
        [landingPageDic2 setObject:[NSString stringWithFormat:[NSString stringWithFormat:@"%d", 1], likes] forKey:@"liked"];
        //[Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:@"1" field:@"liked" postId:landingPageDic2.LPTVPostID];
        
    }else{
        likes--;
        [landingPageDic2 setObject:[NSString stringWithFormat:[NSString stringWithFormat:@"%d", 0], likes] forKey:@"liked"];
        //[Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:@"1" field:@"liked" postId:landingPageDic2.LPTVPostID];
        
    }
    
    [landingPageDic2 setObject:[NSString stringWithFormat:@"%ld", (long)likes] forKey:@"likesCount"];
    //[Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:[NSString stringWithFormat:@"%@", [[tempDic objectForKey:@"data"] objectForKey:@"count"]] field:@"likes_count" postId:landingPageDic2.LPTVPostID];
    
    [self.tableArray replaceObjectAtIndex:btn.tag withObject:landingPageDic2];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:btn.tag inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)rollbackLikeButtonActionForIndexPath:(NSIndexPath *)indexpath{
    LandingPageCustomCell *cell = (LandingPageCustomCell *)[self.tableView cellForRowAtIndexPath:indexpath];
    UIButton *btn = cell.heartButton;
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
    
    NSInteger likes = [landingPageDic2.LPTVLikes_count integerValue];
    if ([landingPageDic2.LPTVLiked integerValue] == 0) {
        likes++;
        [landingPageDic2 setObject:[NSString stringWithFormat:[NSString stringWithFormat:@"%d", 1], likes] forKey:@"liked"];
        //[Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:@"1" field:@"liked" postId:landingPageDic2.LPTVPostID];
        
    }else{
        likes--;
        [landingPageDic2 setObject:[NSString stringWithFormat:[NSString stringWithFormat:@"%d", 0], likes] forKey:@"liked"];
        //[Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:@"1" field:@"liked" postId:landingPageDic2.LPTVPostID];
        
    }
    
    [landingPageDic2 setObject:[NSString stringWithFormat:@"%ld", (long)likes] forKey:@"likesCount"];
    //[Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:[NSString stringWithFormat:@"%@", [[tempDic objectForKey:@"data"] objectForKey:@"count"]] field:@"likes_count" postId:landingPageDic2.LPTVPostID];
    
    [self.tableArray replaceObjectAtIndex:btn.tag withObject:landingPageDic2];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:btn.tag inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)shareButtonAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    
    NSDictionary *landingPageDic = [self.tableArray objectAtIndex:btn.tag];
    
    NSString *textToShare = landingPageDic.LPTVTitle;
    NSString *textToShare2 = landingPageDic.LPTVContent;
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
    NSDictionary *tempDic = [self.tableArray objectAtIndex:tap.view.tag];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DoctorPageViewController *view = (DoctorPageViewController *)[story instantiateViewControllerWithIdentifier:@"DoctorPageViewController"];
    view.userEntityId = tempDic.LPTVUserEntityId;
    view.userTitle = tempDic.LPTVUserTitle;
    view.userJobTitle = tempDic.LPTVUserJobTitle;
    view.userAvatar = tempDic.LPTVUserAvatarUrl;
    [self.navigationController pushViewController:view animated:YES];
    [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%ld", (long)tap.view.tag] forKey:@"selectedRow"];
}

- (void)saveImageIntoDocumetsWithImage:(UIImage*)image withName:(NSString*)imageName{
    NSData *imageData = UIImagePNGRepresentation(image); //convert image into .png format.
    NSFileManager *fileManager = [NSFileManager defaultManager];//create instance of NSFileManager
    NSString *appDocumentsDirectory = [DocumentDirectoy getDocuementsDirectory];
    NSString *fullPath = [appDocumentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", imageName]]; //add our image to the path
    BOOL resultSave = [fileManager createFileAtPath:fullPath contents:imageData attributes:nil]; //finally save the path (image)
    if (resultSave) {
        ////NSLog(@"image saved");
    } else {
        ////NSLog(@"error saving image");
    }
}

- (UIImage *)loadImageFilesWithName:(NSString *)imageName{
    documentsDirectory = [DocumentDirectoy getDocuementsDirectory];
    
    UIImageView *tempImageView = [[UIImageView alloc]init];
    tempImageView.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", documentsDirectory, imageName]];
    return tempImageView.image;
}

- (void)drawCircleOnView:(UIView *)aView withRadius:(NSInteger)radius{
    //int radius = 100;
    CAShapeLayer *circle = [CAShapeLayer layer];
    // Make a circular shape
    circle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*radius, 2.0*radius)
                                             cornerRadius:radius].CGPath;
    // Center the shape in self.view
    circle.position = CGPointMake(CGRectGetMidX(self.view.frame)-radius,
                                  CGRectGetMidY(self.view.frame)-radius);
    
    // Configure the apperence of the circle
    circle.fillColor = [UIColor clearColor].CGColor;
    circle.strokeColor = [UIColor blackColor].CGColor;
    circle.lineWidth = 5;
    
    // Add to parent layer
    [aView.layer addSublayer:circle];
    
    // Configure animation
    CABasicAnimation *drawAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    drawAnimation.duration            = 10.0; // "animate over 10 seconds or so.."
    drawAnimation.repeatCount         = 1.0;  // Animate only once..
    
    // Animate from no part of the stroke being drawn to the entire stroke being drawn
    drawAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    drawAnimation.toValue   = [NSNumber numberWithFloat:1.0f];
    
    // Experiment with timing to get the appearence to look the way you want
    drawAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    // Add the animation to the circle
    [circle addAnimation:drawAnimation forKey:@"drawCircleAnimation"];
}

- (void)downloadPlayButtonAction:(UITapGestureRecognizer *)sender{
    if (!isDownloadingAudio) {
        isDownloadingAudio = !isDownloadingAudio;
        isDownloadingVideo = NO;
        whichRowShouldBeReload = sender.view.tag;
        [self startAnimationProgress];
        NSDictionary *tempDic = [self.tableArray objectAtIndex:sender.view.tag];
        NSString *fileUrl;
        NSString *fileName;
        if ([tempDic.LPTVPostType isEqualToString:@"audio"]) {
            fileUrl = tempDic.LPTVAudioUrl;
        } else if ([tempDic.LPTVPostType isEqualToString:@"video"]){
            fileUrl = tempDic.LPTVVideoUrl;
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
        
    } else {
        isDownloadingAudio = !isDownloadingAudio;
        isDownloadingVideo = NO;
    }
    
}

- (void)downloadPlayButtonActionVideo:(id)sender{
    if (!isDownloadingVideo) {
        isDownloadingVideo = !isDownloadingVideo;
        isDownloadingAudio = NO;
        UIButton *btn = (UIButton *)sender;
        whichRowShouldBeReload = btn.tag;
        [self startAnimationProgress];
        NSDictionary *tempDic = [self.tableArray objectAtIndex:btn.tag];
        NSString *fileUrl;
        NSString *fileName;
        if ([tempDic.LPTVPostType isEqualToString:@"audio"]) {
            fileUrl = tempDic.LPTVAudioUrl;
        } else if ([tempDic.LPTVPostType isEqualToString:@"video"]){
            fileUrl = tempDic.LPTVVideoUrl;
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
    } else {
        isDownloadingVideo = !isDownloadingVideo;
        isDownloadingAudio = NO;
    }
}


#pragma mark - progress view for download
- (void)startAnimationProgress
{
    _timerForProgress = [NSTimer scheduledTimerWithTimeInterval:0.03
                                                         target:self
                                                       selector:@selector(progressChange)
                                                       userInfo:nil
                                                        repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timerForProgress forMode:NSRunLoopCommonModes];
}
- (void)progressChange
{
    if (!isDownloadingAudio || !isDownloadingVideo) {
        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:whichRowShouldBeReload inSection:0];
        LandingPageCustomCellAudio *cell = (LandingPageCustomCellAudio *)[self.tableView cellForRowAtIndexPath:indexpath];
        if ([cell isKindOfClass:[LandingPageCustomCellAudio class]] ||
            [cell isKindOfClass:[LandingPageCustomCellVideo class]]) {
            CGFloat progress = cell.largeProgressView.progress + 0.0001f;
            [cell.largeProgressView setProgress:progress animated:YES];
            if (cell.largeProgressView.progress >= 1.0f && [_timerForProgress isValid]) {
                //[progressView setProgress:0.f animated:YES];
                [self stopAnimationProgress];
            }
        }
        
    } else {
        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:whichRowShouldBeReload inSection:0];
        LandingPageCustomCellAudio *cell = (LandingPageCustomCellAudio *)[self.tableView cellForRowAtIndexPath:indexpath];
        if ([cell isKindOfClass:[LandingPageCustomCellAudio class]] ||
            [cell isKindOfClass:[LandingPageCustomCellVideo class]]) {
            CGFloat progress = cell.largeProgressView.progress - 0.0001f;
            [cell.largeProgressView setProgress:progress animated:YES];
            if (cell.largeProgressView.progress <= 0) {
                [cell.largeProgressView setProgress:0.f animated:YES];
                [self stopAnimationProgress];
            }
        }
        
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
    if (!isDownloadingAudio || !isDownloadingVideo) {
        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:whichRowShouldBeReload inSection:0];
        LandingPageCustomCellAudio *cell = (LandingPageCustomCellAudio *)[self.tableView cellForRowAtIndexPath:indexpath];
        if ([cell isKindOfClass:[LandingPageCustomCellAudio class]] ||
            [cell isKindOfClass:[LandingPageCustomCellVideo class]]) {
            CGFloat progress = cell.largeProgressView.progress + 0.01f;
            [cell.largeProgressView setProgress:progress animated:YES];
            
            if (cell.largeProgressView.progress >= 1.0f && [_timerForProgressFinal isValid]) {
                //[progressView setProgress:0.f animated:YES];
                [self stopAnimationProgressFinal];
                [self.tableView reloadData];
                isDownloadingVideo = NO;
                isDownloadingAudio = NO;
            }
        }
        
    } else {
        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:whichRowShouldBeReload inSection:0];
        LandingPageCustomCellAudio *cell = (LandingPageCustomCellAudio *)[self.tableView cellForRowAtIndexPath:indexpath];
        if ([cell isKindOfClass:[LandingPageCustomCellAudio class]] ||
            [cell isKindOfClass:[LandingPageCustomCellVideo class]]) {
            CGFloat progress = cell.largeProgressView.progress - 0.01f;
            [cell.largeProgressView setProgress:progress animated:YES];
            
            if (cell.largeProgressView.progress <= 0) {
                [cell.largeProgressView setProgress:0 animated:YES];
                [self stopAnimationProgressFinal];
                //[self.tableView reloadData];
            }
        }
        
    }
    
}
- (void)stopAnimationProgressFinal
{
    [_timerForProgressFinal invalidate];
    _timerForProgressFinal = nil;
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (IS_IPAD) {
        if (selectedRow == indexPath.row) {
            if (isExpand) {
                NSDictionary *landingPageDic = [self.tableArray objectAtIndex:indexPath.row];
                return [self getHeightOfString:landingPageDic.LPTVContent];
                
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
                return [self getHeightOfString:landingPageDic.LPTVContent];
                
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
    NSString *postType = landingPageDic.LPTVPostType;
    
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
                    cell.titleLabel.text = landingPageDic.LPTVTitle;
                    
                    //date
                    NSDateFormatter *currentDateFormatter = [[NSDateFormatter alloc]init];
                    [currentDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    NSDate *endDate = [NSDate date];
                    
                    double timestampval = [landingPageDic.LPTVPublish_date doubleValue];
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
                    NSString *pathOfAudio = [NSString stringWithFormat:@"%@/%@", documentPath, [landingPageDic.LPTVAudioUrl lastPathComponent]];
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
                    cell.categoryLabel.text = landingPageDic.LPTVCategoryName;
                    if ([cell.categoryLabel.text length] == 0) {
                        cell.categoryLabel.text = landingPageDic.LPCategoryName;
                    }
                    
                    //seen label
                    cell.commentCountLabel.text = landingPageDic.LPTVRecommends_count;
                    
                    //like label
                    cell.likeCountLabel.text = landingPageDic.LPTVLikes_count;
                    cell.likeCountLabel.tag = indexPath.row;
                    //author image
                    [cell.authorImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", landingPageDic.LPTVUserAvatarUrl]] placeholderImage:[UIImage imageNamed:@"icon upload ax"]];
                    cell.authorImageView.userInteractionEnabled = YES;
                    cell.authorImageView.tag = indexPath.row;
                    //UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]init];
                    //[tap addTarget:self action:@selector(tapOnAuthorImage:)];
                    //[cell.authorImageView addGestureRecognizer:tap];
                    
                    //author name
                    cell.authorNameLabel.text = landingPageDic.LPTVUserTitle;
                    
                    //author job title
                    cell.authorJobLabel.text = landingPageDic.LPTVUserJobTitle;
                    
                    //content
                    cell.contentLabel.text = landingPageDic.LPTVContent;
                    //cell.contentLabel.text = [[cell.contentLabel.text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
                    
                    if (selectedRow == indexPath.row) {
                        cell.commentImageView.image = [UIImage imageNamed:@"comment"];
                        CGRect rect = cell.contentLabel.frame;
                        rect.size.height = [self getHeightOfString:landingPageDic.LPTVContent];
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
                    
                    if ([landingPageDic.LPTVFavorite integerValue] == 0) {
                        [cell.favButton setImage:[UIImage imageNamed:@"fav off"] forState:UIControlStateNormal];
                    }else{
                        [cell.favButton setImage:[UIImage imageNamed:@"fav on"] forState:UIControlStateNormal];
                    }
                    
                    if ([landingPageDic.LPTVLiked integerValue] == 0) {
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
                    cell.titleLabel.text = landingPageDic.LPTVTitle;
                    
                    //date
                    NSDateFormatter *currentDateFormatter = [[NSDateFormatter alloc]init];
                    [currentDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    NSDate *endDate = [NSDate date];
                    
                    double timestampval = [landingPageDic.LPTVPublish_date doubleValue];
                    NSTimeInterval timestamp = (NSTimeInterval)timestampval;
                    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
                    cell.dateLabel.text = [NSString stringWithFormat:@"%@",
                                           [TimeAgoViewController timeIntervalWithStartDate:startDate withEndDate:endDate]];
                    
                    //post image
                    [cell.postImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", landingPageDic.LPTVImageUrl]] placeholderImage:[UIImage imageNamed:@"broken_image"]];
                    
                    //category
                    cell.categoryLabel.text = landingPageDic.LPTVCategoryName;
                    if ([cell.categoryLabel.text length] == 0) {
                        cell.categoryLabel.text = landingPageDic.LPCategoryName;
                    }
                    
                    //seen label
                    cell.commentCountLabel.text = landingPageDic.LPTVRecommends_count;
                    
                    //like label
                    cell.likeCountLabel.text = landingPageDic.LPTVLikes_count;
                    cell.likeCountLabel.tag = indexPath.row;
                    //author image
                    [cell.authorImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", landingPageDic.LPTVUserAvatarUrl]] placeholderImage:[UIImage imageNamed:@"icon upload ax"]];
                    cell.authorImageView.userInteractionEnabled = YES;
                    cell.authorImageView.tag = indexPath.row;
                    //UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]init];
                    //[tap addTarget:self action:@selector(tapOnAuthorImage:)];
                    //[cell.authorImageView addGestureRecognizer:tap];
                    
                    //author name
                    cell.authorNameLabel.text = landingPageDic.LPTVUserTitle;
                    
                    //author job title
                    cell.authorJobLabel.text = landingPageDic.LPTVUserJobTitle;
                    
                    //content
                    cell.contentLabel.text = landingPageDic.LPTVContent;
                    //cell.contentLabel.text = [[cell.contentLabel.text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
                    
                    if (selectedRow == indexPath.row) {
                        cell.commentImageView.image = [UIImage imageNamed:@"comment"];
                        CGRect rect = cell.contentLabel.frame;
                        rect.size.height = [self getHeightOfString:landingPageDic.LPTVContent];
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
                    
                    if ([landingPageDic.LPTVFavorite integerValue] == 0) {
                        [cell.favButton setImage:[UIImage imageNamed:@"fav off"] forState:UIControlStateNormal];
                    }else{
                        [cell.favButton setImage:[UIImage imageNamed:@"fav on"] forState:UIControlStateNormal];
                    }
                    
                    if ([landingPageDic.LPTVLiked integerValue] == 0) {
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
                    cell.titleLabel.text = landingPageDic.LPTVTitle;
                    
                    //date
                    NSDateFormatter *currentDateFormatter = [[NSDateFormatter alloc]init];
                    [currentDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    NSDate *endDate = [NSDate date];
                    
                    double timestampval = [landingPageDic.LPTVPublish_date doubleValue];
                    NSTimeInterval timestamp = (NSTimeInterval)timestampval;
                    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
                    cell.dateLabel.text = [NSString stringWithFormat:@"%@",
                                           [TimeAgoViewController timeIntervalWithStartDate:startDate withEndDate:endDate]];
                    
                    //post image
                    [cell.postImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", landingPageDic.LPTVImageUrl]] placeholderImage:[UIImage imageNamed:@"broken_image"]];
                    
                    //category
                    cell.categoryLabel.text = landingPageDic.LPTVCategoryName;
                    if ([cell.categoryLabel.text length] == 0) {
                        cell.categoryLabel.text = landingPageDic.LPCategoryName;
                    }
                    
                    //seen label
                    cell.commentCountLabel.text = landingPageDic.LPTVRecommends_count;
                    
                    //like label
                    cell.likeCountLabel.text = landingPageDic.LPTVLikes_count;
                    cell.likeCountLabel.tag = indexPath.row;
                    //author image
                    [cell.authorImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", landingPageDic.LPTVUserAvatarUrl]] placeholderImage:[UIImage imageNamed:@"icon upload ax"]];
                    cell.authorImageView.userInteractionEnabled = YES;
                    cell.authorImageView.tag = indexPath.row;
                    //UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]init];
                    //[tap addTarget:self action:@selector(tapOnAuthorImage:)];
                    //[cell.authorImageView addGestureRecognizer:tap];
                    
                    //author name
                    cell.authorNameLabel.text = landingPageDic.LPTVUserTitle;
                    
                    //author job title
                    cell.authorJobLabel.text = landingPageDic.LPTVUserJobTitle;
                    
                    //content
                    cell.contentLabel.text = landingPageDic.LPTVContent;
                    //cell.contentLabel.text = [[cell.contentLabel.text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
                    
//                    if (selectedRow == indexPath.row) {
//                        cell.commentImageView.image = [UIImage imageNamed:@"comment"];
//                        CGRect rect = cell.contentLabel.frame;
//                        rect.size.height = [self getHeightOfString:landingPageDic.LPTVContent];
//                        //rect.origin.y = cell.authorImageView.frame.origin.y - 100;
//                        if (rect.origin.y < cell.authorImageView.frame.origin.y) {
//                            rect.origin.y = cell.authorImageView.frame.origin.y;
//                        }
//                        [cell.contentLabel setFrame:rect];
//                        [cell.contentLabel sizeToFit];
//                    }else{
                        cell.commentImageView.image = [UIImage imageNamed:@"comment"];
//                    }
                    
                    cell.favButton.tag = indexPath.row;
                    [cell.favButton addTarget:self action:@selector(favButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                    
                    cell.heartButton.tag = indexPath.row;
                    [cell.heartButton addTarget:self action:@selector(likeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                    
                    cell.shareButton.tag = indexPath.row;
                    [cell.shareButton addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                    
                    if ([landingPageDic.LPTVFavorite integerValue] == 0) {
                        [cell.favButton setImage:[UIImage imageNamed:@"fav off"] forState:UIControlStateNormal];
                    }else{
                        [cell.favButton setImage:[UIImage imageNamed:@"fav on"] forState:UIControlStateNormal];
                    }
                    
                    if ([landingPageDic.LPTVLiked integerValue] == 0) {
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
    /*
    if ([self hasConnectivity]) {
        if (cell.tag == loadingCellTag) {
            NSDictionary *landingPageDic = [self.tableArray lastObject];
            NSInteger dateNumber = [landingPageDic.LPTVPublish_date integerValue];
            dateNumber -= 1;
            NSString *categoryId = [[NSUserDefaults standardUserDefaults]objectForKey:@"categoryId"];
            if ([categoryId length] > 0) {
                isPagingForCategories = YES;
                [self fetchPostsFromServerWithEntityId:entityId page:page];
            } else {
                isPagingForCategories = NO;
                [self fetchPostsFromServerWithEntityId:entityId page:page];
            }
        }
    }
    */
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

- (void)fetchPostsFromServerWithEntityId:(NSInteger)entityIdOf page:(NSInteger)pageOf{
    [ProgressHUD show:@""];
    NSDictionary *params = @{@"entity_id":[NSNumber numberWithInteger:entityIdOf],
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
        NSDictionary *resDic  =responseObject;
        if ([[resDic objectForKey:@"success"]integerValue] == 1) {
            
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
/*
- (void)fetchPostsFromServerWithRequest:(NSString *)request WithDate:(NSString *)date{
    NSDictionary *userpassDic = [GetUsernamePassword getUsernamePassword];
    NSDictionary *params;
    if ([userpassDic count] > 1) {
        //delete flag for Visit Without Login
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"VisitWithoutLogin"];
        
        params = @{@"username":[userpassDic objectForKey:@"username"],
                   @"password":[userpassDic objectForKey:@"password"],
                   @"request":request,
                   @"date":date,
                   @"unit_id":@"3"};
    }else{
        params = @{@"username":@"",
                   @"password":@"",
                   @"request":request,
                   @"date":date,
                   @"unit_id":@"3"};
        
    }
    
    //    KeychainWrapper *keychainWrapper = [[KeychainWrapper alloc]init];
    //    NSString *username = [keychainWrapper myObjectForKey:(__bridge id)(kSecAttrDescription)];
    //    NSString *password = [keychainWrapper myObjectForKey:(__bridge id)(kSecAttrService)];
    NSString *url = [NSString stringWithFormat:@"%@api/timeline", BaseURL];
    
    if (!isBusyNow) {
        isBusyNow = YES;
        [refreshControl endRefreshing];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        manager.requestSerializer.timeoutInterval = 45;
        [manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
            [ProgressHUD dismiss];
            noMoreData = NO;
            NSDictionary *tempDic = (NSDictionary *)responseObject;
            NSString *login =  [tempDic objectForKey:@"authorized"];
            if ([login integerValue]  == 0) {
                [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"isNotLoggedin"];
            }
            
            [Database initDB];
            
            //check if this view, landingpage, is loaded from scratch
            NSString *isFirstRun = [[NSUserDefaults standardUserDefaults]objectForKey:@"isFirstRun"];
            if ([isFirstRun length] == 0) {
                self.tableArray = [[NSMutableArray alloc]init];
                [Database initDB];
                int result = [Database deleteLandingPageWithFilePath:[Database getDbFilePath]];
                if (result == 0) {
                    //[self populateTableViewArray];
                    [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"isFirstRun"];
                }
            }
            
            for (NSDictionary *post in [tempDic objectForKey:@"posts"]) {
                [Database insertIntoLandingPageWithFilePath:[Database getDbFilePath] postID:post.LPPostID title:post.LPTitle content:post.LPContent contentSummary:post.LPContentSummary contentHTML:post.LPContentHTML imageUrl:post.LPImageUrl publish_date:post.LPPublish_date categoryId:post.LPCategoryId categoryName:post.LPCategoryName userAvatarUrl:post.LPUserAvatarUrl userTitle:post.LPUserTitle userJobTitle:post.LPUserJobTitle userPageId:post.LPUserPageId userEntity:post.LPUserEntity userEntityId:post.LPUserEntityId likes_count:[NSString stringWithFormat:@"%ld",(long)post.LPLikes_count] recommends_count:post.LPRecommends_count favorites_count:post.LPFavorites_count liked:post.LPLiked favorite:post.LPFavorite recommended:post.LPRecommended tags:post.LPTags postType:post.LPPostType audioUrl:post.LPAudioUrl videoUrl:post.LPVideoUrl audioSize:post.LPAudioSize videoSize:post.LPVideoSize];
                
                //copy fav items into favorite table
                if ([post.LPFavorite integerValue] == 1) {
                    [Database copyLandingPageIntoFavoriteWithFilePath:[Database getDbFilePath] postID:post.LPPostID];
                }
            }
            
            [Database updateURLLandingPageTable:[Database getDbFilePath]];
            
            //copy fav items into favorite table
            //[Database copyLandingPageIntoFavoriteWithFilePath:[Database getDbFilePath]];
            
            [ProgressHUD dismiss];
            [ProgressHUD dismiss];
            [ProgressHUD dismiss];
            isBusyNow = NO;
            
            if ([[tempDic objectForKey:@"posts"]count] > 0) {
                [self populateTableViewArray];
            }else{
                noMoreData = YES;
                //[self.tableView reloadData];
            }
            
        } failure:^(NSURLSessionTask *operation, NSError *error) {
             
            [ProgressHUD dismiss];
            isBusyNow = NO;
        }];
    }
}

- (void)fetchPostsFromServerWithCategory:(NSString *)categoryId WithRequest:(NSString *)request WithDate:(NSString *)date{
    NSDictionary *userpassDic = [GetUsernamePassword getUsernamePassword];
    NSDictionary *params;
    if ([userpassDic count] > 1) {
        
        params = @{@"username":[userpassDic objectForKey:@"username"],
                   @"password":[userpassDic objectForKey:@"password"],
                   @"date":date,
                   @"request":request,
                   @"category_id":categoryId,
                   @"unit_id":@"3"};
    }else{
        params = @{@"username":@"",
                   @"password":@"",
                   @"date":date,
                   @"request":request,
                   @"category_id":categoryId,
                   @"unit_id":@"3"};
        
    }
    
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
            [ProgressHUD dismiss];
            NSDictionary *tempDic = (NSDictionary *)responseObject;
            noMoreData = NO;
            if (!isPagingForCategories){
                self.tableArray = [[NSMutableArray alloc]init];
                [Database initDB];
                [Database deleteLandingPageWithFilePath:[Database getDbFilePath]];
                [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"isFirstRun"];
            }
            
            for (NSDictionary *post in [tempDic objectForKey:@"posts"]) {
                [Database insertIntoLandingPageWithFilePath:[Database getDbFilePath] postID:post.LPPostID title:post.LPTitle content:post.LPContent contentSummary:post.LPContentSummary contentHTML:post.LPContentHTML imageUrl:post.LPImageUrl publish_date:post.LPPublish_date categoryId:post.LPCategoryId categoryName:post.LPCategoryName userAvatarUrl:post.LPUserAvatarUrl userTitle:post.LPUserTitle userJobTitle:post.LPUserJobTitle userPageId:post.LPUserPageId userEntity:post.LPUserEntity userEntityId:post.LPUserEntityId likes_count:[NSString stringWithFormat:@"%ld",(long)post.LPLikes_count] recommends_count:post.LPRecommends_count favorites_count:post.LPFavorites_count liked:post.LPLiked favorite:post.LPFavorite recommended:post.LPRecommended tags:post.LPTags postType:post.LPPostType audioUrl:post.LPAudioUrl videoUrl:post.LPVideoUrl audioSize:post.LPAudioSize videoSize:post.LPVideoSize];
            }
            [Database updateURLLandingPageTable:[Database getDbFilePath]];
            
            [ProgressHUD dismiss];
            [ProgressHUD dismiss];
            [ProgressHUD dismiss];
            isBusyNow = NO;
            
            if ([[tempDic objectForKey:@"posts"]count] > 0) {
                [self populateTableViewArray];
            }else{
                noMoreData = YES;
                //[self.tableView reloadData];
            }
            
        } failure:^(NSURLSessionTask *operation, NSError *error) {
             
            [ProgressHUD dismiss];
            isBusyNow = NO;
        }];
    }
}
*/

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
        
        NSDictionary *userpassDic = [GetUsernamePassword getUsernamePassword];
        if ([userpassDic count] == 0) {
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
                
                [self populateTableViewArray];
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
            NSIndexPath *indexpath = [NSIndexPath indexPathForRow:idOfRow inSection:0];
            [self rollbackLikeButtonActionForIndexPath:indexpath];
            [_likeArray removeObjectAtIndex:idOfTargetDelete];
            /*
             if (idOfTargetDelete < [_likeArray count]) {
             [_likeArray removeObjectAtIndex:idOfTargetDelete];
             [Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:@"0" field:@"liked" postId:idOfPost];
             [Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:[NSString stringWithFormat:@"%@", [[tempDic objectForKey:@"data"] objectForKey:@"count"]] field:@"likes_count" postId:idOfPost];
             [self populateTableViewArray];
             }
             */
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [refreshControl endRefreshing];
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
        /*
         if (idOfTargetDelete < [_likeArray count]) {
         [_likeArray removeObjectAtIndex:idOfTargetDelete];
         //
         NSDictionary *landingPageDic = [self.tableArray objectAtIndex:idOfRow];
         NSMutableDictionary *landingPageDic2 = [[NSMutableDictionary alloc]initWithDictionary:landingPageDic];
         NSInteger likes = [landingPageDic2.LPTVLikes_count integerValue];
         likes--;
         [landingPageDic2 setObject:[NSString stringWithFormat:@"%ld", (long)likes] forKey:@"likesCount"];
         [landingPageDic2 setObject:[NSString stringWithFormat:[NSString stringWithFormat:@"%d", 0], likes] forKey:@"liked"];
         [self.tableArray replaceObjectAtIndex:idOfRow withObject:landingPageDic2];
         [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idOfRow inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
         
         */
        //[Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:[NSString stringWithFormat:@"%ld", (long)likes] field:@"liked" postId:idOfPost];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idOfRow inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        //}
        
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
        
        NSDictionary *userpassDic = [GetUsernamePassword getUsernamePassword];
        if ([userpassDic count] == 0) {
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
                //copy fav items into favorite table
                [Database copyLandingPageIntoFavoriteWithFilePath:[Database getDbFilePath] postID:idOfPost];
                
                [self populateTableViewArray];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idOfRow inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            }
        }else if ([[tempDic objectForKey:@"status"] isEqualToString:@"-"]){//status = "-"
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
                //delete fav item from favorite
                [Database deleteFavoriteWithFilePath:[Database getDbFilePath] withID:idOfPost];
                [self populateTableViewArray];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idOfRow inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
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
            //[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idOfRow inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
        
    }];
}

#pragma mark - drop down menu methods by Arash
- (void)openCloseMenu{
    if (!isMenuOpen) {
        [UIView animateWithDuration:0.4 animations:^{
            menuImageView.transform = CGAffineTransformMakeRotation(M_PI * -1);
            menuItemsArray =[[NSMutableArray alloc]init];
            menuItemsArray = [[Database selectFromCategoriesWithFilePath:[Database getDbFilePath]]mutableCopy];
            [UIView animateWithDuration:1.0 animations:^{
                UILabel *selectCategorylabel = [[UILabel alloc]initWithFrame:CGRectMake(menuView.frame.size.width/2 - 75, 10, 150, 25)];
                selectCategorylabel.text = NSLocalizedString(@"selectCategory", @"");
                selectCategorylabel.font = FONT_NORMAL(13);
                selectCategorylabel.textAlignment = NSTextAlignmentCenter;
                [menuScrollView addSubview:selectCategorylabel];
                UIView *horizontalView = [[UIView alloc]initWithFrame:CGRectMake(0, 30, menuScrollView.frame.size.width, 1)];
                horizontalView.backgroundColor = [UIColor grayColor];
                [menuScrollView addSubview:horizontalView];
                CGFloat yPositionOfLabel = 40;
                for (int i = 0; i < [menuItemsArray count]; i++) {
                    
                    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(menuView.frame.size.width - 250, yPositionOfLabel, 200, 25)];
                    label.text = [NSString stringWithFormat:@"%@", [[menuItemsArray objectAtIndex:i]objectForKey:@"name"]];
                    label.textAlignment = NSTextAlignmentRight;
                    label.userInteractionEnabled = YES;
                    label.tag = i;
                    label.font = FONT_NORMAL(12);
                    [menuScrollView addSubview:label];
                    UITapGestureRecognizer *labelTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapOnLabelAction:)];
                    [label addGestureRecognizer:labelTap];
                    yPositionOfLabel += 35;
                }
                
                CGRect rectScroll = menuScrollView.frame;
                rectScroll.size.height = yPositionOfLabel;
                [menuScrollView setFrame:rectScroll];
                menuScrollView.contentSize = CGSizeMake(menuScrollView.frame.size.width, yPositionOfLabel * 1.8);
                CGRect rectMenu = menuView.frame;
                rectMenu.size.height = yPositionOfLabel + 10;
                [menuView setFrame:rectMenu];
                
                //
                NSInteger selectedItem = [[[NSUserDefaults standardUserDefaults]objectForKey:@"selectedItemNumber"]integerValue];
                CGFloat yPositionOfImage = 40;
                yPositionOfImage += selectedItem * 35;
                [UIView animateWithDuration:1.0 animations:^{
                    CGRect rect = selectImageView.frame;
                    rect.origin.y = yPositionOfImage;
                    [selectImageView setFrame:rect];
                }completion:nil];
                //
            }];
            
        }];
        isMenuOpen = !isMenuOpen;
    } else {
        [self closeMenu];
    }
}

- (void)tapOnLabelAction:(UITapGestureRecognizer *)tap{
    [ProgressHUD show:@"" Interaction:NO];
    [self stopAnimationProgress];
    [self stopAnimationProgressFinal];
    [self.tableView removeFromSuperview];
    [self makeTableViewWithYpos:70];
    [self.tableArray removeAllObjects];
    [self.tableView reloadData];
    
    selectedRow = 1000;
    selectedItemNumber = tap.view.tag;
    NSString *categoryId = [[menuItemsArray objectAtIndex:selectedItemNumber]objectForKey:@"Id"];
    if (selectedItemNumber == 0)/*all category*/ {
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"categoryId"];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"isFirstRun"];
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInteger:selectedItemNumber]
                                                 forKey:@"selectedItemNumber"];
        
        //[self fetchPostsFromServerWithRequest:@"" WithDate:@""];
        [self fetchPostsFromServerWithEntityId:entityId page:page];
    }else{
        [[NSUserDefaults standardUserDefaults]setObject:categoryId forKey:@"categoryId"];
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInteger:selectedItemNumber]
                                                 forKey:@"selectedItemNumber"];
        isPagingForCategories = NO;
        //[self fetchPostsFromServerWithCategory:categoryId WithRequest:@"" WithDate:@""];
        [self fetchPostsFromServerWithEntityId:entityId page:page];
    }
    CGFloat yPositionOfImage = 40;
    yPositionOfImage += selectedItemNumber * 35;
    [UIView animateWithDuration:1.0 animations:^{
        CGRect rect = selectImageView.frame;
        rect.origin.y = yPositionOfImage;
        [selectImageView setFrame:rect];
    }completion:^(BOOL finished) {
        [self performSelector:@selector(closeMenu) withObject:nil afterDelay:0.5];
    }];
}

- (void)closeMenu{
    [UIView animateWithDuration:0.4 animations:^{
        menuImageView.transform = CGAffineTransformMakeRotation(2 * M_PI);
        CGRect rectMenu = menuView.frame;
        rectMenu.size.height = 0;
        [menuView setFrame:rectMenu];
        
        CGRect rectScroll = menuScrollView.frame;
        rectScroll.size.height = 0;
        [menuScrollView setFrame:rectScroll];
        
    } completion:^(BOOL finished) {
        isMenuOpen = !isMenuOpen;
        
    }];
}

#pragma mark - get notifications

- (void)getNotificationsFromServer{
    NSUserDefaults *defualt = [NSUserDefaults standardUserDefaults];
    NSString *mobile = [defualt objectForKey:@"mobile"];
    NSString *password = [defualt objectForKey:@"password"];
    NSString *urlString = [NSString stringWithFormat:@"%@%@", BaseURL, @"notifications"];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    if ([mobile length] == 0) {
        mobile = @"";
    }
    
    if ([password length] == 0) {
        password = @"";
    }
    NSDictionary *params = @{
                             @"username":mobile,
                             @"password":password,
                             @"debug":@"1"
                             };
    [manager POST:urlString parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [ProgressHUD dismiss];
        NSDictionary *dict = responseObject;
        
        if ([[dict objectForKey:@"has_notification"]integerValue] > 0) {
            [self saveNotif:nil];
        }
        ////NSLog(@"%@", dict);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [ProgressHUD dismiss];
    }];
    
}

- (void)pushToConsultationList{
    [self performSegueWithIdentifier:@"fromHomeView" sender:nil];
}

- (IBAction)saveNotif:(id)sender
{
    UIMutableUserNotificationAction *notificationAction1 = [[UIMutableUserNotificationAction alloc] init];
    notificationAction1.identifier = @"Accept";
    notificationAction1.title = @"مشاهده";
    notificationAction1.activationMode = UIUserNotificationActivationModeForeground;
    notificationAction1.destructive = NO;
    notificationAction1.authenticationRequired = NO;
    
    UIMutableUserNotificationAction *notificationAction2 = [[UIMutableUserNotificationAction alloc] init];
    notificationAction2.identifier = @"Reject";
    notificationAction2.title = @"بعدا";
    notificationAction2.activationMode = UIUserNotificationActivationModeBackground;
    notificationAction2.destructive = YES;
    notificationAction2.authenticationRequired = YES;
    
    UIMutableUserNotificationCategory *notificationCategory = [[UIMutableUserNotificationCategory alloc] init];
    notificationCategory.identifier = @"Arash";
    [notificationCategory setActions:@[notificationAction1,notificationAction2] forContext:UIUserNotificationActionContextDefault];
    [notificationCategory setActions:@[notificationAction1,notificationAction2] forContext:UIUserNotificationActionContextMinimal];
    NSSet *categories = [NSSet setWithObjects:notificationCategory, nil];
    UIUserNotificationType notificationType = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:notificationType categories:categories];
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    
    // New for iOS 8 - Register the notifications
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    //[self setNotificationTypesAllowed];
    //notification.fireDate = [NSDate date];
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.repeatInterval = 0;
    notification.category = @"Arash";
    notification.alertBody = @"به سوال شما پاسخ داده شده است. لطفا چک کنید.";
    //notification.applicationIconBadgeNumber = 1;
    notification.soundName = UILocalNotificationDefaultSoundName;
    // this will schedule the notification to fire at the fire date
    //[[UIApplication sharedApplication] scheduleLocalNotification:notification];
    // this will fire the notification right away, it will still also fire at the date we set
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

- (void)registerUserDeviceTokenOnServer{
    NSString *urlString = [NSString stringWithFormat:@"%@%@", BaseURL, @"push_notification/set_user"];
    NSUserDefaults *defualt = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [defualt objectForKey:@"user_id"];
    NSString *devToken = [defualt objectForKey:@"deviceToken"];
    
    if ([user_id length] == 0) {
        user_id = @"";
    }
    
    if ([devToken length] == 0) {
        devToken = @"";
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSDictionary *params = @{
                             @"type":@"apn",
                             @"push_notif_id":devToken,
                             @"user_id":user_id,
                             @"debug":@"1"
                             };
    
    [manager POST:urlString parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    }];
}

#pragma mark - scrollview delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height) {
        // we are at the end
        page++;
        [self fetchPostsFromServerWithEntityId:entityId page:page];
    }
}

@end
