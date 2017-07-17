//
//  DirectQuestionViewController.m
//  MSN
//
//  Created by Yarima on 5/4/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "ConsultationDetailViewController.h"
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
#import "NSDictionary+consultation.h"
#import "AttributedTextClass.h"
#import "DocumentDirectoy.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "ImageViewController.h"
#import "GetUsernamePassword.h"
#import "HealthStatusViewController.h"
#import "ConsultationListViewController.h"
#import "UIImage+Extra.h"
#import "NSDictionary+consultation.h"
#define Height_QuestionView 60

@interface ConsultationDetailViewController()<UITextViewDelegate,UIGestureRecognizerDelegate,
UITextFieldDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate>
{
     
    BOOL    isBusyNow;
    UIImageView *coverImageView;
    UIImageView *doctorImageView;
    UILabel *authorNameLabel;
    UILabel *authorJobLabel;
    UIButton *menubuttons;
    UIView *questionView;
    UIButton *sendButton;
    UIButton *attachButton;
    UITextView *questionTextView;
    CGFloat lastHeightOfQuestionTextView;
    UIView *packageListView;
    NSMutableArray *packegesArray;
    CGFloat yPositionOfLabel;
    NSMutableArray *packageColorArray;
    CGFloat yPositionOfSelectedButton;
    NSInteger selectedPackageId;
    UIView *packageBuyView;
    UILabel *selectLabel;
    UIView *blurView;
    CGFloat yPositionOfTableView;
    UIView *bgViewForListAllType;
    UIImageView *imageViewListMaker;
    UIActivityIndicatorView *activityIndicator;
    UIImageView *selectedImageView;
    UIProgressView *playbackProgress;
    UIView *headerView;
    UIView *whiteHeaderView;
    BOOL isMenuVisible;
    //UIButton *menuButton;
    //UILabel *titleLabel;
    UILabel *forWhomLabel;
    UIImageView *dockImageView;
    BOOL isLeftMenuVisible;
    UIView *transparentView;
    UIButton *answerButton;
    NSMutableArray *tableArray;
    UIView *replyViewBG;
    //UIButton *sendButton;
    UIButton *recorderButton;
    NSString *documentsDirectory;
    NSString *recordingVoiceNameStr;
    UIView *recordingView;
    UILabel *recordingTimerLabel;
    NSTimer *playbackTimer;
    UIProgressView *playSoundeProgress;
    NSInteger currentPlayingCellInRow;
    UIView *playRecordedSoundView;
    UIView *showSelectedImageView;
    BOOL isPlayingTempVoice;
    UITextField *answertextField;
    NSString *doctorUserId;
    UIButton *lockUnlockButton;
    BOOL isQuestionLocked;
    UIView *LockStausOnBottomView;
    UIView *lockUnlockAlertView;
    UIProgressView *uploadFileProgress;
    UIView *notifView;
    UIView *blurViewForMenu;
    NSInteger idOfAttachment;
    UIView *attachFileView;
    UIImageView *playImageView;
    NSInteger idOfCurrentPlayingAudio;
}
@property NSProgress *progress;

@property(retain, nonatomic)UIScrollView *scrollView;
@property (strong, nonatomic)AVAudioRecorder *audioRecorder;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (weak, nonatomic) NSTimer *myTimer;
@property (weak, nonatomic) NSTimer *timerForUpload;
@property int currentTimeInSeconds;


@end

@implementation ConsultationDetailViewController
- (void)viewDidDisappear:(BOOL)animated{
    [ProgressHUD dismiss];
}
- (void)viewDidLoad {
    self.navigationController.navigationBar.hidden = YES;
    
    [super viewDidLoad];
    idOfAttachment = 0;
     
    isBusyNow = NO;
    lastHeightOfQuestionTextView = 40;
    //make View
    [self makeTopBar];
    [self makeCategoryUI];
    //[self makeAgreementText];
    [self questionView];
    
    for (int i = 0; i < [_dictionary.answersArray count]; i++) {
        //NSLog(@"%@", _dictionary.answersArray[i]);
        NSDictionary *dic = _dictionary.answersArray[i];
        if (dic.is_user_message == 0) {
            //NSLog(@"%@", dic.doctorInfo);
        }
    }
    
    yPositionOfTableView = 5;
    NSDictionary * args = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithFloat:yPositionOfTableView], @"yPos",
                           nil];
    [self performSelectorInBackground:@selector(makeListForAllAnswerTypesWithYposition:) withObject:args];
    
    //NSLog(@"self.navigationControllers: %@", [self.navigationController viewControllers]);
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showAttachImage2:) name:@"showAttachImage2" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - make list for all answer types
- (void)makeListForAllAnswerTypesWithYposition:(NSDictionary *)dic{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat yPosition = [[dic objectForKey:@"yPos"]floatValue];
        [bgViewForListAllType removeFromSuperview];
        bgViewForListAllType = [[UIView alloc]initWithFrame:CGRectMake(0, yPosition, screenWidth, 300)];
        [self.scrollView addSubview:bgViewForListAllType];
        
        CGFloat ypositionOfRow = 5;
        
        for (int i = 0; i < [_dictionary.answersArray count]; i++) {
            NSDictionary *answer = [_dictionary.answersArray objectAtIndex:i];
            NSString *answerStr = answer.messageText;//[answer objectForKey:@"answer"];
            NSString *documentUrl = answer.document_url;//[answer objectForKey:@"document_url"];
            NSString *voiceUrl = answer.voice_url;//[answer objectForKey:@"voice_url"];
            NSString *dateStr = answer.created;//[answer objectForKey:@"created"];
            //NSLog(@"%@", answerStr);
            //date
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *startDate = [[NSDate alloc] init];
            startDate = [dateFormatter dateFromString:dateStr];
            //current date
            NSDateFormatter *currentDateFormatter = [[NSDateFormatter alloc]init];
            [currentDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *endDate = [NSDate date];
            UILabel *dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, ypositionOfRow + 5, screenWidth - 20, 25)];
            dateLabel.font = FONT_NORMAL(13);
            dateLabel.textColor = [UIColor lightGrayColor];
            dateLabel.text = [NSString stringWithFormat:@"%@",
                              [TimeAgoViewController timeIntervalWithStartDate:startDate withEndDate:endDate]];
            
            dateLabel.numberOfLines = 1;
            dateLabel.textAlignment = NSTextAlignmentLeft;
            [bgViewForListAllType addSubview:dateLabel];
            
            //answer text
            UILabel *answerLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, ypositionOfRow + 20, screenWidth - 20, [self getHeightOfString:answerStr])];
            answerLabel.font = FONT_BOLD(13);
            answerLabel.textColor = [UIColor blackColor];
            //answerLabel.text = answerStr;
            answerLabel.attributedText = [[NSAttributedString alloc] initWithString:answerStr attributes:[AttributedTextClass makeAttributedTextWithLineSpacing:19.0]];
            answerLabel.numberOfLines = 0;
            answerLabel.textAlignment = NSTextAlignmentRight;
            [bgViewForListAllType addSubview:answerLabel];
            //NSLog(@"answer:%@", answerStr);
            ypositionOfRow = answerLabel.frame.origin.y + answerLabel.frame.size.height + 20;
            
            //imageView
            if (documentUrl != (id)[NSNull null] ) {
                imageViewListMaker = [[UIImageView alloc]initWithFrame:CGRectMake(10, answerLabel.frame.origin.y + answerLabel.frame.size.height + 20, screenWidth - 20, screenWidth - 20)];
                imageViewListMaker.userInteractionEnabled = YES;
                imageViewListMaker.tag = i;
                UITapGestureRecognizer *imageViewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImageView:)];
                [imageViewListMaker addGestureRecognizer:imageViewTap];
                imageViewListMaker.image = [UIImage imageNamed:@"format_png.png"];
                [bgViewForListAllType addSubview:imageViewListMaker];
                ypositionOfRow = imageViewListMaker.frame.origin.y + imageViewListMaker.frame.size.height + 20;
                imageViewListMaker.image = [self loadImageFilesWithPath:[NSString stringWithFormat:@"%@/%@",
                                                                         [DocumentDirectoy getDocuementsDirectory], [documentUrl lastPathComponent]]];
                if (!imageViewListMaker.image) {
                    imageViewListMaker.image = [UIImage imageNamed:@"format_png.png"];
                    activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                    activityIndicator.center = CGPointMake(imageViewListMaker.frame.size.width/2, imageViewListMaker.frame.size.height/2);
                    [imageViewListMaker addSubview:activityIndicator];
                    [activityIndicator startAnimating];
                    
                    dispatch_async(kBgQueue, ^{
                        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BaseURL, documentUrl]]];
                        if (imgData) {
                            UIImage *image = [UIImage imageWithData:imgData];
                            if (image){
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self saveImageIntoDocumetsWithImage:image withName:[documentUrl lastPathComponent]];
                                    imageViewListMaker.image=image;
                                    [activityIndicator stopAnimating];
                                    [activityIndicator removeFromSuperview];
                                });
                            }
                        }
                    });
                    
                }
            }
            
            //voice
            if (voiceUrl != (id)[NSNull null]) {
                if (documentUrl != (id)[NSNull null]) {
                    ypositionOfRow = imageViewListMaker.frame.origin.y + imageViewListMaker.frame.size.height + 90;
                    
                } else {
                    ypositionOfRow = answerLabel.frame.origin.y + answerLabel.frame.size.height + 90;
                    
                }
                
                NSString *mp3FileName = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject]stringByAppendingPathComponent:voiceUrl]lastPathComponent];
                NSString *pathOfMP3 = [[NSURL fileURLWithPath:mp3FileName]path];
                unsigned long long fileSize;
                BOOL isDirectory;
                NSString *documentPath = [DocumentDirectoy getDocuementsDirectory];
                pathOfMP3 = [NSString stringWithFormat:@"%@%@", documentPath, pathOfMP3];
                if ([[NSFileManager defaultManager]fileExistsAtPath:pathOfMP3 isDirectory:&isDirectory]) {
                    CGFloat yposOfProgress = ypositionOfRow - 60;
                    fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:pathOfMP3 error:nil]fileSize];
                    AVAudioPlayer *sound = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:pathOfMP3] error:nil];
                    UILabel *durationLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 140, yposOfProgress + 10, 100, 25)];
                    durationLabel.text = [NSString stringWithFormat:@"%@", [self formattedTime:sound.duration]];
                    durationLabel.textAlignment = NSTextAlignmentCenter;
                    durationLabel.font = FONT_NORMAL(11);
                    [bgViewForListAllType addSubview:durationLabel];
                    
                    playImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 60, yposOfProgress + 10, 25, 25)];
                    playImageView.image = [UIImage imageNamed:@"play icon.png"];
                    //                if (isPlayingTempVoice/*currentPlayingCellInRow == indexPath.row*/) {
                    //                    playImageView.image = [UIImage imageNamed:@"stop.png"];
                    //                }
                    playImageView.userInteractionEnabled = YES;
                    playImageView.tag = i;
                    UITapGestureRecognizer *playtap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playTap:)];
                    [playImageView addGestureRecognizer:playtap];
                    [bgViewForListAllType addSubview:playImageView];
                    
                    playbackProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
                    playbackProgress.frame = CGRectMake(10, yposOfProgress + 19, screenWidth - 150, 10);
                    playbackProgress.tag = i;
                    [bgViewForListAllType addSubview:playbackProgress];
                    //            if ([[NSFileManager defaultManager]fileExistsAtPath:pathOfMP3 isDirectory:&isDirectory]) {
                    //
                }else{
                    [self getAudioWithURL:voiceUrl];
                }
                
            }
            UIView *horizontalLineView = [[UIView alloc]initWithFrame:CGRectMake(0, ypositionOfRow, screenWidth, 1)];
            horizontalLineView.backgroundColor = [UIColor lightGrayColor];
            [bgViewForListAllType addSubview:horizontalLineView];
            
            //NSLog(@"voice_url:%@",answer.voice_url);
        }
        
        bgViewForListAllType.frame = CGRectMake(0, yPosition, screenWidth, ypositionOfRow + 20);
        self.scrollView.contentSize = CGSizeMake(screenWidth, bgViewForListAllType.frame.size.height  + bgViewForListAllType.frame.origin.y + 130);
    });
}


#pragma mark - Custom methods
- (void)saveAudioIntoDocumetsWithData:(NSData*)audioData withName:(NSString*)audioName{
    if (audioData) {
        
        NSString *tempName = [audioName lastPathComponent];
        NSString *mp3FileName = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject]stringByAppendingPathComponent:tempName];
        //create the file
        [[NSFileManager defaultManager] createFileAtPath:mp3FileName contents:audioData attributes:nil];
        //[self hideHUD];
        NSDictionary * args = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithFloat:yPositionOfTableView], @"yPos",
                               nil];
        
        [self makeListForAllAnswerTypesWithYposition:args];
    }
}

- (void)getAudioWithURL:(NSString *)url
{
    //[HUD showUIBlockingIndicatorWithText:@"در حال دریافت اطلاعات"];
    url = [url stringByReplacingOccurrencesOfString:@"abresalamat.ir" withString:@"213.233.175.250:8081"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSURL *fileURL = [NSURL URLWithString:url];
                       NSData *fileData = [NSData dataWithContentsOfURL:fileURL];
                       
                       //This is your completion handler
                       dispatch_sync(dispatch_get_main_queue(), ^{
                           [self saveAudioIntoDocumetsWithData:fileData withName:[NSString stringWithFormat:@"%@", fileURL]];
                       });
                   });
}

- (void)playTap:(UITapGestureRecognizer *)tap{
    idOfCurrentPlayingAudio = tap.view.tag;
    UIImageView *imageView = (UIImageView *)tap.view;
    imageView.image = [UIImage imageNamed:@"Stop"];
    UITapGestureRecognizer *tapToStop = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(stopAudio:)];
    imageView.userInteractionEnabled = YES;
    [imageView addGestureRecognizer:tapToStop];
    NSDictionary *dicy = [_dictionary.answersArray objectAtIndex:tap.view.tag];
    [self playAudioWithName:[NSString stringWithFormat:@"%@/%@",[DocumentDirectoy getDocuementsDirectory], [dicy.voice_url lastPathComponent]]];
}

- (void)tapImageView:(UITapGestureRecognizer *)tap{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ImageViewController *view = (ImageViewController *)[story instantiateViewControllerWithIdentifier:@"ImageViewController"];
    NSDictionary *dicy = [_dictionary.answersArray objectAtIndex:tap.view.tag];
    NSString *documentUrl = dicy.document_url;//[[tableArray objectAtIndex:tap.view.tag] objectForKey:@"document_url"];
    view.imageViewPath =  [NSString stringWithFormat:@"%@/%@",
                           [DocumentDirectoy getDocuementsDirectory], [documentUrl lastPathComponent]];
    view.imageViewURL = [NSString stringWithFormat:@"%@",
                         [NSString stringWithFormat:@"%@", dicy.document_url]];
    [self.navigationController pushViewController:view animated:YES];
    
}
- (void)saveImageIntoDocumetsWithImage:(UIImage*)image withName:(NSString*)imageName{
    NSData *imageData = UIImagePNGRepresentation(image); //convert image into .png format.
    NSFileManager *fileManager = [NSFileManager defaultManager];//create instance of NSFileManager
    NSString *appDocumentsDirectory = [DocumentDirectoy getDocuementsDirectory];
    NSString *fullPath = [appDocumentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", imageName]]; //add our image to the path
    BOOL resultSave = [fileManager createFileAtPath:fullPath contents:imageData attributes:nil]; //finally save the path (image)
    if (resultSave) {
        //NSLog(@"image saved");
        selectedImageView.image = nil;
    } else {
        //NSLog(@"error saving image");
        //[self updateTableViewForImage];
        
        NSDictionary * args = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithFloat:yPositionOfTableView], @"yPos",
                               nil];
        
        [self makeListForAllAnswerTypesWithYposition:args];
        
    }
}

- (UIImage *)loadImageFilesWithPath:(NSString *)path{
    documentsDirectory = [DocumentDirectoy getDocuementsDirectory];
    
    UIImageView *tempImageView = [[UIImageView alloc]init];
    tempImageView.image = [UIImage imageWithContentsOfFile:path];
    return tempImageView.image;
}

- (void)makeTopBar{
    
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 70)];
    topView.backgroundColor = COLOR_3;
    [topView makeGradient:topView];
    topView.userInteractionEnabled = YES;
    [self.view addSubview:topView];
    
    CGFloat topViewHeight = topView.frame.size.height;
    
    UILabel *titleLabel2 =[[UILabel alloc]initWithFrame:CGRectMake(screenWidth/2 - 100, topViewHeight/2 - 15, 200, 40)];
    titleLabel2.font = FONT_NORMAL(20);
    titleLabel2.text = NSLocalizedString(@"newConsultation", @"");
    titleLabel2.textColor = [UIColor whiteColor];
    titleLabel2.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:titleLabel2];
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
    
    //500 × 672
    UIButton *deleteButtonImg = [[UIButton alloc]initWithFrame:CGRectMake(45, 26 , 15, 20)];
    [deleteButtonImg setBackgroundImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
    [deleteButtonImg addTarget:self action:@selector(deleteButtonImgAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deleteButtonImg];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissTextView)];
    [topView addGestureRecognizer:tap];
    
    //Top gray view
    UIView *statusViewGray = [[UIView alloc]initWithFrame:CGRectMake(0, 70, screenWidth, 30)];
    statusViewGray.backgroundColor = [UIColor grayColor];
    [self.view addSubview:statusViewGray];
    
    UILabel *dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 5, 100, 25)];
    dateLabel.font = FONT_BOLD(13);
    dateLabel.textColor = [UIColor grayColor];
    //NSLog(@"%@", self.dictionary);
    //date
    NSString *dateStr = self.dictionary.created;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *startDate = [[NSDate alloc] init];
    startDate = [dateFormatter dateFromString:dateStr];
    //current date
    NSDateFormatter *currentDateFormatter = [[NSDateFormatter alloc]init];
    [currentDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *endDate = [NSDate date];
    dateLabel.font = FONT_NORMAL(13);
    dateLabel.textColor = [UIColor whiteColor];
    dateLabel.text = [NSString stringWithFormat:@"%@",
                      [TimeAgoViewController timeIntervalWithStartDate:startDate withEndDate:endDate]];
    dateLabel.textAlignment = NSTextAlignmentLeft;
    [statusViewGray addSubview:dateLabel];
    
    UILabel *categoryLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 200, 5, 180, 25)];
    categoryLabel.font = FONT_BOLD(13);
    categoryLabel.textColor = [UIColor grayColor];
    categoryLabel.font = FONT_NORMAL(13);
    categoryLabel.textColor = [UIColor whiteColor];
    //category
    NSArray *medicalSectionArray = [Database selectFromMedicalSectionWithID:_dictionary.medical_section_id WithFilePath:[Database getDbFilePath]];
    if([medicalSectionArray count] > 0)
        categoryLabel.text = [NSString stringWithFormat:@"%@",
                              [[medicalSectionArray objectAtIndex:0]objectForKey:@"name"]];
    
    if (_dictionary.medical_section_id == 0)
        categoryLabel.text = NSLocalizedString(@"soalAzPezeshk", @"");
    categoryLabel.textAlignment = NSTextAlignmentRight;
    [statusViewGray addSubview:categoryLabel];
    
    
    
}

- (void)makeCategoryUI{
    //CGFloat yPositionOfViewForTitleAndImage = statusViewWhite.frame.origin.y + statusViewWhite.frame.size.height;
    self.scrollView  = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 100, screenWidth, screenHeight - 0)];
    [self.view addSubview:self.scrollView];
    /*
     UIView *bgViewForTitleAndImage = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 200)];
     bgViewForTitleAndImage.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cyanColor1.png"]];
     [self.scrollView addSubview:bgViewForTitleAndImage];
     
     UILabel *questionDateLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 100, 25)];
     questionDateLabel.font = FONT_BOLD(11);
     questionDateLabel.textColor = [UIColor grayColor];
     //questionDateLabel.text = [NSString stringWithFormat:@"%@", [[self.dictionary objectForKey:@"ConsultationQuestion"]objectForKey:@"last_date_modified"]];
     questionDateLabel.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", _dictionary.created] attributes:[AttributedTextClass makeAttributedTextWithLineSpacing:19.0]];
     questionDateLabel.textAlignment = NSTextAlignmentLeft;
     [bgViewForTitleAndImage addSubview:questionDateLabel];
     NSDictionary *dicy = [_dictionary.answersArray objectAtIndex:0];
     NSString *questionString = dicy.messageText;
     UILabel *questionTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 25, screenWidth - 20, [self getHeightOfString:questionString])];
     questionTitleLabel.font = FONT_BOLD(13);
     questionTitleLabel.textColor = [UIColor grayColor];
     questionTitleLabel.text = questionString;
     questionTitleLabel.numberOfLines = 0;
     questionTitleLabel.textAlignment = NSTextAlignmentRight;
     [bgViewForTitleAndImage addSubview:questionTitleLabel];
     CGRect bgViewRect2 = bgViewForTitleAndImage.frame;
     bgViewRect2.size.height = questionTitleLabel.frame.origin.y + questionTitleLabel.frame.size.height + 10;
     [bgViewForTitleAndImage setFrame:bgViewRect2];
     
     __block UIImageView *questionImageView;
     NSString *tempId = dicy.document_id;
     //NSLog(@"%@", tempId);
     if(dicy.document_id != (id)[NSNull null]){
     if (dicy.document_url != (id)[NSNull null]) {
     NSString *documentUrl = dicy.document_url;
     UIImageView *tempHeaderImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, questionTitleLabel.frame.size.height + questionTitleLabel.frame.origin.y + 50, screenWidth - 20, screenWidth - 20)];
     tempHeaderImageView.image = [UIImage imageNamed:@"format_png.png"];
     [bgViewForTitleAndImage addSubview:tempHeaderImageView];
     tempHeaderImageView.image = [self loadImageFilesWithPath:[NSString stringWithFormat:@"%@/%@",
     [DocumentDirectoy getDocuementsDirectory], [documentUrl lastPathComponent]]];
     [bgViewForTitleAndImage addSubview:questionImageView];
     CGRect bgViewRect = bgViewForTitleAndImage.frame;
     bgViewRect.size.height = tempHeaderImageView.frame.origin.y + tempHeaderImageView.frame.size.height + 10;
     [bgViewForTitleAndImage setFrame:bgViewRect];
     
     if (!tempHeaderImageView.image) {
     tempHeaderImageView.image = [UIImage imageNamed:@"format_png.png"];
     activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
     activityIndicator.center = CGPointMake(tempHeaderImageView.frame.size.width/2, tempHeaderImageView.frame.size.height/2);
     [tempHeaderImageView addSubview:activityIndicator];
     [activityIndicator startAnimating];
     
     dispatch_async(kBgQueue, ^{
     NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:documentUrl]];
     if (imgData) {
     UIImage *image = [UIImage imageWithData:imgData];
     if (image){
     dispatch_async(dispatch_get_main_queue(), ^{
     [self saveImageIntoDocumetsWithImage:image withName:[documentUrl lastPathComponent]];
     tempHeaderImageView.image=image;
     [bgViewForTitleAndImage addSubview:questionImageView];
     CGRect bgViewRect = bgViewForTitleAndImage.frame;
     bgViewRect.size.height = questionImageView.frame.origin.y + questionImageView.frame.size.height + 10;
     [bgViewForTitleAndImage setFrame:bgViewRect];
     [activityIndicator stopAnimating];
     [activityIndicator removeFromSuperview];
     });
     }
     }
     });
     
     }
     
     }
     }
     */
}

- (void)makeAgreementText{
    NSMutableString *string1 = [[NSMutableString alloc]initWithString:NSLocalizedString(@"text1", @"")];
    [string1 appendString:[NSString stringWithFormat:@"\n%@", NSLocalizedString(@"text2", @"")]];
    [string1 appendString:[NSString stringWithFormat:@"\n%@", NSLocalizedString(@"text3", @"")]];
    UITextView *textView1 = [[UITextView alloc]initWithFrame:CGRectMake(10, 70, screenWidth - 20, [self getHeightOfString:string1])];
    textView1.font = FONT_MEDIUM(12);
    if (IS_IPHONE_5_IOS7 || IS_IPHONE_5_IOS8 || IS_IPHONE_4_AND_OLDER_IOS7 || IS_IPHONE_4_AND_OLDER_IOS8) {
        textView1.font = FONT_NORMAL(10);
    }
    textView1.textAlignment = NSTextAlignmentRight;
    textView1.text = string1;
    textView1.userInteractionEnabled = NO;
    [self.view addSubview:textView1];
    
    UIButton *callEmergencyButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth/2 - 75, textView1.frame.origin.y + textView1.frame.size.height, 150, 30)];
    callEmergencyButton.layer.cornerRadius = 15;
    callEmergencyButton.clipsToBounds = YES;
    callEmergencyButton.backgroundColor = COLOR_1;
    callEmergencyButton.titleLabel.font = FONT_MEDIUM(13);
    [callEmergencyButton setTitle:NSLocalizedString(@"callEmergency", @"") forState:UIControlStateNormal];
    [callEmergencyButton addTarget:self action:@selector(callEmergencyButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:callEmergencyButton];
    
    NSMutableString *string2 = [[NSMutableString alloc]initWithString:NSLocalizedString(@"text4", @"")];
    [string2 appendString:[NSString stringWithFormat:@"\n%@", NSLocalizedString(@"text5", @"")]];
    [string2 appendString:[NSString stringWithFormat:@"\n%@", NSLocalizedString(@"text6", @"")]];
    [string2 appendString:[NSString stringWithFormat:@"\n%@", NSLocalizedString(@"text7", @"")]];
    UITextView *textView2 = [[UITextView alloc]initWithFrame:CGRectMake(10, callEmergencyButton.frame.origin.y + callEmergencyButton.frame.size.height, screenWidth - 20, [self getHeightOfString:string2])];
    textView2.font = FONT_MEDIUM(12);
    if (IS_IPHONE_5_IOS7 || IS_IPHONE_5_IOS8 || IS_IPHONE_4_AND_OLDER_IOS7 || IS_IPHONE_4_AND_OLDER_IOS8) {
        textView2.font = FONT_NORMAL(10);
    }
    textView2.textAlignment = NSTextAlignmentRight;
    textView2.text = string2;
    textView2.userInteractionEnabled =NO;
    if (IS_IPHONE_4_AND_OLDER_IOS8)
        textView2.userInteractionEnabled = YES;
    
    [self.view addSubview:textView2];
}

- (void)dismissTextView{
    [UIView animateWithDuration:0.5 animations:^{
        CGRect rect = questionView.frame;
        rect.origin.y = screenHeight - Height_QuestionView;
        [questionView setFrame:rect];
        [questionTextView resignFirstResponder];
    }];
}

- (void)questionView{
    questionView = [[UIView alloc]initWithFrame:CGRectMake(0, screenHeight - 50, screenWidth, Height_QuestionView)];
    questionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:questionView];
    
    attachButton = [[UIButton alloc]initWithFrame:CGRectMake(10, questionView.frame.size.height/2 - 25, 40, 40)];
    [attachButton setBackgroundImage:[UIImage imageNamed:@"attach icon"] forState:UIControlStateNormal];
    [attachButton addTarget:self action:@selector(attachButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [questionView addSubview:attachButton];
    
    sendButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - 50, questionView.frame.size.height/2 - 25, 40, 40)];
    [sendButton setBackgroundImage:[UIImage imageNamed:@"send icon"] forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [questionView addSubview:sendButton];
    
    questionTextView = [[UITextView alloc]initWithFrame:CGRectMake(attachButton.frame.size.width + attachButton.frame.origin.x + 10, 5, screenWidth - 120, 40)];
    questionTextView.font = FONT_MEDIUM(12);
    questionTextView.tag = 534;
    questionTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    questionTextView.delegate = self;
    questionTextView.layer.borderColor = [UIColor grayColor].CGColor;
    questionTextView.layer.borderWidth = 1.0;
    questionTextView.textColor = [UIColor grayColor];
    questionTextView.text = NSLocalizedString(@"enteryouText", @"");
    //questionTextView.backgroundColor = [UIColor brownColor];
    questionTextView.textAlignment = NSTextAlignmentRight;
    [questionView addSubview:questionTextView];
    
    if (_dictionary.is_closed == 1) {
        [self showLockStausOnBottom];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHideHandler:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

}

- (void)attachButtonAction{
    [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"isComingFromDirectQuestion"];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UploadDocumentsViewController *view = (UploadDocumentsViewController *)[story instantiateViewControllerWithIdentifier:@"UploadDocumentsViewController"];
    view.isFromConsultationDetail = YES;
    [self.navigationController pushViewController:view animated:YES];
}

- (void)sendButtonAction{
    if ([questionTextView.text length] > 10 && ![questionTextView.text isEqualToString:NSLocalizedString(@"enteryouText", @"")]) {
        [self sendQuestionToServer];
    }else{
        
        
    }
}

- (CGFloat)getHeightOfString:(NSString *)labelText{
    
    UIFont *myFont = FONT_MEDIUM(11);
    if (IS_IPHONE_5_IOS7 || IS_IPHONE_5_IOS8 || IS_IPHONE_4_AND_OLDER_IOS7 || IS_IPHONE_4_AND_OLDER_IOS8) {
        myFont = FONT_NORMAL(9);
    }
    
    
    if (IS_IPAD) {
        myFont = FONT_NORMAL(22);
    }
    CGSize sizeOfText = [labelText boundingRectWithSize: CGSizeMake( self.view.bounds.size.width - 20,CGFLOAT_MAX)
                                                options: (NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                             attributes: [NSDictionary dictionaryWithObject:myFont
                                                                                     forKey:NSFontAttributeName]
                                                context: nil].size;
    CGFloat height = sizeOfText.height + 50;
    if (IS_IPHONE_4_AND_OLDER_IOS8)
        height = sizeOfText.height + 10;
    return height;
    
}

- (void)callEmergencyButtonAction{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"115"]];
}

- (void)menuButtonAction {
    //[self showHideRightMenu];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"toggleMenuVisibility" object:nil];
}

- (void)backButtonImgAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deleteButtonImgAction{
    
}

- (void)loadAudioFiles{
    documentsDirectory = [DocumentDirectoy getDocuementsDirectory];
    NSArray *filePathsArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:documentsDirectory  error:nil];
    for (int i = 0; i < [filePathsArray count]; i++) {
        /*
         NSDictionary *tempDic = [[NSDictionary alloc]initWithObjectsAndKeys:
         [filePathsArray objectAtIndex:i], @"answer", nil];
         if (([[tempDic objectForKey:@"answer"]containsString:@".caf"]) &&
         ([[tempDic objectForKey:@"answer"]containsString:[NSString stringWithFormat:@"_%@", [[self.dictionary objectForKey:@"ConsultationQuestion"]objectForKey:@"id"]]])) {
         if (![tableArray containsObject:[tempDic objectForKey:@"answer"]]) {
         [tableArray addObject:tempDic];
         }
         
         }
         */
    }
}

- (void)showLockStausOnBottom{
    LockStausOnBottomView = [[UIView alloc]initWithFrame:CGRectMake(0, screenHeight - 50, screenWidth, 50)];
    LockStausOnBottomView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"grayColor3.png"]];
    [self.view addSubview:LockStausOnBottomView];
    
    UILabel *aLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 2, screenWidth - 40, 50)];
    aLabel.font = FONT_NORMAL(13);
    aLabel.textColor = [UIColor blackColor];
    aLabel.numberOfLines = 2;
    aLabel.textAlignment = NSTextAlignmentCenter;
    aLabel.text = [NSString stringWithFormat:@"%@", NSLocalizedString(@"lockStatusBottom", @"")];
    [LockStausOnBottomView addSubview:aLabel];
    
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
    //    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //    HealthStatusViewController *view = (HealthStatusViewController *)[story instantiateViewControllerWithIdentifier:@"HealthStatusViewController"];
    //    [self.navigationController pushViewController:view animated:YES];
}

- (void)pushToAbout{
    //    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //    HealthStatusViewController *view = (HealthStatusViewController *)[story instantiateViewControllerWithIdentifier:@"HealthStatusViewController"];
    //    [self.navigationController pushViewController:view animated:YES];
}

- (void)showAttachImage2:(NSNotification *)notif{
    NSDictionary *notifDic = notif.object;
    idOfAttachment = [[notifDic objectForKey:@"id"]integerValue];
    //NSLog(@"%@", notif.object);
    [attachFileView removeFromSuperview];
    attachFileView = [[UIView alloc]initWithFrame:CGRectMake(0, questionView.frame.origin.y - 68, screenWidth, 60)];
    attachFileView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:attachFileView];
    
    NSInteger documentImageViewWidth = 45;
    UIImageView *documentImageView = [[UIImageView alloc]initWithFrame:
                                      CGRectMake(screenWidth - 140, 5,documentImageViewWidth, documentImageViewWidth)];
    documentImageView.layer.cornerRadius = documentImageViewWidth / 2;
    documentImageView.clipsToBounds = YES;
    [attachFileView addSubview:documentImageView];
    [documentImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL, [notifDic objectForKey:@"file"]]] placeholderImage:[UIImage imageNamed:@"broken_image"]];
    
    UIButton *removeAttachButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - 60, 5, 45, 45)];
    [removeAttachButton setBackgroundImage:[UIImage imageNamed:@"popup_no"] forState:UIControlStateNormal];
    [removeAttachButton addTarget:self action:@selector(removeAttachButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [attachFileView addSubview:removeAttachButton];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, screenWidth - 100, 25)];
    titleLabel.font = FONT_NORMAL(11);
    titleLabel.text = [NSString stringWithFormat:@"%@", [notifDic objectForKey:@"name"]];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [attachFileView addSubview:titleLabel];
    
}

-(void)removeAttachButtonAction{
    [attachFileView removeFromSuperview];
    idOfAttachment = 0;
}

#pragma mark - reply actions(send, attach, record)
- (void)showAnswerButtonAction{
    answerButton = [CustomButton initButtonWithTitle:NSLocalizedString(@"answerUserQuestion", @"")
                                      withTitleColor:[UIColor whiteColor]
                                       withBackColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"titleColor.png"]]
                                           withFrame:CGRectMake(screenWidth/2 - 100, screenHeight - 60, 200, 40)];
    answerButton.titleLabel.font = FONT_BOLD(14);
    [answerButton addTarget:self action:@selector(answerButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:answerButton];
    if (isQuestionLocked) {
        answerButton.hidden = YES;
    } else {
        answerButton.hidden = NO;
    }
    
}
- (void)answerButtonAction{
    /*
     if ([self hasConnectivity]) {
     [self checkLockWithQuestionID:[NSString stringWithFormat:@"%@", [[self.dictionary objectForKey:@"ConsultationQuestion"]objectForKey:@"id"]] doctorUserID:[NSString stringWithFormat:@"119"]];
     }else{
     UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"noInternet", @"") message:NSLocalizedString(@"becomeOnline", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil, nil];
     [alert show];
     }
     */
}

#pragma mark - play, delete, record audio

- (void)playAudio{
    isPlayingTempVoice = YES;
    [self playAudioWithName:recordingVoiceNameStr];
}

- (void)stopAudio:(UITapGestureRecognizer *)tap{
    UIImageView *imageView = (UIImageView *)tap.view;
    imageView.image = [UIImage imageNamed:@"play icon"];
    UITapGestureRecognizer *playtap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playTap:)];
    [imageView addGestureRecognizer:playtap];
    isPlayingTempVoice = NO;
    [self.audioPlayer stop];
    
}

- (void)playAudioWithName:(NSString *)nameOfVoice {
    
    NSError *error;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:nameOfVoice]
                                                              error:nil];
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
    self.audioPlayer.delegate = self;
    [self.audioPlayer prepareToPlay];
    if (error){
        ////NSLog(@"Error: %@",[error localizedDescription]);
         
    }else{
        [self.audioPlayer play];
        playbackTimer=[NSTimer scheduledTimerWithTimeInterval:0.01
                                                       target:self
                                                     selector:@selector(playbackTimerAction:)
                                                     userInfo:nil
                                                      repeats:YES];
    }
}

-(void)playbackTimerAction:(NSTimer*)timer {
    
    float total = self.audioPlayer.duration;
    float f = self.audioPlayer.currentTime / total;
    
    if (isPlayingTempVoice) {
        playSoundeProgress.progress = f;
    } else {
        playbackProgress.progress = f;
    }
    
    if ((total * 0.95) <= self.audioPlayer.currentTime) {
        if (isPlayingTempVoice) {
            playSoundeProgress.progress = 0.0;
            
        } else {
            playbackProgress.progress = 0.0;
            if (playImageView.tag == idOfCurrentPlayingAudio) {
                playImageView.image = [UIImage  imageNamed:@"play icon"];
            }
            //[playbackProgress removeFromSuperview];
        }
        
        [playbackTimer invalidate];
        [self stopTimer];
        isPlayingTempVoice = NO;
    }
    
    ////NSLog(@"%f--%f", total, self.audioPlayer.currentTime);
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    //NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    //[self.tableView reloadRowsAtIndexPaths:@[selectedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
}


#pragma mark - timer

- (NSTimer *)createTimer {
    return [NSTimer scheduledTimerWithTimeInterval:1.0
                                            target:self
                                          selector:@selector(startTimer)
                                          userInfo:nil
                                           repeats:YES];
}

- (NSString *)formattedTime:(int)totalSeconds
{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}



- (void)startTimer {
    
    if (!_currentTimeInSeconds) {
        _currentTimeInSeconds = 3 * 60 ;
    }
    
    if (!_myTimer) {
        _myTimer = [self createTimer];
    }
}

- (void)stopTimer {
    recordingTimerLabel.text = @"03:00";
    _currentTimeInSeconds = 0;
    [_myTimer invalidate];
}

#pragma mark - textview delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (textView.tag == 534) {
        if ([textView.text isEqualToString:NSLocalizedString(@"enteryouText", @"")]) {
            textView.text = @"";
            textView.textColor = [UIColor blackColor];
        }
        if( [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location != NSNotFound ) {
            CGRect rect = textView.frame;
            if (rect.size.height <= screenHeight * 0.3){
                rect.size.height += 25;
                lastHeightOfQuestionTextView = rect.size.height;
                //rect.origin.y -= 25;
                [textView setFrame:rect];
                
                rect = sendButton.frame;
                rect.origin.y += 25;
                [sendButton setFrame:rect];
                
                rect = attachButton.frame;
                rect.origin.y += 25;
                [attachButton setFrame:rect];
                
                rect = questionView.frame;
                rect.size.height += 25;
                rect.origin.y -= 25;
                [questionView setFrame:rect];
            }else
                NSLog(@"this is enough frame");
        }
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    if (textView.tag == 534) {
        [UIView animateWithDuration:0.5 animations:^{
            CGRect rect = questionView.frame;
            if (IS_IPAD) rect.origin.y = screenHeight - 360;
            else rect.origin.y = screenHeight - 260;
            [questionView setFrame:rect];
            
            rect = questionTextView.frame;
            rect.size.height = lastHeightOfQuestionTextView;
            if (lastHeightOfQuestionTextView > 40) {
                CGFloat numOfEnters = lastHeightOfQuestionTextView / 25;
                numOfEnters --;
                rect.origin.y = 0;//-= numOfEnters * 25;
                [questionTextView setFrame:rect];
                
                rect = sendButton.frame;
                rect.origin.y += questionView.frame.size.height/2 - 25;
                [sendButton setFrame:rect];
                
                rect = attachButton.frame;
                rect.origin.y += questionView.frame.size.height/2 - 25;
                [attachButton setFrame:rect];
                
                rect = questionView.frame;
                rect.size.height = lastHeightOfQuestionTextView + 25;
                numOfEnters --;
                rect.origin.y -= numOfEnters * 25;
                [questionView setFrame:rect];
                
                rect = sendButton.frame;
                rect.origin.y = questionView.frame.size.height - 65;
                [sendButton setFrame:rect];
                
                rect = attachButton.frame;
                rect.origin.y = questionView.frame.size.height - 70;
                [attachButton setFrame:rect];
                
            }
            
            [textView layoutIfNeeded];
            [textView becomeFirstResponder];
        }];
    }
}

- (void)resignQuestionTextView {
    [UIView animateWithDuration:0.5 animations:^{
        CGRect rect = questionView.frame;
        rect.origin.y = screenHeight - Height_QuestionView;
        rect.size.height = Height_QuestionView;
        [questionView setFrame:rect];
        
        rect = sendButton.frame;
        rect.origin.y = questionView.frame.size.height/2 - 25;
        [sendButton setFrame:rect];
        
        rect = attachButton.frame;
        rect.origin.y = questionView.frame.size.height/2 - 25;
        [attachButton setFrame:rect];
        
        //CGRectMake(attachButton.frame.size.width + attachButton.frame.origin.x + 10, 5, screenWidth - 120, 40)
        rect = questionTextView.frame;
        rect.size.height = 40;
        rect.origin.y = 5;
        [questionTextView setFrame:rect];
        [questionTextView resignFirstResponder];
    }];
}

- (void) keyboardWillHideHandler:(NSNotification *)notification {
    //show another viewcontroller here
    [self resignQuestionTextView];
}

- (void) keyboardDidHideHandler:(NSNotification *)notification {
    //show another viewcontroller here
    //[self resignQuestionTextView];
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    [self resignQuestionTextView];
}
#pragma mark - connection

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

- (void)sendQuestionToServer{
    dispatch_async(dispatch_get_main_queue(), ^{
        [ProgressHUD show:@"" Interaction:NO];
    });
    /*
     call-> "consultationDirect";
     
     if access_service == false{
     call->"consultationDirectPackageList"
     
     on click on buy{
     call->"buyConsultationDirect" with id 84;
     if access_service == true{
     call-> "consultationDirect";
     if result == true{
     show dialog 24h and back to consultationList
     }
     }
     }
     }else{
     show dialog 24h and back to consultationList
     }
     */
    [self resignQuestionTextView];
    [self closePackageList];
    NSData *plainTextData = [questionTextView.text dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64Message = [plainTextData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
    NSDictionary *userpassDic = [GetUsernamePassword getUsernamePassword];
    NSDictionary *params = @{@"username":[userpassDic objectForKey:@"username"]/*@"09191234072"*/,
                             @"password":[userpassDic objectForKey:@"password"]/*@“123456”*/,
                             @"consultation_id":[NSString stringWithFormat:@"%ld", (long)_dictionary.consultation_id],
                             @"message":base64Message,
                             @"document_id":[NSNumber numberWithInteger:idOfAttachment],
                             @"debug":@"1",
                             @"unit_id": @"3"
                             };
    NSString *url = [NSString stringWithFormat:@"%@consultation_answer", BaseURL];
    
    
    if (!isBusyNow) {
        isBusyNow = YES;
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        [manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
            [ProgressHUD dismiss];
            NSDictionary *tempDic = (NSDictionary *)responseObject;
            if ([[tempDic objectForKey:@"success"]integerValue] == 1) {
                //NSLog(@"%@", _dictionary.answersArray);
                [self fetchConsultationsFromServer];
                
                //[self backButtonImgAction];
            } else {

                
            }
            [ProgressHUD dismiss];
            isBusyNow = NO;
            
        } failure:^(NSURLSessionTask *operation, NSError *error) {
             
            [ProgressHUD dismiss];
            isBusyNow = NO;
        }];
    }
    
}

- (void)fetchConsultationsFromServer{
    dispatch_async(dispatch_get_main_queue(), ^{
        [ProgressHUD show:@"" Interaction:NO];
    });
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
    
    isBusyNow = YES;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    manager.requestSerializer.timeoutInterval = 45;;
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        questionTextView.text = @"";
        [self removeAttachButtonAction];
        
        NSDictionary *tempDic = (NSDictionary *)responseObject;
        NSMutableArray *tempArray = [[NSMutableArray alloc]init];
        for (NSDictionary *tempo in [tempDic objectForKey:@"items"]) {
            NSInteger consultationId = [[NSNumber numberWithInteger:tempo.consultation_id]integerValue];
            if (consultationId == _dictionary.consultation_id) {
                [tempArray addObject:tempo];
            }
        }
        
        if ([tempArray count] > 0) {
            _dictionary = [tempArray objectAtIndex:0];
            NSDictionary * args = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithFloat:yPositionOfTableView], @"yPos",
                                   nil];
            [bgViewForListAllType removeFromSuperview];
            [self makeListForAllAnswerTypesWithYposition:args];
        }
        
        [ProgressHUD dismiss];
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
         
        [ProgressHUD dismiss];
    }];
}

- (void)consultationDirectPackageList{
    [ProgressHUD show:@"" Interaction:NO];
    NSString *url = [NSString stringWithFormat:@"%@consultationDirectPackageList", BaseURL];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:url parameters:nil progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        [ProgressHUD dismiss];
        blurView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
        blurView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.6];
        [self.view addSubview:blurView];
        
        packageListView = [[UIView alloc]initWithFrame:CGRectMake(20, screenHeight/3, screenWidth - 40, 200)];
        packageListView.backgroundColor = [UIColor whiteColor];
        NSDictionary *dict = responseObject;
        packegesArray = [[NSMutableArray alloc]init];
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 300, 25)];
        titleLabel.font = FONT_NORMAL(11);
        titleLabel.text = NSLocalizedString(@"selectPackage", @"");
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
            [packageListView addSubview:button];
            UILabel *aLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, yPositionOfLabel - 10, screenWidth - 160, 45)];
            aLabel.font = FONT_NORMAL(11);
            aLabel.numberOfLines = 2;
            aLabel.textAlignment = NSTextAlignmentCenter;
            NSInteger price = [[[tempDic objectForKey:@"Package"] objectForKey:@"price"]integerValue];
            price = price / 10;
            aLabel.text = [NSString stringWithFormat:@"%ld تومان\n%@", (long)price,[[tempDic objectForKey:@"Package"] objectForKey:@"description"]];
            [packageListView addSubview:aLabel];
            
            yPositionOfLabel += 50;
        }
        UIButton *doneButtn = [CustomButton initButtonWithTitle:NSLocalizedString(@"payWithhamraheAval", @"") withTitleColor:[UIColor whiteColor] withBackColor:[UIColor colorWithRed:26/255.0 green:184/255.0 blue:180/255.0 alpha:1.0]
                                                      withFrame:CGRectMake(packageListView.frame.size.width - 190, yPositionOfLabel + 20, 180, 25)];
        [doneButtn addTarget:self action:@selector(buyConsultationDirect) forControlEvents:UIControlEventTouchUpInside];
        [packageListView addSubview:doneButtn];
        UIButton *backButton = [CustomButton initButtonWithTitle:NSLocalizedString(@"back", @"") withTitleColor:[UIColor whiteColor] withBackColor:[UIColor grayColor] withFrame:CGRectMake(10, yPositionOfLabel + 20, 70, 25)];
        [backButton addTarget:selectLabel action:@selector(closePackageList) forControlEvents:UIControlEventTouchUpInside];
        [packageListView addSubview:backButton];
        CGRect rect = packageListView.frame;
        rect.size.height = yPositionOfLabel + 80;
        [packageListView setFrame:rect];
        packageListView.layer.cornerRadius = 14;
        packageListView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        packageListView.layer.borderWidth = 3.0;
        [blurView addSubview:packageListView];
        
        yPositionOfSelectedButton = 30;
        [selectLabel removeFromSuperview];
        selectLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, yPositionOfSelectedButton, packageListView.frame.size.width - 19, 45)];
        selectLabel.backgroundColor = [UIColor clearColor];
        selectLabel.layer.cornerRadius = 5;
        selectLabel.layer.borderWidth = 1.0;
        selectLabel.layer.borderColor = [UIColor colorWithRed:7/255.0 green:125/255.0 blue:195/255.0 alpha:1.0].CGColor;
        [packageListView addSubview:selectLabel];
        selectedPackageId = [[[[packegesArray objectAtIndex:0] objectForKey:@"Package"]objectForKey:@"id"]integerValue];
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
         
        [ProgressHUD dismiss];
    }];
}

- (void)buyConsultationDirect{
    NSDictionary *userpassDic = [GetUsernamePassword getUsernamePassword];
    NSDictionary *params = @{@"username":[userpassDic objectForKey:@"username"]/*@"09191234072"*/,
                             @"password":[userpassDic objectForKey:@"password"]/*123456*/,
                             @"profile_id":[GetUsernamePassword getProfileId],
                             @"debug":@"1",
                             @"unit_id": @"3"
                             };
    NSString *url = [NSString stringWithFormat:@"%@buyConsultationDirect", BaseURL];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        NSDictionary *tempDic = (NSDictionary *)responseObject;
        if (([[tempDic objectForKey:@"success"]integerValue] == 1) &&
            ([[tempDic objectForKey:@"access_service"]integerValue] == 1)) {
            [self sendQuestionToServer];
        }else{
            }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        
        [ProgressHUD dismiss];
    }];
}

- (void)closePackageList{
    [packageListView removeFromSuperview];
    //[packageBuyView removeFromSuperview];
    [blurView removeFromSuperview];
    selectedPackageId = 1000;
}

- (void)deleteConsultation{
    [ProgressHUD show:@"" Interaction:NO];
    NSDictionary *userpassDic = [GetUsernamePassword getUsernamePassword];
    NSDictionary *params = @{@"username":[userpassDic objectForKey:@"username"]/*@"09191234072"*/,
                             @"password":[userpassDic objectForKey:@"password"]/*123456*/,
                             @"consultation_id":[NSString stringWithFormat:@"%ld", (long)_dictionary.consultation_id],
                             @"debug":@"1",
                             @"unit_id": @"3"
                             };
    NSString *url = [NSString stringWithFormat:@"%@consultation_remove", BaseURL];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        [ProgressHUD dismiss];
        NSDictionary *dict = (NSDictionary *)responseObject;
        NSString *login = [dict objectForKey:@"login"];
        NSString *success = [dict objectForKey:@"success"];
        if (login && success) {
            
            [self.navigationController popViewControllerAnimated:YES];
        }else{
             
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        
        [ProgressHUD dismiss];
    }];
}

@end
