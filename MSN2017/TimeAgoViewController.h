//
//  TimeAgoViewController.h
//  HealthCloud
//
//  Created by Arash on 1/12/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeAgoViewController : NSObject
+ (NSString*)timeIntervalWithStartDate:(NSDate*)d1 withEndDate:(NSDate*)d2;
@end
