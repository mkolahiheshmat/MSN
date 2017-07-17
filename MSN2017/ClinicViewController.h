//
//  ClinicViewController.h
//  MSN
//
//  Created by Yarima on 4/24/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClinicViewController : UIViewController
@property(nonatomic, retain)NSString *userEntityId;
@property(nonatomic, retain)NSString *userAvatar;
@property(nonatomic, retain)NSString *userTitle;
@property(nonatomic, retain)NSString *userJobTitle;
@property(nonatomic, retain)NSDictionary *dictionary;
@property(nonatomic)BOOL isFromPushNotif;
@end
