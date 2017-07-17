//
//  SearchViewCustomCell.m
//  MSN
//
//  Created by Yarima on 4/30/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "MessageDetailCustomCell.h"
#import "Header.h"
#import "UIView+Bubble.h"
@implementation MessageDetailCustomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier isSameUser:(BOOL)isSameUser height:(CGFloat)height{
    
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (isSameUser) {//align right
            self.myImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 60, 10, 40, 40)];
            self.myImageView.layer.cornerRadius = 20;
            self.myImageView.clipsToBounds = YES;
            [self addSubview:self.myImageView];
            
            self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, self.authorLabel.frame.origin.y + 20, screenWidth - 60 - 47, 25)];
            self.titleLabel.font = FONT_MEDIUM(13);
            self.titleLabel.minimumScaleFactor = 0.9;
            self.titleLabel.textColor = [UIColor blackColor];
            self.titleLabel.textAlignment = NSTextAlignmentRight;
            self.titleLabel.adjustsFontSizeToFitWidth = YES;
            [self addSubview:self.titleLabel];
            
            self.dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.myImageView.frame.size.height / 2, 70, 25)];
            self.dateLabel.font = FONT_MEDIUM(11);
            self.dateLabel.minimumScaleFactor = 0.5;
            self.dateLabel.textColor = [UIColor grayColor];
            self.dateLabel.textAlignment = NSTextAlignmentRight;
            self.dateLabel.adjustsFontSizeToFitWidth = YES;
            [self addSubview:self.dateLabel];
            
        } else {//align left
            self.myImageView = [[UIImageView alloc]initWithFrame:CGRectMake(20, 10, 40, 40)];
            self.myImageView.layer.cornerRadius = 20;
            self.myImageView.clipsToBounds = YES;
            [self addSubview:self.myImageView];
            
            self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, self.authorLabel.frame.origin.y + 20, screenWidth - 60 - 47, 25)];
            self.titleLabel.font = FONT_MEDIUM(13);
            self.titleLabel.minimumScaleFactor = 0.9;
            self.titleLabel.textColor = [UIColor blackColor];
            self.titleLabel.textAlignment = NSTextAlignmentRight;
            self.titleLabel.adjustsFontSizeToFitWidth = YES;
            [self addSubview:self.titleLabel];
            
            self.dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 80, self.myImageView.frame.size.height / 2, 70, 25)];
            self.dateLabel.font = FONT_MEDIUM(11);
            self.dateLabel.minimumScaleFactor = 0.5;
            self.dateLabel.textColor = [UIColor grayColor];
            self.dateLabel.textAlignment = NSTextAlignmentRight;
            self.dateLabel.adjustsFontSizeToFitWidth = YES;
            [self addSubview:self.dateLabel];
        }
        
    }
    return self;
}
@end
