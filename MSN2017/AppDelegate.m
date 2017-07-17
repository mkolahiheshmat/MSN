//
//  AppDelegate.m
//  MSN
//
//  Created by Yarima on 4/6/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "AppDelegate.h"
#import "CustomPageViewController.h"
#import "DocumentDirectoy.h"
#import "FirstViewController.h"
#import "SecondViewController.h"
#import "ThirdViewController.h"
#import "FourthViewController.h"
#import "FifthViewController.h"
#import <UserNotifications/UserNotifications.h>

#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    self.tabBarController = [[UITabBarController alloc] init];
    
    FirstViewController *firstViewController = [[FirstViewController alloc]init];
    firstViewController.title = @"First View";
    UIImage *img1 = [UIImage imageNamed:@"iconTab0"];
    firstViewController.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"Profile" image:img1 tag:0];//[[UITabBarItem alloc]initWithTabBarSystemItem:UITabBarSystemItemSearch tag:0];
    UINavigationController *firstNavController = [[UINavigationController alloc]initWithRootViewController:firstViewController];
    
    SecondViewController *secondViewController = [[SecondViewController alloc]init];
    secondViewController.title = @"Second View";
    UIImage *img2 = [UIImage imageNamed:@"iconTab2"];
    secondViewController.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"Timeline" image:img2 tag:0];//[[UITabBarItem alloc]initWithTabBarSystemItem:UITabBarSystemItemFavorites tag:1];
    UINavigationController *secondNavController = [[UINavigationController alloc]initWithRootViewController:secondViewController];
    
    ThirdViewController *thirdViewController = [[ThirdViewController alloc]init];
    thirdViewController.title = @"Third View";
    UIImage *img3 = [UIImage imageNamed:@"iconTab3"];
    thirdViewController.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"Post" image:img3 tag:0];//[[UITabBarItem alloc]initWithTabBarSystemItem:UITabBarSystemItemRecents tag:2];
    UINavigationController *thirdNavController = [[UINavigationController alloc]initWithRootViewController:thirdViewController];
    
    FourthViewController *fourthViewController = [[FourthViewController alloc]init];
    fourthViewController.title = @"Forth View";
    UIImage *img4 = [UIImage imageNamed:@"iconTab4"];
    fourthViewController.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"Contact" image:img4 tag:0];//[[UITabBarItem alloc]initWithTabBarSystemItem:UITabBarSystemItemDownloads tag:3];
    UINavigationController *fourthNavController = [[UINavigationController alloc]initWithRootViewController:fourthViewController];
    
    FifthViewController *fifthViewController = [[FifthViewController alloc]init];
    fifthViewController.title = @"Fifth View";
    UIImage *img5 = [UIImage imageNamed:@"iconTab5"];
    fifthViewController.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"Message" image:img5 tag:0];//[[UITabBarItem alloc]initWithTabBarSystemItem:UITabBarSystemItemContacts tag:4];
    UINavigationController *fifthNavController = [[UINavigationController alloc]initWithRootViewController:fifthViewController];
    
    NSArray* controllers = [NSArray arrayWithObjects:firstNavController, secondNavController, thirdNavController, fourthNavController, fifthNavController, nil];
    self.tabBarController.viewControllers = controllers;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    self.tabBarController.selectedIndex = 1;
    
    //Arash, Push notification
     [self registerForRemoteNotifications];
    
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInteger:0] forKey:@"lastPageNumber"];
    
    
        //Arash, Push notification
    [self registerForRemoteNotifications];

    return YES;
}

- (void)registerForRemoteNotifications {
    if(SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0")){
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            if(!error){
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            }
        }];
    }
    else {
        // Code for old versions
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}

//Called to let your app know which action was selected by the user for a given notification.
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
    //NSLog(@"User Info : %@",response.notification.request.content.userInfo);
    completionHandler();
}

void uncaughtExceptionHandler(NSException *exception) {
    // You code here, you app will already be unload so you can only see what went wrong.
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"isFirstRun"];
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"isFirstRun"];
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"isFirstRun"];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"isFirstRun"];
}

#pragma mark - Remote Notification Delegate // <= iOS 9.x
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    NSString *processedDeviceTokenString = [[[[devToken description]
                                              stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                             stringByReplacingOccurrencesOfString: @">" withString: @""]
                                            stringByReplacingOccurrencesOfString: @" " withString: @""];
    [[NSUserDefaults standardUserDefaults]setObject:processedDeviceTokenString forKey:@"deviceToken"];
    
    //NSString *str = [[NSUserDefaults standardUserDefaults]objectForKey:@"registerDeviceToken"];
    //if ([str length] == 0) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"registerDeviceTokenOnServer" object:nil];
    //}

    NSLog(@"%@", devToken);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"Push Notification Information : %@",userInfo);
        //[[NSNotificationCenter defaultCenter]postNotificationName:@"NavigateToInbox" object:nil];
    switch (application.applicationState) {
        case UIApplicationStateActive:
                //app is currently active, can update badges count here
            break;
        case UIApplicationStateInactive:
                //app is transitioning from background to foreground (user taps notification), do what you need when user taps here
            [[NSNotificationCenter defaultCenter]postNotificationName:@"NavigateToInbox" object:nil];
            break;
        case UIApplicationStateBackground:
                //app is in background, if content-available key of your notification is set to 1, poll to your backend to retrieve data and update your interface here
            [[NSNotificationCenter defaultCenter]postNotificationName:@"NavigateToInbox" object:nil];
            break;
        default:
            break;
    }
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"%@ = %@", NSStringFromSelector(_cmd), error);
    NSLog(@"Error = %@",error);
}

#pragma mark - UNUserNotificationCenter Delegate // >= iOS 10
    //Called when a notification is delivered to a foreground app.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    
    NSLog(@"User Info = %@",notification.request.content.userInfo);
    
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound);
}

#pragma mark - Class Methods

/**
 Notification Registration
 */
- (void)registerForRemoteNotification {
    if(SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0")) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            if( !error ){
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            }
        }];
    }else{
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}

@end
