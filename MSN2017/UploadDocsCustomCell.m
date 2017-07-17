//
//  CustomCell2.m
//  AdvisorsHealthCloud
//
//  Created by Arash on 12/26/15.
//  Copyright © 2015 Arash. All rights reserved.
//

#import "UploadDocsCustomCell.h"

@implementation UploadDocsCustomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
       
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //NSLog(@"TABLEVIEW_CELL_HEIGHT:%f", TABLEVIEW_CELL_HEIGHT);
        self.dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 100, 25)];
        self.dateLabel.font = FONT_NORMAL(11);
        self.dateLabel.minimumScaleFactor = 0.7;
        self.dateLabel.textColor = [UIColor lightGrayColor];
        self.dateLabel.textAlignment = NSTextAlignmentLeft;
        self.dateLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.dateLabel];

        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, TABLEVIEW_CELL_HEIGHT/2 - 30, screenWidth - 140, 60)];
        self.titleLabel.font = FONT_BOLD(15);
        self.titleLabel.numberOfLines = 2;
        self.titleLabel.minimumScaleFactor = 0.7;
        self.titleLabel.textAlignment = NSTextAlignmentRight;
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.titleLabel];
        
        NSInteger documentImageViewWidth = TABLEVIEW_CELL_HEIGHT * 0.7;
        self.documentImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - documentImageViewWidth - 20, TABLEVIEW_CELL_HEIGHT/2 - documentImageViewWidth/2,documentImageViewWidth, documentImageViewWidth)];
        self.documentImageView.layer.cornerRadius = documentImageViewWidth / 2;
        self.documentImageView.clipsToBounds = YES;
        [self addSubview:self.documentImageView];

    }
    return self;
}
@end
