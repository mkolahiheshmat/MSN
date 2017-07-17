//
//  NSDictionary+LandingPage.m
//  MSN
//
//  Created by Yarima on 4/9/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "NSDictionary+LandingPage.h"

@implementation NSDictionary (profile)
/*
 age = "-1";
 "blood_pressures" =     (
 );
 "blood_sugars" =     (
 );
 "blood_type" = n;
 email = "";
 "first_name" = "\U0628\U062f\U0648\U0646";
 height = "-1";
 id = 30276;
 "ideal_weight" = "-90";
 "is_main_profile" = 1;
 "is_married" = n;
 "last_name" = "\U0646\U0627\U0645";
 photo = "<null>";
 sex = "<null>";
 username = 09124059774;
 weights =     (
 );
 */
- (NSInteger)ageProfile{
     return [self[@"age"]integerValue];
}
- (NSArray *)BPArrayProfile{
    NSArray *arr = self[@"blood_pressures"];
    return arr;
}
- (NSArray *)BGArrayProfile{
    NSArray *arr = self[@"blood_sugars"];
    return arr;
}
- (NSArray *)weightsArrayProfile{
    NSArray *arr = self[@"weights"];
    return arr;
}
- (NSString *)blood_typeProfile{
    NSString *str = self[@"blood_type"];
    return str;
}
- (NSString *)emailProfile{
    NSString *str = self[@"email"];
    return str;
}
- (NSString *)first_nameProfile{
    NSString *str = self[@"first_name"];
    return str;
}
- (NSString *)last_nameProfile{
    NSString *str = self[@"last_name"];
    return str;
}
- (NSInteger)heightProfile{
    NSInteger str = [self[@"height"]integerValue];
    return str;
}
- (NSInteger)profileIdProfile{
    NSInteger str = [self[@"id"]integerValue];
    return str;
}
- (NSString *)ideal_weightProfile{
    NSString *str = self[@"ideal_weight"];
    return str;
}
- (NSInteger)is_main_profile{
    NSInteger str = [self[@"is_main_profile"]integerValue];
    return str;
}
- (NSString *)is_marriedProfile{
    NSString *str = self[@"is_married"];
    return str;
}
- (NSString *)photoProfile{
    NSString *str = self[@"photo"];
    return str;
}
- (NSString *)sexProfile{
    NSString *str = self[@"sex"];
    return str;
}

- (NSString *)usernameProfile{
    NSString *str = self[@"username"];
    return str;
}

- (NSString *)birthdate{
    NSString *str = self[@"birthDate"];
    return  str;
}
@end
