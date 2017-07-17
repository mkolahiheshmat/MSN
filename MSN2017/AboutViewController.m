//
//  AboutViewController.m
//  MSN
//
//  Created by Yarima on 5/29/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "AboutViewController.h"
#import "Header.h"
#import <AFHTTPSessionManager.h>
#import <UIImageView+AFNetworking.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import "UploadDocumentsViewController.h"
#import "ConsultationListViewController.h"
#import "HealthStatusViewController.h"
#import "FavoritesViewController.h"
#import "AboutViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "UIImage+Extra.h"
@interface AboutViewController ()<MFMailComposeViewControllerDelegate>
{
     
}
@property(nonatomic, retain)UITableView *tableView;
@property(nonatomic, retain)NSMutableArray *tableArray;
@end

@implementation AboutViewController

- (void)viewDidLoad {
    self.navigationController.navigationBar.hidden = YES;

    [super viewDidLoad];
     
    [self makeTopBar];
    [self makeBody];
    //NSLog(@"self.navigationControllers: %@", [self.navigationController viewControllers]);
}

#pragma mark - Custom methods

- (void)makeTopBar{
    
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 70)];
    topView.backgroundColor = COLOR_3;
    [topView makeGradient:topView];
    [self.view addSubview:topView];
    
    CGFloat topViewHeight = topView.frame.size.height;
    
    UILabel *titleLabel =[[UILabel alloc]initWithFrame:CGRectMake(screenWidth/2 - 100, topViewHeight/2 - 15, 200, 40)];
    titleLabel.font = FONT_NORMAL(20);
    titleLabel.text = NSLocalizedString(@"aboutus", @"");
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:titleLabel];
    //54 × 39
    UIButton *menuButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - 60, topViewHeight/2 - 20, 54, 54)];
    //menuButton.backgroundColor = [UIColor redColor];
    UIImage *img = [UIImage imageNamed:@"menu side"];
    [menuButton setImage:[img imageByScalingProportionallyToSize:CGSizeMake(54/2,39/2)] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(menuButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:menuButton];

    UIButton *backButtonImg = [[UIButton alloc]initWithFrame:CGRectMake(0, 16 , 45, 45)];
    [backButtonImg setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButtonImg addTarget:self action:@selector(backButtonImgAction) forControlEvents:UIControlEventTouchUpInside];
    //[self.view addSubview:backButtonImg];
    
}

- (void)makeBody{
    
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 70, screenWidth, screenHeight - 70)];
    [self.view addSubview:scrollView];
    
    CGFloat heightOfLabel = [self getHeightOfString:NSLocalizedString(@"about", @"")];
    UITextView *contentTextView;
    if (IS_IPAD) {
        contentTextView = [[UITextView alloc]initWithFrame:CGRectMake(20, 0, screenWidth - 40, 400)];
        contentTextView.font = FONT_NORMAL(21);
    } else {
        contentTextView = [[UITextView alloc]initWithFrame:CGRectMake(20, 0, screenWidth - 40, heightOfLabel)];
        contentTextView.font = FONT_NORMAL(15);
    }
    
    
    contentTextView.editable = NO;
    //
    UITextPosition *beginning = contentTextView.beginningOfDocument;
    UITextPosition *start = [contentTextView positionFromPosition:beginning offset:0];
    UITextPosition *end = [contentTextView positionFromPosition:start offset:[contentTextView.text length]];
    UITextRange *textRange = [contentTextView textRangeFromPosition:start toPosition:end];
    [contentTextView setBaseWritingDirection:UITextWritingDirectionRightToLeft forRange:textRange];
    contentTextView.textAlignment = NSTextAlignmentJustified;
    contentTextView.text = NSLocalizedString(@"about", @"");
    contentTextView.textColor = [UIColor blackColor];
    [scrollView addSubview:contentTextView];
    
    /////////////////////////////////horizonalView///////////////////////////
    UIView *horizonalView = [[UIView alloc]initWithFrame:CGRectMake(10, contentTextView.frame.origin.y + contentTextView.frame.size.height + 20, screenWidth - 20, 1)];
    horizonalView.backgroundColor = [UIColor lightGrayColor];
    [scrollView addSubview:horizonalView];
    
    UILabel *contactusLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/2 - 100, contentTextView.frame.origin.y + contentTextView.frame.size.height + 50, 200, 25)];
    contactusLabel.font = FONT_NORMAL(15);
    contactusLabel.text = NSLocalizedString(@"contactus", @"");
    contactusLabel.textColor = [UIColor blackColor];
    contactusLabel.textAlignment = NSTextAlignmentCenter;
    [scrollView addSubview:contactusLabel];
    
    UIButton *telegramButton = [[UIButton alloc]initWithFrame:CGRectMake(20, contactusLabel.frame.origin.y + 40, 50, 50)];
    [telegramButton setImage:[UIImage imageNamed:@"telegram"] forState:UIControlStateNormal];
    [telegramButton addTarget:self action:@selector(telegramButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:telegramButton];
    
    //187 × 125
    UIButton *emailButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth/2 - ((187 * 0.32)/2), contactusLabel.frame.origin.y + 50, 187 * 0.32, 125 * 0.32)];
    [emailButton setImage:[UIImage imageNamed:@"contactusemail"] forState:UIControlStateNormal];
    [emailButton addTarget:self action:@selector(emailButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:emailButton];

    //125 × 125
    UIButton *instaButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - 80, contactusLabel.frame.origin.y + 50, 125 * 0.32, 125 * 0.32)];
    [instaButton setImage:[UIImage imageNamed:@"contactusinsta"] forState:UIControlStateNormal];
    [instaButton addTarget:self action:@selector(instaButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:instaButton];

    /////////////////////////////////horizonalView///////////////////////////
    UIView *horizonalView2 = [[UIView alloc]initWithFrame:CGRectMake(10, emailButton.frame.origin.y + 70, screenWidth - 20, 1)];
    horizonalView2.backgroundColor = [UIColor lightGrayColor];
    [scrollView addSubview:horizonalView2];
    
    //collegue
    UILabel *collegueLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/2 - 100, horizonalView2.frame.origin.y + 30, 200, 25)];
    collegueLabel.font = FONT_NORMAL(15);
    collegueLabel.text = NSLocalizedString(@"collegue", @"");
    collegueLabel.textColor = [UIColor blackColor];
    collegueLabel.textAlignment = NSTextAlignmentCenter;
    [scrollView addSubview:collegueLabel];
    
    UIButton *vasButton = [[UIButton alloc]initWithFrame:CGRectMake(20, horizonalView2.frame.origin.y + 70, 60, 60)];
    [vasButton setImage:[UIImage imageNamed:@"vaslablogo"] forState:UIControlStateNormal];
    [vasButton addTarget:self action:@selector(vasButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:vasButton];
    
    //315 × 276
    UIButton *logoButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth/2 - 30, horizonalView2.frame.origin.y + 70, 315 * 0.25, 276 * 0.25)];
    [logoButton setImage:[UIImage imageNamed:@"abresalamatlogo"] forState:UIControlStateNormal];
    [logoButton addTarget:self action:@selector(logoButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:logoButton];

    //300 × 200
    UIButton *mciButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - 80, horizonalView2.frame.origin.y + 80, 300 * 0.25, 200 * 0.25)];
    [mciButton setImage:[UIImage imageNamed:@"mci"] forState:UIControlStateNormal];
    [mciButton addTarget:self action:@selector(mciButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:mciButton];
    
    /////////////////////////////////horizonalView///////////////////////////
    UIView *horizonalView3 = [[UIView alloc]initWithFrame:CGRectMake(10, mciButton.frame.origin.y + 80, screenWidth - 20, 1)];
    horizonalView3.backgroundColor = [UIColor lightGrayColor];
    [scrollView addSubview:horizonalView3];
    
    //677 × 325
    UIButton *yarimaButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth/2 - ((677 * 0.10)/2), horizonalView3.frame.origin.y + 30, 677 * 0.10, 325 * 0.10)];
    [yarimaButton setImage:[UIImage imageNamed:@"yariamlogo"] forState:UIControlStateNormal];
    [yarimaButton addTarget:self action:@selector(yarimaButtonAction) forControlEvents:UIControlEventTouchUpInside];
    //[scrollView addSubview:yarimaButton];

    UILabel *verLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/2 - 100, horizonalView3.frame.origin.y + 10, 200, 25)];
    verLabel.font = FONT_NORMAL(15);
    verLabel.text = @"نسخه 3.0";
    verLabel.textColor = [UIColor blackColor];
    verLabel.textAlignment = NSTextAlignmentCenter;
    [scrollView addSubview:verLabel];

    scrollView.contentSize = CGSizeMake(screenWidth, verLabel.frame.origin.y + 50);

}

- (void)telegramButtonAction{
    
}

- (void)instaButtonAction{
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://user?username=abresalamat"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        [[UIApplication sharedApplication] openURL:instagramURL];
    }else
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.instagram.com/abresalamat"]];
    }
    
}

-(void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    //handle any error
    [controller dismissViewControllerAnimated:YES completion:nil];
}


- (void)emailButtonAction{
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        mailCont.mailComposeDelegate = self;
        [mailCont setSubject:@""];
        [mailCont setToRecipients:[NSArray arrayWithObjects:@"crm@abresalamat.ir", nil]];
        [mailCont setMessageBody:[@"" stringByAppendingString:@""] isHTML:NO];
        [self presentViewController:mailCont animated:YES completion:nil];
    }else{
        //setupemail
        
    }
}

- (void)yarimaButtonAction{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.yarima.co/"]];
    
}

- (void)mciButtonAction{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.mci.ir/"]];

}

- (void)logoButtonAction{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://health.mcicloud.ir/"]];

}

- (void)vasButtonAction{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://vaslab.ir"]];

}

- (CGFloat)getHeightOfString:(NSString *)labelText{
    
    UIFont *font = FONT_NORMAL(16);
    if (IS_IPAD) {
        font = FONT_NORMAL(22);
    }
    CGSize sizeOfText = [labelText boundingRectWithSize: CGSizeMake( self.view.bounds.size.width - 30,CGFLOAT_MAX)
                                                options: (NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                             attributes: [NSDictionary dictionaryWithObject:font
                                                                                     forKey:NSFontAttributeName]
                                                context: nil].size;
    CGFloat height = sizeOfText.height + 50;
    if (height < screenWidth + 10)
        height = screenWidth + 10;
    return height;
    
}

- (void)menuButtonAction {
    //[self showHideRightMenu];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"toggleMenuVisibility" object:nil];
}

- (void)backButtonImgAction{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)pushToUploadDocs{
    self.navigationController.viewControllers = @[[[self.navigationController viewControllers]objectAtIndex:0], [[self.navigationController viewControllers]lastObject]];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UploadDocumentsViewController *view = (UploadDocumentsViewController *)[story instantiateViewControllerWithIdentifier:@"UploadDocumentsViewController"];
    [self.navigationController pushViewController:view animated:YES];
}

- (void)pushToConsultation{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ConsultationListViewController *view = (ConsultationListViewController *)[story instantiateViewControllerWithIdentifier:@"ConsultationListViewController"];
    [self.navigationController pushViewController:view animated:YES];
}

- (void)pushToHealthStatus{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HealthStatusViewController *view = (HealthStatusViewController *)[story instantiateViewControllerWithIdentifier:@"HealthStatusViewController"];
    [self.navigationController pushViewController:view animated:YES];
}

- (void)pushToFav{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FavoritesViewController *view = (FavoritesViewController *)[story instantiateViewControllerWithIdentifier:@"FavoritesViewController"];
    [self.navigationController pushViewController:view animated:YES];
}

- (void)pushToAbout{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AboutViewController *view = (AboutViewController *)[story instantiateViewControllerWithIdentifier:@"AboutViewController"];
    [self.navigationController pushViewController:view animated:YES];
}
@end
