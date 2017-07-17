//
//  NSDictionary+LandingPage.h
//  MSN
//
//  Created by Yarima on 4/9/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (LandingPage)
- (NSString *)LPPostID;
- (NSString *)LPTitle;
- (NSString *)LPContent;
- (NSString *)LPImageUrl;
- (NSString *)LPPublish_date;
- (NSString *)LPCategoryId;
- (NSString *)LPCategoryName;
- (NSString *)LPUserAvatarUrl;
- (NSString *)LPUserTitle;
- (NSString *)LPUserJobTitle;
- (NSString *)LPUserPageId;
- (NSString *)LPUserEntity;
- (NSString *)LPUserEntityId;
- (NSInteger)LPLikes_count;
- (NSString *)LPRecommends_count;
- (NSString *)LPFavorites_count;
- (NSString *)LPLiked;
- (NSString *)LPFavorite;
- (NSString *)LPRecommended;
- (NSArray *)LPTags;
- (NSString *)LPPostType;
- (NSString *)LPVideoUrl;
- (NSString *)LPAudioUrl;
- (NSInteger)LPAudioSize;
- (NSInteger)LPVideoSize;
- (NSString *)LPContentSummary;
- (NSString *)LPContentHTML;
- (NSInteger)LPForeign_key;
- (NSString *)LPFollow;
- (NSString *)LPVideoSnapshot;
- (NSArray *)LPvotingOptions;
@end
