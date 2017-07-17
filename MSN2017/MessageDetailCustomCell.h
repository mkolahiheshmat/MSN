//
//  SearchViewCustomCell.h
//  MSN
//
//  Created by Yarima on 4/30/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageDetailCustomCell : UITableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier isSameUser:(BOOL)isSameUser height:(CGFloat)height;
@property(nonatomic, retain)UIImageView *myImageView;
@property(nonatomic, retain)UILabel *titleLabel;
@property(nonatomic, retain)UILabel *authorLabel;
@property(nonatomic, retain)UILabel *dateLabel;
@end
