//
//  GetUsernamePassword.h
//  MSN
//
//  Created by Yarima on 5/11/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetUsernamePassword : NSObject
+ (NSDictionary *)getUsernamePassword;
+ (NSString *)getUserId;
+ (NSString *)getProfileId;
+ (NSDictionary *)getProfileData;
+ (NSString *)getAccessToken;
@end
