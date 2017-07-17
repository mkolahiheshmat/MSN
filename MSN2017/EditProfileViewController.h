//
//  EditProfileViewController.h
//  MSN
//
//  Created by Yarima on 5/16/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditProfileViewController : UIViewController
@property(nonatomic, retain)NSDictionary *profileDictionary;
@property(nonatomic, retain)NSArray *selectedTagsArray1;
@property(nonatomic)NSInteger selectedJobTileID;
@property BOOL isFromEditProfile;
@end
