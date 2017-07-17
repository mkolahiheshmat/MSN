//
//  UploadNewFileViewController.m
//  MSN
//
//  Created by Yarima on 5/8/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "UploadNewFileViewController.h"
#import "Header.h"
#import <AFHTTPSessionManager.h>
#import <UIImageView+AFNetworking.h>
#import "CustomButton.h"
#import "ProgressHUD.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import "DocumentDirectoy.h"
#import "ConvertToPersianDate.h"
#import "GetUsernamePassword.h"
#import "UIImage+Extra.h"
@interface UploadNewFileViewController()<UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
     
    UIScrollView *scrollView;
    UIImageView *imageView;
    UITextField *documentNameTextField;
    UITextField *clinicTextField;
    UIButton *showDatePickerButton;
    UIButton *sendButton;
    UIPickerView *datePickerView;
    NSMutableArray *daysArray;
    NSMutableArray *monthsArray;
    NSMutableArray *yearsArray;
    BOOL isHidden;
    UIToolbar *dateToolbar;
    NSString *year;
    NSString *month;
    NSString *day;
    
}
@end
@implementation UploadNewFileViewController
- (void)viewDidDisappear:(BOOL)animated{
    [ProgressHUD dismiss];
}
- (void)viewDidLoad{
    self.navigationController.navigationBar.hidden = YES;
    
     
    
    //make View
    [self makeTopBar];
    [self makeUIElements];
    
    //NSLog(@"self.navigationControllers: %@", [self.navigationController viewControllers]);
}

#pragma mark - Custom methods

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
    titleLabel.font = FONT_NORMAL(20);
    titleLabel.text = NSLocalizedString(@"uploadDocs", @"");
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:titleLabel];

    UIButton *backButtonImg = [[UIButton alloc]initWithFrame:CGRectMake(0, 16 , 45, 45)];
    [backButtonImg setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButtonImg addTarget:self action:@selector(backButtonImgAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButtonImg];
}

- (void)makeUIElements{
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 70, screenWidth, screenHeight -70)];
    scrollView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissTextField)];
    [scrollView addGestureRecognizer:tap];
    [self.view addSubview:scrollView];
    
    imageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth/2 - 100, 10, 200, 200)];
    imageView.image = self.documentImageView.image;
    [scrollView addSubview:imageView];
    
    documentNameTextField = [[UITextField alloc]initWithFrame:CGRectMake(screenWidth/2 - 100, imageView.frame.origin.y + imageView.frame.size.height + 30, 200, 30)];
    documentNameTextField.placeholder = NSLocalizedString(@"filename", "");
    documentNameTextField.delegate = self;
    documentNameTextField.font = FONT_NORMAL(15);
    documentNameTextField.clipsToBounds = YES;
    documentNameTextField.textAlignment = NSTextAlignmentCenter;
    documentNameTextField.layer.cornerRadius = 15;
    documentNameTextField.layer.borderWidth = 2.0;
    documentNameTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    documentNameTextField.tag = 54;
    [scrollView addSubview:documentNameTextField];
    
    showDatePickerButton = [CustomButton initButtonWithTitle:NSLocalizedString(@"date", @"") withTitleColor:[UIColor blackColor] withBackColor:[UIColor whiteColor] withFrame:CGRectMake(screenWidth/2 - 100, documentNameTextField.frame.origin.y + documentNameTextField.frame.size.height + 30, 200, 30)];
    [showDatePickerButton addTarget:self action:@selector(showDataPicker) forControlEvents:UIControlEventTouchUpInside];
    showDatePickerButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    showDatePickerButton.layer.borderWidth = 2.0;
    showDatePickerButton.clipsToBounds = YES;
    showDatePickerButton.titleLabel.font = FONT_NORMAL(15);
    [scrollView addSubview:showDatePickerButton];
    
    clinicTextField = [[UITextField alloc]initWithFrame:CGRectMake(screenWidth/2 - 100, showDatePickerButton.frame.origin.y + showDatePickerButton.frame.size.height + 30, 200, 30)];
    clinicTextField.placeholder = NSLocalizedString(@"clinic", "");
    clinicTextField.delegate = self;
    clinicTextField.layer.cornerRadius = 15;
    clinicTextField.clipsToBounds = YES;
    clinicTextField.font = FONT_NORMAL(15);
    clinicTextField.textAlignment = NSTextAlignmentCenter;
    clinicTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    clinicTextField.layer.borderWidth = 2.0;
    clinicTextField.clipsToBounds = YES;
    clinicTextField.tag = 64;
    [scrollView addSubview:clinicTextField];
    
    sendButton = [CustomButton initButtonWithTitle:NSLocalizedString(@"taeed", @"") withTitleColor:[UIColor whiteColor] withBackColor:[UIColor colorWithRed:26/255.0 green:184/255.0 blue:180/255.0 alpha:1.0] withFrame:CGRectMake(screenWidth/2 - 75, clinicTextField.frame.origin.y + clinicTextField.frame.size.height + 30, 150, 30)];
    [sendButton addTarget:self action:@selector(uploadDocumentsToServer) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:sendButton];
    
    if ([self image:imageView.image isEqualTo:[UIImage imageNamed:@"broken_image"]]) {
        [self disableSendButton];
    }
    scrollView.contentSize = CGSizeMake(screenWidth, screenHeight);
    [self initiateDatePicker];
    if (_isFromTableView) {
        [self loadImageFileFromDocument];
        if (!imageView.image){
            UIImage *placeholderImage = [UIImage imageNamed:@"png"];
            if ([_documentImgageUrl containsString:@"jpg"] || [_documentImgageUrl containsString:@"jpeg"])
                placeholderImage = [UIImage imageNamed:@"jpeg"];
            
            [imageView setImageWithURL:[NSURL URLWithString:
                                        [NSString stringWithFormat:@"%@%@",BaseURL, _documentImgageUrl]]
                      placeholderImage:placeholderImage];
        }
        if (_documentName != (id)[NSNull null]) {
            documentNameTextField.text = _documentName;
        }
        
        [showDatePickerButton setTitle:_documentDate forState:UIControlStateNormal];
        if (_documentClinic != (id)[NSNull null]) {
            clinicTextField.text = _documentClinic;
        }
        
        [sendButton setTitle:NSLocalizedString(@"download", @"") forState:UIControlStateNormal];
        [sendButton removeTarget:self action:@selector(uploadDocumentsToServer) forControlEvents:UIControlEventTouchUpInside];
        [sendButton addTarget:self action:@selector(saveImageIntoDocumets) forControlEvents:UIControlEventTouchUpInside];
        
        documentNameTextField.userInteractionEnabled = NO;
        [showDatePickerButton setTitle:_documentDate forState:UIControlStateNormal];
        showDatePickerButton.userInteractionEnabled = NO;
        clinicTextField.userInteractionEnabled = NO;
    }
}

- (void)initiateDatePicker{
    daysArray = [[NSMutableArray alloc]init];
    for (int i = 1; i < 32 ; i++) {
        [daysArray addObject:[NSString stringWithFormat:@"%d", i]];
    }
    
    monthsArray = [[NSMutableArray alloc]initWithObjects:
                   NSLocalizedString(@"far", @""),
                   NSLocalizedString(@"ordi", @""),
                   NSLocalizedString(@"khordad", @""),
                   NSLocalizedString(@"tir", @""),
                   NSLocalizedString(@"mordad", @""),
                   NSLocalizedString(@"shahrivar", @""),
                   NSLocalizedString(@"mahr", @""),
                   NSLocalizedString(@"aban", @""),
                   NSLocalizedString(@"azar", @""),
                   NSLocalizedString(@"day", @""),
                   NSLocalizedString(@"bahman", @""),
                   NSLocalizedString(@"esfand", @"")
                   ,nil];
    
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY.MM.dd HH:mm:ss"];
    NSString *stringFromDate = [formatter stringFromDate:now];
    NSInteger persianYear = [ConvertToPersianDate getPersianYear:stringFromDate];
    NSInteger persianMonth = [ConvertToPersianDate getPersianMonth:stringFromDate];
    NSInteger persianDay = [ConvertToPersianDate getPersianDay:stringFromDate];
    year = [NSString stringWithFormat:@"%ld", (long)persianYear];
    month = [NSString stringWithFormat:@"%ld", (long)persianMonth];
    day = [NSString stringWithFormat:@"%ld", (long)persianDay];
    NSString *shamsiDate = [ConvertToPersianDate ConvertToPersianDate3:stringFromDate];
    [showDatePickerButton setTitle:[NSString stringWithFormat:@"%@", shamsiDate] forState:UIControlStateNormal];
    
    yearsArray = [[NSMutableArray alloc]init];
    for (NSInteger i = persianYear - 2; i <= persianYear ; i++) {
        [yearsArray addObject:[NSString stringWithFormat:@"%ld", (long)i]];
    }
    
    datePickerView = [[UIPickerView alloc] init];
    [datePickerView setDataSource: self];
    [datePickerView setDelegate: self];
    datePickerView.tag = 1;
    datePickerView.backgroundColor = [UIColor whiteColor];
    [datePickerView setFrame: CGRectMake(0, screenHeight, screenWidth, 200.0f)];
    [self.view addSubview:datePickerView];
    
}

- (void)backButtonImgAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissTextField{
    [documentNameTextField resignFirstResponder];
    [clinicTextField resignFirstResponder];
    [scrollView scrollRectToVisible:CGRectMake(1, 1, 1, 1) animated:YES];
}

- (void)loadImageFileFromDocument{
    NSString *imageFileName = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject]stringByAppendingPathComponent:_documentImgageUrl]lastPathComponent];
    NSString *pathOfImage = [[NSURL fileURLWithPath:imageFileName]path];
    BOOL isDirectory;
    NSString *documentPath = [DocumentDirectoy getDocuementsDirectory];
    pathOfImage = [NSString stringWithFormat:@"%@%@", documentPath, pathOfImage];
    if ([[NSFileManager defaultManager]fileExistsAtPath:pathOfImage isDirectory:&isDirectory]) {
        imageView.image = [UIImage imageWithContentsOfFile:pathOfImage];
        [self disableSendButton];
    }
}

- (void)saveImageIntoDocumets{
    //convert image into .png format.
    NSData *imageData = UIImagePNGRepresentation(imageView.image);
    //create instance of NSFileManager
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *appDocumentsDirectory = [DocumentDirectoy getDocuementsDirectory];
    //add our image to the path
    NSString *fullPath = [appDocumentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", [_documentImgageUrl lastPathComponent]]];
    //finally save the path (image)
    BOOL resultSave = [fileManager createFileAtPath:fullPath contents:imageData attributes:nil];
    if (resultSave) {
        //NSLog(@"image saved");
        [self disableSendButton];
    }
}

- (void)disableSendButton{
    sendButton.userInteractionEnabled = NO;
    [sendButton setBackgroundColor:[UIColor grayColor]];
}

- (BOOL)image:(UIImage *)image1 isEqualTo:(UIImage *)image2
{
    NSData *data1 = UIImagePNGRepresentation(image1);
    NSData *data2 = UIImagePNGRepresentation(image2);
    
    return [data1 isEqual:data2];
}

#pragma mark - date picker delegate

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    return 3;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    NSInteger count =   0;
    switch (component) {
        case 0:
            count = [yearsArray count];
            break;
        case 1:
            count = [monthsArray count];
            break;
        case 2:
            count = [daysArray count];
            break;
            
    }
    return count;
}


- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = @"";
    switch (component) {
        case 0:
            title = [yearsArray objectAtIndex:row];
            break;
        case 1:
            title = [monthsArray objectAtIndex:row];
            break;
        case 2:
            if (pickerView.tag == 1)
                title = [daysArray objectAtIndex:row];
            break;
            
    }
    
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName:[UIFont fontWithName:@"YekanMob" size:11]}];
    
    return attString;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    UILabel* tView = (UILabel*)view;
    NSString *title = @"";
    switch (component) {
        case 0:
            title = [yearsArray objectAtIndex:row];
            break;
        case 1:
            title = [monthsArray objectAtIndex:row];
            break;
        case 2:
            title = [daysArray objectAtIndex:row];
            break;
            
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
// Do something with the selected row.
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    switch (component) {
        case 0:
            year = [yearsArray objectAtIndex:row];
            break;
        case 1:
            month = [monthsArray objectAtIndex:row];
            break;
        case 2:
            day = [daysArray objectAtIndex:row];
            break;
    }
    [showDatePickerButton setTitle:[NSString stringWithFormat:@"%@ %@ %@",day, month, year]forState:UIControlStateNormal];
    
}


- (void)showDataPicker{
    showDatePickerButton.userInteractionEnabled = NO;
    [self dismissTextField];
    
    CGPoint topOffset = CGPointMake(0, 120);
    [scrollView setContentOffset:topOffset animated:YES];
    
    isHidden = NO;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         datePickerView.frame = CGRectMake(0, screenHeight - 180, screenWidth, 200.0f);
                     }
                     completion:^(BOOL finished){
                         //
                     }];
    
    dateToolbar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,screenHeight - 220,screenWidth,44)];
    [dateToolbar setBarStyle:UIBarStyleBlackOpaque];
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"تایید"
                                                                      style:UIBarButtonItemStyleDone target:self action:@selector(DoneButtonForBirthdatePickerView:)];
    dateToolbar.items = @[barButtonDone];
    //barButtonDone.tintColor=[UIColor whiteColor];
    [self.view addSubview:dateToolbar];
    
}

- (void)DoneButtonForBirthdatePickerView:(id)sender{
    
    [self hideBirthdatepickerView];
}

- (void)hideBirthdatepickerView{
    showDatePickerButton.userInteractionEnabled = YES;
    isHidden = YES;
    
    CGPoint topOffset = CGPointMake(0, 0);
    [scrollView setContentOffset:topOffset animated:YES];
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         datePickerView.frame = CGRectMake(0, screenHeight, screenWidth, 200.0f);
                     }
                     completion:^(BOOL finished){
                     }];
    dateToolbar.hidden = YES;
    [dateToolbar removeFromSuperview];
    
}


#pragma mark - text field delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField.tag == 54) {
        if (IS_IPHONE_4_AND_OLDER_IOS7 || IS_IPHONE_4_AND_OLDER_IOS8) {
            scrollView.contentSize = CGSizeMake(screenWidth, screenHeight * 1.3);
            [scrollView scrollRectToVisible:CGRectMake(1, 1, 1, screenHeight * 1.3) animated:YES];
        }else if (IS_IPHONE_5_IOS7 || IS_IPHONE_5_IOS8) {
            scrollView.contentSize = CGSizeMake(screenWidth, screenHeight * 1.3);
            [scrollView scrollRectToVisible:CGRectMake(1, 1, 1, screenHeight * 1.3) animated:YES];
        }else{
            [scrollView scrollRectToVisible:CGRectMake(1, 1, 1, 1) animated:YES];
        }
    } else if (textField.tag == 64){
        if (IS_IPHONE_4_AND_OLDER_IOS7 || IS_IPHONE_4_AND_OLDER_IOS8) {
            scrollView.contentSize = CGSizeMake(screenWidth, screenHeight * 1.4);
            [scrollView scrollRectToVisible:CGRectMake(1, 1, 1, screenHeight * 1.4) animated:YES];
        }else if (IS_IPHONE_5_IOS7 || IS_IPHONE_5_IOS8) {
            scrollView.contentSize = CGSizeMake(screenWidth, screenHeight * 1.3);
            [scrollView scrollRectToVisible:CGRectMake(1, 1, 1, screenHeight * 1.3) animated:YES];
        }else{
            [scrollView scrollRectToVisible:CGRectMake(1, 1, 1, screenHeight + 50) animated:YES];
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
}
#pragma mark - connection
- (NSString *)encodeToBase64String:(UIImage *)image {
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:0];
}

- (void)downloadImageIntoDocs{
    if ([self hasConnectivity]) {
        
    } else {
         
    }
}
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

- (void)uploadDocumentsToServer{
    if ([self hasConnectivity]) {
        
        if ([documentNameTextField.text length] == 0){
            
            return;
        }
        if ([clinicTextField.text length] == 0) {
            
            
            return;
        }
        if ([showDatePickerButton.titleLabel.text length] == 0) {
            
            
            return;
        }
        
        [self dismissTextField];
        
        [ProgressHUD show:NSLocalizedString(@"", @"") Interaction:NO];
        NSString *file = [self encodeToBase64String:imageView.image];
        NSString *docName = [NSString stringWithFormat:@"%@",documentNameTextField.text];
        NSString *docProvider = [NSString stringWithFormat:@"%@",clinicTextField.text];
        NSString *docRefDate = [NSString stringWithFormat:@"%@",showDatePickerButton.titleLabel.text];
        
        NSData *documentData = [docName dataUsingEncoding:NSUTF8StringEncoding];
        NSData *docProviderData = [docProvider dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *userpassDic = [GetUsernamePassword getUsernamePassword];
        NSDictionary *params;
        if ([userpassDic count] > 1) {
            
            params = @{@"username":[userpassDic objectForKey:@"username"]/*@"09191234072"*/,
                                     @"password":[userpassDic objectForKey:@"password"]/*@“123456”*/,
                                     @"profile_id":[GetUsernamePassword getProfileId]/*@"30273"*/,
                                     @"file_type":@"png",
                                     @"file":file,
                                     @"doc_name":[documentData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn],
                                     @"doc_provider":[docProviderData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn],
                                     @"doc_ref_date":docRefDate,
                                     @"debug":@"1",
                                     @"unit_id": @"3"
                                     };
        }else{
            params = @{@"username":@"",
                       @"password":@"",
                       @"profile_id":@"",
                       @"file_type":@"png",
                       @"file":file,
                       @"doc_name":@"",
                       @"doc_provider":@"",
                       @"doc_ref_date":@"",
                       @"debug":@"1",
                       @"unit_id": @"3"
                       };
        }
        //    KeychainWrapper *keychainWrapper = [[KeychainWrapper alloc]init];
        //    NSString *username = [keychainWrapper myObjectForKey:(__bridge id)(kSecAttrDescription)];
        //    NSString *password = [keychainWrapper myObjectForKey:(__bridge id)(kSecAttrService)];
        NSString *url = [NSString stringWithFormat:@"%@Document_add", BaseURL];
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        [manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
            [ProgressHUD dismiss];
            NSDictionary *tempDic = (NSDictionary *)responseObject;
            //NSLog(@"%@", tempDic);
            //success
            if ([[tempDic objectForKey:@"success"]integerValue] == 1) {
                
                [self backButtonImgAction];
                NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                [dic setObject:[[tempDic objectForKey:@"document"]objectForKey:@"file"] forKey:@"file"];
                [dic setObject:[NSString stringWithFormat:@"%@", docName] forKey:@"name"];
                [dic setObject:[[tempDic objectForKey:@"document"]objectForKey:@"id"] forKey:@"id"];
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"backButtonImgAction"
                 object:dic];
                
                //[[NSNotificationCenter defaultCenter]
                // postNotificationName:@"showAttachImage"
                // object:nil];
                
                //Fail
            } else {
               
                
            }
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            [ProgressHUD dismiss];
             
        }];
    } else {
         
    }
}


@end
