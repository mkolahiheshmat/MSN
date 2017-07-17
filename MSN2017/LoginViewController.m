//
//  LoginViewController.m
//  MSN
//
//  Created by Yarima on 5/11/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "LoginViewController.h"
#import "ImageResizer.h"
#import "Header.h"
#import "CustomButton.h"
#import "ShakeAnimation.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <AFHTTPSessionManager.h>
#import "ProgressHUD.h"
#import "EnterCodeViewController.h"
#import "ReplacerEngToPer.h"
@interface LoginViewController()<UIScrollViewDelegate, UITextFieldDelegate>
{
    
    UIScrollView *_scrollView;
    UIPageControl *pageControl;
    UIImageView *logoImageView;
    UITextField *phoneTextField;
}

@end
@implementation LoginViewController

- (void)viewDidLoad{
    
    //self.view.backgroundColor = [UIColor colorWithRed:11/255.0 green:195/255.0 blue:193/255.0 alpha:1.0];
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *imageViewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissTextField)];
    [self.view addGestureRecognizer:imageViewTap];
    
    logoImageView = [ImageResizer resizeImageWithImage:[UIImage imageNamed:@"logo"] withWidth:screenWidth/3 withPoint:CGPointMake(screenWidth/3, 40)];
    [self.view addSubview:logoImageView];
    
    UIButton *backButtonImg = [[UIButton alloc]initWithFrame:CGRectMake(0, 16 , 45, 45)];
    [backButtonImg setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButtonImg addTarget:self action:@selector(backButtonImgAction) forControlEvents:UIControlEventTouchUpInside];
    //[self.view addSubview:backButtonImg];
    
    UILabel *titleLabel =[[UILabel alloc]initWithFrame:CGRectMake(10, logoImageView.frame.size.height + 20, screenWidth - 20, 40)];
    titleLabel.font = FONT_NORMAL(20);
    titleLabel.text = NSLocalizedString(@"enterMobile", @"");
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    //[self.view addSubview:titleLabel];
    
    //loginTozih
    UILabel *tozihLabel =[[UILabel alloc]initWithFrame:CGRectMake(10, logoImageView.frame.size.height + 20, screenWidth - 20, 60)];
    tozihLabel.font = FONT_NORMAL(15);
    tozihLabel.text = NSLocalizedString(@"loginTozih", @"");
    tozihLabel.textColor = [UIColor blackColor];
    tozihLabel.numberOfLines = 2;
    tozihLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tozihLabel];
    
    phoneTextField = [[UITextField alloc]initWithFrame:CGRectMake(screenWidth/2 - 100, logoImageView.frame.size.height + 140, 200, 30)];
    phoneTextField.placeholder = NSLocalizedString(@"enterYourMobile", @"");
    phoneTextField.tag = 354;
    phoneTextField.layer.cornerRadius = 15;
    phoneTextField.backgroundColor = [UIColor whiteColor];
    phoneTextField.clipsToBounds = YES;
    phoneTextField.font = FONT_NORMAL(15);
    phoneTextField.textAlignment = NSTextAlignmentCenter;
    phoneTextField.delegate = self;
    phoneTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    [phoneTextField addTarget:self
                       action:@selector(textFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
    
    [self.view addSubview:phoneTextField];
    
    UIButton *sendButton = [CustomButton
                            initButtonWithTitle:NSLocalizedString(@"taeed", @"")
                            withTitleColor:[UIColor whiteColor]
                            withBackColor:COLOR_5
                            withFrame:CGRectMake(screenWidth/2 - 80, logoImageView.frame.size.height + 200, 160, 30)];
    sendButton.titleLabel.font = FONT_NORMAL(15);
    [sendButton addTarget:self action:@selector(sendButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendButton];
    
    NSString *mobileString = [[NSUserDefaults standardUserDefaults]objectForKey:@"mobile"];
    if ([mobileString length] == 11) {
        UIButton *codeTaeedButton = [CustomButton
                                     initButtonWithTitle:NSLocalizedString(@"entercode", @"")
                                     withTitleColor:COLOR_5
                                     withBackColor:[UIColor clearColor]
                                     withFrame:CGRectMake(screenWidth/2 - 80, logoImageView.frame.size.height + 260, 160, 30)];
        codeTaeedButton.titleLabel.font = FONT_NORMAL(15);
        [codeTaeedButton addTarget:self action:@selector(codeTaeedButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:codeTaeedButton];
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(backButtonImgAction) name:@"dimissLoginView" object:nil];
    
}


#pragma mark - custom methods

- (void)backButtonImgAction{
    //[self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:NO completion:nil];
    [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"dismissIntroView"];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"dismissIntroView" object:nil];
}

- (void)sendButtonAction{
    [self dismissTextField];
    if (![self isNumeric:phoneTextField.text] ||
        [phoneTextField.text length] != 11) {
        [ShakeAnimation startShake:phoneTextField];
        return;
    }
    
    if ([self hasConnectivity]) {
        [self loginConnection];
    }else{
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@""
                                      message:NSLocalizedString(@"becomeOnline", @"")
                                      preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"OK", @"")
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 
                             }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)codeTaeedButtonAction{
    [self pushToEnterCode];
}

- (void)dismissTextField{
    if (IS_IPHONE_4_AND_OLDER_IOS7 || IS_IPHONE_4_AND_OLDER_IOS8) {
        [UIView animateWithDuration:0.4 animations:^{
            CGRect rect = self.view.frame;
            rect.origin.y = 0;
            [self.view setFrame:rect];
            
        }];
    }
    
    [phoneTextField resignFirstResponder];
}

-(BOOL)isNumeric:(NSString*)inputString{
    BOOL isValid = NO;
    if ([inputString length] > 0) {
        NSCharacterSet *alphaNumbersSet = [NSCharacterSet decimalDigitCharacterSet];
        NSCharacterSet *stringSet = [NSCharacterSet characterSetWithCharactersInString:inputString];
        isValid = [alphaNumbersSet isSupersetOfSet:stringSet];
    }
    
    return isValid;
}

- (void)pushToEnterCode{
    //[self dismissViewControllerAnimated:YES completion:nil];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    EnterCodeViewController *view = (EnterCodeViewController *)[story instantiateViewControllerWithIdentifier:@"EnterCodeViewController"];
    view.mobileString = [[NSUserDefaults standardUserDefaults]objectForKey:@"mobile"];
    //[self.navigationController pushViewController:view animated:YES];
    [self presentViewController:view animated:YES completion:nil];
}
#pragma mark - text field delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.tag == 354) {
        if(range.length + range.location > textField.text.length)
        {
            return NO;
        }
        
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return newLength <= 11;
    }else{
        return NO;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (IS_IPHONE_4_AND_OLDER_IOS7 || IS_IPHONE_4_AND_OLDER_IOS8) {
        [UIView animateWithDuration:0.5 animations:^{
            CGRect rect = self.view.frame;
            rect.origin.y -= 50;
            [self.view setFrame:rect];
            
        }];
    }
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [self dismissTextField];
    return YES;
}

-(void)textFieldDidChange :(UITextField *)textField{
    if ([textField.text length] >=2) {
       textField.text = [textField.text stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@"09"];
    }
    
    phoneTextField.text = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    phoneTextField.text = [textField.text stringByReplacingOccurrencesOfString:@"0098" withString:@"0"];
    phoneTextField.text = [textField.text stringByReplacingOccurrencesOfString:@"+98" withString:@"0"];
    phoneTextField.text = phoneTextField.text;
}

#pragma mark - connection
- (BOOL)hasConnectivity {
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
    if(reachability != NULL) {
        //NetworkStatus retVal = NotReachable;
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(reachability, &flags)) {
            if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
            {
                // if target host is not reachable
                return NO;
            }
            
            if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
            {
                // if target host is reachable and no connection is required
                //  then we'll assume (for now) that your on Wi-Fi
                return YES;
            }
            
            
            if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
                 (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
            {
                // ... and the connection is on-demand (or on-traffic) if the
                //     calling application is using the CFSocketStream or higher APIs
                
                if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
                {
                    // ... and no [user] intervention is needed
                    return YES;
                }
            }
            
            if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
            {
                // ... but WWAN connections are OK if the calling application
                //     is using the CFNetwork (CFSocketStream?) APIs.
                return YES;
            }
        }
    }
    
    return NO;
}

- (void)loginConnection{
    if ([phoneTextField.text length] != 11) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"شماره موبایل باید ۱۱ رقم باشد" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            return;
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    [ProgressHUD show:NSLocalizedString(@"retrievingdata", @"") Interaction:NO];
    NSDictionary *params = @{@"username":[ReplacerEngToPer replacer:phoneTextField.text]
                             };
    NSString *url = [NSString stringWithFormat:@"%@api/users/register", BaseURL];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        [ProgressHUD dismiss];
        NSDictionary *dict = responseObject;
        NSString *success =  [dict objectForKey:@"success"];
        if ([success integerValue] == 1) {
            NSInteger userID = [[[responseObject objectForKey:@"data"]objectForKey:@"id"]integerValue];
            NSUserDefaults *defualt = [NSUserDefaults standardUserDefaults];
            [defualt setObject:phoneTextField.text forKey:@"mobile"];
            [defualt setObject:@"YES" forKey:@"waitForEnterCode"];
            [defualt setObject:[NSNumber numberWithInteger:userID] forKey:@"userID"];
            [self pushToEnterCode];
        } else {
            NSString *alertMessage = [responseObject objectForKey:@"message"];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"error", @"") message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            }];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [ProgressHUD dismiss];
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:NSLocalizedString(@"errorinData", @"")
                                      message:[NSString stringWithFormat:@"%@",[error localizedDescription]]
                                      preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"OK", @"")
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 
                             }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }];
    
}


@end
