//
//  SearchViewCustomCell.m
//  MSN
//
//  Created by Yarima on 4/30/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "FolloweeCustomCell.h"
#import "Header.h"

@implementation FolloweeCustomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.myImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 60, 15, 55, 55)];
        self.myImageView.layer.cornerRadius = 27;
        self.myImageView.clipsToBounds = YES;
        [self addSubview:self.myImageView];
        
        self.followerLabel = [[UILabel alloc]initWithFrame:CGRectMake(90, self.myImageView.frame.origin.y + 10, screenWidth - 90 - 64, 45)];
        self.followerLabel.font = FONT_NORMAL(15);
        self.followerLabel.numberOfLines = 2;
        self.followerLabel.minimumScaleFactor = 0.5;
        self.followerLabel.textColor = [UIColor blackColor];
        self.followerLabel.textAlignment = NSTextAlignmentRight;
        self.followerLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.followerLabel];
    
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
