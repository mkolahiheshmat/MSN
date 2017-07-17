//
//  SearchViewCustomCell.m
//  MSN
//
//  Created by Yarima on 4/30/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "SearchViewCustomCell.h"
#import "Header.h"

@implementation SearchViewCustomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
        
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.myImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 60, 25, 55, 55)];
        self.myImageView.layer.cornerRadius = 27;
        self.myImageView.clipsToBounds = YES;
        [self addSubview:self.myImageView];
        
        self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, self.myImageView.frame.origin.y + 10, screenWidth - 60 - 47, 25)];
        self.nameLabel.font = FONT_MEDIUM(13);
        //self.nameLabel.minimumScaleFactor = 0.5;
        self.nameLabel.textColor = [UIColor blackColor];
        self.nameLabel.textAlignment = NSTextAlignmentRight;
        //self.nameLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.nameLabel];
        
        self.jobLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, self.nameLabel.frame.origin.y + 20, screenWidth - 60 - 47, 25)];
        self.jobLabel.font = FONT_NORMAL(11);
        self.jobLabel.minimumScaleFactor = 0.5;
        self.jobLabel.textColor = [UIColor blackColor];
        self.jobLabel.textAlignment = NSTextAlignmentRight;
        self.jobLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.jobLabel];
    }
    return self;
}
@end
