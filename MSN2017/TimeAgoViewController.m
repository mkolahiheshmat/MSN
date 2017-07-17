//
//  TimeAgoViewController.m
//  HealthCloud
//
//  Created by Arash on 1/12/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "TimeAgoViewController.h"

@interface TimeAgoViewController ()

@end

@implementation TimeAgoViewController

//Constants
#define SECOND 1
#define MINUTE (60 * SECOND)
#define HOUR (60 * MINUTE)
#define DAY (24 * HOUR)
#define MONTH (30 * DAY)

+ (NSString*)timeIntervalWithStartDate:(NSDate*)d1 withEndDate:(NSDate*)d2
{
    //Calculate the delta in seconds between the two dates
    NSTimeInterval delta = [d2 timeIntervalSinceDate:d1];
    if (delta < 0) {
        return @"چند ثانیه پیش";
    }
    
    if (delta < 1 * MINUTE)
    {
        return delta == 1 ? @"یک ثانیه پیش" : [NSString stringWithFormat:@"%d ثانیه پیش", (int)delta];
    }
    if (delta < 2 * MINUTE)
    {
        return @"یک دقیقه پیش";
    }
    if (delta < 45 * MINUTE)
    {
        int minutes = floor((double)delta/MINUTE);
        return [NSString stringWithFormat:@"%d دقیقه قبل", minutes];
    }
    if (delta < 90 * MINUTE)
    {
        return @"یک ساعت پیش";
    }
    if (delta < 24 * HOUR)
    {
        int hours = floor((double)delta/HOUR);
        return [NSString stringWithFormat:@"%d ساعت پیش", hours];
    }
    if (delta < 48 * HOUR)
    {
        return @"دیروز";
    }
    if (delta < 30 * DAY)
    {
        int days = floor((double)delta/DAY);
        if (days >=30) {
            return [NSString stringWithFormat:@"۱ ماه قبل"];
        } else {
            int weeks = floor((double)days/7);
            if (weeks > 0 && weeks <=3) {
                return [NSString stringWithFormat:@"%d هفته پیش", weeks];
            }else
                return [NSString stringWithFormat:@"%d روز پیش", days];
        }
        
    }
    if (delta < 12 * MONTH)
    {
        int months = floor((double)delta/MONTH);
        return months <= 1 ? @"۱ ماه قبل" : [NSString stringWithFormat:@"%d ماه قبل", months];
    }
    else
    {
        int years = floor((double)delta/MONTH/12.0);
        return years <= 1 ? @"۱ سال قبل" : [NSString stringWithFormat:@"چند لحظه قبل"];
    }
}
@end
