    //
    //  LandingPageDetailViewController.m
    //  MSN
    //
    //  Created by Yarima on 7/23/16.
    //  Copyright © 2016 Arash. All rights reserved.
    //

#import "LandingPageDetailViewController.h"
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
#import "DACircularProgressView.h"
#import "CustomButton.h"
#import "CommentViewController.h"
#import "ReportAbuseViewController.h"
#import "ImageResizer.h"
#import "TopicPageViewController.h"
#import "UserProfileViewController.h"
@interface LandingPageDetailViewController()<UIWebViewDelegate, AVAudioPlayerDelegate, UIGestureRecognizerDelegate>
{
    UIScrollView *scrollView;
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
    NSString *postType;
    NSString *contentHTMLStr;
    UIView *settingMenuView;
    UIButton *optionsbutton;
    BOOL allowToSendVoting;
    UIScrollView *namesScrollView;
    NSMutableArray *selectedTagsArray;
}
@property(nonatomic, retain)UILabel *titleLabel;
@property(nonatomic, retain)UILabel *dateLabel;
@property(nonatomic, retain)UILabel *categoryLabel;
@property(nonatomic, retain)UIImageView *postImageView;
@property(nonatomic, retain)UILabel *likeCountLabel;
@property(nonatomic, retain)UILabel *commentCountLabel;
@property(nonatomic, retain)UIImageView *authorImageView;
@property(nonatomic, retain)UILabel *authorNameLabel;
@property(nonatomic, retain)UILabel *authorJobLabel;
@property(nonatomic, retain)UITextView *contentTextView;
@property(nonatomic, retain)UIWebView *webView;
@property(nonatomic, retain)UIImageView *commentImageView;
@property(nonatomic, retain)UIButton *favButton;
@property(nonatomic, retain)UIButton *heartButton;
@property(nonatomic, retain)UIButton *shareButton;
@property(nonatomic, retain)UIButton *downloadPlayButton;
@property(nonatomic, retain)UILabel *totalDurationLabel;
@property(nonatomic, retain)UILabel *currentTimeLabel;
@property(nonatomic, retain)DACircularProgressView *largeProgressView;
@property (strong, nonatomic) NSTimer *timerForProgress;
@property (strong, nonatomic) NSTimer *timerForProgressFinal;
@end

@implementation LandingPageDetailViewController
- (void)viewDidLoad{
    [self makeTopBar];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateCommentsCount:) name:@"updateCommentsCount" object:nil];
    NSString *postId = _dictionary.LPTVPostID;
    if ([postId integerValue] == 0) {
        postId = _dictionary.LPPostID;
    }
    if ([postId integerValue] == 0){
        postId = _postId;
    }
    [self postDetailWithID:postId];
    
    postType = _dictionary.LPTVPostType;
    if ([postType length] == 0) {
        postType = _dictionary.LPPostType;
    }
    
        //    if ([postType isEqualToString:@"audio"]) {
        //        [self makeBodyForAudio];
        //    }else if ([postType isEqualToString:@"video"]) {
        //        [self makeBodyForVideo];
        //    }else {
        //        [self makeBody];
        //    }
}

- (void)makeTopBar{
    
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 70)];
    topView.backgroundColor = COLOR_3;
    [topView makeGradient:topView];
    topView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissTextView)];
    [topView addGestureRecognizer:tap];
    [self.view addSubview:topView];
    
    
    CGFloat topViewHeight = topView.frame.size.height;
    
    UILabel *titleLabel =[[UILabel alloc]initWithFrame:CGRectMake(screenWidth/2 - 100, topViewHeight/2 - 15, 200, 40)];
    titleLabel.font = FONT_NORMAL(20);
    titleLabel.numberOfLines = 2;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.minimumScaleFactor = 0.5;
    titleLabel.text = _dictionary.LPTVTitle;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:titleLabel];
    
    UIButton *backButtonImg = [[UIButton alloc]initWithFrame:CGRectMake(0, 16 , 45, 45)];
    [backButtonImg setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButtonImg addTarget:scrollView action:@selector(backButtonImgAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButtonImg];
    
        //54 × 39
    /*
     UIButton *menuButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - 60, topViewHeight/2 - 20, 54, 54)];
     //menuButton.backgroundColor = [UIColor redColor];
     UIImage *img = [UIImage imageNamed:@"menu side"];
     [menuButton setImage:[img imageByScalingProportionallyToSize:CGSizeMake(54/2,39/2)] forState:UIControlStateNormal];
     [menuButton addTarget:scrollView action:@selector(menuButtonAction) forControlEvents:UIControlEventTouchUpInside];
     [topView addSubview:menuButton];
     
     //45x69
     UIButton *searchButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - 100, topViewHeight/2 - 10, 54 *0.4, 69 * 0.4)];
     [searchButton setBackgroundImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
     [searchButton addTarget:scrollView action:@selector(searchButtonAction) forControlEvents:UIControlEventTouchUpInside];
     [topView addSubview:searchButton];
     
     //232 × 192
     categoryButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 232 * topViewHeight/232, 192 * topViewHeight/192)];
     [categoryButton setBackgroundImage:[UIImage imageNamed:@"daste bandi"] forState:UIControlStateNormal];
     [categoryButton addTarget:scrollView action:@selector(categoryButtonAction) forControlEvents:UIControlEventTouchUpInside];
     [topView addSubview:categoryButton];
     categoryButton.userInteractionEnabled = NO;
     */
}

- (void)makeBody{
        //NSLog(@"%@", _dictionary);
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 70, screenWidth, screenHeight - 70)];
    scrollView.contentSize = CGSizeMake(screenWidth, [self getHeightOfString:_dictionary.LPContent] + 200);
    scrollView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissTextView)];
    [scrollView addGestureRecognizer:tap];
    
    [self.view addSubview:scrollView];
    
    if (([_dictionary.LPImageUrl length] > 10) || ([_dictionary.LPTVImageUrl length] > 10)) {
        self.postImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenWidth * 0.42)];
        self.postImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.postImageView.clipsToBounds = YES;
            //post image
        if ([_dictionary.LPTVImageUrl length] == 0) {
            [_postImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", _dictionary.LPImageUrl]] placeholderImage:[UIImage imageNamed:@"broken_image"]];
        }else{
            [_postImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", _dictionary.LPTVImageUrl]] placeholderImage:[UIImage imageNamed:@"broken_image"]];
        }
        [scrollView addSubview:self.postImageView];
    }
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, self.postImageView.frame.origin.y + self.postImageView.frame.size.height + 70, screenWidth - 110, 60)];
    self.titleLabel.font = FONT_BOLD(17);
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.minimumScaleFactor = 0.7;
    self.titleLabel.textAlignment = NSTextAlignmentRight;
    if ([_dictionary.LPTVTitle length] == 0) {
        self.titleLabel.text = _dictionary.LPTitle;
    } else {
        self.titleLabel.text = _dictionary.LPTVTitle;
    }
    
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
        //[scrollView addSubview:self.titleLabel];
    
        //268 × 75
    UIImageView *categoryBGImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 107.2, 30)];
    categoryBGImageView.image = [UIImage imageNamed:@"kadr"];
    [self.postImageView addSubview:categoryBGImageView];
    
    self.commentCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 5, 20, 20)];
    self.commentCountLabel.font = FONT_NORMAL(11);
    self.commentCountLabel.minimumScaleFactor = 0.7;
    self.commentCountLabel.textColor = [UIColor grayColor];
    self.commentCountLabel.textAlignment = NSTextAlignmentLeft;
    self.commentCountLabel.adjustsFontSizeToFitWidth = YES;
    if ([_dictionary.LPTVRecommends_count length] == 0) {
        _commentCountLabel.text = _dictionary.LPRecommends_count;
    } else {
        _commentCountLabel.text = _dictionary.LPTVRecommends_count;
    }
    
        //[scrollView addSubview:self.commentCountLabel];
    
    self.categoryLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, categoryBGImageView.frame.size.width, categoryBGImageView.frame.size.height)];
    self.categoryLabel.font = FONT_MEDIUM(11);
    self.categoryLabel.minimumScaleFactor = 0.7;
    self.categoryLabel.textColor = [UIColor whiteColor];
    self.categoryLabel.textAlignment = NSTextAlignmentCenter;
    self.categoryLabel.adjustsFontSizeToFitWidth = YES;
    if ([_dictionary.LPTVCategoryName length] == 0) {
        _categoryLabel.text = _dictionary.LPCategoryName;
    }else{
        _categoryLabel.text = _dictionary.LPTVCategoryName;
    }
    [categoryBGImageView addSubview:self.categoryLabel];
    
    NSInteger authorImageWidth = 60;
    self.authorImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - authorImageWidth - 20, self.postImageView.frame.origin.y + self.postImageView.frame.size.height + 10, authorImageWidth, authorImageWidth)];
    self.authorImageView.layer.cornerRadius = authorImageWidth / 2;
    self.authorImageView.clipsToBounds = YES;
    if ([_dictionary.LPTVUserAvatarUrl length] == 0) {
        [_authorImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", _dictionary.LPUserAvatarUrl]] placeholderImage:[UIImage imageNamed:@"icon upload ax"]];
    } else {
        [_authorImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", _dictionary.LPTVUserAvatarUrl]] placeholderImage:[UIImage imageNamed:@"icon upload ax"]];
    }
    
    _authorImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap10 = [[UITapGestureRecognizer alloc]init];
    [tap10 addTarget:self action:@selector(tapOnAuthorImage:)];
    [_authorImageView addGestureRecognizer:tap10];
    [scrollView addSubview:self.authorImageView];
    
    self.authorNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, self.authorImageView.frame.origin.y + 10, screenWidth - authorImageWidth - 40, 25)];
    self.authorNameLabel.font = FONT_MEDIUM(13);
    self.authorNameLabel.minimumScaleFactor = 0.7;
    self.authorNameLabel.textColor = [UIColor blackColor];
    self.authorNameLabel.textAlignment = NSTextAlignmentRight;
    self.authorNameLabel.adjustsFontSizeToFitWidth = YES;
    if ([_dictionary.LPTVUserTitle length] == 0) {
        _authorNameLabel.text = _dictionary.LPUserTitle;
    }else{
        _authorNameLabel.text = _dictionary.LPTVUserTitle;
    }
    
    [scrollView addSubview:self.authorNameLabel];
    
    UIButton *moreButton = [CustomButton initButtonWithImage:[UIImage imageNamed:@"moreButton"] withFrame:CGRectMake(10, self.authorNameLabel.frame.origin.y, 30, 30)];
    [moreButton addTarget:self action:@selector(moreButtonAction) forControlEvents:UIControlEventTouchUpInside];
    moreButton.tintColor = COLOR_5;
    [scrollView addSubview:moreButton];
    
        //    self.authorJobLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, self.authorImageView.frame.origin.y + 25, screenWidth - authorImageWidth - 40, 25)];
        //    self.authorJobLabel.font = FONT_NORMAL(11);
        //    self.authorJobLabel.minimumScaleFactor = 0.7;
        //    self.authorJobLabel.textColor = [UIColor blackColor];
        //    self.authorJobLabel.textAlignment = NSTextAlignmentRight;
        //    self.authorJobLabel.adjustsFontSizeToFitWidth = YES;
        //    if ([_dictionary.LPTVUserJobTitle length] == 0) {
        //        _authorJobLabel.text = _dictionary.LPUserJobTitle;
        //    } else {
        //        _authorJobLabel.text = _dictionary.LPTVUserJobTitle;
        //    }
        //
        //    [scrollView addSubview:self.authorJobLabel];
    
        //self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(10, self.authorImageView.frame.origin.y + self.authorImageView.frame.size.height + 10, screenWidth - 20, /*[self getHeightOfString:_dictionary.LPTVContentHTML] - */10)];
        //self.webView.delegate = self;
        //self.webView.layer.borderColor = [UIColor redColor].CGColor;
        //self.webView.layer.borderWidth = 2.0;
        //self.webView.clipsToBounds = YES;
    /*NSString* path = [[NSBundle mainBundle] pathForResource:@"html"
     ofType:@"txt"];
     NSString* content = [NSString stringWithContentsOfFile:path
     encoding:NSUTF8StringEncoding
     error:NULL];
     */
        //    NSMutableString *htmlContent = [[NSMutableString alloc]init];
        //    [htmlContent insertString:[NSString stringWithFormat:@"<html dir=\"rtl\"><body bg=\"red\" style=\"width:100%%;word-wrap:break-word;<!--background-color:powderblue-->;\" align=\"justify\"  id=\"body\">%@</body></html>", _dictionary.LPTVContentHTML] atIndex:0];
        //    [self.webView loadHTMLString:htmlContent baseURL:nil];
        //[scrollView addSubview:_webView];
    
    self.contentTextView = [[UITextView alloc]initWithFrame:CGRectMake(10, self.authorImageView.frame.origin.y + self.authorImageView.frame.size.height + 10, screenWidth - 20, [self getHeightOfString:_dictionary.LPContent]+50 )];
    self.contentTextView.userInteractionEnabled = NO;
    self.contentTextView.font = FONT_NORMAL(15);
    _contentTextView.text = _dictionary.LPContent;
    if (IS_IPAD) {
        self.contentTextView.font = FONT_NORMAL(19);
        self.contentTextView.frame = CGRectMake(10, self.authorImageView.frame.origin.y + self.authorImageView.frame.size.height + 10, screenWidth - 20, 200);
    }
    self.contentTextView.textColor = [UIColor blackColor];
    self.contentTextView.textAlignment = NSTextAlignmentRight;
    [scrollView addSubview:self.contentTextView];
    
    UIImageView *snapshotImageView;
    if ([[_dictionary objectForKey:@"image"]length] > 10) {
        snapshotImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, _contentTextView.frame.origin.y + _contentTextView.frame.size.height, screenWidth, screenWidth * 0.7)];
        snapshotImageView.userInteractionEnabled = YES;
        [scrollView addSubview:snapshotImageView];
        [snapshotImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [_dictionary objectForKey:@"image"]]] placeholderImage:[UIImage imageNamed:@"broken_image"]];
        
    } else {
        snapshotImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, _contentTextView.frame.origin.y + _contentTextView.frame.size.height, screenWidth, 0 * 0.7)];
        snapshotImageView.userInteractionEnabled = YES;
        [scrollView addSubview:snapshotImageView];
    }
    
    namesScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, snapshotImageView.frame.origin.y+ snapshotImageView.frame.size.height + 5, screenWidth, 40)];
    namesScrollView.contentSize = CGSizeMake(screenWidth * 2, 40);
    [scrollView addSubview:namesScrollView];
        //52 × 49
    self.heartButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - 40, snapshotImageView.frame.origin.y+ snapshotImageView.frame.size.height + 50, 52 * 0.4, 49*0.4)];
    [self.heartButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
    [self.heartButton addTarget:self action:@selector(likeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:self.heartButton];
    
    self.likeCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 70, snapshotImageView.frame.origin.y+ snapshotImageView.frame.size.height + 50, 25, 20)];
    self.likeCountLabel.font = FONT_NORMAL(11);
    self.likeCountLabel.minimumScaleFactor = 0.7;
    self.likeCountLabel.textColor = [UIColor blackColor];
    self.likeCountLabel.textAlignment = NSTextAlignmentRight;
    self.likeCountLabel.adjustsFontSizeToFitWidth = YES;
    [scrollView addSubview:self.likeCountLabel];
    if ([_dictionary.LPTVLikes_count length] == 0) {
        _likeCountLabel.text = [NSString stringWithFormat:@"%ld", (long)_dictionary.LPLikes_count];
    } else {
        _likeCountLabel.text = _dictionary.LPTVLikes_count;
    }
    
        //46 × 49
    self.commentImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 100, snapshotImageView.frame.origin.y+ snapshotImageView.frame.size.height + 50, 46*0.4, 49*0.4)];
    self.commentImageView.image = [UIImage imageNamed:@"comment"];
    self.commentImageView.userInteractionEnabled = YES;
    self.commentImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(commentImageViewAction:)];
    [self.commentImageView addGestureRecognizer:tap2];
    [scrollView addSubview:self.commentImageView];
    
    self.commentCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 126, snapshotImageView.frame.origin.y+ snapshotImageView.frame.size.height + 50, 25, 20)];
    self.commentCountLabel.font = FONT_NORMAL(11);
    self.commentCountLabel.text = _dictionary.LPRecommends_count;
    self.commentCountLabel.minimumScaleFactor = 0.7;
    self.commentCountLabel.textColor = [UIColor blueColor];
    self.commentCountLabel.textAlignment = NSTextAlignmentRight;
    self.commentCountLabel.adjustsFontSizeToFitWidth = YES;
    [scrollView addSubview:self.commentCountLabel];
    
        //46 × 43
    self.favButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - 150, snapshotImageView.frame.origin.y+ snapshotImageView.frame.size.height + 50, 46 * 0.4, 43 * 0.4)];
    [self.favButton setImage:[UIImage imageNamed:@"fav off"] forState:UIControlStateNormal];
    [self.favButton addTarget:self action:@selector(favButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:self.favButton];
    
        //35 × 44
    self.shareButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - 180, snapshotImageView.frame.origin.y+ snapshotImageView.frame.size.height + 50, 35*0.4, 44*0.4)];
    [self.shareButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [self.shareButton addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:self.shareButton];
    
    
    if ([_dictionary.LPTVFavorite integerValue] == 0) {
        [_favButton setImage:[UIImage imageNamed:@"fav off"] forState:UIControlStateNormal];
    }else{
        [_favButton setImage:[UIImage imageNamed:@"fav on"] forState:UIControlStateNormal];
    }
    
    if ([_dictionary.LPTVLiked integerValue] == 0) {
        [_heartButton setImage:[UIImage imageNamed:@"like icon"] forState:UIControlStateNormal];
    }else{
        [_heartButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
    }
    
    self.dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, _favButton.frame.origin.y, 100, 25)];
    self.dateLabel.font = FONT_NORMAL(11);
    self.dateLabel.minimumScaleFactor = 0.7;
    self.dateLabel.textColor = [UIColor lightGrayColor];
    self.dateLabel.textAlignment = NSTextAlignmentLeft;
    self.dateLabel.adjustsFontSizeToFitWidth = YES;
        //date
    NSDateFormatter *currentDateFormatter = [[NSDateFormatter alloc]init];
    [currentDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *endDate = [NSDate date];
    
    double timestampval = [_dictionary.LPTVPublish_date doubleValue];
    NSTimeInterval timestamp = (NSTimeInterval)timestampval;
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
    _dateLabel.text = [NSString stringWithFormat:@"%@",
                       [TimeAgoViewController timeIntervalWithStartDate:startDate withEndDate:endDate]];
    [scrollView addSubview:self.dateLabel];
    
    scrollView.contentSize = CGSizeMake(screenWidth, _favButton.frame.origin.y + 150);
    
}

- (void)makeBodyForAudio{
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 70, screenWidth, screenHeight - 70)];
    [self.view addSubview:scrollView];
    
    if (([_dictionary.LPImageUrl length] > 10) || ([_dictionary.LPTVImageUrl length] > 10)) {
        self.postImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenWidth * 0.42)];
        self.postImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.postImageView.clipsToBounds = YES;
            //post image
        if ([_dictionary.LPTVImageUrl length] == 0) {
            [_postImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", _dictionary.LPImageUrl]] placeholderImage:[UIImage imageNamed:@"broken_image"]];
        }else{
            [_postImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", _dictionary.LPTVImageUrl]] placeholderImage:[UIImage imageNamed:@"broken_image"]];
        }
        [scrollView addSubview:self.postImageView];
    }
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, self.postImageView.frame.origin.y + self.postImageView.frame.size.height + 70, screenWidth - 110, 60)];
    self.titleLabel.font = FONT_BOLD(17);
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.minimumScaleFactor = 0.7;
    self.titleLabel.textAlignment = NSTextAlignmentRight;
    if ([_dictionary.LPTVTitle length] == 0) {
        self.titleLabel.text = _dictionary.LPTitle;
    } else {
        self.titleLabel.text = _dictionary.LPTVTitle;
    }
    
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
        //[scrollView addSubview:self.titleLabel];
    
        //268 × 75
    UIImageView *categoryBGImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 107.2, 30)];
    categoryBGImageView.image = [UIImage imageNamed:@"kadr"];
    [self.postImageView addSubview:categoryBGImageView];
    
    self.commentCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 5, 20, 20)];
    self.commentCountLabel.font = FONT_NORMAL(11);
    self.commentCountLabel.minimumScaleFactor = 0.7;
    self.commentCountLabel.textColor = [UIColor grayColor];
    self.commentCountLabel.textAlignment = NSTextAlignmentLeft;
    self.commentCountLabel.adjustsFontSizeToFitWidth = YES;
    if ([_dictionary.LPTVRecommends_count length] == 0) {
        _commentCountLabel.text = _dictionary.LPRecommends_count;
    } else {
        _commentCountLabel.text = _dictionary.LPTVRecommends_count;
    }
    
        //[scrollView addSubview:self.commentCountLabel];
    
    self.categoryLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, categoryBGImageView.frame.size.width, categoryBGImageView.frame.size.height)];
    self.categoryLabel.font = FONT_MEDIUM(11);
    self.categoryLabel.minimumScaleFactor = 0.7;
    self.categoryLabel.textColor = [UIColor whiteColor];
    self.categoryLabel.textAlignment = NSTextAlignmentCenter;
    self.categoryLabel.adjustsFontSizeToFitWidth = YES;
    if ([_dictionary.LPTVCategoryName length] == 0) {
        _categoryLabel.text = _dictionary.LPCategoryName;
    }else{
        _categoryLabel.text = _dictionary.LPTVCategoryName;
    }
    [categoryBGImageView addSubview:self.categoryLabel];
    
    NSInteger authorImageWidth = 60;
    self.authorImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - authorImageWidth - 20, self.postImageView.frame.origin.y + self.postImageView.frame.size.height + 10, authorImageWidth, authorImageWidth)];
    self.authorImageView.layer.cornerRadius = authorImageWidth / 2;
    self.authorImageView.clipsToBounds = YES;
    if ([_dictionary.LPTVUserAvatarUrl length] == 0) {
        [_authorImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", _dictionary.LPUserAvatarUrl]] placeholderImage:[UIImage imageNamed:@"icon upload ax"]];
    } else {
        [_authorImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", _dictionary.LPTVUserAvatarUrl]] placeholderImage:[UIImage imageNamed:@"icon upload ax"]];
    }
    
    _authorImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]init];
        [tap addTarget:self action:@selector(tapOnAuthorImage:)];
        [_authorImageView addGestureRecognizer:tap];
    [scrollView addSubview:self.authorImageView];
    
    self.authorNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, self.authorImageView.frame.origin.y + 10, screenWidth - authorImageWidth - 40, 25)];
    self.authorNameLabel.font = FONT_MEDIUM(13);
    self.authorNameLabel.minimumScaleFactor = 0.7;
    self.authorNameLabel.textColor = [UIColor blackColor];
    self.authorNameLabel.textAlignment = NSTextAlignmentRight;
    self.authorNameLabel.adjustsFontSizeToFitWidth = YES;
    if ([_dictionary.LPTVUserTitle length] == 0) {
        _authorNameLabel.text = _dictionary.LPUserTitle;
    }else{
        _authorNameLabel.text = _dictionary.LPTVUserTitle;
    }
    
    [scrollView addSubview:self.authorNameLabel];
    
    UIButton *moreButton = [CustomButton initButtonWithImage:[UIImage imageNamed:@"moreButton"] withFrame:CGRectMake(10, self.authorNameLabel.frame.origin.y, 30, 30)];
    [moreButton addTarget:self action:@selector(moreButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:moreButton];
        //    self.authorJobLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, self.authorImageView.frame.origin.y + 25, screenWidth - authorImageWidth - 40, 25)];
        //    self.authorJobLabel.font = FONT_NORMAL(11);
        //    self.authorJobLabel.minimumScaleFactor = 0.7;
        //    self.authorJobLabel.textColor = [UIColor blackColor];
        //    self.authorJobLabel.textAlignment = NSTextAlignmentRight;
        //    self.authorJobLabel.adjustsFontSizeToFitWidth = YES;
        //    if ([_dictionary.LPTVUserJobTitle length] == 0) {
        //        _authorJobLabel.text = _dictionary.LPUserJobTitle;
        //    } else {
        //        _authorJobLabel.text = _dictionary.LPTVUserJobTitle;
        //    }
        //
        //    [scrollView addSubview:self.authorJobLabel];
    
        //self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(10, self.authorImageView.frame.origin.y + self.authorImageView.frame.size.height + 10, screenWidth - 20, /*[self getHeightOfString:_dictionary.LPTVContentHTML] - */10)];
        //self.webView.delegate = self;
        //self.webView.layer.borderColor = [UIColor redColor].CGColor;
        //self.webView.layer.borderWidth = 2.0;
        //self.webView.clipsToBounds = YES;
    /*NSString* path = [[NSBundle mainBundle] pathForResource:@"html"
     ofType:@"txt"];
     NSString* content = [NSString stringWithContentsOfFile:path
     encoding:NSUTF8StringEncoding
     error:NULL];
     */
        //    NSMutableString *htmlContent = [[NSMutableString alloc]init];
        //    [htmlContent insertString:[NSString stringWithFormat:@"<html dir=\"rtl\"><body bg=\"red\" style=\"width:100%%;word-wrap:break-word;<!--background-color:powderblue-->;\" align=\"justify\"  id=\"body\">%@</body></html>", _dictionary.LPTVContentHTML] atIndex:0];
        //    [self.webView loadHTMLString:htmlContent baseURL:nil];
        //[scrollView addSubview:_webView];
    
    self.contentTextView = [[UITextView alloc]initWithFrame:CGRectMake(10, self.authorImageView.frame.origin.y + self.authorImageView.frame.size.height + 10, screenWidth - 20, [self getHeightOfString:_dictionary.LPContent]+ 50 )];
    self.contentTextView.userInteractionEnabled = NO;
        //self.contentTextView.contentSize = CGSizeMake(screenWidth, [self getHeightOfString:_dictionary.LPContent]);
    self.contentTextView.font = FONT_NORMAL(15);
    _contentTextView.text = _dictionary.LPContent;
    if (IS_IPAD) {
        self.contentTextView.font = FONT_NORMAL(19);
        self.contentTextView.frame = CGRectMake(10, self.authorImageView.frame.origin.y + self.authorImageView.frame.size.height + 10, screenWidth - 20, 200);
    }
    self.contentTextView.textColor = [UIColor blackColor];
    
    self.contentTextView.textAlignment = NSTextAlignmentRight;
    [scrollView addSubview:self.contentTextView];
    
    scrollView.contentSize = CGSizeMake(screenWidth, [self getHeightOfString:_dictionary.LPContent] + 350);
    
    UIButton *playButton = [CustomButton initButtonWithImage:[UIImage imageNamed:@"play icon"] withFrame:CGRectMake(10, _contentTextView.frame.origin.y+ _contentTextView.frame.size.height + 5, 40, 40)];
    [playButton addTarget:self action:@selector(audioButtonAction) forControlEvents:UIControlEventTouchUpInside];
    if (IS_IPAD) {
        playButton.frame = CGRectMake(10, 150, 40, 40);
    }
    [scrollView addSubview:playButton];
    
    UIImageView *audioSampleImageView = [[UIImageView alloc]initWithFrame:CGRectMake(70, _contentTextView.frame.origin.y+ _contentTextView.frame.size.height + 5, screenWidth - 130, 30)];
    audioSampleImageView.image = [UIImage imageNamed:@"progress play"];
    [scrollView addSubview:audioSampleImageView];
    
    namesScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, _contentTextView.frame.origin.y+ _contentTextView.frame.size.height + 60, screenWidth, 40)];
    namesScrollView.contentSize = CGSizeMake(screenWidth * 2, 40);
    [scrollView addSubview:namesScrollView];
    
        //52 × 49
    self.heartButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - 40, _contentTextView.frame.origin.y+ _contentTextView.frame.size.height + 105, 52 * 0.4, 49*0.4)];
    [self.heartButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
    [self.heartButton addTarget:self action:@selector(likeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:self.heartButton];
    
    self.likeCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 70, _contentTextView.frame.origin.y+ _contentTextView.frame.size.height + 105, 25, 20)];
    self.likeCountLabel.font = FONT_NORMAL(11);
    self.likeCountLabel.minimumScaleFactor = 0.7;
    self.likeCountLabel.textColor = [UIColor blackColor];
    self.likeCountLabel.textAlignment = NSTextAlignmentRight;
    self.likeCountLabel.adjustsFontSizeToFitWidth = YES;
    [scrollView addSubview:self.likeCountLabel];
    if ([_dictionary.LPTVLikes_count length] == 0) {
        _likeCountLabel.text = [NSString stringWithFormat:@"%ld", (long)_dictionary.LPLikes_count];
    } else {
        _likeCountLabel.text = _dictionary.LPTVLikes_count;
    }
    
        //46 × 49
    self.commentImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 100, _contentTextView.frame.origin.y+ _contentTextView.frame.size.height + 105, 46*0.4, 49*0.4)];
    self.commentImageView.image = [UIImage imageNamed:@"comment"];
    self.commentImageView.userInteractionEnabled = YES;
    self.commentImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(commentImageViewAction:)];
    [self.commentImageView addGestureRecognizer:tap2];
    [scrollView addSubview:self.commentImageView];
    
    self.commentCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 126, _contentTextView.frame.origin.y+ _contentTextView.frame.size.height + 105, 25, 20)];
    self.commentCountLabel.font = FONT_NORMAL(11);
    self.commentCountLabel.text = _dictionary.LPRecommends_count;
    self.commentCountLabel.minimumScaleFactor = 0.7;
    self.commentCountLabel.textColor = [UIColor blueColor];
    self.commentCountLabel.textAlignment = NSTextAlignmentRight;
    self.commentCountLabel.adjustsFontSizeToFitWidth = YES;
    [scrollView addSubview:self.commentCountLabel];
    
    
        //46 × 43
    self.favButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - 150, _contentTextView.frame.origin.y+ _contentTextView.frame.size.height + 105, 46 * 0.4, 43 * 0.4)];
    [self.favButton setImage:[UIImage imageNamed:@"fav off"] forState:UIControlStateNormal];
    [self.favButton addTarget:self action:@selector(favButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:self.favButton];
    
        //35 × 44
    self.shareButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - 180, _contentTextView.frame.origin.y+ _contentTextView.frame.size.height + 105, 35*0.4, 44*0.4)];
    [self.shareButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [self.shareButton addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:self.shareButton];
    
    
    if ([_dictionary.LPTVFavorite integerValue] == 0) {
        [_favButton setImage:[UIImage imageNamed:@"fav off"] forState:UIControlStateNormal];
    }else{
        [_favButton setImage:[UIImage imageNamed:@"fav on"] forState:UIControlStateNormal];
    }
    
    if ([_dictionary.LPTVLiked integerValue] == 0) {
        [_heartButton setImage:[UIImage imageNamed:@"like icon"] forState:UIControlStateNormal];
    }else{
        [_heartButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
    }
    
    self.dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, _favButton.frame.origin.y + 4, 100, 25)];
    self.dateLabel.font = FONT_NORMAL(11);
    self.dateLabel.minimumScaleFactor = 0.7;
    self.dateLabel.textColor = [UIColor lightGrayColor];
    self.dateLabel.textAlignment = NSTextAlignmentLeft;
    self.dateLabel.adjustsFontSizeToFitWidth = YES;
        //date
    NSDateFormatter *currentDateFormatter = [[NSDateFormatter alloc]init];
    [currentDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *endDate = [NSDate date];
    
    double timestampval = [_dictionary.LPTVPublish_date doubleValue];
    NSTimeInterval timestamp = (NSTimeInterval)timestampval;
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
    _dateLabel.text = [NSString stringWithFormat:@"%@",
                       [TimeAgoViewController timeIntervalWithStartDate:startDate withEndDate:endDate]];
    [scrollView addSubview:self.dateLabel];
    
    scrollView.contentSize = CGSizeMake(screenWidth, _favButton.frame.origin.y + 150);
}

- (void)makeBodyForVideo{
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 70, screenWidth, screenHeight - 70)];
    [self.view addSubview:scrollView];
    
    if (([_dictionary.LPImageUrl length] > 10) || ([_dictionary.LPTVImageUrl length] > 10)) {
        self.postImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenWidth * 0.42)];
        self.postImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.postImageView.clipsToBounds = YES;
            //post image
        if ([_dictionary.LPTVImageUrl length] == 0) {
            [_postImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", _dictionary.LPImageUrl]] placeholderImage:[UIImage imageNamed:@"broken_image"]];
        }else{
            [_postImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", _dictionary.LPTVImageUrl]] placeholderImage:[UIImage imageNamed:@"broken_image"]];
        }
        [scrollView addSubview:self.postImageView];
        
    }
    
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, self.postImageView.frame.origin.y + self.postImageView.frame.size.height + 70, screenWidth - 110, 60)];
    self.titleLabel.font = FONT_BOLD(17);
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.minimumScaleFactor = 0.7;
    self.titleLabel.textAlignment = NSTextAlignmentRight;
    if ([_dictionary.LPTVTitle length] == 0) {
        self.titleLabel.text = _dictionary.LPTitle;
    } else {
        self.titleLabel.text = _dictionary.LPTVTitle;
    }
    
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
        //[scrollView addSubview:self.titleLabel];
    
        //268 × 75
    UIImageView *categoryBGImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 107.2, 30)];
    categoryBGImageView.image = [UIImage imageNamed:@"kadr"];
    [self.postImageView addSubview:categoryBGImageView];
    
    self.categoryLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, categoryBGImageView.frame.size.width, categoryBGImageView.frame.size.height)];
    self.categoryLabel.font = FONT_MEDIUM(11);
    self.categoryLabel.minimumScaleFactor = 0.7;
    self.categoryLabel.textColor = [UIColor whiteColor];
    self.categoryLabel.textAlignment = NSTextAlignmentCenter;
    self.categoryLabel.adjustsFontSizeToFitWidth = YES;
    if ([_dictionary.LPTVCategoryName length] == 0) {
        _categoryLabel.text = _dictionary.LPCategoryName;
    }else{
        _categoryLabel.text = _dictionary.LPTVCategoryName;
    }
    [categoryBGImageView addSubview:self.categoryLabel];
    
    NSInteger authorImageWidth = 60;
    self.authorImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - authorImageWidth - 20, self.postImageView.frame.origin.y + self.postImageView.frame.size.height + 10, authorImageWidth, authorImageWidth)];
    self.authorImageView.layer.cornerRadius = authorImageWidth / 2;
    self.authorImageView.clipsToBounds = YES;
    if ([_dictionary.LPTVUserAvatarUrl length] == 0) {
        [_authorImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", _dictionary.LPUserAvatarUrl]] placeholderImage:[UIImage imageNamed:@"icon upload ax"]];
    } else {
        [_authorImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", _dictionary.LPTVUserAvatarUrl]] placeholderImage:[UIImage imageNamed:@"icon upload ax"]];
    }
    
    _authorImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]init];
        [tap addTarget:self action:@selector(tapOnAuthorImage:)];
        [_authorImageView addGestureRecognizer:tap];
    [scrollView addSubview:self.authorImageView];
    
    self.authorNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, self.authorImageView.frame.origin.y + 10, screenWidth - authorImageWidth - 40, 25)];
    self.authorNameLabel.font = FONT_MEDIUM(13);
    self.authorNameLabel.minimumScaleFactor = 0.7;
    self.authorNameLabel.textColor = [UIColor blackColor];
    self.authorNameLabel.textAlignment = NSTextAlignmentRight;
    self.authorNameLabel.adjustsFontSizeToFitWidth = YES;
    if ([_dictionary.LPTVUserTitle length] == 0) {
        _authorNameLabel.text = _dictionary.LPUserTitle;
    }else{
        _authorNameLabel.text = _dictionary.LPTVUserTitle;
    }
    
    [scrollView addSubview:self.authorNameLabel];
    
    UIButton *moreButton = [CustomButton initButtonWithImage:[UIImage imageNamed:@"moreButton"] withFrame:CGRectMake(10, self.authorNameLabel.frame.origin.y, 30, 30)];
    [moreButton addTarget:self action:@selector(moreButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:moreButton];
    
        //    self.authorJobLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, self.authorImageView.frame.origin.y + 25, screenWidth - authorImageWidth - 40, 25)];
        //    self.authorJobLabel.font = FONT_NORMAL(11);
        //    self.authorJobLabel.minimumScaleFactor = 0.7;
        //    self.authorJobLabel.textColor = [UIColor blackColor];
        //    self.authorJobLabel.textAlignment = NSTextAlignmentRight;
        //    self.authorJobLabel.adjustsFontSizeToFitWidth = YES;
        //    if ([_dictionary.LPTVUserJobTitle length] == 0) {
        //        _authorJobLabel.text = _dictionary.LPUserJobTitle;
        //    } else {
        //        _authorJobLabel.text = _dictionary.LPTVUserJobTitle;
        //    }
        //
        //    [scrollView addSubview:self.authorJobLabel];
    
        //self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(10, self.authorImageView.frame.origin.y + self.authorImageView.frame.size.height + 10, screenWidth - 20, /*[self getHeightOfString:_dictionary.LPTVContentHTML] - */10)];
        //self.webView.delegate = self;
        //self.webView.layer.borderColor = [UIColor redColor].CGColor;
        //self.webView.layer.borderWidth = 2.0;
        //self.webView.clipsToBounds = YES;
    /*NSString* path = [[NSBundle mainBundle] pathForResource:@"html"
     ofType:@"txt"];
     NSString* content = [NSString stringWithContentsOfFile:path
     encoding:NSUTF8StringEncoding
     error:NULL];
     */
        //    NSMutableString *htmlContent = [[NSMutableString alloc]init];
        //    [htmlContent insertString:[NSString stringWithFormat:@"<html dir=\"rtl\"><body bg=\"red\" style=\"width:100%%;word-wrap:break-word;<!--background-color:powderblue-->;\" align=\"justify\"  id=\"body\">%@</body></html>", _dictionary.LPTVContentHTML] atIndex:0];
        //    [self.webView loadHTMLString:htmlContent baseURL:nil];
        //[scrollView addSubview:_webView];
    
    self.contentTextView = [[UITextView alloc]initWithFrame:CGRectMake(10, self.authorImageView.frame.origin.y + self.authorImageView.frame.size.height + 10, screenWidth - 20, [self getHeightOfString:_dictionary.LPContent] +50)];
    self.contentTextView.userInteractionEnabled = NO;
    self.contentTextView.font = FONT_NORMAL(15);
    _contentTextView.text = _dictionary.LPContent;
    if (IS_IPAD) {
        self.contentTextView.font = FONT_NORMAL(19);
        self.contentTextView.frame = CGRectMake(10, self.authorImageView.frame.origin.y + self.authorImageView.frame.size.height + 10, screenWidth - 20, 200);
    }
    self.contentTextView.textColor = [UIColor blackColor];
    
    self.contentTextView.textAlignment = NSTextAlignmentRight;
    [scrollView addSubview:self.contentTextView];
    
    scrollView.contentSize = CGSizeMake(screenWidth, [self getHeightOfString:_dictionary.LPContent] + 350);
    
        //post image
        //    UIImageView *snapshotImageView = [ImageResizer resizeImageWithImage:[UIImage imageNamed:@"logo"] withWidth:screenWidth withPoint:CGPointMake(0, _contentTextView.frame.origin.y+ _contentTextView.frame.size.height + 5)];
        //    [scrollView addSubview:snapshotImageView];
    UIImageView *snapshotImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, _contentTextView.frame.origin.y + _contentTextView.frame.size.height, screenWidth, screenWidth * 0.7)];
    snapshotImageView.userInteractionEnabled = YES;
    [scrollView addSubview:snapshotImageView];
    [snapshotImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [_dictionary objectForKey:@"video_snapshot"]]] placeholderImage:[UIImage imageNamed:@"broken_image"]];
    
    UIButton *playButton = [CustomButton initButtonWithImage:[UIImage imageNamed:@"iconvideo"] withFrame:CGRectMake(screenWidth/2 - 20, snapshotImageView.frame.size.height /2 - 20, 40, 40)];
    [playButton addTarget:self action:@selector(videoButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [snapshotImageView addSubview:playButton];
    
    UIImageView *audioSampleImageView = [[UIImageView alloc]initWithFrame:CGRectMake(70, _contentTextView.frame.origin.y+ _contentTextView.frame.size.height + 5, screenWidth - 130, 30)];
    audioSampleImageView.image = [UIImage imageNamed:@"progress play"];
        //[scrollView addSubview:audioSampleImageView];
    
    namesScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, snapshotImageView.frame.origin.y+ snapshotImageView.frame.size.height + 5, screenWidth, 40)];
    namesScrollView.contentSize = CGSizeMake(screenWidth * 2, 40);
    [scrollView addSubview:namesScrollView];
    
    
        //52 × 49
    self.heartButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - 40, snapshotImageView.frame.origin.y+ snapshotImageView.frame.size.height + 50, 52 * 0.4, 49*0.4)];
    [self.heartButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
    [self.heartButton addTarget:self action:@selector(likeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:self.heartButton];
    
    self.likeCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 70, snapshotImageView.frame.origin.y+ snapshotImageView.frame.size.height + 50, 25, 20)];
    self.likeCountLabel.font = FONT_NORMAL(11);
    self.likeCountLabel.minimumScaleFactor = 0.7;
    self.likeCountLabel.textColor = [UIColor blackColor];
    self.likeCountLabel.textAlignment = NSTextAlignmentRight;
    self.likeCountLabel.adjustsFontSizeToFitWidth = YES;
    [scrollView addSubview:self.likeCountLabel];
    if ([_dictionary.LPTVLikes_count length] == 0) {
        _likeCountLabel.text = [NSString stringWithFormat:@"%ld", (long)_dictionary.LPLikes_count];
    } else {
        _likeCountLabel.text = _dictionary.LPTVLikes_count;
    }
    
        //46 × 49
    self.commentImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 100, snapshotImageView.frame.origin.y+ snapshotImageView.frame.size.height + 50, 46*0.4, 49*0.4)];
    self.commentImageView.image = [UIImage imageNamed:@"comment"];
    self.commentImageView.userInteractionEnabled = YES;
    self.commentImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(commentImageViewAction:)];
    [self.commentImageView addGestureRecognizer:tap2];
    [scrollView addSubview:self.commentImageView];
    
    self.commentCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 126, snapshotImageView.frame.origin.y+ snapshotImageView.frame.size.height + 50, 25, 20)];
    self.commentCountLabel.font = FONT_NORMAL(11);
    self.commentCountLabel.text = _dictionary.LPRecommends_count;
    self.commentCountLabel.minimumScaleFactor = 0.7;
    self.commentCountLabel.textColor = [UIColor blueColor];
    self.commentCountLabel.textAlignment = NSTextAlignmentRight;
    self.commentCountLabel.adjustsFontSizeToFitWidth = YES;
    [scrollView addSubview:self.commentCountLabel];
    
    
        //46 × 43
    self.favButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - 150, snapshotImageView.frame.origin.y+ snapshotImageView.frame.size.height + 50, 46 * 0.4, 43 * 0.4)];
    [self.favButton setImage:[UIImage imageNamed:@"fav off"] forState:UIControlStateNormal];
    [self.favButton addTarget:self action:@selector(favButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:self.favButton];
    
        //35 × 44
    self.shareButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - 180, snapshotImageView.frame.origin.y+ snapshotImageView.frame.size.height + 50, 35*0.4, 44*0.4)];
    [self.shareButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [self.shareButton addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:self.shareButton];
    
    
    if ([_dictionary.LPTVFavorite integerValue] == 0) {
        [_favButton setImage:[UIImage imageNamed:@"fav off"] forState:UIControlStateNormal];
    }else{
        [_favButton setImage:[UIImage imageNamed:@"fav on"] forState:UIControlStateNormal];
    }
    
    if ([_dictionary.LPTVLiked integerValue] == 0) {
        [_heartButton setImage:[UIImage imageNamed:@"like icon"] forState:UIControlStateNormal];
    }else{
        [_heartButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
    }
    
    self.dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, _favButton.frame.origin.y + 4, 100, 25)];
    self.dateLabel.font = FONT_NORMAL(11);
    self.dateLabel.minimumScaleFactor = 0.7;
    self.dateLabel.textColor = [UIColor lightGrayColor];
    self.dateLabel.textAlignment = NSTextAlignmentLeft;
    self.dateLabel.adjustsFontSizeToFitWidth = YES;
        //date
    NSDateFormatter *currentDateFormatter = [[NSDateFormatter alloc]init];
    [currentDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *endDate = [NSDate date];
    
    double timestampval = [_dictionary.LPTVPublish_date doubleValue];
    NSTimeInterval timestamp = (NSTimeInterval)timestampval;
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
    _dateLabel.text = [NSString stringWithFormat:@"%@",
                       [TimeAgoViewController timeIntervalWithStartDate:startDate withEndDate:endDate]];
    [scrollView addSubview:self.dateLabel];
    
    scrollView.contentSize = CGSizeMake(screenWidth, _favButton.frame.origin.y + 150);
    
}

- (void)makeBodyForDocument{
    
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 70, screenWidth, screenHeight - 70)];
    scrollView.contentSize = CGSizeMake(screenWidth, [self getHeightOfString:_dictionary.LPContent] + 200);
    [self.view addSubview:scrollView];
    
    if (([_dictionary.LPImageUrl length] > 10) || ([_dictionary.LPTVImageUrl length] > 10)) {
        self.postImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenWidth * 0.42)];
        self.postImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.postImageView.clipsToBounds = YES;
            //post image
        if ([_dictionary.LPTVImageUrl length] == 0) {
            [_postImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", _dictionary.LPImageUrl]] placeholderImage:[UIImage imageNamed:@"broken_image"]];
        }else{
            [_postImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", _dictionary.LPTVImageUrl]] placeholderImage:[UIImage imageNamed:@"broken_image"]];
        }
        [scrollView addSubview:self.postImageView];
    }
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, self.postImageView.frame.origin.y + self.postImageView.frame.size.height + 70, screenWidth - 110, 60)];
    self.titleLabel.font = FONT_BOLD(17);
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.minimumScaleFactor = 0.7;
    self.titleLabel.textAlignment = NSTextAlignmentRight;
    if ([_dictionary.LPTVTitle length] == 0) {
        self.titleLabel.text = _dictionary.LPTitle;
    } else {
        self.titleLabel.text = _dictionary.LPTVTitle;
    }
    
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
        //[scrollView addSubview:self.titleLabel];
    
        //268 × 75
    UIImageView *categoryBGImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 107.2, 30)];
    categoryBGImageView.image = [UIImage imageNamed:@"kadr"];
    [self.postImageView addSubview:categoryBGImageView];
    
    self.commentCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 5, 20, 20)];
    self.commentCountLabel.font = FONT_NORMAL(11);
    self.commentCountLabel.minimumScaleFactor = 0.7;
    self.commentCountLabel.textColor = [UIColor grayColor];
    self.commentCountLabel.textAlignment = NSTextAlignmentLeft;
    self.commentCountLabel.adjustsFontSizeToFitWidth = YES;
    if ([_dictionary.LPTVRecommends_count length] == 0) {
        _commentCountLabel.text = _dictionary.LPRecommends_count;
    } else {
        _commentCountLabel.text = _dictionary.LPTVRecommends_count;
    }
    
        //[scrollView addSubview:self.commentCountLabel];
    
    self.categoryLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, categoryBGImageView.frame.size.width, categoryBGImageView.frame.size.height)];
    self.categoryLabel.font = FONT_MEDIUM(11);
    self.categoryLabel.minimumScaleFactor = 0.7;
    self.categoryLabel.textColor = [UIColor whiteColor];
    self.categoryLabel.textAlignment = NSTextAlignmentCenter;
    self.categoryLabel.adjustsFontSizeToFitWidth = YES;
    if ([_dictionary.LPTVCategoryName length] == 0) {
        _categoryLabel.text = _dictionary.LPCategoryName;
    }else{
        _categoryLabel.text = _dictionary.LPTVCategoryName;
    }
    [categoryBGImageView addSubview:self.categoryLabel];
    
    NSInteger authorImageWidth = 60;
    self.authorImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - authorImageWidth - 20, self.postImageView.frame.origin.y + self.postImageView.frame.size.height + 10, authorImageWidth, authorImageWidth)];
    self.authorImageView.layer.cornerRadius = authorImageWidth / 2;
    self.authorImageView.clipsToBounds = YES;
    if ([_dictionary.LPTVUserAvatarUrl length] == 0) {
        [_authorImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", _dictionary.LPUserAvatarUrl]] placeholderImage:[UIImage imageNamed:@"icon upload ax"]];
    } else {
        [_authorImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", _dictionary.LPTVUserAvatarUrl]] placeholderImage:[UIImage imageNamed:@"icon upload ax"]];
    }
    
    _authorImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]init];
    [tap addTarget:self action:@selector(tapOnAuthorImage:)];
    [_authorImageView addGestureRecognizer:tap];
    [scrollView addSubview:self.authorImageView];
    
    self.authorNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, self.authorImageView.frame.origin.y + 10, screenWidth - authorImageWidth - 40, 25)];
    self.authorNameLabel.font = FONT_MEDIUM(13);
    self.authorNameLabel.minimumScaleFactor = 0.7;
    self.authorNameLabel.textColor = [UIColor blackColor];
    self.authorNameLabel.textAlignment = NSTextAlignmentRight;
    self.authorNameLabel.adjustsFontSizeToFitWidth = YES;
    if ([_dictionary.LPTVUserTitle length] == 0) {
        _authorNameLabel.text = _dictionary.LPUserTitle;
    }else{
        _authorNameLabel.text = _dictionary.LPTVUserTitle;
    }
    
    [scrollView addSubview:self.authorNameLabel];
    
    UIButton *moreButton = [CustomButton initButtonWithImage:[UIImage imageNamed:@"moreButton"] withFrame:CGRectMake(10, self.authorNameLabel.frame.origin.y, 30, 30)];
    [moreButton addTarget:self action:@selector(moreButtonAction) forControlEvents:UIControlEventTouchUpInside];
    moreButton.tintColor = COLOR_5;
    [scrollView addSubview:moreButton];
    
        //    self.authorJobLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, self.authorImageView.frame.origin.y + 25, screenWidth - authorImageWidth - 40, 25)];
        //    self.authorJobLabel.font = FONT_NORMAL(11);
        //    self.authorJobLabel.minimumScaleFactor = 0.7;
        //    self.authorJobLabel.textColor = [UIColor blackColor];
        //    self.authorJobLabel.textAlignment = NSTextAlignmentRight;
        //    self.authorJobLabel.adjustsFontSizeToFitWidth = YES;
        //    if ([_dictionary.LPTVUserJobTitle length] == 0) {
        //        _authorJobLabel.text = _dictionary.LPUserJobTitle;
        //    } else {
        //        _authorJobLabel.text = _dictionary.LPTVUserJobTitle;
        //    }
        //
        //    [scrollView addSubview:self.authorJobLabel];
    
        //self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(10, self.authorImageView.frame.origin.y + self.authorImageView.frame.size.height + 10, screenWidth - 20, /*[self getHeightOfString:_dictionary.LPTVContentHTML] - */10)];
        //self.webView.delegate = self;
        //self.webView.layer.borderColor = [UIColor redColor].CGColor;
        //self.webView.layer.borderWidth = 2.0;
        //self.webView.clipsToBounds = YES;
    /*NSString* path = [[NSBundle mainBundle] pathForResource:@"html"
     ofType:@"txt"];
     NSString* content = [NSString stringWithContentsOfFile:path
     encoding:NSUTF8StringEncoding
     error:NULL];
     */
        //    NSMutableString *htmlContent = [[NSMutableString alloc]init];
        //    [htmlContent insertString:[NSString stringWithFormat:@"<html dir=\"rtl\"><body bg=\"red\" style=\"width:100%%;word-wrap:break-word;<!--background-color:powderblue-->;\" align=\"justify\"  id=\"body\">%@</body></html>", _dictionary.LPTVContentHTML] atIndex:0];
        //    [self.webView loadHTMLString:htmlContent baseURL:nil];
        //[scrollView addSubview:_webView];
    
    self.contentTextView = [[UITextView alloc]initWithFrame:CGRectMake(10, self.authorImageView.frame.origin.y + self.authorImageView.frame.size.height + 10, screenWidth - 20, [self getHeightOfString:_dictionary.LPContent]+50 )];
    self.contentTextView.userInteractionEnabled = NO;
    self.contentTextView.font = FONT_NORMAL(15);
    _contentTextView.text = _dictionary.LPContent;
    if (IS_IPAD) {
        self.contentTextView.font = FONT_NORMAL(19);
        self.contentTextView.frame = CGRectMake(10, self.authorImageView.frame.origin.y + self.authorImageView.frame.size.height + 10, screenWidth - 20, 200);
    }
    self.contentTextView.textColor = [UIColor blackColor];
    
    self.contentTextView.textAlignment = NSTextAlignmentRight;
    [scrollView addSubview:self.contentTextView];
    
    UIView *documentView;
    if ([[_dictionary objectForKey:@"document"]length] > 10) {
        documentView = [[UIImageView alloc]initWithFrame:CGRectMake(0, _contentTextView.frame.origin.y + _contentTextView.frame.size.height + 5, screenWidth, 60)];
        documentView.userInteractionEnabled = YES;
            //documentView.backgroundColor = [UIColor grayColor];
        [scrollView addSubview:documentView];
        
        UIImageView *attachImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 50, 15, 25, 25)];
        attachImageView.image = [UIImage imageNamed:@"attach"];
        [documentView addSubview:attachImageView];
        
        self.likeCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 160, 5, 100, 45)];
        self.likeCountLabel.font = FONT_NORMAL(15);
        self.likeCountLabel.minimumScaleFactor = 0.7;
        self.likeCountLabel.text = @"فایل مستند";
        self.likeCountLabel.textColor = COLOR_5;
        self.likeCountLabel.textAlignment = NSTextAlignmentRight;
        self.likeCountLabel.adjustsFontSizeToFitWidth = YES;
        [documentView addSubview:self.likeCountLabel];
        
        UIButton *openDocButton = [CustomButton initButtonWithTitle:@"" withTitleColor:[UIColor redColor] withBackColor:[UIColor clearColor] withFrame:CGRectMake(0, 0, screenWidth, 60)];
        [openDocButton addTarget:self action:@selector(openDocumentAction) forControlEvents:UIControlEventTouchUpInside];
        [documentView addSubview:openDocButton];
        
        
        
    } else {
        documentView = [[UIImageView alloc]initWithFrame:CGRectMake(0, _contentTextView.frame.origin.y + _contentTextView.frame.size.height, screenWidth, 0 * 0.7)];
        [scrollView addSubview:documentView];
    }
    
    namesScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, documentView.frame.origin.y+ documentView.frame.size.height + 5, screenWidth, 40)];
    namesScrollView.contentSize = CGSizeMake(screenWidth * 2, 40);
    [scrollView addSubview:namesScrollView];
        //52 × 49
    self.heartButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - 40, documentView.frame.origin.y+ documentView.frame.size.height + 50, 52 * 0.4, 49*0.4)];
    [self.heartButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
    [self.heartButton addTarget:self action:@selector(likeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:self.heartButton];
    
    self.likeCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 70, documentView.frame.origin.y+ documentView.frame.size.height + 50, 25, 20)];
    self.likeCountLabel.font = FONT_NORMAL(11);
    self.likeCountLabel.minimumScaleFactor = 0.7;
    self.likeCountLabel.textColor = [UIColor blackColor];
    self.likeCountLabel.textAlignment = NSTextAlignmentRight;
    self.likeCountLabel.adjustsFontSizeToFitWidth = YES;
    [scrollView addSubview:self.likeCountLabel];
    if ([_dictionary.LPTVLikes_count length] == 0) {
        _likeCountLabel.text = [NSString stringWithFormat:@"%ld", (long)_dictionary.LPLikes_count];
    } else {
        _likeCountLabel.text = _dictionary.LPTVLikes_count;
    }
    
        //46 × 49
    self.commentImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 100, documentView.frame.origin.y+ documentView.frame.size.height + 50, 46*0.4, 49*0.4)];
    self.commentImageView.image = [UIImage imageNamed:@"comment"];
    self.commentImageView.userInteractionEnabled = YES;
    self.commentImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(commentImageViewAction:)];
    [self.commentImageView addGestureRecognizer:tap2];
    [scrollView addSubview:self.commentImageView];
    
    self.commentCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 126, documentView.frame.origin.y+ documentView.frame.size.height + 50, 25, 20)];
    self.commentCountLabel.font = FONT_NORMAL(11);
    self.commentCountLabel.text = _dictionary.LPRecommends_count;
    self.commentCountLabel.minimumScaleFactor = 0.7;
    self.commentCountLabel.textColor = [UIColor blueColor];
    self.commentCountLabel.textAlignment = NSTextAlignmentRight;
    self.commentCountLabel.adjustsFontSizeToFitWidth = YES;
    [scrollView addSubview:self.commentCountLabel];
    
        //46 × 43
    self.favButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - 150, documentView.frame.origin.y+ documentView.frame.size.height + 50, 46 * 0.4, 43 * 0.4)];
    [self.favButton setImage:[UIImage imageNamed:@"fav off"] forState:UIControlStateNormal];
    [self.favButton addTarget:self action:@selector(favButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:self.favButton];
    
        //35 × 44
    self.shareButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - 180, documentView.frame.origin.y+ documentView.frame.size.height + 50, 35*0.4, 44*0.4)];
    [self.shareButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [self.shareButton addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:self.shareButton];
    
    
    if ([_dictionary.LPTVFavorite integerValue] == 0) {
        [_favButton setImage:[UIImage imageNamed:@"fav off"] forState:UIControlStateNormal];
    }else{
        [_favButton setImage:[UIImage imageNamed:@"fav on"] forState:UIControlStateNormal];
    }
    
    if ([_dictionary.LPTVLiked integerValue] == 0) {
        [_heartButton setImage:[UIImage imageNamed:@"like icon"] forState:UIControlStateNormal];
    }else{
        [_heartButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
    }
    
    self.dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, _favButton.frame.origin.y, 100, 25)];
    self.dateLabel.font = FONT_NORMAL(11);
    self.dateLabel.minimumScaleFactor = 0.7;
    self.dateLabel.textColor = [UIColor lightGrayColor];
    self.dateLabel.textAlignment = NSTextAlignmentLeft;
    self.dateLabel.adjustsFontSizeToFitWidth = YES;
        //date
    NSDateFormatter *currentDateFormatter = [[NSDateFormatter alloc]init];
    [currentDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *endDate = [NSDate date];
    
    double timestampval = [_dictionary.LPTVPublish_date doubleValue];
    NSTimeInterval timestamp = (NSTimeInterval)timestampval;
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
    _dateLabel.text = [NSString stringWithFormat:@"%@",
                       [TimeAgoViewController timeIntervalWithStartDate:startDate withEndDate:endDate]];
    [scrollView addSubview:self.dateLabel];
    
    scrollView.contentSize = CGSizeMake(screenWidth, _favButton.frame.origin.y + 150);
    
}

- (void)makeBodyForVoting{
        //NSLog(@"%@", _dictionary);
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 70, screenWidth, screenHeight - 70)];
    scrollView.contentSize = CGSizeMake(screenWidth, [self getHeightOfString:_dictionary.LPContent] + 200);
    [self.view addSubview:scrollView];
    
    if (([_dictionary.LPImageUrl length] > 10) || ([_dictionary.LPTVImageUrl length] > 10)) {
        self.postImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenWidth * 0.42)];
        self.postImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.postImageView.clipsToBounds = YES;
            //post image
        if ([_dictionary.LPTVImageUrl length] == 0) {
            [_postImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", _dictionary.LPImageUrl]] placeholderImage:[UIImage imageNamed:@"broken_image"]];
        }else{
            [_postImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", _dictionary.LPTVImageUrl]] placeholderImage:[UIImage imageNamed:@"broken_image"]];
        }
        [scrollView addSubview:self.postImageView];
    }
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, self.postImageView.frame.origin.y + self.postImageView.frame.size.height + 70, screenWidth - 110, 60)];
    self.titleLabel.font = FONT_BOLD(17);
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.minimumScaleFactor = 0.7;
    self.titleLabel.textAlignment = NSTextAlignmentRight;
    if ([_dictionary.LPTVTitle length] == 0) {
        self.titleLabel.text = _dictionary.LPTitle;
    } else {
        self.titleLabel.text = _dictionary.LPTVTitle;
    }
    
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
        //[scrollView addSubview:self.titleLabel];
    
        //268 × 75
    UIImageView *categoryBGImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 107.2, 30)];
    categoryBGImageView.image = [UIImage imageNamed:@"kadr"];
    [self.postImageView addSubview:categoryBGImageView];
    
    self.commentCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 5, 20, 20)];
    self.commentCountLabel.font = FONT_NORMAL(11);
    self.commentCountLabel.minimumScaleFactor = 0.7;
    self.commentCountLabel.textColor = [UIColor grayColor];
    self.commentCountLabel.textAlignment = NSTextAlignmentLeft;
    self.commentCountLabel.adjustsFontSizeToFitWidth = YES;
    if ([_dictionary.LPTVRecommends_count length] == 0) {
        _commentCountLabel.text = _dictionary.LPRecommends_count;
    } else {
        _commentCountLabel.text = _dictionary.LPTVRecommends_count;
    }
    
        //[scrollView addSubview:self.commentCountLabel];
    
    self.categoryLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, categoryBGImageView.frame.size.width, categoryBGImageView.frame.size.height)];
    self.categoryLabel.font = FONT_MEDIUM(11);
    self.categoryLabel.minimumScaleFactor = 0.7;
    self.categoryLabel.textColor = [UIColor whiteColor];
    self.categoryLabel.textAlignment = NSTextAlignmentCenter;
    self.categoryLabel.adjustsFontSizeToFitWidth = YES;
    if ([_dictionary.LPTVCategoryName length] == 0) {
        _categoryLabel.text = _dictionary.LPCategoryName;
    }else{
        _categoryLabel.text = _dictionary.LPTVCategoryName;
    }
    [categoryBGImageView addSubview:self.categoryLabel];
    
    NSInteger authorImageWidth = 60;
    self.authorImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - authorImageWidth - 20, self.postImageView.frame.origin.y + self.postImageView.frame.size.height + 10, authorImageWidth, authorImageWidth)];
    self.authorImageView.layer.cornerRadius = authorImageWidth / 2;
    self.authorImageView.clipsToBounds = YES;
    if ([_dictionary.LPTVUserAvatarUrl length] == 0) {
        [_authorImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", _dictionary.LPUserAvatarUrl]] placeholderImage:[UIImage imageNamed:@"icon upload ax"]];
    } else {
        [_authorImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", _dictionary.LPTVUserAvatarUrl]] placeholderImage:[UIImage imageNamed:@"icon upload ax"]];
    }
    
    _authorImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]init];
        [tap addTarget:self action:@selector(tapOnAuthorImage:)];
        [_authorImageView addGestureRecognizer:tap];
    [scrollView addSubview:self.authorImageView];
    
    self.authorNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, self.authorImageView.frame.origin.y + 10, screenWidth - authorImageWidth - 40, 25)];
    self.authorNameLabel.font = FONT_MEDIUM(13);
    self.authorNameLabel.minimumScaleFactor = 0.7;
    self.authorNameLabel.textColor = [UIColor blackColor];
    self.authorNameLabel.textAlignment = NSTextAlignmentRight;
    self.authorNameLabel.adjustsFontSizeToFitWidth = YES;
    if ([_dictionary.LPTVUserTitle length] == 0) {
        _authorNameLabel.text = _dictionary.LPUserTitle;
    }else{
        _authorNameLabel.text = _dictionary.LPTVUserTitle;
    }
    
    [scrollView addSubview:self.authorNameLabel];
    
    UIButton *moreButton = [CustomButton initButtonWithImage:[UIImage imageNamed:@"moreButton"] withFrame:CGRectMake(10, self.authorNameLabel.frame.origin.y, 30, 30)];
    [moreButton addTarget:self action:@selector(moreButtonAction) forControlEvents:UIControlEventTouchUpInside];
    moreButton.tintColor = COLOR_5;
    [scrollView addSubview:moreButton];
    
        //    self.authorJobLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, self.authorImageView.frame.origin.y + 25, screenWidth - authorImageWidth - 40, 25)];
        //    self.authorJobLabel.font = FONT_NORMAL(11);
        //    self.authorJobLabel.minimumScaleFactor = 0.7;
        //    self.authorJobLabel.textColor = [UIColor blackColor];
        //    self.authorJobLabel.textAlignment = NSTextAlignmentRight;
        //    self.authorJobLabel.adjustsFontSizeToFitWidth = YES;
        //    if ([_dictionary.LPTVUserJobTitle length] == 0) {
        //        _authorJobLabel.text = _dictionary.LPUserJobTitle;
        //    } else {
        //        _authorJobLabel.text = _dictionary.LPTVUserJobTitle;
        //    }
        //
        //    [scrollView addSubview:self.authorJobLabel];
    
        //self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(10, self.authorImageView.frame.origin.y + self.authorImageView.frame.size.height + 10, screenWidth - 20, /*[self getHeightOfString:_dictionary.LPTVContentHTML] - */10)];
        //self.webView.delegate = self;
        //self.webView.layer.borderColor = [UIColor redColor].CGColor;
        //self.webView.layer.borderWidth = 2.0;
        //self.webView.clipsToBounds = YES;
    /*NSString* path = [[NSBundle mainBundle] pathForResource:@"html"
     ofType:@"txt"];
     NSString* content = [NSString stringWithContentsOfFile:path
     encoding:NSUTF8StringEncoding
     error:NULL];
     */
        //    NSMutableString *htmlContent = [[NSMutableString alloc]init];
        //    [htmlContent insertString:[NSString stringWithFormat:@"<html dir=\"rtl\"><body bg=\"red\" style=\"width:100%%;word-wrap:break-word;<!--background-color:powderblue-->;\" align=\"justify\"  id=\"body\">%@</body></html>", _dictionary.LPTVContentHTML] atIndex:0];
        //    [self.webView loadHTMLString:htmlContent baseURL:nil];
        //[scrollView addSubview:_webView];
    
    self.contentTextView = [[UITextView alloc]initWithFrame:CGRectMake(10, self.authorImageView.frame.origin.y + self.authorImageView.frame.size.height + 10, screenWidth - 20, [self getHeightOfString:_dictionary.LPContent] +50)];
    self.contentTextView.userInteractionEnabled = NO;
    self.contentTextView.font = FONT_NORMAL(15);
    _contentTextView.text = _dictionary.LPContent;
    if (IS_IPAD) {
        self.contentTextView.font = FONT_NORMAL(19);
        self.contentTextView.frame = CGRectMake(10, self.authorImageView.frame.origin.y + self.authorImageView.frame.size.height + 10, screenWidth - 20, 200);
    }
    self.contentTextView.textColor = [UIColor blackColor];
    
    self.contentTextView.textAlignment = NSTextAlignmentRight;
    [scrollView addSubview:self.contentTextView];
    
    UIImageView *snapshotImageView;
    if ([[_dictionary objectForKey:@"image"]length] > 10) {
        snapshotImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, _contentTextView.frame.origin.y + _contentTextView.frame.size.height, screenWidth, screenWidth * 0.7)];
        snapshotImageView.userInteractionEnabled = YES;
        [scrollView addSubview:snapshotImageView];
        [snapshotImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [_dictionary objectForKey:@"image"]]] placeholderImage:[UIImage imageNamed:@"broken_image"]];
        
    } else {
        snapshotImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, _contentTextView.frame.origin.y + _contentTextView.frame.size.height, screenWidth, 0 * 0.7)];
        snapshotImageView.userInteractionEnabled = YES;
        [scrollView addSubview:snapshotImageView];
    }
    
    
    NSArray *optionsArr = [_dictionary objectForKey:@"options"];
    
    CGFloat yPos = snapshotImageView.frame.origin.y + snapshotImageView.frame.size.height + 5;
    for (NSInteger i = 0; i < [optionsArr count]; i++) {
        NSString *str = [NSString stringWithFormat:@"%@", [[optionsArr objectAtIndex:i]objectForKey:@"text"]];
        
        optionsbutton = [CustomButton initButtonWithTitle:str withTitleColor:COLOR_5 withBackColor:WHITE_COLOR isRounded:YES withFrame:CGRectMake(20, yPos, screenWidth - 40, 30)];
        [optionsbutton addTarget:self action:@selector(VotingAction:) forControlEvents:UIControlEventTouchUpInside];
        optionsbutton.tag = [[[optionsArr objectAtIndex:i]objectForKey:@"id"]integerValue];
        [scrollView addSubview:optionsbutton];
        
        UILabel *percentLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 70, 25)];
        percentLabel.font = FONT_MEDIUM(13);
        percentLabel.text = [NSString stringWithFormat:@"%2.2f %%", [[[optionsArr objectAtIndex:i]objectForKey:@"answers_percent"]floatValue]];
        percentLabel.minimumScaleFactor = 0.7;
        percentLabel.textColor = [COLOR_5 colorWithAlphaComponent:0.4];
        if ([[[optionsArr objectAtIndex:i]objectForKey:@"answered"]integerValue] == 1) {
            percentLabel.textColor = [GREEN_COLOR colorWithAlphaComponent:0.4];
        }
        percentLabel.textAlignment = NSTextAlignmentLeft;
        [optionsbutton addSubview:percentLabel];
        yPos += 35;
    }
    
    namesScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, yPos, screenWidth, 40)];
    namesScrollView.contentSize = CGSizeMake(screenWidth * 2, 40);
    [scrollView addSubview:namesScrollView];
    
        //52 × 49
    self.heartButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - 40, yPos + 50, 52 * 0.4, 49*0.4)];
    [self.heartButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
    [self.heartButton addTarget:self action:@selector(likeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:self.heartButton];
    
    self.likeCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 70, yPos + 50, 25, 20)];
    self.likeCountLabel.font = FONT_NORMAL(11);
    self.likeCountLabel.minimumScaleFactor = 0.7;
    self.likeCountLabel.textColor = [UIColor blackColor];
    self.likeCountLabel.textAlignment = NSTextAlignmentRight;
    self.likeCountLabel.adjustsFontSizeToFitWidth = YES;
    [scrollView addSubview:self.likeCountLabel];
    if ([_dictionary.LPTVLikes_count length] == 0) {
        _likeCountLabel.text = [NSString stringWithFormat:@"%ld", (long)_dictionary.LPLikes_count];
    } else {
        _likeCountLabel.text = _dictionary.LPTVLikes_count;
    }
    
        //46 × 49
    self.commentImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 100, yPos + 50, 46*0.4, 49*0.4)];
    self.commentImageView.image = [UIImage imageNamed:@"comment"];
    self.commentImageView.userInteractionEnabled = YES;
    self.commentImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(commentImageViewAction:)];
    [self.commentImageView addGestureRecognizer:tap2];
    [scrollView addSubview:self.commentImageView];
    
    self.commentCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 126, yPos + 50, 25, 20)];
    self.commentCountLabel.font = FONT_NORMAL(11);
    self.commentCountLabel.text = _dictionary.LPRecommends_count;
    self.commentCountLabel.minimumScaleFactor = 0.7;
    self.commentCountLabel.textColor = [UIColor blueColor];
    self.commentCountLabel.textAlignment = NSTextAlignmentRight;
    self.commentCountLabel.adjustsFontSizeToFitWidth = YES;
    [scrollView addSubview:self.commentCountLabel];
    
        //46 × 43
    self.favButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - 150, yPos + 50, 46 * 0.4, 43 * 0.4)];
    [self.favButton setImage:[UIImage imageNamed:@"fav off"] forState:UIControlStateNormal];
    [self.favButton addTarget:self action:@selector(favButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:self.favButton];
    
        //35 × 44
    self.shareButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - 180, yPos + 50, 35*0.4, 44*0.4)];
    [self.shareButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [self.shareButton addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:self.shareButton];
    
    
    if ([_dictionary.LPTVFavorite integerValue] == 0) {
        [_favButton setImage:[UIImage imageNamed:@"fav off"] forState:UIControlStateNormal];
    }else{
        [_favButton setImage:[UIImage imageNamed:@"fav on"] forState:UIControlStateNormal];
    }
    
    if ([_dictionary.LPTVLiked integerValue] == 0) {
        [_heartButton setImage:[UIImage imageNamed:@"like icon"] forState:UIControlStateNormal];
    }else{
        [_heartButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
    }
    
    self.dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, _favButton.frame.origin.y, 100, 25)];
    self.dateLabel.font = FONT_NORMAL(11);
    self.dateLabel.minimumScaleFactor = 0.7;
    self.dateLabel.textColor = [UIColor lightGrayColor];
    self.dateLabel.textAlignment = NSTextAlignmentLeft;
    self.dateLabel.adjustsFontSizeToFitWidth = YES;
        //date
    NSDateFormatter *currentDateFormatter = [[NSDateFormatter alloc]init];
    [currentDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *endDate = [NSDate date];
    
    double timestampval = [_dictionary.LPTVPublish_date doubleValue];
    NSTimeInterval timestamp = (NSTimeInterval)timestampval;
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
    _dateLabel.text = [NSString stringWithFormat:@"%@",
                       [TimeAgoViewController timeIntervalWithStartDate:startDate withEndDate:endDate]];
    [scrollView addSubview:self.dateLabel];
    
    scrollView.contentSize = CGSizeMake(screenWidth, _favButton.frame.origin.y + 150);
    
        //NSArray *optionsArray = [[tempDic objectForKey:@"data"]objectForKey:@"options"];
    for (NSInteger i = 0; i < [optionsArr count] ; i++) {
        for(id view in [scrollView subviews]){
            if([view isKindOfClass:[UIButton class]]){
                UIButton *btn = (UIButton *)view;
                if (btn.tag == [[[optionsArr objectAtIndex:i]objectForKey:@"id"]integerValue]) {
                    CGFloat percent = [[[optionsArr objectAtIndex:i]objectForKey:@"answers_percent"]integerValue];
                    CGFloat width = btn.frame.size.width;
                    CGFloat height = btn.frame.size.height;
                    CGFloat xpos = ((100 - percent)/100) * width;
                        //                    if (xpos > 50) {
                        //                        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        //                    }
                    UIView *coloredView = [[UIView alloc]initWithFrame:CGRectMake(xpos, 0, width - xpos, height)];
                    coloredView.backgroundColor = [COLOR_5 colorWithAlphaComponent:0.4];
                    if ([[[optionsArr objectAtIndex:i]objectForKey:@"answered"]integerValue] == 1) {
                        coloredView.backgroundColor = [GREEN_COLOR colorWithAlphaComponent:0.4];
                    }
                    coloredView.tag = 120;
                    UIView *v = [btn viewWithTag:120];
                    v.hidden = YES;
                    [btn bringSubviewToFront:v];
                    [v removeFromSuperview];
                    [btn addSubview:coloredView];
                }
            }
        }
    }
    
}

- (void)makeTagViewWithYPos:(CGFloat)yPos{
    NSString *tags = [NSString stringWithFormat:@"%@", _dictionary.LPTVTags];
    if ([tags length] == 0) {
        tags = [NSString stringWithFormat:@"%@", _dictionary.LPTags];
    }
    
    NSArray *tagsArray;
    NSInteger countOfTags;
    if ([tags containsString:@",,,"]) {
        tagsArray = [tags componentsSeparatedByString:@",,,"];
        countOfTags = [tagsArray count] - 1;
        CGFloat xPOS = 10;
        CGFloat yPOS = yPos;
        for (NSInteger i = 0; i < countOfTags; i++) {
            NSString *tagName = [tagsArray objectAtIndex:i];
            NSArray *arr = [tagName componentsSeparatedByString:@","];
            tagName = [arr lastObject];
            CGSize size = [self getSizeOfString:tagName];
            if (countOfTags == 1)
                xPOS = screenWidth/2 - size.width/2;
            if (xPOS + size.width+10 > screenWidth) {
                xPOS = 10;
                yPOS += 30;
            }
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(xPOS, yPOS, size.width + 10, 25)];
            label.userInteractionEnabled = YES;
            label.tag = i;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tagLabelAction:)];
            [label addGestureRecognizer:tap];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = tagName;
            label.font = FONT_NORMAL(13);
            label.textColor = COLOR_1;
            label.layer.cornerRadius = 12;
            label.layer.borderColor = COLOR_1.CGColor;
            label.layer.borderWidth = 0.5;
            label.clipsToBounds = YES;
            [scrollView addSubview:label];
            
            xPOS += label.frame.size.width + 10;
            
            
            if ((xPOS > screenWidth) || ((i+1) % 3 == 0)) {
                xPOS = 10;
                yPOS += 30;
            }
        }
        
    } else {
        tagsArray = _dictionary.LPTags;
        countOfTags = [tagsArray count];
        CGFloat xPOS = 10;
        CGFloat yPOS = yPos;
        for (NSInteger i = 0; i < countOfTags; i++) {
            NSString *tagName = [[tagsArray objectAtIndex:i]objectForKey:@"name"];
            CGSize size = [self getSizeOfString:tagName];
            if (countOfTags == 1)
                xPOS = screenWidth/2 - size.width/2;
            if (xPOS + size.width+10 > screenWidth) {
                xPOS = 10;
                yPOS += 30;
            }
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(xPOS, yPOS, size.width + 10, 25)];
            label.userInteractionEnabled = YES;
            label.tag = i;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tagLabelAction:)];
            [label addGestureRecognizer:tap];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = tagName;
            label.font = FONT_NORMAL(13);
            label.textColor = COLOR_1;
            label.layer.cornerRadius = 12;
            label.layer.borderColor = COLOR_1.CGColor;
            label.layer.borderWidth = 0.5;
            label.clipsToBounds = YES;
            [scrollView addSubview:label];
            
            xPOS += label.frame.size.width + 10;
            
            
            if ((xPOS > screenWidth) || ((i+1) % 3 == 0)) {
                xPOS = 10;
                yPOS += 30;
            }
        }
        
    }
    
    
    
    scrollView.contentSize = CGSizeMake(screenWidth,yPos + 200);
}

- (void)VotingAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSLog(@"%ld", (long)btn.tag);
    [self sendVotingWithID:btn.tag];
}

- (void)downloadPlayButtonAction:(UITapGestureRecognizer *)sender{
    if (!isDownloadingAudio) {
        isDownloadingAudio = !isDownloadingAudio;
        isDownloadingVideo = NO;
        whichRowShouldBeReload = sender.view.tag;
        [self startAnimationProgress];
        NSDictionary *tempDic = _dictionary;
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
        NSDictionary *tempDic = _dictionary;
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

- (void)tagLabelAction:(UITapGestureRecognizer *)tap{
    UILabel *label = (UILabel *)tap.view;
    NSLog(@"%@", label.text);
}

- (void)shareButtonAction:(id)sender{
        //UIButton *btn = (UIButton *)sender;
    
    NSDictionary *landingPageDic = _dictionary;
    
    if ([[landingPageDic objectForKey:@"type"]isEqualToString:@"question"]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"اشتراک گذاری" message:@"امکان اشتراک گذاری محتوی نظرسنجی وجود ندارد" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }else if ([[landingPageDic objectForKey:@"type"]isEqualToString:@"audio"]) {
        NSString *title;
        if (landingPageDic.LPTVTitle != (id)[NSNull null]) {
            title = landingPageDic.LPTVTitle;
        } else {
            title = landingPageDic.LPTitle;
        }
        NSString *content = landingPageDic.LPContent;
        NSString *url = landingPageDic.LPAudioUrl;
        NSString *str = [NSString stringWithFormat:@"%@\n%@\n%@",title, content, url];
        NSArray *objectsToShare = @[str];
        
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
    }else if ([[landingPageDic objectForKey:@"type"]isEqualToString:@"video"]) {
        NSString *title;
        if (landingPageDic.LPTVTitle != (id)[NSNull null]) {
            title = landingPageDic.LPTVTitle;
        } else {
            title = landingPageDic.LPTitle;
        }
        NSString *content = landingPageDic.LPContent;
        NSString *url = landingPageDic.LPVideoUrl;
        
        NSString *str = [NSString stringWithFormat:@"%@\n%@\n%@",title, content, url];
        NSArray *objectsToShare = @[str];
        
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
    }else{
        NSString *title;
        if (landingPageDic.LPTVTitle != (id)[NSNull null]) {
            title = landingPageDic.LPTVTitle;
        } else {
            title = landingPageDic.LPTitle;
        }
        NSString *content = landingPageDic.LPContent;
        
        NSString *str = [NSString stringWithFormat:@"%@\n%@",title, content];
        NSArray *objectsToShare = @[str];
        
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
    NSDictionary *landingPageDic = _dictionary;
    if ([landingPageDic.LPPostID integerValue] != 0) {
        [self favOnServerWithID:landingPageDic.LPPostID];
    } else {
        [self favOnServerWithID:landingPageDic.LPTVPostID];
    }
    
    
}

- (void)likeButtonAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    UIImage *offImage = [UIImage imageNamed:@"like icon"];
    UIImage *onImage = [UIImage imageNamed:@"like"];
    UIImage *currentImage = [btn imageForState:UIControlStateNormal];
    if ([UIImagePNGRepresentation(offImage) isEqualToData:UIImagePNGRepresentation(currentImage)]) {
        [btn setImage:onImage forState:UIControlStateNormal];
        NSInteger count = [_likeCountLabel.text integerValue];
        count++;
        _likeCountLabel.text = [NSString stringWithFormat:@"%ld", (long)count];
    }else{
        [btn setImage:offImage forState:UIControlStateNormal];
        NSInteger count = [_likeCountLabel.text integerValue];
        count--;
        if (count < 0) {
            count = 0;
        }
        _likeCountLabel.text = [NSString stringWithFormat:@"%ld", (long)count];
    }
    
    NSDictionary *landingPageDic = _dictionary;
    NSMutableDictionary *landingPageDic2 = [[NSMutableDictionary alloc]initWithDictionary:landingPageDic];
    if ([landingPageDic2.LPPostID integerValue] > 0) {
        [self likeOnServerWithID:landingPageDic2.LPPostID];
    } else {
        [self likeOnServerWithID:landingPageDic2.LPTVPostID];
    }
    
    
    NSInteger likes = landingPageDic2.LPLikes_count;
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
    
    
}

- (CGFloat)getHeightOfString:(NSString *)labelText{
    
    UIFont *font = FONT_NORMAL(15);
    if (IS_IPAD) {
        font = FONT_NORMAL(26);
    }
    CGSize sizeOfText = [labelText boundingRectWithSize: CGSizeMake( self.view.bounds.size.width - 30,CGFLOAT_MAX)
                                                options: (NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                             attributes: [NSDictionary dictionaryWithObject:font
                                                                                     forKey:NSFontAttributeName]
                                                context: nil].size;
    CGFloat height = sizeOfText.height;
        //    if (height < screenWidth + 10)
        //        height = screenWidth + 10;
    return height;
    
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

- (void)pushToLoginView{
    [self presentViewController:[self IntroViewController] animated:YES completion:nil];
}

- (IntroViewController *)IntroViewController{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    IntroViewController *view = (IntroViewController *)[story instantiateViewControllerWithIdentifier:@"IntroViewController"];
    return view;
}

- (void)backButtonImgAction{
    [self.navigationController popViewControllerAnimated:YES];
    [audioPlayer stop];
}

- (void)audioButtonAction{
    NSDictionary *dic = _dictionary;
        //NSLog(@"%@", [dic objectForKey:@"audio"]);
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    VideoPlayerViewController *view = (VideoPlayerViewController *)[story instantiateViewControllerWithIdentifier:@"VideoPlayerViewController"];
    view.urlString = [dic objectForKey:@"audio"];
    view.titleString = [dic objectForKey:@"title"];
    [self presentViewController:view animated:YES completion:nil];
}

- (void)videoButtonAction{
    NSDictionary *dic = _dictionary;
        //NSLog(@"%@", [dic objectForKey:@"video"]);
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    VideoPlayerViewController *view = (VideoPlayerViewController *)[story instantiateViewControllerWithIdentifier:@"VideoPlayerViewController"];
    view.urlString = [dic objectForKey:@"video"];
    view.titleString = [dic objectForKey:@"title"];
    [self presentViewController:view animated:YES completion:nil];
}

- (void)moreButtonAction{
        //NSLog(@"%@", _dictionary);
    [settingMenuView removeFromSuperview];
    settingMenuView = [[UIView alloc]initWithFrame:CGRectMake(20, self.authorNameLabel.frame.origin.y + 50, 100, 50)];
    settingMenuView.backgroundColor = [UIColor whiteColor];
    settingMenuView.clipsToBounds = NO;
    settingMenuView.layer.shadowOffset = CGSizeMake(0, 0);
    settingMenuView.layer.shadowRadius = 20;
    settingMenuView.layer.shadowOpacity = 0.1;
    [self.view addSubview:settingMenuView];
    
    if ([[_dictionary objectForKey:@"can_edit"]integerValue] == 1) {
        UIButton *deletePostButton = [CustomButton initButtonWithTitle:@"حذف پست" withTitleColor:[UIColor blackColor] withBackColor:[UIColor clearColor] withFrame:CGRectMake(20, 10, settingMenuView.frame.size.width - 20, 30)];
        [deletePostButton addTarget:self action:@selector(deletePostButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [settingMenuView addSubview:deletePostButton];
        [scrollView addSubview:settingMenuView];
        
    } else {
        UIButton *reportButton = [CustomButton initButtonWithTitle:@"گزارش " withTitleColor:[UIColor blackColor] withBackColor:[UIColor clearColor] withFrame:CGRectMake(20, 10, settingMenuView.frame.size.width - 20, 30)];
        [reportButton addTarget:self action:@selector(reportButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [settingMenuView addSubview:reportButton];
    }
}

- (void)deletePostButtonAction{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"آیا از حذف پست مطمئن هستید؟" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"حذف" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [settingMenuView removeFromSuperview];
        [self deletePostFromServerWithID];
    }];
    [alert addAction:deleteAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self dismissTextView];
    }];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)dismissTextView{
    [settingMenuView removeFromSuperview];
}

- (void)commentImageViewAction:(UITapGestureRecognizer *)tap{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CommentViewController *view = (CommentViewController *)[story instantiateViewControllerWithIdentifier:@"CommentViewController"];
    view.postId = [[_dictionary objectForKey:@"id"]integerValue];
    view.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:view animated:YES];
}

- (void)reportButtonAction{
    [self dismissTextView];
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ReportAbuseViewController *view = (ReportAbuseViewController *)[story instantiateViewControllerWithIdentifier:@"ReportAbuseViewController"];
    view.idOfProfile = [[_dictionary objectForKey:@"id"]integerValue];
    view.model = @"post";
    [self presentViewController:view animated:YES completion:nil];
}

- (void)openDocumentAction{
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    VideoPlayerViewController *view = (VideoPlayerViewController *)[story instantiateViewControllerWithIdentifier:@"VideoPlayerViewController"];
    view.titleString = [_dictionary objectForKey:@"title"];
    view.urlString = [_dictionary objectForKey:@"document"];
    view.hidesBottomBarWhenPushed = YES;
    [self presentViewController:view animated:YES completion:nil];
}

- (void)updateCommentsCount:(NSNotification *)notif{
        //NSLog(@"%@", notif);
    _commentCountLabel.text = [NSString stringWithFormat:@"%ld", (long)[notif.object integerValue]];
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

- (void)deleteTagImageAction:(UITapGestureRecognizer *)tapy{
    NSDictionary *dic = [selectedTagsArray objectAtIndex:tapy.view.tag];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TopicPageViewController *view = (TopicPageViewController *)[story instantiateViewControllerWithIdentifier:@"TopicPageViewController"];
    view.dictionary = dic;
    view.tagName = [NSString stringWithFormat:@"%@",[dic objectForKey:@"name"]];
    view.tagIDx = [[dic objectForKey:@"id"]integerValue];
    view.isComingFromTags = YES;//first call entity detail with tagId then call
    view.postId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]];
    [self.navigationController pushViewController:view animated:YES];
    
}

- (void)tapOnAuthorImage:(UITapGestureRecognizer *)tap{
    NSDictionary *tempDic = _dictionary;
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UserProfileViewController *view = (UserProfileViewController *)[story instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
    view.entityID = [[[tempDic objectForKey:@"entity"]objectForKey:@"id"]integerValue];//[[[tempDic objectForKey:@"entity"]objectForKey:@"id"]integerValue];
    view.dictionary = tempDic;
    [self.navigationController pushViewController:view animated:YES];
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
        NSString *audioName = _dictionary.LPTVAudioUrl;
        if ([audioName length] == 0) {
            audioName = _dictionary.LPAudioUrl;
        }
        [self playAudioWithName:[audioName lastPathComponent]];
        playingAudioRowNumber = btn.tag;
        whichRowShouldBeReload = playingAudioRowNumber;
    }
}

- (void)playVideo:(id)sender{
    NSDictionary *dic = _dictionary;
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    VideoPlayerViewController *view = (VideoPlayerViewController *)[story instantiateViewControllerWithIdentifier:@"VideoPlayerViewController"];
    view.dictionary = dic;
    [self presentViewController:view animated:YES completion:nil];
}

- (void)stopAudioPlayer{
    [audioPlayer stop];
    [self stopTimer];
    [playbackTimer invalidate];
    [_downloadPlayButton setImage:[UIImage imageNamed:@"play icon"] forState:UIControlStateNormal];
    _currentTimeLabel.text = @"00:00";
    
}

- (void)playAudioWithName:(NSString *)nameOfVoice {
    [_downloadPlayButton setImage:[UIImage imageNamed:@"Stop"] forState:UIControlStateNormal];
        //_currentTimeLabel.text = [NSString stringWithFormat:@"%@", [self formattedTime:audioPlayer.currentTime]];
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
    if (audioPlayer.currentTime > 0) {
        
        _currentTimeLabel.text = [NSString stringWithFormat:@"%@", [self formattedTime:audioPlayer.currentTime]];
        
            //[self.tableView reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationNone];
    } else {
        [playbackTimer invalidate];
        [UIView animateWithDuration:1.0 animations:^{
                //_waveform.progressSamples = _waveform.totalSamples;
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
    [self stopTimer];
    [_downloadPlayButton setImage:[UIImage imageNamed:@"play icon"] forState:UIControlStateNormal];
    _currentTimeLabel.text = @"00:00";
    
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
        CGFloat progress = _largeProgressView.progress + 0.0001f;
        [_largeProgressView setProgress:progress animated:YES];
        if (_largeProgressView.progress >= 1.0f && [_timerForProgress isValid]) {
                //[progressView setProgress:0.f animated:YES];
            [self stopAnimationProgress];
        }
    }else {
        CGFloat progress = _largeProgressView.progress - 0.0001f;
        [_largeProgressView setProgress:progress animated:YES];
        if (_largeProgressView.progress <= 0) {
            [_largeProgressView setProgress:0.f animated:YES];
            [self stopAnimationProgress];
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
        CGFloat progress = _largeProgressView.progress + 0.01f;
        [_largeProgressView setProgress:progress animated:YES];
        
        if (_largeProgressView.progress >= 1.0f && [_timerForProgressFinal isValid]) {
                //[progressView setProgress:0.f animated:YES];
            [self stopAnimationProgressFinal];
            isDownloadingVideo = NO;
            isDownloadingAudio = NO;
            [scrollView removeFromSuperview];
            if ([postType isEqualToString:@"audio"]) {
                [self makeBodyForAudio];
            }else if ([postType isEqualToString:@"video"]) {
                [self makeBodyForVideo];
            }
        }
        
    } else {
        CGFloat progress = _largeProgressView.progress - 0.01f;
        [_largeProgressView setProgress:progress animated:YES];
        
        if (_largeProgressView.progress <= 0) {
            [_largeProgressView setProgress:0 animated:YES];
            [self stopAnimationProgressFinal];
                //[self.tableView reloadData];
        }
    }
}
- (void)stopAnimationProgressFinal
{
    [_timerForProgressFinal invalidate];
    _timerForProgressFinal = nil;
    
}

#pragma mark - webview delegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    /*
     CGRect frame = webView.frame;
     frame.size.height = 5.0f;
     webView.frame = frame;
     */
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    CGSize mWebViewTextSize = [webView sizeThatFits:CGSizeMake(1.0f, 1.0f)]; // Pass about any size
    CGRect mWebViewFrame = webView.frame;
    mWebViewFrame.size.height = mWebViewTextSize.height;
    webView.frame = mWebViewFrame;
    
        //Disable bouncing in webview
    for (id subview in webView.subviews) {
        if ([[subview class] isSubclassOfClass: [UIScrollView class]]) {
            [subview setBounces:NO];
        }
    }
    
    scrollView.contentSize = CGSizeMake(screenWidth,mWebViewTextSize.height + 300);
    
    [self makeTagViewWithYPos:mWebViewTextSize.height + 310];
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
        
        if ([[tempDic objectForKey:@"errors"]count] > 0) {
                //NSString *message = NSLocalizedString(@"passwordIsChanged", @"");
            
            UIImage *offImage = [UIImage imageNamed:@"like icon"];
            [_heartButton setImage:offImage forState:UIControlStateNormal];
            return;
        }
        if ([[[tempDic objectForKey:@"data"]objectForKey:@"status"] isEqualToString:@"+"]) {
            [Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:@"1" field:@"liked" postId:idOfPost];
            [Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:[NSString stringWithFormat:@"%@", [[tempDic objectForKey:@"data"] objectForKey:@"count"]] field:@"likes_count" postId:idOfPost];
            [Database copyLandingPageIntoFavoriteWithFilePath:[Database getDbFilePath] postID:idOfPost];
            UIImage *onImage = [UIImage imageNamed:@"like"];
            [_heartButton setImage:onImage forState:UIControlStateNormal];
            //_likeCountLabel.text = [NSString stringWithFormat:@"%@", [[tempDic objectForKey:@"data"] objectForKey:@"count"]];
        }else{//status = "-"
            [Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:@"0" field:@"liked" postId:idOfPost];
            [Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:[NSString stringWithFormat:@"%@", [[tempDic objectForKey:@"data"] objectForKey:@"count"]] field:@"likes_count" postId:idOfPost];
            [Database copyLandingPageIntoFavoriteWithFilePath:[Database getDbFilePath] postID:idOfPost];
            UIImage *offImage = [UIImage imageNamed:@"like icon"];
            [_heartButton setImage:offImage forState:UIControlStateNormal];
            //_likeCountLabel.text = [NSString stringWithFormat:@"%ld", (long)_dictionary.LPLikes_count];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        
    }];
}

- (void)favOnServerWithID:(NSString *)idOfPost{
    /*http://213.233.175.250:8081/web_services/v3/social_activities/setFavorite*/
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
        
    } progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {        NSDictionary *tempDic = (NSDictionary *)responseObject;
        
        if ([[tempDic objectForKey:@"errors"]count] > 0) {
                //NSString *message = NSLocalizedString(@"passwordIsChanged", @"");
            
            UIImage *offImage = [UIImage imageNamed:@"fav off"];
            [_favButton setImage:offImage forState:UIControlStateNormal];
            return;
        }
        
        if ([[[tempDic objectForKey:@"data"]objectForKey:@"status"] isEqualToString:@"+"]) {
            [Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:@"1" field:@"favorite" postId:idOfPost];
                //copy fav items into favorite table
            [Database copyLandingPageIntoFavoriteWithFilePath:[Database getDbFilePath] postID:idOfPost];
            UIImage *onImage = [UIImage imageNamed:@"fav on"];
            [_favButton setImage:onImage forState:UIControlStateNormal];
        }else if ([[[tempDic objectForKey:@"data"]objectForKey:@"status"] isEqualToString:@"-"]){//status = "-"
            [Database updateLandingPageWithFilePath:[Database getDbFilePath] SetValue:@"0" field:@"favorite" postId:idOfPost];
                //delete fav item from favorite
            [Database deleteFavoriteWithFilePath:[Database getDbFilePath] withID:idOfPost];
                //[Database copyLandingPageIntoFavoriteWithFilePath:[Database getDbFilePath] postID:idOfPost];
            UIImage *offImage = [UIImage imageNamed:@"fav off"];
            [_favButton setImage:offImage forState:UIControlStateNormal];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        
    }];
}

- (void)postDetailWithID:(NSString *)idOfPost{
    
    [ProgressHUD show:@""];
    NSDictionary *params = @{@"id":idOfPost
                             };
    NSString *url = [NSString stringWithFormat:@"%@api/post/detail", BaseURL];
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
        NSDictionary *resDic  = (NSDictionary *)responseObject;
        if ([[resDic objectForKey:@"data"]count] == 0) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"این پست حذف شده است." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        _dictionary = [resDic objectForKey:@"data"];
        if ([postType isEqualToString:@"audio"]) {
            [self makeBodyForAudio];
        }else if ([postType isEqualToString:@"video"]) {
            [self makeBodyForVideo];
        }else if ([postType isEqualToString:@"document"]) {
            [self makeBodyForDocument];
        }else if ([postType isEqualToString:@"question"]) {
            [self makeBodyForVoting];
        }else{
            [self makeBody];
        }
        
        if ([[[resDic objectForKey:@"data"]objectForKey:@"multi_select"]isEqualToString:@"YES"]) {
            allowToSendVoting = YES;
        } else if (([[[resDic objectForKey:@"data"]objectForKey:@"multi_select"]integerValue] == 0) && ([[[resDic objectForKey:@"data"]objectForKey:@"answered_question"]integerValue] == 1)) {
            allowToSendVoting = NO;
        } else if (([[[resDic objectForKey:@"data"]objectForKey:@"multi_select"]integerValue] == 0) && ([[[resDic objectForKey:@"data"]objectForKey:@"answered_question"]integerValue] == 0)) {
            allowToSendVoting = YES;
        }
        
        
        selectedTagsArray = [[NSMutableArray alloc]init];
        for (NSDictionary *tag in [[resDic objectForKey:@"data"]objectForKey:@"tags"]) {
            [selectedTagsArray addObject:tag];
        }
        
        [self reloadTagsView];
        
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

- (void)deletePostFromServerWithID{
    if (!isBusyNow) {
        isBusyNow = YES;
        [refreshControl endRefreshing];
        [ProgressHUD show:@""];
        NSDictionary *params = @{@"id":[_dictionary objectForKey:@"id"]
                                 };
        NSString *url = [NSString stringWithFormat:@"%@api/post/delete", BaseURL];
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
            if ([[tempDic objectForKey:@"success"]integerValue] == 1) {
                [self.navigationController popViewControllerAnimated:YES];
                [Database deleteLandingPageWithFilePath:[Database getDbFilePath] withID:[NSString stringWithFormat:@"%@", [_dictionary objectForKey:@"id"]]];
            }
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[tempDic objectForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                    // ////NSLog(@"You pressed button OK");
            }];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            
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

- (void)sendVotingWithID:(NSInteger)idOfPost{
    if (!allowToSendVoting) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"شما قبلا به این سوال پاسخ داده اید" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action= [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    
    [ProgressHUD show:@""];
    NSDictionary *params = @{@"poll_option_id":[NSNumber numberWithInteger:idOfPost]
                             };
    NSString *url = [NSString stringWithFormat:@"%@api/post/poll_answer/add", BaseURL];
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
        NSDictionary *tempDic = (NSDictionary *)responseObject;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%@", [tempDic objectForKey:@"message"]] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                // ////NSLog(@"You pressed button OK");
        }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        allowToSendVoting = !allowToSendVoting;
        
        NSArray *optionsArray = [[tempDic objectForKey:@"data"]objectForKey:@"options"];
        for (NSInteger i = 0; i < [optionsArray count] ; i++) {
            for(id view in [scrollView subviews]){
                if([view isKindOfClass:[UIButton class]]){
                    UIButton *btn = (UIButton *)view;
                    if (btn.tag == [[[optionsArray objectAtIndex:i]objectForKey:@"id"]integerValue]) {
                        CGFloat percent = [[[optionsArray objectAtIndex:i]objectForKey:@"answers_percent"]integerValue];
                        CGFloat width = btn.frame.size.width;
                        CGFloat height = btn.frame.size.height;
                        CGFloat xpos = ((100 - percent)/100) * width;
                            //                    if (xpos > 50) {
                            //                        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                            //                    }
                        UIView *coloredView = [[UIView alloc]initWithFrame:CGRectMake(xpos, 0, width - xpos, height)];
                        coloredView.backgroundColor = [COLOR_5 colorWithAlphaComponent:0.4];
                        if ([[[optionsArray objectAtIndex:i]objectForKey:@"answered"]integerValue] == 1){
                            coloredView.backgroundColor = [GREEN_COLOR colorWithAlphaComponent:0.4];
                        }
                        coloredView.tag = 120;
                        UIView *v = [btn viewWithTag:120];
                        v.hidden = YES;
                        [btn bringSubviewToFront:v];
                        [v removeFromSuperview];
                        [btn addSubview:coloredView];
                    }
                }
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


@end
