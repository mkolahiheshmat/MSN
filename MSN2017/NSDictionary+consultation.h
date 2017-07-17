//
//  NSDictionary+LandingPage.h
//  MSN
//
//  Created by Yarima on 4/9/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (consultation)
/*
 "consultation_id": 19381,
 "medical_section_id": 47,
 "profile_id": 30273,
 "created": "2016-05-09 10:12:34",
 "is_closed": 0,
 "answers": [
 {
 "answer_id": 10000019381,
 "message": "سلام جهت تست",
 "is_user_message": true,
 "document_id": null,
 "document_url": null,
 "voice_url": null,
 "created": "2016-05-09 10:12:34",
 "doctor": null
 },
 */
- (NSInteger)consultation_id;
- (NSInteger)medical_section_id;
- (NSInteger)profile_id;
- (NSString *)created;
- (NSInteger)is_closed;
- (NSInteger)answer_id;
- (NSString *)messageText;
- (BOOL)is_user_message;
- (NSString *)document_id;
- (NSString *)document_url;
- (NSString *)voice_url;
- (NSArray *)answersArray;
- (NSDictionary *)doctorInfo;
@end
