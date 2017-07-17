//
//  RootController.h
//  VCContainmentTut
//
//  Created by A Khan on 01/05/2013.
//  Copyright (c) 2013 AK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate> // (1)
+ (instancetype)sharedInstanceWithViewControllers:(NSArray *)viewControllers andMenuTitles:(NSArray *)menuTitles;
- (RootController *)initWithViewControllers:(NSArray *)viewControllers andMenuTitles:(NSArray *)menuTitles;

@end
