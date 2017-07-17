//
//  CustomCell2.m
//  AdvisorsHealthCloud
//
//  Created by Arash on 12/26/15.
//  Copyright © 2015 Arash. All rights reserved.
//

#import "LandingPageCustomCell.h"
#import "Header.h"

@implementation LandingPageCustomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier isPostImage:(BOOL)isPostImage{
    
      
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        NSInteger authorImageWidth = 60;
        self.authorImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - authorImageWidth - 20, 20, authorImageWidth, authorImageWidth)];
        self.authorImageView.layer.cornerRadius = authorImageWidth / 2;
        self.authorImageView.clipsToBounds = YES;
        [self addSubview:self.authorImageView];
        
        self.authorNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, self.authorImageView.frame.origin.y + 10, screenWidth - authorImageWidth - 50, 25)];
        self.authorNameLabel.font = FONT_MEDIUM(13);
        self.authorNameLabel.minimumScaleFactor = 0.7;
        self.authorNameLabel.textColor = COLOR_5;
        self.authorNameLabel.textAlignment = NSTextAlignmentRight;
        self.authorNameLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.authorNameLabel];
        
        self.authorJobLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, self.authorNameLabel.frame.origin.y + 25, screenWidth - authorImageWidth - 40, 25)];
        self.authorJobLabel.font = FONT_NORMAL(11);
        self.authorJobLabel.minimumScaleFactor = 0.7;
        self.authorJobLabel.textColor = [UIColor blackColor];
        self.authorJobLabel.textAlignment = NSTextAlignmentRight;
        self.authorJobLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.authorJobLabel];

        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, self.authorImageView.frame.origin.y + self.authorImageView.frame.size.height, screenWidth - 30, 45)];
        self.titleLabel.font = FONT_BOLD(16);
        self.titleLabel.numberOfLines = 2;
        self.titleLabel.minimumScaleFactor = 0.5;
        self.titleLabel.textAlignment = NSTextAlignmentRight;
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.titleLabel];
        
        //268 × 75
        UIImageView *categoryBGImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 107.2, 30)];
        categoryBGImageView.image = [UIImage imageNamed:@"kadr"];
        [self addSubview:categoryBGImageView];
        
        //290 × 68
        UIImageView *blurBGImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 107, self.postImageView.frame.size.height - 25, 107.3, 25)];
        blurBGImageView.image = [UIImage imageNamed:@"blur"];
        [self.postImageView addSubview:blurBGImageView];
        
        //44 × 22
        UIImageView *seenImageView = [[UIImageView alloc]initWithFrame:CGRectMake(7, 9, 22, 11)];
        seenImageView.image = [UIImage imageNamed:@"see icon"];
        //[blurBGImageView addSubview:seenImageView];
        
        self.categoryLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, categoryBGImageView.frame.size.width, categoryBGImageView.frame.size.height)];
        self.categoryLabel.font = FONT_MEDIUM(11);
        self.categoryLabel.minimumScaleFactor = 0.7;
        self.categoryLabel.textColor = [UIColor whiteColor];
        self.categoryLabel.textAlignment = NSTextAlignmentCenter;
        self.categoryLabel.adjustsFontSizeToFitWidth = YES;
        [categoryBGImageView addSubview:self.categoryLabel];
        
        self.contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height - 20, screenWidth - 30, 70)];
        self.contentLabel.font = FONT_NORMAL(15);
        if (IS_IPAD) {
            self.contentLabel.font = FONT_NORMAL(19);
            self.contentLabel.frame = CGRectMake(10, self.authorImageView.frame.origin.y + self.authorImageView.frame.size.height + 10, screenWidth - 20, 100);
        }
        self.contentLabel.textColor = [UIColor blackColor];
        self.contentLabel.numberOfLines = 0;
        self.contentLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:self.contentLabel];
        
        self.postImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, self.contentLabel.frame.origin.y + self.contentLabel.frame.size.height, screenWidth, screenWidth * 0.42)];
        self.postImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.postImageView.clipsToBounds = YES;
        [self addSubview:self.postImageView];
        
        if (!isPostImage) {
            CGRect rect = self.postImageView.frame;
            rect.size.height = 0;
            self.postImageView.frame = rect;
        }
        
        //30 × 27
        UIImageView *likeImageView = [[UIImageView alloc]initWithFrame:CGRectMake(65, 9, 15, 13.5)];
        likeImageView.image = [UIImage imageNamed:@"like icon"];
        [blurBGImageView addSubview:likeImageView];
        
        self.likeCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(81, 5, 20, 20)];
        self.likeCountLabel.font = FONT_NORMAL(11);
        self.likeCountLabel.minimumScaleFactor = 0.7;
        self.likeCountLabel.textColor = [UIColor grayColor];
        self.likeCountLabel.textAlignment = NSTextAlignmentLeft;
        self.likeCountLabel.adjustsFontSizeToFitWidth = YES;
        [blurBGImageView addSubview:self.likeCountLabel];

        //46 × 49
        self.commentImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 100, _postImageView.frame.origin.y+ _postImageView.frame.size.height + 5, 46*0.4, 49*0.4)];
        self.commentImageView.image = [UIImage imageNamed:@"comment"];
        [self addSubview:self.commentImageView];
        
        self.commentCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 140, _postImageView.frame.origin.y+ _postImageView.frame.size.height + 5, 36, 20)];
        self.commentCountLabel.font = FONT_NORMAL(11);
        self.commentCountLabel.minimumScaleFactor = 0.7;
        self.commentCountLabel.textColor = [UIColor grayColor];
        self.commentCountLabel.textAlignment = NSTextAlignmentRight;
        self.commentCountLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.commentCountLabel];
        
        //52 × 49
        self.heartButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - 40, _postImageView.frame.origin.y+ _postImageView.frame.size.height + 5, 52 * 0.4, 49*0.4)];
        [self.heartButton setImage:[UIImage imageNamed:@"like icon"] forState:UIControlStateNormal];
        [self addSubview:self.heartButton];
        
        self.likeCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 80, _postImageView.frame.origin.y+ _postImageView.frame.size.height + 5, 36, 20)];
        self.likeCountLabel.font = FONT_NORMAL(11);
        self.likeCountLabel.minimumScaleFactor = 0.7;
        self.likeCountLabel.textColor = [UIColor grayColor];
        self.likeCountLabel.textAlignment = NSTextAlignmentRight;
        self.likeCountLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.likeCountLabel];
        
        //46 × 43
        self.favButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - 160, _postImageView.frame.origin.y+ _postImageView.frame.size.height + 5, 46 * 0.4, 43 * 0.4)];
        [self.favButton setImage:[UIImage imageNamed:@"fav off"] forState:UIControlStateNormal];
        [self addSubview:self.favButton];

        //35 × 44
        self.shareButton = [[UIButton alloc]initWithFrame:CGRectMake(150, _postImageView.frame.origin.y+ _postImageView.frame.size.height + 5, 35*0.4, 44*0.4)];
        [self.shareButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
        //[self addSubview:self.shareButton];

        self.dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, _shareButton.frame.origin.y, 100, 25)];
        self.dateLabel.font = FONT_NORMAL(11);
        self.dateLabel.minimumScaleFactor = 0.7;
        self.dateLabel.textColor = [UIColor lightGrayColor];
        self.dateLabel.textAlignment = NSTextAlignmentLeft;
        self.dateLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.dateLabel];
    }
    return self;
}
@end
