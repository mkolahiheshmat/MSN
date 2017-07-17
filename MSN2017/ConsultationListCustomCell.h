//
//  LandingPageCustomCell.h
//  AdvisorsHealthCloud
//
//  Created by Yarima on 11/16/15.
//  Copyright (c) 2015 Yarima. All rights reserved.
//

#import <UIKit/UIKit.h>
#define TABLEVIEW_CELL_HEIGHT   [[UIScreen mainScreen] bounds].size.height * 0.13

@interface ConsultationListCustomCell : UITableViewCell
@property(nonatomic, retain)UILabel *dateLabel;
@property(nonatomic, retain)UILabel *categoryLabel;
@property(nonatomic, retain)UILabel *mainTitleLabel;
@property(nonatomic, retain)UILabel *counterLabel;
@property(nonatomic, retain)UIImageView *lockStausImage;
@end
