//
//  FirstViewController.h
//  MSN
//
//  Created by Yarima on 11/5/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserProfileViewController : UIViewController
@property(nonatomic, retain)NSDictionary *dictionary;
@property(nonatomic)NSInteger entityID;
@property(nonatomic)BOOL isFromPushNotif;
@end
