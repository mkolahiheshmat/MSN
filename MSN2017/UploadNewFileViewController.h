//
//  UploadNewFileViewController.h
//  MSN
//
//  Created by Yarima on 5/8/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UploadNewFileViewController : UIViewController
@property(nonatomic, retain)UIImageView *documentImageView;
@property(nonatomic, retain)NSString *documentName;
@property(nonatomic, retain)NSString *documentDate;
@property(nonatomic, retain)NSString *documentClinic;
@property(nonatomic, retain)NSString *documentImgageUrl;
@property(nonatomic)BOOL isFromTableView;
@end
