//
//  UploadDocumentsViewController.m
//  MSN
//
//  Created by Yarima on 5/8/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "UploadDocumentsViewController.h"
#import "Header.h"
#import <AFHTTPSessionManager.h>
#import <UIImageView+AFNetworking.h>
#import "UploadDocsCustomCell.h"
#import "CustomButton.h"
#import "ProgressHUD.h"
#import "NSDictionary+uploadDocs.h"
#import "ConvertToPersianDate.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import "UploadNewFileViewController.h"
#import "ConsultationListViewController.h"
#import "GetUsernamePassword.h"
#import "HealthStatusViewController.h"
#import "FavoritesViewController.h"
#import "AboutViewController.h"
#import "UIImage+Extra.h"
#import "LoginViewController.h"
#import "IntroViewController.h"
@interface UploadDocumentsViewController()<UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
     
    UIView *galleryCameraView;
    UIImageView *selectedImageView;
    NSDictionary *selectedRowDic;
    BOOL disableTableView;
}
@property(nonatomic, retain)UITableView *tableView;
@property(nonatomic, retain)NSMutableArray *tableArray;
@end

@implementation UploadDocumentsViewController

- (void)viewDidDisappear:(BOOL)animated{
    [ProgressHUD dismiss];
}

- (void)viewWillDisappear:(BOOL)animated{
    self.tableView.userInteractionEnabled = YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [self fetchAllDocumentsFromServer];
    disableTableView = YES;
}

- (void)viewDidLoad{
    self.navigationController.navigationBar.hidden = YES;
    
     
    
    if (self.isFromDirectQuestion)
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(backButtonImgAction:)
                                                    name:@"backButtonImgAction"
                                                  object:nil];
    //make View
    [self makeTopBar];
    [self makeTableViewWithYpos:70];
    if ([self hasConnectivity]) {
        [self fetchAllDocumentsFromServer];
    } else {
         
    }
    
    //NSLog(@"self.navigationControllers: %@", [self.navigationController viewControllers]);
    
}

#pragma mark - Custom methods

- (void)makeTopBar{
    
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 70)];
    topView.backgroundColor = COLOR_3;
    [topView makeGradient:topView];
    topView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideGalleryCameraView)];
    [topView addGestureRecognizer:tap];
    [self.view addSubview:topView];
    
    CGFloat topViewHeight = topView.frame.size.height;
    
    UILabel *titleLabel =[[UILabel alloc]initWithFrame:CGRectMake(screenWidth/2 - 100, topViewHeight/2 - 15, 200, 40)];
    titleLabel.font = FONT_NORMAL(18);
    titleLabel.text = NSLocalizedString(@"uploadDocs", @"");
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

    NSString *iscomingFromDirectquestion = [[NSUserDefaults standardUserDefaults]objectForKey:@"isComingFromDirectQuestion"];
    if ([iscomingFromDirectquestion isEqualToString:@"YES"]) {
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"isComingFromDirectQuestion"];
        UIButton *backButtonImg = [[UIButton alloc]initWithFrame:CGRectMake(0, 16 , 45, 45)];
        [backButtonImg setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
        [backButtonImg addTarget:self action:@selector(dismissThisView) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:backButtonImg];
    }
    
    //45x69
    UIButton *searchButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - 100, topViewHeight/2 - 10, 54 *0.4, 69 * 0.4)];
    [searchButton setBackgroundImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(searchButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:searchButton];

    
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
- (void)makeTableViewWithYpos:(CGFloat )yPos{
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, yPos, screenWidth, screenHeight - yPos - yPos)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tag = 340;
    [self.view addSubview:self.tableView];
    
    //347 × 98
    UIButton *uploadButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth/2 - 347*0.2, screenHeight - 60, 347*0.4, 98*0.4)];
    [uploadButton setBackgroundImage:[UIImage imageNamed:@"upload icon"] forState:UIControlStateNormal];
    [uploadButton addTarget:self action:@selector(uploadButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:uploadButton];
}

- (void)uploadButtonAction{
    [self hideGalleryCameraView];
    self.tableView.userInteractionEnabled = NO;
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

- (void)galleryButtonAction{
    [self hideGalleryCameraView];
    [self selectPhoto];
}

- (void)cameraButtonAction{
    [self hideGalleryCameraView];
    [self takePhoto];
}

- (void)hideGalleryCameraView{
    [galleryCameraView removeFromSuperview];
    self.tableView.userInteractionEnabled = YES;
}

- (void)menuButtonAction {
    //[self showHideRightMenu];
    disableTableView = !disableTableView;
    self.tableView.userInteractionEnabled = disableTableView;

    [[NSNotificationCenter defaultCenter]postNotificationName:@"toggleMenuVisibility" object:nil];
}

- (void)backButtonImgAction:(NSNotification *)notif{
    if([notif.object count] > 0)
        selectedRowDic = notif.object;
    if (self.isFromDirectQuestion) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"showAttachImage"
         object:selectedRowDic];
    } else if (self.isFromConsultationDetail){
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"showAttachImage2"
         object:selectedRowDic];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dismissThisView{
    [self.navigationController popViewControllerAnimated:YES];
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

- (IntroViewController *)IntroViewController{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    IntroViewController *view = (IntroViewController *)[story instantiateViewControllerWithIdentifier:@"IntroViewController"];
    return view;
}
- (void)pushToLoginView{
    [self presentViewController:[self IntroViewController] animated:YES completion:nil];
}

#pragma mark - camera roll and camera delegate

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
    selectedImageView = [[UIImageView alloc]init];
    selectedImageView.image = chosenImage;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    [self pushToUploadNewFileViewController];
}

- (void)pushToUploadNewFileViewController{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UploadNewFileViewController *view = (UploadNewFileViewController *)[story instantiateViewControllerWithIdentifier:@"UploadNewFileViewController"];
    view.documentImageView = selectedImageView;
    [self presentViewController:view animated:YES completion:nil];
    //[self.navigationController pushViewController:view animated:YES];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - table view delegate


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.tableArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return TABLEVIEW_CELL_HEIGHT;
}

- (UploadDocsCustomCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *cellIdentifier = [NSString stringWithFormat:@"S%1ldR%1ld",(long)indexPath.section,(long)indexPath.row];
    UploadDocsCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
        cell = (UploadDocsCustomCell *)[[UploadDocsCustomCell alloc]
                                        initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    NSDictionary *tempDic = [self.tableArray objectAtIndex:indexPath.row];
    if (tempDic.docName != (id)[NSNull null]) {
        cell.titleLabel.text = tempDic.docName;
    }
    
    NSString *persianDateStr = [ConvertToPersianDate ConvertToPersianDate:tempDic.docCreated];
    cell.dateLabel.text = persianDateStr;
//    cell.documentImageView.image = [UIImage imageNamed:@"png"];
//    if ([tempDic.docFile containsString:@"jpg"] || [tempDic.docFile containsString:@"jpeg"]) {
//        cell.documentImageView.image = [UIImage imageNamed:@"jpeg"];
//    }
    [cell.documentImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL, tempDic.docFile]] placeholderImage:[UIImage imageNamed:@"broken_image"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.isFromDirectQuestion || self.isFromConsultationDetail) {
        selectedRowDic = [self.tableArray objectAtIndex:indexPath.row];
        [self backButtonImgAction:nil];
    } else{
        NSDictionary *tempDic = [self.tableArray objectAtIndex:indexPath.row];
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UploadNewFileViewController *view = (UploadNewFileViewController *)[story instantiateViewControllerWithIdentifier:@"UploadNewFileViewController"];
        view.documentImgageUrl = tempDic.docFile;
        view.documentName = tempDic.docName;
        view.documentDate = [ConvertToPersianDate ConvertToPersianDate:tempDic.docCreated];
        view.documentClinic = tempDic.docProvider;
        view.isFromTableView = YES;
        [self presentViewController:view animated:YES completion:nil];
    }
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

- (void)fetchAllDocumentsFromServer{
    [ProgressHUD show:@""];
    NSDictionary *userpassDic = [GetUsernamePassword getUsernamePassword];
    NSDictionary *params;
    if ([userpassDic count] > 1) {
        
        params = @{@"username":[userpassDic objectForKey:@"username"]/*@"09191234072"*/,
                   @"password":[userpassDic objectForKey:@"password"]/*@“123456”*/,
                   @"profile_id":[GetUsernamePassword getProfileId]/*@"30273"*/,
                   @"debug":@"1",
                   @"unit_id": @"3"
                   };
    }else{
        params = @{@"username":@"",
                   @"password":@"",
                   @"profile_id":@"",
                   @"debug":@"1",
                   @"unit_id": @"3"
                   };
        
    }
    //    KeychainWrapper *keychainWrapper = [[KeychainWrapper alloc]init];
    //    NSString *username = [keychainWrapper myObjectForKey:(__bridge id)(kSecAttrDescription)];
    //    NSString *password = [keychainWrapper myObjectForKey:(__bridge id)(kSecAttrService)];
    NSString *url = [NSString stringWithFormat:@"%@documents", BaseURL];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        self.tableArray = [[NSMutableArray alloc]init];
        NSDictionary *tempDic = (NSDictionary *)responseObject;
        NSString *login =  [tempDic objectForKey:@"login"];
        if ([login integerValue]  == 0) {
            
            [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"isPasswordChanged"];
            
            NSString *message;
            if ([userpassDic count] == 0) {
                message = NSLocalizedString(@"notLogin", @"");
            } else {
                message = NSLocalizedString(@"passwordIsChanged", @"");
            }

             
            return;
        }

        
        for (NSDictionary *dic in [tempDic objectForKey:@"documents"]) {
            [self.tableArray addObject:dic];
        }
        [self.tableView reloadData];
        [ProgressHUD dismiss];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
         
        [ProgressHUD dismiss];
    }];
}
@end
