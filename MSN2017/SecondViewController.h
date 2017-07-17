//
//  SecondViewController.h
//  MSN
//
//  Created by Yarima on 11/5/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol testProtocol <NSObject>
- (void)testMethod;
@property(nonatomic, retain)NSString *testString;
@end

@interface SecondViewController : UIViewController
@property (nonatomic, strong) NSString *(^blockAsAMemberVar)(void);
@property(nonatomic, weak)id <testProtocol> delegate;
@end
