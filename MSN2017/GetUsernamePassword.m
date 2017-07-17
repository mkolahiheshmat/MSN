//
//  GetUsernamePassword.m
//  MSN
//
//  Created by Yarima on 5/11/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "GetUsernamePassword.h"
#import "KeychainWrapper.h"
@implementation GetUsernamePassword

+ (NSDictionary *)getUsernamePassword{
    NSUserDefaults *defualt = [NSUserDefaults standardUserDefaults];
    NSString *username = [defualt objectForKey:@"mobile"];
    NSString *password = [defualt objectForKey:@"password"];
    NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:username, @"username", password, @"password", nil];
    return dic;
}

+ (NSString *)getUserId{
    NSUserDefaults *defualt = [NSUserDefaults standardUserDefaults];
    NSString *profileId = [defualt objectForKey:@"user_id"];
    return profileId;
}

+ (NSString *)getProfileId{
    NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:@"profileData"];
    NSDictionary *profileDic = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:data];
    //NSLog(@"%@", [profileDic objectForKey:@"id"]);
    return [profileDic objectForKey:@"id"];
}

+ (NSDictionary *)getProfileData{
    NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:@"profileData"];
    NSDictionary *profileDic = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:data];
    //NSLog(@"%@", profileDic);
    return profileDic;
}

+ (NSString *)getAccessToken{
    NSUserDefaults *defualt = [NSUserDefaults standardUserDefaults];
    NSString *accessToken = [defualt objectForKey:@"access_token"];
    return accessToken;
}
@end
