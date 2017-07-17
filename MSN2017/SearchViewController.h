//
//  DoctorPageViewController.h
//  MSN
//
//  Created by Yarima on 4/24/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import <UIKit/UIKit.h>
#define TABLEVIEW_CELL_HEIGHT   300
#define TABLEVIEW_CELL_HEIGHT_Iphone6   380

@interface SearchViewController : UIViewController
@property(nonatomic, retain)NSString *userEntityId;
@property(nonatomic, retain)NSString *userAvatar;
@property(nonatomic, retain)NSString *userTitle;
@property(nonatomic, retain)NSString *userJobTitle;
@property(nonatomic, retain)NSDictionary *dictionary;

typedef enum ScrollDirection {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
    ScrollDirectionCrazy,
} ScrollDirection;

@end
