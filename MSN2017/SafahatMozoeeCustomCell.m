//
//  SearchViewCustomCell.m
//  MSN
//
//  Created by Yarima on 4/30/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "SafahatMozoeeCustomCell.h"
#import "Header.h"

@implementation SafahatMozoeeCustomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
        
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.postImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, (screenWidth /2))];
        [self addSubview:self.postImageView];
        
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 60)];
        self.titleLabel.font = FONT_MEDIUM(13);
        self.titleLabel.numberOfLines = 2;
        self.titleLabel.minimumScaleFactor = 0.7;
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
        self.titleLabel.textAlignment = NSTextAlignmentRight;
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.titleLabel];
    }
    return self;
}
@end
