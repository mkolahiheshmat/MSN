//
//  NSDictionary+LandingPage.m
//  MSN
//
//  Created by Yarima on 4/9/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "NSDictionary+LandingPage.h"

@implementation NSDictionary (uploadDocs)
/*
 - (NSString *)docCreated;
 - (NSString *)docUrl;
 - (NSString *)docfileType;
 - (NSString *)docFile;
 - (NSString *)docID;
 - (NSString *)docName;
 - (NSString *)doProvider;
 - (NSString *)docRef_date;
*/
- (NSString *)docCreated{
    NSString *str = self[@"created"];
    return str;
}

- (NSString *)docUrl{
    
    NSString *str = self[@"file_url"];
    return str;
}

- (NSString *)docfileType{
    
    NSString *str = self[@"file_type"];
    return str;
}

- (NSString *)docFile{
    
    NSString *str = self[@"file"];
    return str;
}

- (NSString *)docID{
    
    NSString *str = self[@"id"];
    return str;
}

- (NSString *)docName{
    
    NSString *str = self[@"name"];
    return str;
}

- (NSString *)docProvider{
    
    NSString *str = self[@"provider"];
    return str;
}

- (NSString *)docRef_date{
    
    NSString *str = self[@"ref_date"];
    return str;
}

@end
