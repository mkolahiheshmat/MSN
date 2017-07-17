//
//  UIView+Gradient.m
//  MSN
//
//  Created by Arash on 1/8/17.
//  Copyright © 2017 Arash. All rights reserved.
//

#import "UIView+Gradient.h"
#define GRADIENT_COLOR_1 [UIColor colorWithRed:73/255.0 green:191/255.0 blue:203/255.0 alpha:1.0]
#define GRADIENT_COLOR_2 [UIColor colorWithRed:96/255.0 green:147/255.0 blue:220/255.0 alpha:1.0]

@implementation UIView (Gradient)
- (void)makeGradient:(UIView *)aView{
    //UIView *view = [[UIView alloc] initWithFrame:aView.frame];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = aView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[GRADIENT_COLOR_1 CGColor], (id)[GRADIENT_COLOR_2 CGColor], nil];
    [aView.layer insertSublayer:gradient atIndex:0];
}
@end
