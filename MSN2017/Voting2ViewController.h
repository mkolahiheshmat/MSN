//
//  ThirdViewController.h
//  MSN
//
//  Created by Yarima on 11/5/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Voting2ViewController : UIViewController
@property(nonatomic, copy)NSString *titleString;
@property(nonatomic, copy)NSString *contentString;
@property(nonatomic, retain)NSArray *optionsArray;
@property(nonatomic)BOOL isSingleSelection;
@end
