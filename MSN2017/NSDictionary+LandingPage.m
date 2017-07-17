//
//  NSDictionary+LandingPage.m
//  MSN
//
//  Created by Yarima on 4/9/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "NSDictionary+LandingPage.h"

@implementation NSDictionary (LandingPage)

- (NSString *)LPPostID{
    NSString *str = self[@"id"];
    return str;
}

- (NSString *)LPTitle{
    
    NSString *str = self[@"title"];
    return str;
}

- (NSString *)LPContent{
    
    NSString *str = self[@"text"];
    if ([str length] == 0) {
        str = self[@"question"];
    }
    return str;
}

- (NSString *)LPImageUrl{
    
    NSString *str = self[@"cover"];
    return str;
}

- (NSString *)LPPublish_date{
    
    NSString *str = self[@"publish_date"];
    return str;
}

- (NSString *)LPCategoryId{
    
    //NSString *str = self[@"category"][@"id"];
    //return str;
    return @"";
}

- (NSString *)LPCategoryName{
    //NSString *str = self[@"categoryName"];
    //return str;
    NSArray *arr= self[@"category"];
    if ([arr count] > 0) {
        NSString *str = arr[0][@"name"];
        return str;
    }
    return @"";
}

- (NSString *)LPUserAvatarUrl{
    if ([self[@"entity"] count] > 0) {
        NSString *str = self[@"entity"][@"avatar"];
        return str;
    }
    return @"";
}

- (NSString *)LPUserTitle{
    if ([self[@"entity"] count] > 0) {
    NSString *str = self[@"entity"][@"name"];
    return str;
    }
    return @"";
}

- (NSString *)LPUserJobTitle{
    
    //NSString *str = self[@"user"][@"job_title"];
    return @"";//str;
}

- (NSString *)LPUserPageId{
    
    NSString *str = self[@"user"][@"page_id"];
    return str;
}

- (NSString *)LPUserEntity{
    
    NSString *str = self[@"user"][@"entity"];
    return str;
}

- (NSString *)LPUserEntityId{
    
    NSString *str = self[@"entity"][@"id"];
    return str;
}

- (NSInteger)LPLikes_count{
    
    NSInteger str = [self[@"like_count"]integerValue];
    return str;
}

- (NSString *)LPRecommends_count{
    
    NSString *str = self[@"comment_count"];
    str = [NSString stringWithFormat:@"%@", str];
    if ([str containsString:@"null"]) {
        return @"0";
    }
    return str;
}

- (NSString *)LPFavorites_count{
    
    NSString *str = self[@"favorites_count"];
    return str;
}

- (NSString *)LPLiked{
    
    NSString *str = self[@"liked"];
    return str;
}

- (NSString *)LPFavorite{
    
    NSString *str = self[@"favorite"];
    return str;
}

- (NSString *)LPRecommended{
    
    NSString *str = self[@"recommended"];
    return str;
}

- (NSArray *)LPTags{
    
    NSArray *str = self[@"tags"];
    return str;
}

- (NSArray *)LPvotingOptions{
    
    NSArray *str = self[@"options"];
    if ([str count] == 0) {
        return str = [[NSArray alloc]init];
    }
    return str;
}

- (NSString *)LPPostType{
    NSString *str = self[@"type"];
    return str;
}

- (NSString *)LPVideoUrl{
    NSString *str = self[@"video"];
    return str;
}

- (NSString *)LPAudioUrl{
    NSString *str = self[@"audio"];
    return str;
}

- (NSInteger)LPAudioSize{
    NSInteger str = [self[@"audio_size"]integerValue];
    return str;
}
- (NSInteger)LPVideoSize{
    NSInteger str = [self[@"video_size"]integerValue];
    return str;
}

- (NSString *)LPVideoSnapshot{
    NSString *str = self[@"video_snapshot"];
    return str;
}

- (NSString *)LPContentSummary{
    //NSString *str = self[@"content_summary"];
    return @"";//str;
}
- (NSString *)LPContentHTML{
    //NSString *str = self[@"content_html"];
    return @"";//str;
}

- (NSInteger)LPForeign_key{
    
    NSInteger str = [self[@"foreign_key"]integerValue];
    return str;
}

- (NSString *)LPFollow{
    
    NSString *str = self[@"follow"];
    return str;
}
@end
