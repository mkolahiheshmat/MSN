//
//  FifthViewController.h
//  MSN
//
//  Created by Yarima on 11/5/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditMessageViewController : UIViewController
@property(nonatomic, retain)NSMutableArray *tableArray;
@property(nonatomic, retain)NSString *subjectString;
@property(nonatomic)NSInteger conversationID;
@property(nonatomic)BOOL isJustForShow;
@end
