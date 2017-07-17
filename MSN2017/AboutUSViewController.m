//  Created by Yarima on 7/27/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "AboutUSViewController.h"
#import "Header.h"
#import "UIImage+Extra.h"
#import <AFHTTPSessionManager.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import "ProgressHUD.h"
#import "CustomButton.h"
#import "ShakeAnimation.h"
#import "AppDelegate.h"
#import "GetUsernamePassword.h"
#import "Header.h"
#import "PishnahadatViewController.h"
#define TIMER_DISABLE_SENDBUTTON   1.0 // in seconds
@interface AboutUSViewController ()
{
    UIScrollView *scrollView;
}
@end

@implementation AboutUSViewController

- (void)viewDidDisappear:(BOOL)animated{
    //[self.tabBarController.tabBar setHidden:NO];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self makeTopBar];
    [self makeBody];
}

- (void)makeTopBar{
    
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 70)];
    topView.backgroundColor = COLOR_3;
    [topView makeGradient:topView];
    [self.view addSubview:topView];
    
    CGFloat topViewHeight = topView.frame.size.height;
    
    UILabel *titleLabel =[[UILabel alloc]initWithFrame:CGRectMake(screenWidth/2 - 100, topViewHeight/2 - 15, 200, 40)];
    titleLabel.font = FONT_NORMAL(16);
    titleLabel.text = NSLocalizedString(@"aboutus", @"");
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:titleLabel];
    
    UIButton *backButtonImg = [[UIButton alloc]initWithFrame:CGRectMake(0, 16 , 45, 45)];
    [backButtonImg setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButtonImg addTarget:self action:@selector(backButtonImgAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButtonImg];
    
}

- (void)makeBody{
    UIImageView *bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 70, screenWidth, screenHeight - 70)];
    bgImageView.image = [UIImage imageNamed:@"back msn about"];
    [self.view addSubview:bgImageView];
    
    //226x161
    UIImageView *logoImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth/2 - ((1024 * 0.05)/2), 90, 1024 * 0.05, 1024 * 0.05)];
    logoImageView.image = [UIImage imageNamed:@"logo msn"];
    [self.view addSubview:logoImageView];
    
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 140, screenWidth, screenHeight - 140)];
    scrollView.contentSize = CGSizeMake(screenWidth, [self getHeightOfString:[self customStringFromFile]] + 280);
    [self.view addSubview:scrollView];
    
    UITextView *textView = [[UITextView alloc]initWithFrame:CGRectMake(10, 0, screenWidth - 20, [self getHeightOfString:[self customStringFromFile]] )];
    textView.backgroundColor = [UIColor clearColor];
    textView.text = [self customStringFromFile];
    textView.font = FONT_NORMAL(14);
    textView.userInteractionEnabled = NO;
    textView.textAlignment = NSTextAlignmentRight;
    [scrollView addSubview:textView];
    
    //194x177
    UIImageView *abrImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 90, textView.frame.origin.y + textView.frame.size.height + 20, 194 * 0.3, 177 * 0.3)];
    abrImageView.image = [UIImage imageNamed:@"msn abresalamat"];
    abrImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapAbr = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(abrTapAction:)];
    [abrImageView addGestureRecognizer:tapAbr];
    [scrollView addSubview:abrImageView];
    
    //136x136
    UIImageView *vaslImageView = [[UIImageView alloc]initWithFrame:CGRectMake(50, textView.frame.origin.y + textView.frame.size.height + 20, 136 * 0.3, 136 * 0.3)];
    vaslImageView.image = [UIImage imageNamed:@"msn sharif"];
    vaslImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapVasl = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(vaslabTapAction:)];
    [vaslImageView addGestureRecognizer:tapVasl];
    [scrollView addSubview:vaslImageView];
    
    UIView *emailView = [[UIView alloc]initWithFrame:CGRectMake(20, vaslImageView.frame.origin.y + vaslImageView.frame.size.height + 20, screenWidth - 40, 50)];
    //emailView.backgroundColor = COLOR_3;
    [scrollView addSubview:emailView];
    
    //88x53
    UIImageView *emailImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 80, vaslImageView.frame.origin.y + vaslImageView.frame.size.height + 50, 88 * 0.2, 53 * 0.2)];
    emailImageView.image = [UIImage imageNamed:@"enteghad msn"];
    [scrollView addSubview:emailImageView];
    
    UIButton *btn = [CustomButton initButtonWithTitle:@"ارسال انتقادات و پیشنهادات" withTitleColor:[UIColor blackColor] withBackColor:[UIColor clearColor] withFrame:CGRectMake(40, vaslImageView.frame.origin.y + vaslImageView.frame.size.height + 35, 200, 40)];
    [btn addTarget:self action:@selector(goToPishnahadView) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:btn];
    
}

                                                           - (CGFloat)getHeightOfString:(NSString *)labelText{
                                                               
                                                               UIFont *font = FONT_NORMAL(14);
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


- (NSString *)customStringFromFile
{
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"about" ofType:@"txt"];
    NSString *stringContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    return stringContent;
}
- (void)abrTapAction:(UITapGestureRecognizer *)tap{
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http:www.abresalamat.ir"]];
}

- (void)vaslabTapAction:(UITapGestureRecognizer *)tap{
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http:www.vaslab.ir"]];
}

- (void)goToPishnahadView{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PishnahadatViewController *view = (PishnahadatViewController *)[story instantiateViewControllerWithIdentifier:@"PishnahadatViewController"];
    [self.navigationController pushViewController:view animated:YES];
}
- (void)backButtonImgAction{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
