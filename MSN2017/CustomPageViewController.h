//
//  CustomPageViewController.h
//  MSN
//
//  Created by Yarima on 8/23/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomPageViewController : UIViewController
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, assign) NSString *titleStr;

@property (nonatomic, retain)UILabel *titleLabel;
@property (nonatomic, retain)UIImageView *myImage;
@property (nonatomic, retain)NSString *imageURL;
@property (nonatomic, retain)NSDictionary *jsonData;
@end
