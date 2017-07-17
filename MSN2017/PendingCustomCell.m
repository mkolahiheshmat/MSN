//
//  SearchViewCustomCell.m
//  MSN
//
//  Created by Yarima on 4/30/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "PendingCustomCell.h"
#import "Header.h"

@implementation PendingCustomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.myImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 60, 25, 40, 40)];
        self.myImageView.layer.cornerRadius = 20;
        self.myImageView.clipsToBounds = YES;
        [self addSubview:self.myImageView];
        
        self.followerLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, self.myImageView.frame.origin.y + 2, screenWidth - 60 - 47, 25)];
        self.followerLabel.font = FONT_NORMAL(13);
        self.followerLabel.minimumScaleFactor = 0.5;
        self.followerLabel.textColor = [UIColor blackColor];
        self.followerLabel.textAlignment = NSTextAlignmentRight;
        self.followerLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.followerLabel];
        
        self.followeeLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, self.followerLabel.frame.origin.y + 15, screenWidth - 60 - 47, 25)];
        self.followeeLabel.font = FONT_MEDIUM(11);
        self.followeeLabel.minimumScaleFactor = 0.5;
        self.followeeLabel.textColor = [UIColor blackColor];
        self.followeeLabel.textAlignment = NSTextAlignmentRight;
        self.followeeLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.followeeLabel];
        
        self.bodyLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, self.followeeLabel.frame.origin.y + 20, screenWidth - 60 - 47, 25)];
        self.bodyLabel.font = FONT_MEDIUM(11);
        self.bodyLabel.minimumScaleFactor = 0.9;
        self.bodyLabel.textColor = [UIColor grayColor];
        self.bodyLabel.textAlignment = NSTextAlignmentRight;
        self.bodyLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.bodyLabel];
        
        self.dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 10, 70, 25)];
        self.dateLabel.font = FONT_MEDIUM(11);
        self.dateLabel.minimumScaleFactor = 0.5;
        self.dateLabel.textColor = [UIColor grayColor];
        self.dateLabel.textAlignment = NSTextAlignmentRight;
        self.dateLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.dateLabel];
        
    }
    return self;
}
@end
