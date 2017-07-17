//
//  ShakeAnimation.h
//  AdvisorsHealthCloud
//
//  Created by Yarima on 12/8/15.
//  Copyright (c) 2015 Yarima. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface ShakeAnimation : NSObject
+ (void) startShake:(UIView*)view;
+ (void) shakeEnded:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
@end
