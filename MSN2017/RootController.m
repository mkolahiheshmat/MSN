//
//  RootController.m
//  VCContainmentTut
//
//  Created by A Khan on 01/05/2013.
//  Copyright (c) 2013 AK. All rights reserved.
//

#define kExposedWidth 100.0
#define kExposedWidth_IPAD 400.0
#define kMenuCellID @"MenuCell"
#define kCellHeight 50
#import "RootController.h"
#import "Header.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <AFHTTPSessionManager.h>
#import <UIImageView+AFNetworking.h>
#import "Database.h"
#import "GetUsernamePassword.h"
#import "NSDictionary+profile.h"
#import "DocumentDirectoy.h"
@interface RootController()
{
    BOOL hasFavItems;
    NSArray *imageArray;
    NSDictionary *profileDictionary;
    UIImageView *profileImageView;
}

@property (nonatomic, strong) UITableView *menu;
@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, strong) NSArray *menuTitles;
@property (nonatomic, assign) NSInteger indexOfVisibleController;
@property (nonatomic, assign) BOOL isMenuVisible;

@end


@implementation RootController

+ (instancetype)sharedInstanceWithViewControllers:(NSArray *)viewControllers andMenuTitles:(NSArray *)menuTitles
{
    static RootController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RootController alloc] initWithViewControllers:viewControllers andMenuTitles:menuTitles];
        // Perform other initialisation...
    });
    return sharedInstance;
}
//    You need need to override init method as well, because developer can call [[MyClass alloc]init] method also. that time also we have to return sharedInstance only.

-(RootController *)init
{
    return [RootController sharedInstanceWithViewControllers:@[] andMenuTitles:@[]];
}

- (RootController *)initWithViewControllers:(NSArray *)viewControllers andMenuTitles:(NSArray *)menuTitles
{
    if (self = [super init])
    {
        NSAssert(self.viewControllers.count == self.menuTitles.count, @"There must be one and only one menu title corresponding to every view controller!");    // (1)
        NSMutableArray *tempVCs = [NSMutableArray arrayWithCapacity:viewControllers.count];
        
        self.menuTitles = [menuTitles copy];
        
        for (UIViewController *vc in viewControllers) // (2)
        {
            if (![vc isMemberOfClass:[UINavigationController class]])
            {
                [tempVCs addObject:[[UINavigationController alloc] initWithRootViewController:vc]];
            }
            else
                [tempVCs addObject:vc];
        }
        
        self.viewControllers = [tempVCs copy];
        if (!self.menu) {
            imageArray = [[NSArray alloc]initWithObjects:
                          @"home.png",
                          @"vaziat salamat.png",
                          @"moshavere ba pezeshk.png",
                          @"upload madarek.png",
                          @"alaghe mandi ha.png",
                          @"darbare ma.png",
                          @"darbare ma.png",
                          nil];
            self.menu = [[UITableView alloc] init]; // (4)
            self.menu.delegate = self;
            self.menu.dataSource = self;
        }
        
        
    }
    return self;//[RootController sharedInstanceWithViewControllers:viewControllers andMenuTitles:menuTitles];
}

- (void)viewWillAppear:(BOOL)animated{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //Profile section
    UIView *bgViewProfile = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 150)];
    bgViewProfile.backgroundColor = [UIColor colorWithRed:0.349 green:0.894 blue:0.843 alpha:1.0];

    [self.view addSubview:bgViewProfile];
    
    CGFloat imageSizeBorder = screenWidth * 0.25;
    if (IS_IPAD) {
        imageSizeBorder = screenWidth * 0.11;
    }
    UIImageView *borderImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - imageSizeBorder - 70, 20, imageSizeBorder, imageSizeBorder)];
    borderImageView.image = [UIImage imageNamed:@"border pic"];
    [self.view addSubview:borderImageView];
    
    CGFloat imageSize = screenWidth * 0.2;
    if (IS_IPAD) {
        imageSize = screenWidth * 0.09;
    }
    profileImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - imageSize - 78, 27, imageSize, imageSize)];
    profileDictionary = [GetUsernamePassword getProfileData];
    profileImageView.layer.cornerRadius = imageSize / 2;
    profileImageView.clipsToBounds = YES;
    UIImage *defaultImage = [UIImage imageNamed:@"icon upload ax"];
    profileImageView.image = defaultImage;
    profileImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goToHealthStatus)];
    [profileImageView addGestureRecognizer:tap];
    [self.view addSubview:profileImageView];
    [self loadImageFileFromDocument];
    
    UILabel *nameLabelTop =[[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 180, profileImageView.frame.origin.y + profileImageView.frame.size.height + 10, 150, 25)];
    nameLabelTop.font = FONT_NORMAL(15);
    if ([profileDictionary count] == 0) {
        nameLabelTop.text = NSLocalizedString(@"noName", @"");
    } else {
        nameLabelTop.text = [NSString stringWithFormat:@"%@ %@", profileDictionary.first_nameProfile, profileDictionary.last_nameProfile];
    }
    
    nameLabelTop.textColor = [UIColor blackColor];
    nameLabelTop.textAlignment = NSTextAlignmentCenter;
    nameLabelTop.minimumScaleFactor = 0.5;
    nameLabelTop.backgroundColor = [UIColor clearColor];
    nameLabelTop.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:nameLabelTop];


    [self.menu registerClass:[UITableViewCell class] forCellReuseIdentifier:kMenuCellID];
    self.menu.frame = CGRectMake(0, 160, screenWidth, screenHeight - 150);
    [self.view addSubview:self.menu];
    self.menu.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.indexOfVisibleController = 0;
    UIViewController *visibleViewController = self.viewControllers[0];
    visibleViewController.view.frame = [self offScreenFrame];
    [self addChildViewController:visibleViewController]; // (5)
    [self.view addSubview:visibleViewController.view]; // (6)
    self.isMenuVisible = NO;
    [self adjustContentFrameAccordingToMenuVisibility]; // (7)
    [self.viewControllers[0] didMoveToParentViewController:self]; // (8)
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(toggleMenuVisibility:) name:@"toggleMenuVisibility" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(GoToConsultationViewFromLandingPageDirectly) name:@"GoToConsultationViewFromLandingPageDirectly" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(GoToTimeLineFromAnyWhere) name:@"GoToTimeLineFromAnyWhere" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(GoToSearchView) name:@"GoToSearchView" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(GoToPageNumber:) name:@"GoToPageNumber" object:nil];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self
                                                                                   action:@selector(toggleMenuVisibility:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self
                                                                                    action:@selector(toggleMenuVisibility:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    
    NSArray *favItems = [Database selectFromFavoriteWithFilePath:[Database getDbFilePath]];
    if ([favItems count] > 0) {
        hasFavItems = YES;
    }
}

- (void)toggleMenuVisibility:(id)sender // (9)
{
    self.isMenuVisible = !self.isMenuVisible;
    [self adjustContentFrameAccordingToMenuVisibility];
    [self loadImageFileFromDocument];
}


- (void)adjustContentFrameAccordingToMenuVisibility // (10)
{
    UIViewController *visibleViewController = self.viewControllers[self.indexOfVisibleController];
    CGSize size = visibleViewController.view.frame.size;
    
    if (self.isMenuVisible)
    {
        [UIView animateWithDuration:0.5 animations:^{
            if (IS_IPAD) {
                visibleViewController.view.frame = CGRectMake(kExposedWidth_IPAD - screenWidth, 0, size.width, size.height);
            } else {
                visibleViewController.view.frame = CGRectMake(kExposedWidth - screenWidth, 0, size.width, size.height);
            }
            
        }];
    }
    else
        [UIView animateWithDuration:0.5 animations:^{
            visibleViewController.view.frame = CGRectMake(0, 0, size.width, size.height);
        }];
    
}

- (void)replaceVisibleViewControllerWithViewControllerAtIndex:(NSInteger)index // (11)
{
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInteger:index] forKey:@"lastPageNumber"];
//    if (index == self.indexOfVisibleController){
//        [self toggleMenuVisibility:nil];
//        return;
//    }
    UIViewController *incomingViewController = self.viewControllers[index];
    incomingViewController.view.frame = [self offScreenFrame];
    UIViewController *outgoingViewController = self.viewControllers[self.indexOfVisibleController];
    CGRect visibleFrame = self.view.bounds;
    
    
    [outgoingViewController willMoveToParentViewController:nil]; // (12)
    
    [self addChildViewController:incomingViewController]; // (13)
    [self addChildViewController:outgoingViewController]; // (13)
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents]; // (14)
    [self transitionFromViewController:outgoingViewController // (15)
                      toViewController:incomingViewController
                              duration:0.5 options:0
                            animations:^{
                                outgoingViewController.view.frame = [self offScreenFrame];
                                
                            }
     
                            completion:^(BOOL finished) {
                                [UIView animateWithDuration:0.2
                                                 animations:^{
                                                     [outgoingViewController.view removeFromSuperview];
                                                     [self.view addSubview:incomingViewController.view];
                                                     incomingViewController.view.frame = visibleFrame;
                                                     [[UIApplication sharedApplication] endIgnoringInteractionEvents]; // (16)
                                                 }];
                                [incomingViewController didMoveToParentViewController:self]; // (17)
                                [outgoingViewController removeFromParentViewController]; // (18)
                                self.isMenuVisible = NO;
                                self.indexOfVisibleController = index;
                            }];
}

- (void)replaceVisibleViewControllerWithViewControllerAtIndex2:(NSInteger)index // (11)
{
    if (index == self.indexOfVisibleController){
        [self toggleMenuVisibility:nil];
        return;
    }
    UIViewController *incomingViewController = self.viewControllers[index];
    incomingViewController.view.frame = [self offScreenFrame];
    UIViewController *outgoingViewController = self.viewControllers[self.indexOfVisibleController];
    CGRect visibleFrame = self.view.bounds;
    
    
    [outgoingViewController willMoveToParentViewController:nil]; // (12)
    
    [self addChildViewController:incomingViewController]; // (13)
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents]; // (14)
    [self transitionFromViewController:outgoingViewController // (15)
                      toViewController:incomingViewController
                              duration:0.1 options:0
                            animations:^{
                                //outgoingViewController.view.frame = [self offScreenFrame];
                                
                            }
     
                            completion:^(BOOL finished) {
                                //[UIView animateWithDuration:0.1
                                                 //animations:^{
                                                     [outgoingViewController.view removeFromSuperview];
                                                     [self.view addSubview:incomingViewController.view];
                                                     incomingViewController.view.frame = visibleFrame;
                                                     [[UIApplication sharedApplication] endIgnoringInteractionEvents]; // (16)
                                                 //}];
                                [incomingViewController didMoveToParentViewController:self]; // (17)
                                [outgoingViewController removeFromParentViewController]; // (18)
                                self.isMenuVisible = NO;
                                self.indexOfVisibleController = index;
                            }];
}


// (19):

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kCellHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.menuTitles count] - 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMenuCellID];
    UILabel *titleLabel =[[UILabel alloc]initWithFrame:CGRectMake(10, 10, screenWidth - 60, 25)];
    titleLabel.font = FONT_NORMAL(20);
    titleLabel.text = self.menuTitles[indexPath.row];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentRight;
    [cell addSubview:titleLabel];
    
    UIImageView *iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 40, 10, 30, 30)];
    iconImageView.image = [UIImage imageNamed:[imageArray objectAtIndex:indexPath.row]];
    [cell addSubview:iconImageView];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *inDoctorPage = [[NSUserDefaults standardUserDefaults]objectForKey:@"inDoctorPage"];
    if ([inDoctorPage length] > 0) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"backToMainMenu" object:nil];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"inDoctorPage"];
        [self replaceVisibleViewControllerWithViewControllerAtIndex:indexPath.row];
        
    }else{
        if ([self hasConnectivity])/*online mode*/ {
            [self.menu deselectRowAtIndexPath:indexPath animated:NO];
            [self replaceVisibleViewControllerWithViewControllerAtIndex:indexPath.row];
        } else/*offline mode*/ {
            if (indexPath.row == 5 || indexPath.row == 0 || ((indexPath.row == 4 && hasFavItems))) {
                [self.menu deselectRowAtIndexPath:indexPath animated:NO];
                [self replaceVisibleViewControllerWithViewControllerAtIndex:indexPath.row];
            }else{
                [self.menu deselectRowAtIndexPath:indexPath animated:NO];
                [self toggleMenuVisibility:nil];
                           }
        }
        
    }
}

- (CGRect)offScreenFrame
{
    return CGRectMake( -1 * (self.view.bounds.size.width), 0, self.view.bounds.size.width, self.view.bounds.size.height);
}

#pragma mark - custom method
- (void)GoToConsultationViewFromLandingPageDirectly{
    [self replaceVisibleViewControllerWithViewControllerAtIndex:2];
}

- (void)GoToTimeLineFromAnyWhere{
    [self replaceVisibleViewControllerWithViewControllerAtIndex:0];
}

- (void)GoToSearchView{
    [self replaceVisibleViewControllerWithViewControllerAtIndex2:6];
}

- (void)GoToPageNumber:(NSNotification *)notif{
    NSDictionary *notifDic = notif.object;
    [self replaceVisibleViewControllerWithViewControllerAtIndex2:[[notifDic objectForKey:@"id"]integerValue]];
}

- (void)goToHealthStatus{
    [self replaceVisibleViewControllerWithViewControllerAtIndex:1];
}

- (void)loadImageFileFromDocument{
    if (profileDictionary.photoProfile != (id)[NSNull null]){
        NSString *imageFileName = [NSString stringWithFormat:@"%@/%@", [DocumentDirectoy getDocuementsDirectory], [profileDictionary.photoProfile lastPathComponent]];
        //NSString *imageFileName = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject]stringByAppendingPathComponent:profileDictionary.photoProfile]lastPathComponent];
        NSString *pathOfImage = [[NSURL fileURLWithPath:imageFileName]path];
        BOOL isDirectory;
        if ([[NSFileManager defaultManager]fileExistsAtPath:pathOfImage isDirectory:&isDirectory]) {
            profileImageView.image = [UIImage imageWithContentsOfFile:pathOfImage];
        }else{
                [self loadImageProfileFromServer];
        }
    }
}

- (void)loadImageProfileFromServer{
    //[self loadImageFileFromDocument];
   
        dispatch_async(kBgQueue, ^{
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/thumb_%@",BaseURL,[GetUsernamePassword getProfileId],profileDictionary.photoProfile]];
            NSData *imgData = [NSData dataWithContentsOfURL:url];
            
            if (imgData) {
                UIImage *image = [UIImage imageWithData:imgData];
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        profileImageView.image  = image;
                        [self saveImageIntoDocumets];
                    });
                }
            }
        });
}

- (void)saveImageIntoDocumets{
    //convert image into .png format.
    NSData *imageData = UIImagePNGRepresentation(profileImageView.image);
    //create instance of NSFileManager
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *appDocumentsDirectory = [DocumentDirectoy getDocuementsDirectory];
    //add our image to the path
    NSString *fullPath = [appDocumentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", [profileDictionary.photoProfile lastPathComponent]]];
    //finally save the path (image)
    BOOL resultSave = [fileManager createFileAtPath:fullPath contents:imageData attributes:nil];
    if (resultSave) {
        //NSLog(@"image saved");
    }
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

@end
