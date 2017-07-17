//
//  NSMutableArray+CheckBoundary.h
//  AvoidCrash
//
//  Created by Yarima on 5/23/17.
//  Copyright © 2017 Arash Z. Jahangiri. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (CheckBoundary)
- (id)myObjectAtIndex:(NSInteger)idx;
-(id)objectAtIndexedSubscript:(NSUInteger)idx;
@end
