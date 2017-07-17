//
//  NSDictionary+LandingPage.m
//  MSN
//
//  Created by Yarima on 4/9/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "NSDictionary+LandingPage.h"

@implementation NSDictionary (consultation)
/*
 "consultation_id": 19314,
 "medical_section_id": 0,
 "profile_id": 30273,
 "created": "2016-04-20 12:26:17",
 "is_closed": 0,
 "answers": [
 {
 "answer_id": 10000019314,
 "message": "9",
 "is_user_message": true,
 "document_id": null,
 "document_url": null,
 "voice_url": null,
 "created": "2016-04-20 12:26:17",
 */
- (NSInteger)consultation_id{
    NSInteger str = [self[@"consultation_id"]integerValue];
    return str;
}

- (NSInteger)medical_section_id{
    
    NSInteger str = [self[@"medical_section_id"]integerValue];
    return str;
}

- (NSInteger)profile_id{
    
    NSInteger str = [self[@"profile_id"]integerValue];
    return str;
}

- (NSString *)created{
    
    NSString *str = self[@"created"];
    return str;
}

- (NSInteger)is_closed{
    
    NSInteger str = [self[@"is_closed"]integerValue];
    return str;
}

- (NSInteger)answer_id{
    
    NSInteger str = [self[@"answer_id"]integerValue];
    return str;
}

- (NSString *)messageText{
    
    NSString *str = self[@"message"];
    return str;
}

- (BOOL)is_user_message{
    
    NSString *str = self[@"is_user_message"];
    BOOL isthat = [str boolValue];
    return isthat;
}

- (NSString *)document_id{
    
    NSString *str = self[@"document_id"];
    return str;
}

- (NSString *)document_url{
    
    NSString *str = self[@"document_url"];
    return str;
}

- (NSString *)voice_url{
    
    NSString *str = self[@"voice_url"];
    return str;
}

- (NSArray *)answersArray{
    NSArray *array = self[@"answers"];
    return array;
}

- (NSDictionary *)doctorInfo{
    NSDictionary *dic = self[@"doctor"];
    return  dic;
}
@end
