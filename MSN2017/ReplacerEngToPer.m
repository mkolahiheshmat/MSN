//
//  ReplacerEngToPer.m
//  HafteSobh
//
//  Created by Arash Z. Jahangiri on 18/11/14.
//  Copyright (c) 2014 Arash Z. Jahangiri. All rights reserved.
//

#import "ReplacerEngToPer.h"

@implementation ReplacerEngToPer


+ (NSString *)replacer:(NSString *)tempStr

{
    if (![tempStr isEqual:[NSNull null]]) {
        NSString *s = tempStr;
        s = [s stringByReplacingOccurrencesOfString:@"١" withString:@"1"];
        s = [s stringByReplacingOccurrencesOfString:@"٢" withString:@"2"];
        s = [s stringByReplacingOccurrencesOfString:@"٣" withString:@"3"];
        s = [s stringByReplacingOccurrencesOfString:@"٤" withString:@"4"];
        s = [s stringByReplacingOccurrencesOfString:@"٥" withString:@"5"];
        s = [s stringByReplacingOccurrencesOfString:@"٦" withString:@"6"];
        s = [s stringByReplacingOccurrencesOfString:@"٧" withString:@"7"];
        s = [s stringByReplacingOccurrencesOfString:@"٨" withString:@"8"];
        s = [s stringByReplacingOccurrencesOfString:@"٩" withString:@"9"];
        s = [s stringByReplacingOccurrencesOfString:@"٠" withString:@"0"];
        tempStr = s;
        return tempStr;
        
    }
    
    return tempStr;
}

@end
