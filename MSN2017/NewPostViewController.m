//
//  NewPostViewController.m
//  MSN
//
//  Created by Yarima on 11/16/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "NewPostViewController.h"
#import "Header.h"
#import "CustomButton.h"
#import "Database.h"
#import <AFHTTPSessionManager.h>
#import <UIImageView+AFNetworking.h>
#import "Header.h"
#import <sys/socket.h>
#import <netinet/in.h>

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
#import "EditProfileViewController.h"

@interface NewPostViewController ()<UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIGestureRecognizerDelegate>
{
    UITextField *titleTextField;
    UITextView *contentTextView;
    UIView *galleryCameraView;
    UIImageView *coverImageView;
    UIPickerView *tagPickerView;
    UIPickerView *categoryPickerView;
    UIPickerView *entityPickerView;
    NSMutableArray *categoryArray;
    NSMutableArray *entityArray;
    NSMutableArray *tagsArray;
    BOOL isHiddenPickerView;
    UIButton *selectCategoryButton;
    UIButton *selectTagButton;
    UIButton *selectProfileButton;
    UIToolbar *categoryToolbar;
    UIToolbar *entityToolbar;
    UIToolbar *tagsToolbar;
    UIScrollView *scrollView;
    NSMutableArray *selectedTagsArray;
    UIView *bgViewForTagsLabel;
    NSInteger selectedEntityId;
    UILabel *progressLabel;
    UIButton *sendButton;
}

@end

@implementation NewPostViewController

- (void)viewWillAppear:(BOOL)animated{
    [self getCategoryFromServer];
    [self getTagsFromServer];
    [self getEntityFromServer];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self makeTopBar];
    [self makeBody];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma marks - custom methods
- (void)makeTopBar{
    
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 70)];
    topView.backgroundColor = COLOR_3;
    [topView makeGradient:topView];
    topView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissTextField)];
    [topView addGestureRecognizer:tap];
    [self.view addSubview:topView];
    
    CGFloat topViewHeight = topView.frame.size.height;
    
    UILabel *titleLabel =[[UILabel alloc]initWithFrame:CGRectMake(screenWidth/2 - 100, topViewHeight/2 - 15, 200, 40)];
    titleLabel.font = FONT_NORMAL(16);
    titleLabel.text = NSLocalizedString(@"newpost", @"");
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:titleLabel];
    
    UIButton *backButtonImg = [[UIButton alloc]initWithFrame:CGRectMake(0, 16 , 45, 45)];
    [backButtonImg setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButtonImg addTarget:self action:@selector(backButtonImgAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButtonImg];
}

- (void)makeBody{
    
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 70, screenWidth, screenHeight - 70)];
    scrollView.contentSize = CGSizeMake(screenWidth, screenHeight + 150);
    [self.view addSubview:scrollView];
    //title
    titleTextField = [[UITextField alloc]initWithFrame:CGRectMake(2, 0, screenWidth - 4, 45)];
    titleTextField.backgroundColor = [UIColor clearColor];
    titleTextField.placeholder = NSLocalizedString(@"typetitle", @"");
    titleTextField.tag = 101;
    titleTextField.delegate = self;
    titleTextField.font = FONT_NORMAL(15);
    titleTextField.layer.borderColor = [UIColor grayColor].CGColor;
    titleTextField.layer.borderWidth = 1.0;
    //titleTextField.layer.cornerRadius = 5;
    //titleTextField.clipsToBounds = YES;
    titleTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    titleTextField.textAlignment = NSTextAlignmentRight;
    [scrollView addSubview:titleTextField];
    
    UIView *whiteLineView = [[UIView alloc]initWithFrame:CGRectMake(0, titleTextField.frame.origin.y + titleTextField.frame.size.height - 1, screenWidth, 1)];
    whiteLineView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:whiteLineView];
    
    contentTextView = [[UITextView alloc]initWithFrame:CGRectMake(2, titleTextField.frame.origin.y + titleTextField.frame.size.height, screenWidth - 4, 120) textContainer:nil];
    contentTextView.font = FONT_NORMAL(12);
    contentTextView.delegate = self;
    contentTextView.layer.borderColor = [UIColor grayColor].CGColor;
    contentTextView.layer.borderWidth = 1.0;
    contentTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    contentTextView.textAlignment = NSTextAlignmentRight;
    [scrollView addSubview:contentTextView];
    
    UIButton *selectCoverImageButton = [CustomButton initButtonWithTitle:NSLocalizedString(@"selectCoverImage", @"") withTitleColor:[UIColor blueColor] withBackColor:[UIColor whiteColor] isRounded:NO withFrame:CGRectMake(screenWidth / 2, contentTextView.frame.origin.y + contentTextView.frame.size.height + 10, screenWidth/2, 35)];
    [selectCoverImageButton addTarget:self action:@selector(selectCoverImageButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:selectCoverImageButton];
    
    coverImageView = [[UIImageView alloc]initWithFrame:CGRectMake(20, selectCoverImageButton.frame.origin.y, 60, 60)];
    [scrollView addSubview:coverImageView];
    
    selectCategoryButton = [CustomButton initButtonWithTitle:NSLocalizedString(@"selectCategory", @"") withTitleColor:[UIColor whiteColor] withBackColor:[UIColor colorWithRed:82/255.0 green:153/255.0 blue:223/255.0 alpha:1.0] isRounded:NO withFrame:CGRectMake(0, coverImageView.frame.origin.y + coverImageView.frame.size.height + 15, screenWidth, 35)];
    [selectCategoryButton addTarget:self action:@selector(selectCategoryButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:selectCategoryButton];
    selectCategoryButton.userInteractionEnabled = NO;
    
    selectTagButton = [CustomButton initButtonWithTitle:NSLocalizedString(@"selectTag", @"") withTitleColor:[UIColor whiteColor] withBackColor:[UIColor colorWithRed:82/255.0 green:153/255.0 blue:223/255.0 alpha:1.0] isRounded:NO withFrame:CGRectMake(0, selectCategoryButton.frame.origin.y + selectCategoryButton.frame.size.height + 15, screenWidth, 35)];
    [selectTagButton addTarget:self action:@selector(selectTagButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:selectTagButton];
    selectTagButton.userInteractionEnabled = NO;
    
    UIView *horizontalLine = [[UIView alloc]initWithFrame:CGRectMake(0, selectTagButton.frame.origin.y + selectTagButton.frame.size.height + 60, screenWidth, 1)];
    horizontalLine.backgroundColor = [UIColor grayColor];
    [scrollView addSubview:horizontalLine];
    
    UILabel *titleLabel =[[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 100, horizontalLine.frame.origin.y + 10, 90, 40)];
    titleLabel.font = FONT_NORMAL(16);
    titleLabel.text = NSLocalizedString(@"for:", @"");
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.textAlignment = NSTextAlignmentRight;
    [scrollView addSubview:titleLabel];
    
    selectProfileButton = [CustomButton initButtonWithTitle:NSLocalizedString(@"choose", @"") withTitleColor:[UIColor whiteColor] withBackColor:[UIColor colorWithRed:82/255.0 green:153/255.0 blue:223/255.0 alpha:1.0] isRounded:NO withFrame:CGRectMake(0, titleLabel.frame.origin.y + titleLabel.frame.size.height + 15, screenWidth, 35)];
    [selectProfileButton addTarget:self action:@selector(selectProfileButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:selectProfileButton];
    selectProfileButton.userInteractionEnabled = NO;
    
    //54x73
    UIButton *attachButton = [CustomButton initButtonWithImage:[UIImage imageNamed:@"attach"] withFrame:CGRectMake(20, selectProfileButton.frame.origin.y + selectProfileButton.frame.size.height + 50, 54 * 0.4, 73 * 0.4)];
    [attachButton addTarget:self action:@selector(attachButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:attachButton];
    
    //84x60
    UIButton *attachMediaButton = [CustomButton initButtonWithImage:[UIImage imageNamed:@"attachMedia_create_post"] withFrame:CGRectMake(screenWidth - 60, selectProfileButton.frame.origin.y + selectProfileButton.frame.size.height + 50, 84 * 0.4, 60 * 0.4)];
    [attachMediaButton addTarget:self action:@selector(attachButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:attachMediaButton];
    
    
    sendButton = [CustomButton initButtonWithTitle:NSLocalizedString(@"ارسال", @"") withTitleColor:[UIColor whiteColor] withBackColor:[UIColor colorWithRed:82/255.0 green:153/255.0 blue:223/255.0 alpha:1.0] isRounded:NO withFrame:CGRectMake(0, attachButton.frame.origin.y + attachButton.frame.size.height + 15, screenWidth, 35)];
    [sendButton addTarget:self action:@selector(sendButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:sendButton];
}

- (void)sendButtonAction{
    [self sendToServer];
}
- (void)selectProfileButtonAction{
    [self showPickerViewEntity];
}
- (void)attachButtonAction{
    [self showgalleryCameraView];
}

- (void)selectCoverImageButtonAction{
    [self showgalleryCameraView];
}
- (void)backButtonImgAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissTextField{
    [titleTextField resignFirstResponder];
    [contentTextView resignFirstResponder];
    [self hideGalleryCameraView];
}

- (void)selectCategoryButtonAction{
    [self showPickerViewCategory];
    [self dismissTextField];
}

- (void)selectTagButtonAction{
    [self dismissTextField];
    [self showPickerViewTags];
}

- (void)makePickerViewCategory{
    
    categoryPickerView = [[UIPickerView alloc] init];
    [categoryPickerView setDataSource: self];
    [categoryPickerView setDelegate: self];
    categoryPickerView.tag = 1;
    categoryPickerView.backgroundColor = [UIColor whiteColor];
    [categoryPickerView setFrame: CGRectMake(0, screenHeight, screenWidth, 200.0f)];
    [self.view addSubview:categoryPickerView];
}

- (void)makePickerViewTags{
    
    
    tagPickerView = [[UIPickerView alloc] init];
    [tagPickerView setDataSource: self];
    [tagPickerView setDelegate: self];
    tagPickerView.tag = 2;
    tagPickerView.backgroundColor = [UIColor whiteColor];
    [tagPickerView setFrame: CGRectMake(0, screenHeight, screenWidth, 200.0f)];
    [self.view addSubview:tagPickerView];
}

- (void)makePickerViewEntity{
    
    entityPickerView = [[UIPickerView alloc] init];
    [entityPickerView setDataSource: self];
    [entityPickerView setDelegate: self];
    entityPickerView.tag = 3;
    entityPickerView.backgroundColor = [UIColor whiteColor];
    [entityPickerView setFrame: CGRectMake(0, screenHeight, screenWidth, 200.0f)];
    [self.view addSubview:entityPickerView];
}

- (void)showPickerViewCategory{
    [UIView animateWithDuration:0.5 animations:^{
        scrollView.contentSize = CGSizeMake(screenWidth, screenHeight + 100);
        [scrollView scrollRectToVisible:CGRectMake(0, screenHeight + 50, screenWidth, 1) animated:YES];
        //        CGRect rect = self.view.frame;
        //        rect.origin.y = self.view.frame.origin.y - 60;
        //        self.view.frame = rect;
    }];
    selectCategoryButton.userInteractionEnabled = NO;
    isHiddenPickerView = NO;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         categoryPickerView.frame = CGRectMake(0, screenHeight - 180, screenWidth, 200.0f);
                     }
                     completion:^(BOOL finished){
                         //
                     }];
    
    categoryToolbar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,screenHeight - 220,screenWidth,44)];
    [categoryToolbar setBarStyle:UIBarStyleBlackOpaque];
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"تایید"
                                                                      style:UIBarButtonItemStyleDone target:self action:@selector(DoneButtonForCategoryPickerView)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    categoryToolbar.items = @[flex, barButtonDone];
    //barButtonDone.tintColor=[UIColor whiteColor];
    [self.view addSubview:categoryToolbar];
}

- (void)DoneButtonForCategoryPickerView{
    
    [self hidePickerViewCategory];
}

- (void)hidePickerViewCategory{
    [UIView animateWithDuration:0.5 animations:^{
        scrollView.contentSize = CGSizeMake(screenWidth, selectProfileButton.frame.origin.y + 50);
        [scrollView scrollRectToVisible:CGRectMake(0, 1, screenWidth, 1) animated:YES];
    }];
    selectCategoryButton.userInteractionEnabled = YES;
    isHiddenPickerView = YES;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         categoryPickerView.frame = CGRectMake(0, screenHeight, screenWidth, 200.0f);
                     }
                     completion:^(BOOL finished){
                     }];
    categoryToolbar.hidden = YES;
    [categoryToolbar removeFromSuperview];
}


- (void)showPickerViewTags{
    [UIView animateWithDuration:0.5 animations:^{
        scrollView.contentSize = CGSizeMake(screenWidth, screenHeight + 150 - 100);
        [scrollView scrollRectToVisible:CGRectMake(0, screenHeight + 100, screenWidth, 1) animated:YES];
        //        CGRect rect = self.view.frame;
        //        rect.origin.y = self.view.frame.origin.y - 60;
        //        self.view.frame = rect;
    }];
    
    selectTagButton.userInteractionEnabled = NO;
    isHiddenPickerView = NO;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         tagPickerView.frame = CGRectMake(0, screenHeight - 180, screenWidth, 200.0f);
                     }
                     completion:^(BOOL finished){
                         //
                     }];
    
    tagsToolbar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,screenHeight - 220,screenWidth,44)];
    [tagsToolbar setBarStyle:UIBarStyleBlackOpaque];
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"تایید"
                                                                      style:UIBarButtonItemStyleDone target:self action:@selector(DoneButtonForTagsPickerView)];
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    tagsToolbar.items = @[flex, barButtonDone];
    //barButtonDone.tintColor=[UIColor whiteColor];
    [self.view addSubview:tagsToolbar];
}

- (void)DoneButtonForTagsPickerView{
    
    [self hidePickerViewTags];
}

- (void)hidePickerViewTags{
    [UIView animateWithDuration:0.5 animations:^{
        scrollView.contentSize = CGSizeMake(screenWidth, selectProfileButton.frame.origin.y + 50);
        [scrollView scrollRectToVisible:CGRectMake(0, 1, screenWidth, 1) animated:YES];
    }];
    
    selectTagButton.userInteractionEnabled = YES;
    isHiddenPickerView = YES;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         tagPickerView.frame = CGRectMake(0, screenHeight, screenWidth, 200.0f);
                     }
                     completion:^(BOOL finished){
                     }];
    tagsToolbar.hidden = YES;
    [tagsToolbar removeFromSuperview];
}

- (void)showPickerViewEntity{
    [UIView animateWithDuration:0.5 animations:^{
        scrollView.contentSize = CGSizeMake(screenWidth, screenHeight + 100);
        [scrollView scrollRectToVisible:CGRectMake(0, screenHeight + 50, screenWidth, 1) animated:YES];
        //        CGRect rect = self.view.frame;
        //        rect.origin.y = self.view.frame.origin.y - 60;
        //        self.view.frame = rect;
    }];
    selectProfileButton.userInteractionEnabled = NO;
    isHiddenPickerView = NO;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         entityPickerView.frame = CGRectMake(0, screenHeight - 180, screenWidth, 200.0f);
                     }
                     completion:^(BOOL finished){
                         //
                     }];
    
    entityToolbar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,screenHeight - 220,screenWidth,44)];
    [entityToolbar setBarStyle:UIBarStyleBlackOpaque];
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"تایید"
                                                                      style:UIBarButtonItemStyleDone target:self action:@selector(DoneButtonForEntityPickerView)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    entityToolbar.items = @[flex, barButtonDone];
    //barButtonDone.tintColor=[UIColor whiteColor];
    [self.view addSubview:entityToolbar];
}

- (void)DoneButtonForEntityPickerView{
    
    [self hidePickerViewEntity];
}

- (void)hidePickerViewEntity{
    [UIView animateWithDuration:0.5 animations:^{
        scrollView.contentSize = CGSizeMake(screenWidth, selectProfileButton.frame.origin.y + 170);
        //[scrollView scrollRectToVisible:CGRectMake(0, selectProfileButton.frame.origin.y + 50, screenWidth, 1) animated:YES];
        //[scrollView scrollRectToVisible:CGRectMake(0, 1, screenWidth, 1) animated:YES];
    }];
    selectProfileButton.userInteractionEnabled = YES;
    isHiddenPickerView = YES;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         entityPickerView.frame = CGRectMake(0, screenHeight, screenWidth, 200.0f);
                     }
                     completion:^(BOOL finished){
                     }];
    entityToolbar.hidden = YES;
    [entityToolbar removeFromSuperview];
}


- (void)reloadTagsView{
    //if ([selectedTagsArray count] <= [tagsArray count]) {
        [bgViewForTagsLabel removeFromSuperview];
        CGFloat yPosOfSelectTagsLabel = selectTagButton.frame.origin.y + selectTagButton.frame.size.height + 10;
        bgViewForTagsLabel = [[UIView alloc]initWithFrame:CGRectMake(0, yPosOfSelectTagsLabel, screenWidth, [selectedTagsArray count] * 30)];
        //bgViewForTagsLabel.backgroundColor = [UIColor blueColor];
        [scrollView addSubview:bgViewForTagsLabel];
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
            label.text = [NSString stringWithFormat:@"%@ x", tagName];
            label.font = FONT_NORMAL(13);
            label.textColor = COLOR_1;
            label.layer.cornerRadius = 12;
            label.layer.borderColor = COLOR_1.CGColor;
            label.layer.borderWidth = 0.5;
            label.clipsToBounds = YES;
            [bgViewForTagsLabel addSubview:label];
            
            xPOS += label.frame.size.width + 15;
            
            
            if ((xPOS > screenWidth) || ((i+1) % 3 == 0)) {
                xPOS = 10;
                yPOS += 30;
            }
        }
    //}
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

- (void)deleteTagImageAction:(UITapGestureRecognizer *)tapy{
    
    NSInteger idOfTapLabel = tapy.view.tag;
    [selectedTagsArray removeObjectAtIndex:idOfTapLabel];
    
    [self reloadTagsView];
}

#pragma mark - textfield delegates
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [contentTextView becomeFirstResponder];
    return NO;
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
    [self dismissTextField];
    
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
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    coverImageView.image = chosenImage;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    //upload new image to server
    //[self sendPhotoToServer];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - pickerview delegate
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (pickerView.tag == 1) {
        return [categoryArray count];
    } else if (pickerView.tag == 2) {
        return [tagsArray count];
    } else if (pickerView.tag == 3) {
        return [entityArray count];
    }
    return 0;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* tView = (UILabel*)view;
    NSString *title;
    if (pickerView.tag == 1) {
        title = [[categoryArray objectAtIndex:row]objectForKey:@"name"];
    } else if (pickerView.tag == 2) {
        title = [[tagsArray objectAtIndex:row]objectForKey:@"name"];
    } else if (pickerView.tag == 3) {
        title = [[entityArray objectAtIndex:row]objectForKey:@"name"];
    }
    
    if (!tView){
        tView = [[UILabel alloc] init];
        UIFont *font = FONT_NORMAL(14);
        tView.textAlignment = NSTextAlignmentCenter;
        tView.font =font;
    }
    tView.text = [NSString stringWithFormat:@"%@", title];
    return tView;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (pickerView.tag == 1) {
        [selectCategoryButton setTitle:[NSString stringWithFormat:@"%@", [[categoryArray objectAtIndex:row]objectForKey:@"name"]] forState:UIControlStateNormal];
    } else if (pickerView.tag == 2) {
        if ([selectedTagsArray count] + 1 <= [tagsArray count]) {
            [selectedTagsArray addObject:[tagsArray objectAtIndex:row]];
            [self reloadTagsView];
        }
    } else if (pickerView.tag == 3) {
        [selectProfileButton setTitle:[NSString stringWithFormat:@"%@", [[entityArray objectAtIndex:row]objectForKey:@"name"]] forState:UIControlStateNormal];
        selectedEntityId = [[[entityArray objectAtIndex:row]objectForKey:@"id"]integerValue];
    }
}
/*
 CGFloat ypos = 5;
 for (int i = 0; i < [self.arrayOfProfessions count]; i++) {
 UILabel *tagLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/2 - 150, ypos, 300, 25)];
 tagLabel.textAlignment = NSTextAlignmentCenter;
 tagLabel.textColor = [UIColor blackColor];
 tagLabel.font = FONT_SWISSRA_BOLD(13);
 tagLabel.text = [NSString stringWithFormat:@"%@", [[self.arrayOfProfessions objectAtIndex:i]objectForKey:@"name"]];
 [bgViewForProfessionsLabel addSubview:tagLabel];
 
 UIImageView *closeImg = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 50, ypos, 15, 15)];
 closeImg.image = [UIImage imageNamed:@"delete speciality.png"];
 UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(deleteProfessionImageAction:)];
 tap.delegate = self;
 [closeImg addGestureRecognizer:tap];
 closeImg.userInteractionEnabled = YES;
 closeImg.tag = i;
 [bgViewForProfessionsLabel addSubview:closeImg];
 
 ypos += 30;
 }
 
 */
#pragma mark - connection

- (void)getTagsFromServer{
    NSString *url = [NSString stringWithFormat:@"%@api/tag/all", BaseURL];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"application/json"];
    manager.requestSerializer.timeoutInterval = 45;
    //NSLog(@"%@", [GetUsernamePassword getAccessToken]);
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [GetUsernamePassword getAccessToken]] forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    [manager POST:url parameters:nil progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        NSDictionary *tempDic = (NSDictionary *)responseObject;
        tagsArray = [[NSMutableArray alloc]init];
        selectedTagsArray = [[NSMutableArray alloc]init];
        for (NSDictionary *tag in [tempDic objectForKey:@"data"]) {
            [tagsArray addObject:tag];
        }
        selectTagButton.userInteractionEnabled = YES;
        [self makePickerViewTags];
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [self getTagsFromServer];
    }];
    
}

- (void)getCategoryFromServer{
    NSString *url = [NSString stringWithFormat:@"%@api/category/all", BaseURL];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"application/json"];
    manager.requestSerializer.timeoutInterval = 45;
    //NSLog(@"%@", [GetUsernamePassword getAccessToken]);
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [GetUsernamePassword getAccessToken]] forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    [manager POST:url parameters:nil progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        NSDictionary *tempDic = (NSDictionary *)responseObject;
        categoryArray = [[NSMutableArray alloc]init];
        for (NSDictionary *tag in [tempDic objectForKey:@"data"]) {
            [categoryArray addObject:tag];
        }
        selectCategoryButton.userInteractionEnabled = YES;
        [self makePickerViewCategory];
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [self getCategoryFromServer];
    }];
}

- (void)getEntityFromServer{
    NSString *url = [NSString stringWithFormat:@"%@api/entity/all", BaseURL];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"application/json"];
    manager.requestSerializer.timeoutInterval = 45;
    //NSLog(@"%@", [GetUsernamePassword getAccessToken]);
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [GetUsernamePassword getAccessToken]] forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    [manager POST:url parameters:nil progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        NSDictionary *tempDic = (NSDictionary *)responseObject;
        entityArray = [[NSMutableArray alloc]init];
        for (NSDictionary *tag in [tempDic objectForKey:@"data"]) {
            [entityArray addObject:tag];
        }
        selectProfileButton.userInteractionEnabled = YES;
        [self makePickerViewEntity];
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [self getEntityFromServer];
    }];
}

- (void)sendToServer{
    if ([titleTextField.text length]  < 3) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"تمام فیلدها را پر کنید" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            // ////NSLog(@"You pressed button OK");
        }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    if ([contentTextView.text length]  < 3) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"تمام فیلدها را پر کنید" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            // ////NSLog(@"You pressed button OK");
        }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    if ([selectCategoryButton.titleLabel.text isEqualToString:NSLocalizedString(@"selectCategory", @"")]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"تمام فیلدها را پر کنید" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            // ////NSLog(@"You pressed button OK");
        }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    if ([selectedTagsArray count] == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"تمام فیلدها را پر کنید" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            // ////NSLog(@"You pressed button OK");
        }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    [ProgressHUD show:@""];
    //NSInteger profileId = [[[NSUserDefaults standardUserDefaults]objectForKey:@"profileID"]integerValue];
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init]; /*@{@"entity_id":[NSNumber numberWithInteger:selectedEntityId],
                             @"title":titleTextField.text,
                             @"text":contentTextView.text
                             };*/
    params[@"entity_id"] = [NSNumber numberWithInteger:selectedEntityId];
    params[@"title"] = titleTextField.text;
    params[@"text"] = contentTextView.text;
    for (NSInteger i = 0; i < [selectedTagsArray count]; i++) {
        NSString *keyname = [NSString stringWithFormat:@"tags[%ld]", (long)i];
        [params setValue:[[selectedTagsArray objectAtIndex:i]objectForKey:@"name"] forKey:keyname];
    }
    
    NSData *coverData = UIImagePNGRepresentation(coverImageView.image);
    NSData *imageData = UIImagePNGRepresentation(coverImageView.image);
    NSString *url = [NSString stringWithFormat:@"%@api/post/add", BaseURL];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"application/json"];
    manager.requestSerializer.timeoutInterval = 45;
    //NSLog(@"%@", [GetUsernamePassword getAccessToken]);
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [GetUsernamePassword getAccessToken]] forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    [manager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:coverData
                                    name:@"cover"
                                fileName:@"cover" mimeType:@"image/jpeg"];
        [formData appendPartWithFileData:imageData
                                    name:@"image"
                                fileName:@"image" mimeType:@"image/jpeg"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        //NSLog(@"%f",uploadProgress.fractionCompleted);
        dispatch_async(dispatch_get_main_queue(), ^{
            [sendButton setTitle:[NSString stringWithFormat:@"%f", uploadProgress.fractionCompleted] forState:UIControlStateNormal];

        });
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [ProgressHUD dismiss];
        //[[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"isProfileCompleted"];
        [self dismissViewControllerAnimated:YES completion:^{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%@", [responseObject objectForKey:@"message"]] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                // ////NSLog(@"You pressed button OK");
            }];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }];

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [ProgressHUD dismiss];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%@", [error localizedDescription]] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            // ////NSLog(@"You pressed button OK");
        }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }];
    /*
    [manager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:coverData
                                    name:@"cover"
                                fileName:@"cover" mimeType:@"image/jpeg"];
        [formData appendPartWithFileData:imageData
                                    name:@"image"
                                fileName:@"image" mimeType:@"image/jpeg"];
    } progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [ProgressHUD dismiss];
        [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"isProfileCompleted"];
        [self dismissViewControllerAnimated:YES completion:^{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%@", [responseObject objectForKey:@"message"]] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                // ////NSLog(@"You pressed button OK");
            }];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [ProgressHUD dismiss];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%@", [error localizedDescription]] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            // ////NSLog(@"You pressed button OK");
        }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }];
     */
}

@end
