//
//  FirstViewController.h
//  MSN
//
//  Created by Yarima on 11/5/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopicPageViewController : UIViewController
@property(nonatomic, retain)NSDictionary *dictionary;
@property(nonatomic, retain)NSString *postId;
@property(nonatomic, retain)NSString *tagName;
@property NSInteger tagIDx;
@property(nonatomic)BOOL isComingFromTags;
@end
