//  Created by Arash on 9/2/16.
//  Copyright © 2017 Arash Z. Jahangiri. All rights reserved.
//

#import "NSString+FarsiTools.h"

@implementation NSString(FarsiTools)

- (NSString *)convertEnglishNumbersToFarsi
{
    NSString * retVal = [self copy];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"0" withString:@"۰"];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"1" withString:@"۱"];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"2" withString:@"۲"];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"3" withString:@"۳"];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"4" withString:@"۴"];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"5" withString:@"۵"];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"6" withString:@"۶"];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"7" withString:@"۷"];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"8" withString:@"۸"];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"9" withString:@"۹"];
    
    retVal = [retVal stringByReplacingOccurrencesOfString:@"٠" withString:@"۰"];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"١" withString:@"۱"];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"٢" withString:@"۲"];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"٣" withString:@"۳"];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"٤" withString:@"۴"];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"٥" withString:@"۵"];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"٦" withString:@"۶"];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"٧" withString:@"۷"];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"٨" withString:@"۸"];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"٩" withString:@"۹"];
    
    return retVal;
}

- (NSString *)convertArabicAndFarsiNumbersToEnglish
{
    NSString * retVal = [self copy];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"٠" withString:@"0"];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"١" withString:@"1"];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"٢" withString:@"2"];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"٣" withString:@"3"];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"٤" withString:@"4"];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"٥" withString:@"5"];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"٦" withString:@"6"];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"٧" withString:@"7"];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"٨" withString:@"8"];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"٩" withString:@"9"];
    
    retVal = [retVal stringByReplacingOccurrencesOfString:@"۰" withString:@"0"];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"۱" withString:@"1"];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"۲" withString:@"2"];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"۳" withString:@"3"];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"۴" withString:@"4"];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"۵" withString:@"5"];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"۶" withString:@"6"];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"۷" withString:@"7"];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"۸" withString:@"8"];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"۹" withString:@"9"];
    
    return retVal;
}

- (NSString *)arabicToFarsi
{
    NSString * arabic = [self copy];
    arabic = [arabic stringByReplacingOccurrencesOfString:@"ي" withString:@"ی"];
    arabic = [arabic stringByReplacingOccurrencesOfString:@"ى" withString:@"ی"];
    arabic = [arabic stringByReplacingOccurrencesOfString:@"ئ" withString:@"ی"];
    arabic = [arabic stringByReplacingOccurrencesOfString:@"ك" withString:@"ک"];
    arabic = [arabic stringByReplacingOccurrencesOfString:@"ة" withString:@"ت"];
    
    
    arabic = [arabic stringByReplacingOccurrencesOfString:@"٠" withString:@"۰"];
    arabic = [arabic stringByReplacingOccurrencesOfString:@"١" withString:@"۱"];
    arabic = [arabic stringByReplacingOccurrencesOfString:@"٢" withString:@"۲"];
    arabic = [arabic stringByReplacingOccurrencesOfString:@"٣" withString:@"۳"];
    arabic = [arabic stringByReplacingOccurrencesOfString:@"٤" withString:@"۴"];
    arabic = [arabic stringByReplacingOccurrencesOfString:@"٥" withString:@"۵"];
    arabic = [arabic stringByReplacingOccurrencesOfString:@"٦" withString:@"۶"];
    arabic = [arabic stringByReplacingOccurrencesOfString:@"٧" withString:@"۷"];
    arabic = [arabic stringByReplacingOccurrencesOfString:@"٨" withString:@"۸"];
    arabic = [arabic stringByReplacingOccurrencesOfString:@"٩" withString:@"۹"];
    return arabic;
}

@end
