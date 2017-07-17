//
//  UITextField+toolbar.m
//  MSN2017
//
//  Created by Yarima on 5/6/17.
//  Copyright © 2017 Arash Z. Jahangiri. All rights reserved.
//

#import "UITextField+toolbar.h"

@implementation UITextField (toolbar)
- (void)addToolbar{
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"تایید"
                                                                      style:UIBarButtonItemStyleDone target:self action:@selector(dismissTextField)];
    //barButtonDone.tintColor = [UIColor whiteColor];
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           barButtonDone,
                           nil];    [numberToolbar sizeToFit];
    self.inputAccessoryView = numberToolbar;
}

- (void)dismissTextField{
    [self endEditing:YES];
}
@end
