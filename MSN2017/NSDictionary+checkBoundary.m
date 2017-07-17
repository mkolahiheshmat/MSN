//
//  NSMutableDictionary+checkBoundary.m
//  AvoidCrash
//
//  Created by Yarima on 5/23/17.
//  Copyright © 2017 Arash Z. Jahangiri. All rights reserved.
//

#import "NSDictionary+checkBoundary.h"

@implementation NSDictionary (checkBoundary)
- (id)myObjectForKey:(NSString*)key {
    
    id val = [self valueForKey:key];
    if([val isKindOfClass:[NSNull class]] ||
       val == [NSNull null] ||
       val == nil ||
       val == Nil ||
       val == NULL) {
        return self;
    }
    else {
        return val;
    }
    
}
@end
