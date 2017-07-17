//
//  DirectQuestionViewController.h
//  MSN
//
//  Created by Yarima on 5/4/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DirectQuestionViewController : UIViewController
@property(nonatomic, retain)NSString *userEntityId;
@property(nonatomic, retain)NSString *userAvatar;
@property(nonatomic, retain)NSString *userTitle;
@property(nonatomic, retain)NSString *userJobTitle;
@property(nonatomic, retain)NSDictionary *dictionary;
@property(nonatomic)BOOL   isNewQuestion;
@property(nonatomic)BOOL   isFromDoctorPage;
@end
