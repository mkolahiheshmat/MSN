//
//  UIView+Bubble.m
//  MSN
//
//  Created by Yarima on 12/7/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "UIView+Bubble.h"
#import "UIKit/UIKit.h"
@implementation UIView (Bubble)
+(UIView *)makeBubble:(CGRect)rect flipped:(BOOL)flipped color:(UIColor *)color{
    // declare UIimageView, not UIView
    UIImageView *customView = [[UIImageView alloc] init];
    customView.frame=rect;
    
    // create a new contex to draw
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(rect.size.width, rect.size.height), NO, 0);
    
    //// Rectangle Drawing
    //UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(0, 0, rect.size.width, rect.size.height) cornerRadius: 8];
    UIBezierPath* rectanglePath;
    if (!flipped) {
        rectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(0, 0, rect.size.width, rect.size.height) byRoundingCorners: UIRectCornerTopLeft | UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii: CGSizeMake(10, 10)];
    } else {
        rectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(0, 0, rect.size.width, rect.size.height) byRoundingCorners: UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii: CGSizeMake(10, 10)];
    }
    
    [color setFill];
    [rectanglePath fill];
    
    
    //// Bezier Drawing
    /*
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(rect.origin.x - 10, rect.origin.y + 3)];
    [bezierPath addCurveToPoint: CGPointMake(88.2, rect.origin.y +) controlPoint1: CGPointMake(87.85, 1.6) controlPoint2: CGPointMake(100.18, -2.85)];
    [bezierPath addCurveToPoint: CGPointMake(76.23, 10) controlPoint1: CGPointMake(76.23, 10) controlPoint2: CGPointMake(76.23, 10)];
    [UIColor.greenColor setFill];
    [bezierPath fill];
    */
    customView.image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return customView;
}

@end
