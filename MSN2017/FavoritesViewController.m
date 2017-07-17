//
//  FavoritesViewController.m
//  MSN
//
//  Created by Yarima on 5/29/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "FavoritesViewController.h"
#import "Database.h"
#import <AFHTTPSessionManager.h>
#import <UIImageView+AFNetworking.h>
#import "Header.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import "KeychainWrapper.h"
#import "ProgressHUD.h"
#import "NSDictionary+LandingPageTableView.h"
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
#import "DoctorPageViewController.h"
#import "UIImage+Extra.h"
#import "LandingPageDetailViewController.h"
#import "SearchViewCustomCell.h"
#import "NSDictionary+LandingPageTableView.h"
@interface FavoritesViewController ()<UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate>
{
     
    UILabel *noResultLabel;
    NSInteger  selectedRow;
    BOOL    isExpand;
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
@property (strong, nonatomic) NSTimer *timerForProgress;
@property (strong, nonatomic) NSTimer *timerForProgressFinal;

@end

@implementation FavoritesViewController
- (void)viewDidDisappear:(BOOL)animated{
    [ProgressHUD dismiss];
}

- (void)viewWillDisappear:(BOOL)animated{
    self.tableView.userInteractionEnabled = YES;
}
- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = YES;
    
    [super viewDidLoad];
     
    selectedRow = 1000;
    NSArray *favItems = [Database selectFromFavoriteWithFilePath:[Database getDbFilePath]];
    //NSLog(@"favItems: %@", favItems);
    self.tableArray = [[NSMutableArray alloc]initWithArray:favItems];
    
    [self makeTopBar];
    //NSLog(@"self.navigationControllers: %@", [self.navigationController viewControllers]);
    
    _favArray = [[NSMutableArray alloc]init];
    _likeArray = [[NSMutableArray alloc]init];
    
    disableTableView = YES;
}

#pragma mark - Custom methods

- (void)makeTopBar{
    
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 70)];
    topView.backgroundColor = COLOR_3;
    [self.view addSubview:topView];
    
    CGFloat topViewHeight = topView.frame.size.height;
    
    UILabel *titleLabel =[[UILabel alloc]initWithFrame:CGRectMake(screenWidth/2 - 100, topViewHeight/2 - 15, 200, 40)];
    titleLabel.font = FONT_NORMAL(16);
    titleLabel.text = NSLocalizedString(@"favorites", @"");
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:titleLabel];
    
    //54 × 39
    UIButton *backButtonImg = [[UIButton alloc]initWithFrame:CGRectMake(0, 16 , 45, 45)];
    [backButtonImg setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButtonImg addTarget:self action:@selector(backButtonImgAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButtonImg];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 70, screenWidth, screenHeight - 115)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    //45x69
    UIButton *searchButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - 100, topViewHeight/2 - 10, 54 *0.4, 69 * 0.4)];
    [searchButton setBackgroundImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(searchButtonAction) forControlEvents:UIControlEventTouchUpInside];
    //[topView addSubview:searchButton];

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

- (void)menuButtonAction {
    disableTableView = !disableTableView;
    self.tableView.userInteractionEnabled = disableTableView;
    //[self showHideRightMenu];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"toggleMenuVisibility" object:nil];
}

- (void)backButtonImgAction{
    [self.navigationController popViewControllerAnimated:YES];
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

- (void)tapOnAuthorImage:(UITapGestureRecognizer *)tap{
    NSDictionary *tempDic = [self.tableArray objectAtIndex:tap.view.tag];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DoctorPageViewController *view = (DoctorPageViewController *)[story instantiateViewControllerWithIdentifier:@"DoctorPageViewController"];
    view.userEntityId = tempDic.LPTVUserEntityId;
    view.userTitle = tempDic.LPTVUserTitle;
    view.userJobTitle = tempDic.LPTVUserJobTitle;
    view.userAvatar = tempDic.LPTVUserAvatarUrl;
    [self.navigationController pushViewController:view animated:YES];
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
        //[Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:@"1" field:@"liked" postId:landingPageDic2.LPPostID];
        
    }else{
        likes--;
        [landingPageDic2 setObject:[NSString stringWithFormat:[NSString stringWithFormat:@"%d", 0], likes] forKey:@"liked"];
        //[Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:@"1" field:@"liked" postId:landingPageDic2.LPPostID];
        
    }
    
    [landingPageDic2 setObject:[NSString stringWithFormat:@"%ld", (long)likes] forKey:@"likesCount"];
    //[Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:[NSString stringWithFormat:@"%@", [[tempDic objectForKey:@"data"] objectForKey:@"count"]] field:@"likes_count" postId:landingPageDic2.LPPostID];
    
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
        //[Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:@"1" field:@"liked" postId:landingPageDic2.LPPostID];
        
    }else{
        likes--;
        [landingPageDic2 setObject:[NSString stringWithFormat:[NSString stringWithFormat:@"%d", 0], likes] forKey:@"liked"];
        //[Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:@"1" field:@"liked" postId:landingPageDic2.LPPostID];
        
    }
    
    [landingPageDic2 setObject:[NSString stringWithFormat:@"%ld", (long)likes] forKey:@"likesCount"];
    //[Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:[NSString stringWithFormat:@"%@", [[tempDic objectForKey:@"data"] objectForKey:@"count"]] field:@"likes_count" postId:landingPageDic2.LPPostID];
    
    [self.tableArray replaceObjectAtIndex:btn.tag withObject:landingPageDic2];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:btn.tag inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)shareButtonAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    
    NSDictionary *landingPageDic = [self.tableArray objectAtIndex:btn.tag];
    
    NSString *textToShare = landingPageDic.LPTVTitle;
    NSString *textToShare2 = landingPageDic.LPTVContentSummary;
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
    NSString *documentsDirectory = [DocumentDirectoy getDocuementsDirectory];
    
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
    
}

- (void)downloadPlayButtonActionVideo:(id)sender{
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
    
}

#pragma mark - table view delegate

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    // Set expanded cell then tell tableView to redraw with animation
    selectedRow = indexPath.row;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    [noResultLabel removeFromSuperview];
    if ([self.tableArray count] == 0) {
        noResultLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 220, 10, 200,  25)];
        noResultLabel.font = FONT_MEDIUM(13);
        noResultLabel.text = NSLocalizedString(@"NOfav", @"");
        noResultLabel.minimumScaleFactor = 0.7;
        noResultLabel.textColor = [UIColor blackColor];
        noResultLabel.textAlignment = NSTextAlignmentRight;
        noResultLabel.adjustsFontSizeToFitWidth = YES;
        [self.tableView addSubview:noResultLabel];
        return 0;
    }else{
        return [self.tableArray count];
    }
}

//-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    //minimum size of your cell, it should be single line of label if you are not clear min. then return UITableViewAutomaticDimension;
//    return UITableViewAutomaticDimension;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (IS_IPAD) {
        return 90;
    } else {
        return 90;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SearchViewCustomCell *cell = (SearchViewCustomCell *)[[SearchViewCustomCell alloc]
                                                          initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellSafahatMozoee"];
    
    if (indexPath.row < [self.tableArray count]) {
        NSDictionary *searchDic = [self.tableArray objectAtIndex:indexPath.row];
        cell.nameLabel.text = searchDic.LPTVTitle;//[[self.tableArray objectAtIndex:indexPath.row]objectForKey:@"title"];
        cell.jobLabel.text = searchDic.LPTVUserTitle;//[[[self.tableArray objectAtIndex:indexPath.row]objectForKey:@"entity"]objectForKey:@"name"];
        [cell.myImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", searchDic.LPTVImageUrl]] placeholderImage:[UIImage imageNamed:@"icon upload ax"]];
    }
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
            NSInteger likes = [landingPageDic2.LPTVLikes_count integerValue];
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
    NSDictionary *params = @{@"username":[userpassDic objectForKey:@"username"]/*@"09191234072"*/,
                             @"password":[userpassDic objectForKey:@"password"]/*@“123456”*/,
                             @"model": @"POST",
                             @"foreign_key": idOfPost,
                             @"user_id": [GetUsernamePassword getUserId]/*@"6144"*/,
                             @"unit_id": @"3"
                             };
    
    
    //    KeychainWrapper *keychainWrapper = [[KeychainWrapper alloc]init];
    //    NSString *username = [keychainWrapper myObjectForKey:(__bridge id)(kSecAttrDescription)];
    //    NSString *password = [keychainWrapper myObjectForKey:(__bridge id)(kSecAttrService)];
    NSString *url = [NSString stringWithFormat:@"%@social_activities/setFavorite", BaseURL];
    
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
                //copy fav items into favorite table
                [Database copyLandingPageIntoFavoriteWithFilePath:[Database getDbFilePath] postID:idOfPost];
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
                //delete fav item from favorite
                [Database deleteFavoriteWithFilePath:[Database getDbFilePath] withID:idOfPost];
            }
            
        }
        
        NSArray *favItems = [Database selectFromFavoriteWithFilePath:[Database getDbFilePath]];
        self.tableArray = [[NSMutableArray alloc]initWithArray:favItems];
        [self.tableView reloadData];
        
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
@end
