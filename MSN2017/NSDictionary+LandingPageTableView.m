//
//  NSDictionary+LandingPageTableView.m
//  MSN
//
//  Created by Yarima on 4/12/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import "NSDictionary+LandingPageTableView.h"

@implementation NSDictionary (LandingPageTableView)
- (NSString *)LPTVPostID{
    NSString *str = self[@"postId"];
    return str;
}

- (NSString *)LPTVTitle{
    NSString *str = self[@"title"];
    return str;
}

- (NSString *)LPTVContent{
    NSString *str = self[@"content"];
    return str;
}

- (NSString *)LPTVImageUrl{
    NSString *str = self[@"imageUrl"];
    return str;
}

- (NSString *)LPTVPublish_date{
    NSString *str = self[@"publish_date"];
    return str;
}

- (NSString *)LPTVCategoryId{
    NSString *str = self[@"categoryId"];
    return str;
}

- (NSString *)LPTVCategoryName{
    NSString *str = self[@"categoryName"];
    return str;
}

- (NSString *)LPTVUserAvatarUrl{
    NSString *str = self[@"userAvatarUrl"];
    return str;
}

- (NSString *)LPTVUserTitle{
    NSString *str = self[@"userTitle"];
    return str;
}

- (NSString *)LPTVUserJobTitle{
    NSString *str = self[@"userJobTitle"];
    return str;
}

- (NSString *)LPTVUserPageId{
    NSString *str = self[@"userPageId"];
    return str;
}

- (NSString *)LPTVUserEntity{
    NSString *str = self[@"userEntity"];
    return str;
}

- (NSString *)LPTVUserEntityId{
    NSString *str = self[@"userEntityId"];
    return str;
}

- (NSString *)LPTVLikes_count{
    NSString *str = self[@"likesCount"];
    return str;
}

- (NSString *)LPTVRecommends_count{
    NSString *str = self[@"recommendsCount"];
    if ([str isEqualToString:@"(null)"]) {
        str = @"0";
    }
    return str;
}

- (NSString *)LPTVFavorites_count{
    NSString *str = self[@"favoritesCount"];
    return str;
}

- (NSString *)LPTVLiked{
    NSString *str = self[@"liked"];
    return str;
}

- (NSString *)LPTVFavorite{
    NSString *str = self[@"favorite"];
    return str;
}

- (NSString *)LPTVRecommended{
    NSString *str = self[@"recommended"];
    return str;
}

- (NSArray *)LPTVTags{
    NSArray *array = self[@"tags"];
    return array;
}

- (NSString *)LPTVvotingOptions{
    
    NSString *str = self[@"votingOptions"];
    return str;
}

- (NSString *)LPTVPostType{
    NSString *str = self[@"postType"];
    return str;
}

- (NSString *)LPTVAudioUrl{
    NSString *str = self[@"audioUrl"];
    return str;
}
- (NSString *)LPTVVideoUrl{
    NSString *str = self[@"videoUrl"];
    return str;
}
- (NSInteger)LPTVAudioSize{
    NSInteger str = [self[@"audioSize"]integerValue];
    return str;
}
- (NSInteger)LPTVVideoSize{
    NSInteger str = [self[@"videoSize"]integerValue];
    return str;
}

- (NSString *)LPTVContentSummary{
    NSString *str = self[@"content"];
    return str;
}
- (NSString *)LPTVContentHTML{
    NSString *str = self[@"post"][@"content_html"];
    return str;
}

- (NSString *)LPTVVideoSnapshot{
    NSString *str = self[@"videoSnapshot"];
    return str;
}
@end
