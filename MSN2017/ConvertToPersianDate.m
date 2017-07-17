//
//  ConvertToPersianDate.m
//  MSN
//
//  Created by Yarima on 5/8/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "ConvertToPersianDate.h"

@implementation ConvertToPersianDate
+(NSString*)ConvertToPersianDate:(NSString*) GeorgianDateTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"YYYY.MM.dd HH:mm:ss"];
    NSDate *dateFromString = [[NSDate alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"Asia/Tehran"]];
    dateFromString = [dateFormatter dateFromString:GeorgianDateTime];

    NSCalendar *persianCalender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierPersian];
    unsigned units = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitYearForWeekOfYear;
    NSDateComponents *componentsNow = [persianCalender components:units fromDate:dateFromString];
    
    NSString *year = [NSString stringWithFormat:@"%ld", (long)[componentsNow year]];
    NSString *month = [NSString stringWithFormat:@"%ld", (long)[componentsNow month]];
    NSString *day = [NSString stringWithFormat:@"%ld", (long)[componentsNow day]];
    
    /*
    [monthToPersianMonth setObject:@"فروردین" forKey:@"1"];
    [monthToPersianMonth setObject:@"اردیبهشت" forKey:@"2"];
    [monthToPersianMonth setObject:@"خرداد" forKey:@"3"];
    [monthToPersianMonth setObject:@"تیر" forKey:@"4"];
    [monthToPersianMonth setObject:@"مرداد"   forKey:@"5"];
    [monthToPersianMonth setObject:@"شهریور" forKey:@"6"];
    [monthToPersianMonth setObject:@"مهر" forKey:@"7"];
    [monthToPersianMonth setObject:@"آبان" forKey:@"8"];
    [monthToPersianMonth setObject:@"آذر" forKey:@"9"];
    [monthToPersianMonth setObject:@"دی" forKey:@"10"];
    [monthToPersianMonth setObject:@"بهمن" forKey:@"11"];
    [monthToPersianMonth setObject:@"اسفند" forKey:@"12"];
    */
    //month= [monthToPersianMonth objectForKey:month];
    
    NSString *PersianDate =[NSString stringWithFormat:@"%@ /%@ /%@",year, month, day];
    
    return PersianDate;
}

+(NSString*)ConvertToGregorianDateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day
{
    NSDateComponents *persiancomps = [[NSDateComponents alloc] init];
    [persiancomps setDay:day];
    [persiancomps setMonth:month];
    [persiancomps setYear:year];
    NSCalendar*       persianCal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierPersian];
    NSDate *date = [persianCal dateFromComponents:persiancomps];
    
    NSCalendar *gregorian= [[NSCalendar alloc]
                          initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSUInteger unitFlags = NSCalendarUnitDay | NSCalendarUnitMonth |
    NSCalendarUnitYear;
    NSDateComponents *components = [gregorian components:unitFlags fromDate:date];
    
    NSInteger daynum = [components day];
    NSInteger monthnum = [components month];
    NSInteger yearnum = [components year];
    
    //NSLog(@"%ld/%ld/%ld", (long)daynum, (long)monthnum, (long)yearnum);
    return [NSString stringWithFormat:@"%ld-%ld-%ld", (long)yearnum, (long)monthnum, (long)daynum];
}

+(NSString*)ConvertToPersianDateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day
{
    NSDateComponents *gregoriancomps = [[NSDateComponents alloc] init];
    [gregoriancomps setDay:day];
    [gregoriancomps setMonth:month];
    [gregoriancomps setYear:year];
    NSCalendar*       persianCal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date = [persianCal dateFromComponents:gregoriancomps];
    
    NSCalendar *gregorian= [[NSCalendar alloc]
                            initWithCalendarIdentifier:NSCalendarIdentifierPersian];
    NSUInteger unitFlags = NSCalendarUnitDay | NSCalendarUnitMonth |
    NSCalendarUnitYear;
    NSDateComponents *components = [gregorian components:unitFlags fromDate:date];
    
    
    NSString *yearstr = [NSString stringWithFormat:@"%ld", (long)[components year]];
    NSString *monthstr = [NSString stringWithFormat:@"%ld", (long)[components month]];
    NSString *daystr = [NSString stringWithFormat:@"%ld", (long)[components day]];
    
    NSMutableDictionary *monthToPersianMonth = [[NSMutableDictionary alloc] init];
    [monthToPersianMonth setObject:@"فروردین" forKey:@"1"];
    [monthToPersianMonth setObject:@"اردیبهشت" forKey:@"2"];
    [monthToPersianMonth setObject:@"خرداد" forKey:@"3"];
    [monthToPersianMonth setObject:@"تیر" forKey:@"4"];
    [monthToPersianMonth setObject:@"مرداد"   forKey:@"5"];
    [monthToPersianMonth setObject:@"شهریور" forKey:@"6"];
    [monthToPersianMonth setObject:@"مهر" forKey:@"7"];
    [monthToPersianMonth setObject:@"آبان" forKey:@"8"];
    [monthToPersianMonth setObject:@"آذر" forKey:@"9"];
    [monthToPersianMonth setObject:@"دی" forKey:@"10"];
    [monthToPersianMonth setObject:@"بهمن" forKey:@"11"];
    [monthToPersianMonth setObject:@"اسفند" forKey:@"12"];
    
    monthstr = [monthToPersianMonth objectForKey:monthstr];
    
    NSString *PersianDate = [daystr stringByAppendingFormat:@" %@ %@", monthstr, yearstr];
    
    return PersianDate;

}

+(NSString*)ConvertToPersianDate2:(NSString*) GeorgianDateTime
{
    //========>convert date to persian date===========//
    //NSDate *currDate = [NSDate alloc];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    // this is imporant - we set our input date format to match our input string
    // if format doesn't match you'll get nil from your string, so be careful];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
    // NSString *dateString = [dateFormatter stringFromDate:GeorgianDateTime];
    
    // [dateFormatter setCalendar:NSPersianCalendar];
    NSDate *dateFromString = [[NSDate alloc] init];
    // voila!
    //[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Iran"]];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"Asia/Tehran"]];
    
    
    
    
    dateFromString = [dateFormatter dateFromString:GeorgianDateTime];
    if (dateFromString == nil) {
        [dateFormatter setDateFormat:@"YYYY.MM.dd HH:mm:ss"];
        // NSString *dateString = [dateFormatter stringFromDate:GeorgianDateTime];
        
        // [dateFormatter setCalendar:NSPersianCalendar];
        dateFromString = [[NSDate alloc] init];
        // voila!
        //[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Iran"]];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"Asia/Tehran"]];
        dateFromString = [dateFormatter dateFromString:GeorgianDateTime];
    }
    ////////////Date////////////
    NSCalendar *persianCalender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierPersian];
    unsigned units = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitYearForWeekOfYear;
    //        NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    //        [dateFormatter2 setDateFormat:@"yyyy-MM-dd"];
    NSDateComponents *componentsNow = [persianCalender components:units fromDate:dateFromString];
    
    NSString *year = [NSString stringWithFormat:@"%ld", (long)[componentsNow year]];
    NSString *month = [NSString stringWithFormat:@"%ld", (long)[componentsNow month]];
    NSString *day = [NSString stringWithFormat:@"%ld", (long)[componentsNow day]];
    
    NSMutableDictionary *monthToPersianMonth = [[NSMutableDictionary alloc] init];
    [monthToPersianMonth setObject:@"فروردین" forKey:@"1"];
    [monthToPersianMonth setObject:@"اردیبهشت" forKey:@"2"];
    [monthToPersianMonth setObject:@"خرداد" forKey:@"3"];
    [monthToPersianMonth setObject:@"تیر" forKey:@"4"];
    [monthToPersianMonth setObject:@"مرداد"   forKey:@"5"];
    [monthToPersianMonth setObject:@"شهریور" forKey:@"6"];
    [monthToPersianMonth setObject:@"مهر" forKey:@"7"];
    [monthToPersianMonth setObject:@"آبان" forKey:@"8"];
    [monthToPersianMonth setObject:@"آذر" forKey:@"9"];
    [monthToPersianMonth setObject:@"دی" forKey:@"10"];
    [monthToPersianMonth setObject:@"بهمن" forKey:@"11"];
    [monthToPersianMonth setObject:@"اسفند" forKey:@"12"];
    
    month= [monthToPersianMonth objectForKey:month];
    
    NSString *PersianDate = [day stringByAppendingFormat:@" %@ %@", month, year];
    
    return PersianDate;
}

+(NSString*)ConvertToPersianDate3:(NSString*) GeorgianDateTime
{
    //========>convert date to persian date===========//
    //NSDate *currDate = [NSDate alloc];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    // this is imporant - we set our input date format to match our input string
    // if format doesn't match you'll get nil from your string, so be careful];
    [dateFormatter setDateFormat:@"YYYY.MM.dd HH:mm:ss"];
    // NSString *dateString = [dateFormatter stringFromDate:GeorgianDateTime];
    
    // [dateFormatter setCalendar:NSPersianCalendar];
    NSDate *dateFromString = [[NSDate alloc] init];
    // voila!
    //[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Iran"]];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"Asia/Tehran"]];
    
    
    
    
    dateFromString = [dateFormatter dateFromString:GeorgianDateTime];
    ////////////Date////////////
    NSCalendar *persianCalender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierPersian];
    unsigned units = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitYearForWeekOfYear;
    //        NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    //        [dateFormatter2 setDateFormat:@"yyyy-MM-dd"];
    NSDateComponents *componentsNow = [persianCalender components:units fromDate:dateFromString];
    
    NSString *year = [NSString stringWithFormat:@"%ld", (long)[componentsNow year]];
    NSString *month = [NSString stringWithFormat:@"%ld", (long)[componentsNow month]];
    NSString *day = [NSString stringWithFormat:@"%ld", (long)[componentsNow day]];
    
    NSMutableDictionary *monthToPersianMonth = [[NSMutableDictionary alloc] init];
    [monthToPersianMonth setObject:@"فروردین" forKey:@"1"];
    [monthToPersianMonth setObject:@"اردیبهشت" forKey:@"2"];
    [monthToPersianMonth setObject:@"خرداد" forKey:@"3"];
    [monthToPersianMonth setObject:@"تیر" forKey:@"4"];
    [monthToPersianMonth setObject:@"مرداد"   forKey:@"5"];
    [monthToPersianMonth setObject:@"شهریور" forKey:@"6"];
    [monthToPersianMonth setObject:@"مهر" forKey:@"7"];
    [monthToPersianMonth setObject:@"آبان" forKey:@"8"];
    [monthToPersianMonth setObject:@"آذر" forKey:@"9"];
    [monthToPersianMonth setObject:@"دی" forKey:@"10"];
    [monthToPersianMonth setObject:@"بهمن" forKey:@"11"];
    [monthToPersianMonth setObject:@"اسفند" forKey:@"12"];
    
    month= [monthToPersianMonth objectForKey:month];
    
    NSString *PersianDate = [day stringByAppendingFormat:@" %@ %@", month, year];
    
    return PersianDate;
}


+(NSInteger )getPersianYear:(NSString*) GeorgianDateTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"YYYY.MM.dd HH:mm:ss"];
    NSDate *dateFromString = [[NSDate alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"Asia/Tehran"]];
    dateFromString = [dateFormatter dateFromString:GeorgianDateTime];
    
    NSCalendar *persianCalender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierPersian];
    unsigned units = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitYearForWeekOfYear;
    NSDateComponents *componentsNow = [persianCalender components:units fromDate:dateFromString];
    
    NSInteger year = [componentsNow year];
    return year;
}

+(NSInteger )getPersianMonth:(NSString*) GeorgianDateTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"YYYY.MM.dd HH:mm:ss"];
    NSDate *dateFromString = [[NSDate alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"Asia/Tehran"]];
    dateFromString = [dateFormatter dateFromString:GeorgianDateTime];
    
    NSCalendar *persianCalender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierPersian];
    unsigned units = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitYearForWeekOfYear;
    NSDateComponents *componentsNow = [persianCalender components:units fromDate:dateFromString];
    
    NSInteger month = [componentsNow month];
    return month;
}

+(NSInteger )getPersianDay:(NSString*) GeorgianDateTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"YYYY.MM.dd HH:mm:ss"];
    NSDate *dateFromString = [[NSDate alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"Asia/Tehran"]];
    dateFromString = [dateFormatter dateFromString:GeorgianDateTime];
    
    NSCalendar *persianCalender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierPersian];
    unsigned units = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitYearForWeekOfYear;
    NSDateComponents *componentsNow = [persianCalender components:units fromDate:dateFromString];
    
    NSInteger day = [componentsNow day];
    return day;
}


@end
