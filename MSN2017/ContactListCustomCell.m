//
//  SearchViewCustomCell.m
//  MSN
//
//  Created by Yarima on 4/30/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "ContactListCustomCell.h"
#import "Header.h"

@implementation ContactListCustomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.myImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 60, 10, 45, 45)];
        self.myImageView.layer.cornerRadius = 22;
        self.myImageView.clipsToBounds = YES;
        [self addSubview:self.myImageView];
        
        self.statusImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 20, 20, 20)];
        [self addSubview:self.statusImageView];
        
        self.authorLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, self.myImageView.frame.origin.y + 10, screenWidth - 60 - 47, 25)];
        self.authorLabel.font = FONT_NORMAL(13);
        self.authorLabel.minimumScaleFactor = 0.5;
        self.authorLabel.textColor = [UIColor blackColor];
        self.authorLabel.textAlignment = NSTextAlignmentRight;
        self.authorLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.authorLabel];
    }
    return self;
}
@end
