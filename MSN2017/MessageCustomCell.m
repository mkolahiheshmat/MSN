//
//  SearchViewCustomCell.m
//  MSN
//
//  Created by Yarima on 4/30/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "MessageCustomCell.h"
#import "Header.h"

@implementation MessageCustomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.myImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 60, 25, 40, 40)];
        self.myImageView.layer.cornerRadius = 20;
        self.myImageView.clipsToBounds = YES;
        [self addSubview:self.myImageView];
        
        self.authorLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, self.myImageView.frame.origin.y, screenWidth - 60 - 47, 25)];
        self.authorLabel.font = FONT_NORMAL(13);
        self.authorLabel.minimumScaleFactor = 0.5;
        self.authorLabel.textColor = [UIColor blackColor];
        self.authorLabel.textAlignment = NSTextAlignmentRight;
        self.authorLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.authorLabel];
        
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, self.authorLabel.frame.origin.y + 20, screenWidth - 60 - 47, 25)];
        self.titleLabel.font = FONT_MEDIUM(11);
        self.titleLabel.minimumScaleFactor = 0.5;
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.textAlignment = NSTextAlignmentRight;
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.titleLabel];
        
        self.bodyLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, self.titleLabel.frame.origin.y + 20, screenWidth - 60 - 47, 25)];
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
