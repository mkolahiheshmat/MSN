//
//  CustomCell2.h
//  AdvisorsHealthCloud
//
//  Created by Arash on 12/26/15.
//  Copyright © 2015 Arash. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Header.h"

#define TABLEVIEW_CELL_HEIGHT  [[UIScreen mainScreen] bounds].size.height * 0.13

@interface UploadDocsCustomCell : UITableViewCell
@property(nonatomic, retain)UILabel *titleLabel;
@property(nonatomic, retain)UILabel *dateLabel;
@property(nonatomic, retain)UIImageView *documentImageView;

@end
