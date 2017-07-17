//
//  ProjectCompanyCustomCell.m
//  MSN
//
//  Created by Yarima on 4/30/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "ProjectCompanyCustomCell.h"
#import "Header.h"

@implementation ProjectCompanyCustomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
        
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.avatarimageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 65, 15, 50, 50)];
        self.avatarimageView.layer.cornerRadius = 25;
        self.avatarimageView.clipsToBounds = YES;
        [self addSubview:self.avatarimageView];
        
        self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, self.imageView.frame.origin.y + 28, screenWidth - 80, 25)];
        self.nameLabel.font = FONT_MEDIUM(13);
        self.nameLabel.minimumScaleFactor = 0.7;
        self.nameLabel.textColor = [UIColor blackColor];
        self.nameLabel.textAlignment = NSTextAlignmentRight;
        self.nameLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.nameLabel];
        
        self.jobLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, self.nameLabel.frame.origin.y + 35, screenWidth - 120, 25)];
        self.jobLabel.font = FONT_NORMAL(11);
        self.jobLabel.minimumScaleFactor = 0.7;
        self.jobLabel.textColor = [UIColor blackColor];
        self.jobLabel.textAlignment = NSTextAlignmentRight;
        self.jobLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.jobLabel];
        
        
        //232 × 81
        self.followimageView = [[UIImageView alloc]initWithFrame:CGRectMake(20, 5, 232 * 0.5, 81 * 0.5)];
        self.followimageView.layer.cornerRadius = 40;
        //self.followimageView.clipsToBounds = YES;
        self.followimageView.image = [UIImage imageNamed:@"IWillFollow"];
        //[self addSubview:self.followimageView];
        
    }
    return self;
}
@end
