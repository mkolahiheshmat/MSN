//
//  ConvertToPersianDate.h
//  MSN
//
//  Created by Yarima on 5/8/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConvertToPersianDate : NSObject
+(NSString*)ConvertToPersianDate:(NSString*)GeorgianDateTime;
+(NSString*)ConvertToPersianDate2:(NSString*) GeorgianDateTime;
+(NSString*)ConvertToPersianDate3:(NSString*) GeorgianDateTime;
+(NSInteger)getPersianYear:(NSString*) GeorgianDateTime;
+(NSInteger)getPersianMonth:(NSString*) GeorgianDateTime;
+(NSInteger)getPersianDay:(NSString*) GeorgianDateTime;
+(NSString*)ConvertToGregorianDateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;
+(NSString*)ConvertToPersianDateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;
@end
