//
//  FavoritesDetailViewController.m
//  HealthCloud
//
//  Created by Yarima on 1/5/16.
//  Copyright © 2016 Yarima. All rights reserved.
//

#import "FavoritesDetailViewController.h"
#import "ImageResizer.h"
#import "Header.h"
#import "AttributedTextClass.h"
#import "NSDictionary+LandingPage.h"
//#import <Google/Analytics.h>

@interface FavoritesDetailViewController ()
{
     
}
@property (nonatomic, retain)UIScrollView *scrollView;
@end

@implementation FavoritesDetailViewController
-(void)viewWillAppear:(BOOL)animated{
//    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//    [tracker set:kGAIScreenName value:@"FavoritesDetailViewController"];
//    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}
- (void)viewDidLoad {
    self.navigationController.navigationBar.hidden = YES;

    [super viewDidLoad];
    // Do any additional setup after loading the view.
     
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 70, screenWidth, screenHeight - 70)];
    [self.view addSubview:self.scrollView];
    
    /*
    UIImageView *mainimageView = [ImageResizer resizeImageWithImage:(UIImage *)self.favoritedFeed.image withWidth:screenWidth withPoint:CGPointMake(0, 0)];
    [self.scrollView addSubview:mainimageView];
    
    UIImageView *doctorimageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 50, mainimageView.frame.origin.y + mainimageView.frame.size.height + 10, 40, 40)];
    doctorimageView.layer.cornerRadius = 20;
    doctorimageView.layer.masksToBounds = YES;
    doctorimageView.image = (UIImage *)self.favoritedFeed.doctorImage;
    [self.scrollView addSubview:doctorimageView];
    
    UILabel *doctorLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, mainimageView.frame.origin.y + mainimageView.frame.size.height + 10, 150, 40)];
    doctorLabel.numberOfLines = 2;
    doctorLabel.font = FONT_NORMAL(11);
    doctorLabel.text = [NSString stringWithFormat:@"%@\n%@", self.favoritedFeed.doctorName, self.favoritedFeed.doctorJobTitle];
    doctorLabel.textAlignment = NSTextAlignmentRight;
    [self.scrollView addSubview:doctorLabel];
    
    UIButton *faveButton = [[UIButton alloc]initWithFrame:CGRectMake(50, mainimageView.frame.origin.y + mainimageView.frame.size.height + 10, 30, 30)];
    [faveButton setBackgroundImage:[UIImage imageNamed:@"favorite_on.png"] forState:UIControlStateNormal];
    [self.scrollView addSubview:faveButton];
    
    UIButton *shareButton = [[UIButton alloc]initWithFrame:CGRectMake(10, mainimageView.frame.origin.y + mainimageView.frame.size.height + 10, 30, 30)];
    [shareButton setBackgroundImage:[UIImage imageNamed:@"share.png"] forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(btnShareClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:shareButton];
    
    UILabel *dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/2 - 50, shareButton.frame.origin.y + shareButton.frame.size.height + 50, 100, 25)];
    dateLabel.numberOfLines = 2;
    dateLabel.textColor = [UIColor lightGrayColor];
    dateLabel.font = FONT_SWISSRA_NORMAL(11);
    dateLabel.text = [NSString stringWithFormat:@"%@", self.favoritedFeed.dateTime];
    dateLabel.textAlignment = NSTextAlignmentCenter;
    [self.scrollView addSubview:dateLabel];

    UIView *horizontalLineLeft = [[UIView alloc]initWithFrame:CGRectMake(10, dateLabel.frame.origin.y + 10, dateLabel.frame.origin.x - 10, 1)];
    horizontalLineLeft.backgroundColor = [UIColor lightGrayColor];
    [self.scrollView addSubview:horizontalLineLeft];
    UIView *horizontalLineRight = [[UIView alloc]initWithFrame:CGRectMake(dateLabel.frame.origin.x + dateLabel.frame.size.width, dateLabel.frame.origin.y + 10, screenWidth - (dateLabel.frame.origin.x + dateLabel.frame.size.width + 10), 1)];
    horizontalLineRight.backgroundColor = [UIColor lightGrayColor];
    [self.scrollView addSubview:horizontalLineRight];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, shareButton.frame.origin.y + shareButton.frame.size.height + 80, screenWidth - 20, 40)];
    titleLabel.numberOfLines = 2;
    titleLabel.font = FONT_SWISSRA_NORMAL(13);
    titleLabel.text = [NSString stringWithFormat:@"%@", self.favoritedFeed.title];
    titleLabel.textAlignment = NSTextAlignmentRight;
    [self.scrollView addSubview:titleLabel];
    
    UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, shareButton.frame.origin.y + shareButton.frame.size.height + 120, screenWidth - 20 , [self getLabelHeight])];
    contentLabel.font = FONT_SWISSRA_NORMAL(13);
    contentLabel.numberOfLines = 0;
    contentLabel.textAlignment = NSTextAlignmentRight;
    contentLabel.textColor = [UIColor blackColor];
    contentLabel.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",self.favoritedFeed.content] attributes:[AttributedTextClass makeAttributedTextWithLineSpacing:19.0]];
    [self.scrollView addSubview:contentLabel];

    */

    self.scrollView.contentSize = CGSizeMake(screenWidth, [self getLabelHeight] + 500);
    
    //NSLog(@"self.navigationControllers: %@", [self.navigationController viewControllers]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonAction:(id)sender {
    [self performSegueWithIdentifier:@"popTofav" sender:nil];
}

- (void) loadFromURL: (NSURL*) url callback:(void (^)(UIImage *image))callback {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(queue, ^{
        NSData * imageData = [NSData dataWithContentsOfURL:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = [UIImage imageWithData:imageData];
            callback(image);
        });
    });
}

-(void)btnShareClicked
{
    
    NSString *footerText = @"این مطلب توسط اپلیکیشن سلامت همراه به اشتراک گذاشته شده است";
    NSString *textToShare = [NSString stringWithFormat:@" %@\n\n%@\n\n%@",self.dictionary.LPTitle,self.dictionary.LPContent,footerText];
    //////NSLog(@"%@",textToShare);
    //UIImage *imageToShare = [UIImage imageNamed:@"like_off.png"];
    //NSArray *itemsToShare = @[textToShare, imageToShare];
    NSArray *itemsToShare = @[textToShare];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
    //    activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll]; //or whichever you don't need
    [self presentViewController:activityVC animated:YES completion:nil];
    
}

-(CGFloat)getLabelHeight
{
    NSString *feedContent = self.dictionary.LPContent;
    
    NSMutableParagraphStyle* textStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    textStyle.alignment = NSTextAlignmentRight;
    textStyle.minimumLineHeight = 19.f;
    textStyle.maximumLineHeight = 19.f;
    //textStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    NSDictionary* textFontAttributes = @{NSFontAttributeName: FONT_NORMAL(13),
                                         NSForegroundColorAttributeName: [UIColor blackColor],
                                         NSParagraphStyleAttributeName: textStyle};
    
    NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:feedContent attributes:textFontAttributes];
    CGRect rect = [aString boundingRectWithSize:(CGSize){screenWidth - 20, MAXFLOAT}
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                        context:nil];//you need to specify the some width, height will be calculated
    CGSize requiredSize = rect.size;
    //finally you return your height
    return requiredSize.height;
}


@end
