//
//  FifthViewController.h
//  MSN
//
//  Created by Yarima on 11/5/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageDetailViewController : UIViewController
@property(nonatomic)NSInteger conversationId;
@property(nonatomic, retain)NSArray *participantsArray;
@property(nonatomic, copy)NSString *participantsString;
@property(nonatomic, copy)NSString *subjectString;
@end
