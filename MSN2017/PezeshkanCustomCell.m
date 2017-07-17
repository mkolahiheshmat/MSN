//
//  SearchViewCustomCell.m
//  MSN
//
//  Created by Yarima on 4/30/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "PezeshkanCustomCell.h"
#import "Header.h"

@implementation PezeshkanCustomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
        
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.doctorimageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 100, 5, 80, 80)];
        self.doctorimageView.layer.cornerRadius = 40;
        self.doctorimageView.clipsToBounds = YES;
        [self addSubview:self.doctorimageView];
        
        self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, self.imageView.frame.origin.y + 20, screenWidth - 120, 25)];
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
        
        self.porseshimageView = [[UIImageView alloc]initWithFrame:CGRectMake(20, 5, 80, 80)];
        self.porseshimageView.layer.cornerRadius = 40;
        self.porseshimageView.clipsToBounds = YES;
        self.porseshimageView.image = [UIImage imageNamed:@"Porsesh"];
        [self addSubview:self.porseshimageView];
        
    }
    return self;
}
@end
