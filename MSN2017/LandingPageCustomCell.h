//
//  CustomCell2.h
//  AdvisorsHealthCloud
//
//  Created by Arash on 12/26/15.
//  Copyright © 2015 Arash. All rights reserved.
//

#import <UIKit/UIKit.h>
#define TABLEVIEW_CELL_HEIGHT   300
#define TABLEVIEW_CELL_HEIGHT_Iphone6   380

@interface LandingPageCustomCell : UITableViewCell
@property(nonatomic, retain)UILabel *titleLabel;
@property(nonatomic, retain)UILabel *dateLabel;
@property(nonatomic, retain)UILabel *categoryLabel;
@property(nonatomic, retain)UIImageView *postImageView;
@property(nonatomic, retain)UILabel *likeCountLabel;
@property(nonatomic, retain)UILabel *commentCountLabel;
@property(nonatomic, retain)UIImageView *authorImageView;
@property(nonatomic, retain)UILabel *authorNameLabel;
@property(nonatomic, retain)UILabel *authorJobLabel;
@property(nonatomic, retain)UILabel *contentLabel;
@property(nonatomic, retain)UIImageView *commentImageView;
@property(nonatomic, retain)UIButton *favButton;
@property(nonatomic, retain)UIButton *heartButton;
@property(nonatomic, retain)UIButton *shareButton;
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier isPostImage:(BOOL)isPostImage;
@end
