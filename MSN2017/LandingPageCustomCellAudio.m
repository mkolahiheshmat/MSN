//
//  CustomCell2.m
//  AdvisorsHealthCloud
//
//  Created by Arash on 12/26/15.
//  Copyright © 2015 Arash. All rights reserved.
//

#import "LandingPageCustomCellAudio.h"
#import "Header.h"
#import "CustomButton.h"
@implementation LandingPageCustomCellAudio

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        NSInteger authorImageWidth = 60;
        self.authorImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - authorImageWidth - 20, 20, authorImageWidth, authorImageWidth)];
        self.authorImageView.layer.cornerRadius = authorImageWidth / 2;
        self.authorImageView.clipsToBounds = YES;
        [self addSubview:self.authorImageView];
        
        self.authorNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, self.authorImageView.frame.origin.y + 10, screenWidth - authorImageWidth - 40, 25)];
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
        
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, self.authorImageView.frame.origin.y + self.authorImageView.frame.size.height + 0, screenWidth - 120, 30)];
        self.titleLabel.font = FONT_BOLD(17);
        self.titleLabel.numberOfLines = 2;
        self.titleLabel.minimumScaleFactor = 0.7;
        self.titleLabel.textAlignment = NSTextAlignmentRight;
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.titleLabel];
       
        
        self.postImageView = [[UIImageView alloc]initWithFrame:CGRectMake(100, self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 60, screenWidth - (screenWidth/5) - 100, screenWidth * 0.1)];
        self.postImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.postImageView.clipsToBounds = YES;
        //[self addSubview:self.postImageView];
        //self.waveform.doesAllowScrubbing = YES;
        //self.waveform.doesAllowStretch = YES;
        //self.waveform.doesAllowScroll = YES;

        //[self addSubview:self.waveform];
        
        self.totalDurationLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 80, self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 65, 70, 25)];
        if (IS_IPAD) {
            self.totalDurationLabel.frame = CGRectMake(screenWidth - 80, self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 85, 70, 25);
        }
        self.totalDurationLabel.font = FONT_NORMAL(17);
        self.totalDurationLabel.numberOfLines = 2;
        self.totalDurationLabel.minimumScaleFactor = 0.7;
        self.totalDurationLabel.textAlignment = NSTextAlignmentRight;
        self.totalDurationLabel.adjustsFontSizeToFitWidth = YES;
        //[self addSubview:self.totalDurationLabel];

        self.currentTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 65, 70, 25)];
        if (IS_IPAD) {
            self.currentTimeLabel.frame = CGRectMake(60, self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 85, 70, 25);
        }
        self.currentTimeLabel.font = FONT_NORMAL(17);
        self.currentTimeLabel.numberOfLines = 2;
        self.currentTimeLabel.text = @"00:00";
        self.currentTimeLabel.minimumScaleFactor = 0.7;
        self.currentTimeLabel.textAlignment = NSTextAlignmentLeft;
        self.currentTimeLabel.adjustsFontSizeToFitWidth = YES;
        //[self addSubview:self.currentTimeLabel];
        
        self.downloadPlayButton = [CustomButton initButtonWithImage:[UIImage imageNamed:@"play icon"] withFrame:CGRectMake(10, 130, 40, 40)];
        if (IS_IPAD) {
            self.downloadPlayButton.frame = CGRectMake(10, 150, 40, 40);
        }
        [self addSubview:self.downloadPlayButton];

        UIImageView *audioSampleImageView = [[UIImageView alloc]initWithFrame:CGRectMake(70, 130, screenWidth - 130, 30)];
        audioSampleImageView.image = [UIImage imageNamed:@"progress play"];
        [self addSubview:audioSampleImageView];
        
        //268 × 75
        UIImageView *categoryBGImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 107.2, 30)];
        categoryBGImageView.image = [UIImage imageNamed:@"kadr"];
        [self addSubview:categoryBGImageView];
        
        //290 × 68
        UIImageView *blurBGImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 107, self.downloadPlayButton.frame.size.height - 25, 107.3, 25)];
        blurBGImageView.image = [UIImage imageNamed:@"blur"];
        //[self.waveform addSubview:blurBGImageView];
        
        //44 × 22
        UIImageView *seenImageView = [[UIImageView alloc]initWithFrame:CGRectMake(7, 9, 22, 11)];
        seenImageView.image = [UIImage imageNamed:@"see icon"];
        //[blurBGImageView addSubview:seenImageView];
        
        self.commentCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 5, 20, 20)];
        self.commentCountLabel.font = FONT_NORMAL(11);
        self.commentCountLabel.minimumScaleFactor = 0.7;
        self.commentCountLabel.textColor = [UIColor grayColor];
        self.commentCountLabel.textAlignment = NSTextAlignmentLeft;
        self.commentCountLabel.adjustsFontSizeToFitWidth = YES;
        //[blurBGImageView addSubview:self.commentCountLabel];
        
        self.categoryLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, categoryBGImageView.frame.size.width, categoryBGImageView.frame.size.height)];
        self.categoryLabel.font = FONT_MEDIUM(11);
        self.categoryLabel.minimumScaleFactor = 0.7;
        self.categoryLabel.textColor = [UIColor whiteColor];
        self.categoryLabel.textAlignment = NSTextAlignmentCenter;
        self.categoryLabel.adjustsFontSizeToFitWidth = YES;
        [categoryBGImageView addSubview:self.categoryLabel];
        
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
        [self.heartButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
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
        
        self.largeProgressView = [[DACircularProgressView alloc]initWithFrame:CGRectMake(_downloadPlayButton.frame.origin.x, _downloadPlayButton.frame.origin.y, 40, 40)];
        self.largeProgressView.progressTintColor = [UIColor redColor];
        self.largeProgressView.roundedCorners = NO;
        //[self addSubview:self.largeProgressView];
    }
    return self;
}
@end
