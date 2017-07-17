//
//  LandingPageDetailViewController.h
//  MSN
//
//  Created by Yarima on 7/23/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LandingPageDetailViewController : UIViewController
@property(nonatomic, retain)NSDictionary *dictionary;
@property(nonatomic, retain)NSString *postId;
@property(nonatomic)BOOL isFromPushNotif;
@end
