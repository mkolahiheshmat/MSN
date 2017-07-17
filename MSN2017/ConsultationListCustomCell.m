//
//  LandingPageCustomCell.m
//  AdvisorsHealthCloud
//
//  Created by Yarima on 11/16/15.
//  Copyright (c) 2015 Yarima. All rights reserved.
//
#import "ConsultationListCustomCell.h"
#import "Header.h"
#import <QuartzCore/QuartzCore.h>

@implementation ConsultationListCustomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
      
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 6, 150, 20)];
        self.dateLabel.font = FONT_NORMAL(11);
        self.dateLabel.textColor = [UIColor grayColor];
        self.dateLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.dateLabel];
        
        self.categoryLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 130, 9, 120, 20)];
        self.categoryLabel.font = FONT_NORMAL(11);
        self.categoryLabel.textAlignment = NSTextAlignmentCenter;
        self.categoryLabel.textColor = [UIColor colorWithRed:26/255.0 green:184/255.0 blue:180/255.0 alpha:1.0];
        self.categoryLabel.layer.cornerRadius = 9.0;
        self.categoryLabel.layer.borderColor = [UIColor colorWithRed:26/255.0 green:184/255.0 blue:180/255.0 alpha:1.0].CGColor;
        self.categoryLabel.layer.borderWidth = 1.0;
        self.categoryLabel.backgroundColor = [UIColor clearColor];
        self.categoryLabel.clipsToBounds = YES;
        [self addSubview:self.categoryLabel];
        
        self.mainTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, TABLEVIEW_CELL_HEIGHT/2, screenWidth - 110 , 30)];
        self.mainTitleLabel.font = FONT_NORMAL(11);
        self.mainTitleLabel.textAlignment = NSTextAlignmentRight;
        self.mainTitleLabel.textColor = [UIColor blackColor];
        [self addSubview:self.mainTitleLabel];
        
        self.counterLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, TABLEVIEW_CELL_HEIGHT/2, 30, 30)];
        self.counterLabel.font = FONT_NORMAL(11);
        self.counterLabel.textColor = [UIColor redColor];
        self.counterLabel.layer.borderColor = [UIColor redColor].CGColor;
        self.counterLabel.layer.cornerRadius = 15;
        self.counterLabel.layer.borderWidth =1.0;
        self.counterLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.counterLabel];
        
        self.lockStausImage = [[UIImageView alloc]initWithFrame:CGRectMake(20, TABLEVIEW_CELL_HEIGHT/2, 30, 30)];
        [self addSubview:self.lockStausImage];
        
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

@end
