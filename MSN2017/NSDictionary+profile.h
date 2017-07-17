//
//  NSDictionary+LandingPage.h
//  MSN
//
//  Created by Yarima on 4/9/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (profile)
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
- (NSInteger)ageProfile;
- (NSArray *)BPArrayProfile;
- (NSArray *)BGArrayProfile;
- (NSArray *)weightsArrayProfile;
- (NSString *)blood_typeProfile;
- (NSString *)emailProfile;
- (NSString *)first_nameProfile;
- (NSString *)last_nameProfile;
- (NSInteger)heightProfile;
- (NSInteger)profileId;
- (NSString *)ideal_weightProfile;
- (NSInteger)is_main_profileProfile;
- (NSString *)is_marriedProfile;
- (NSString *)photoProfile;
- (NSString *)sexProfile;
- (NSString *)usernameProfile;
- (NSString *)birthdate;
@end
