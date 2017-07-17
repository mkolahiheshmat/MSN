//
//  CommentCustomCell.m
//  MSN
//
//  Created by Yarima on 11/23/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "CommentCustomCell.h"
#import "Header.h"
#import "CustomButton.h"
@implementation CommentCustomCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSInteger authorImageWidth = 40;
        self.authorImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - authorImageWidth - 20, 2, authorImageWidth, authorImageWidth)];
        self.authorImageView.layer.cornerRadius = authorImageWidth / 2;
        self.authorImageView.clipsToBounds = YES;
        [self addSubview:self.authorImageView];
        
        self.authorNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, self.authorImageView.frame.origin.y + 10, screenWidth - authorImageWidth - 40, 25)];
        self.authorNameLabel.font = FONT_NORMAL(13);
        self.authorNameLabel.minimumScaleFactor = 0.7;
        self.authorNameLabel.textColor = [UIColor blackColor];
        self.authorNameLabel.textAlignment = NSTextAlignmentRight;
        self.authorNameLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.authorNameLabel];
        
        self.dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 2, 80, 25)];
        self.dateLabel.font = FONT_NORMAL(11);
        self.dateLabel.minimumScaleFactor = 0.7;
        self.dateLabel.textColor = [UIColor lightGrayColor];
        self.dateLabel.textAlignment = NSTextAlignmentLeft;
        self.dateLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.dateLabel];
        
        self.contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, self.authorImageView.frame.origin.y + self.authorImageView.frame.size.height, screenWidth - 30, 60)];
        self.contentLabel.font = FONT_NORMAL(15);
        if (IS_IPAD) {
            self.contentLabel.font = FONT_NORMAL(19);
            self.contentLabel.frame = CGRectMake(10, self.authorImageView.frame.origin.y + self.authorImageView.frame.size.height + 10, screenWidth - 20, 200);
        }
        self.contentLabel.textColor = [UIColor blackColor];
        self.contentLabel.numberOfLines = 0;
        self.contentLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:self.contentLabel];
    }
    
    return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
