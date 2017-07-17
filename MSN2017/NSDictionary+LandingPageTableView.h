//
//  NSDictionary+LandingPageTableView.h
//  MSN
//
//  Created by Yarima on 4/12/16.
//  Copyright © 2016 Arash. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (LandingPageTableView)
- (NSString *)LPTVPostID;
- (NSString *)LPTVTitle;
- (NSString *)LPTVContent;
- (NSString *)LPTVImageUrl;
- (NSString *)LPTVPublish_date;
- (NSString *)LPTVCategoryId;
- (NSString *)LPTVCategoryName;
- (NSString *)LPTVUserAvatarUrl;
- (NSString *)LPTVUserTitle;
- (NSString *)LPTVUserJobTitle;
- (NSString *)LPTVUserPageId;
- (NSString *)LPTVUserEntity;
- (NSString *)LPTVUserEntityId;
- (NSString *)LPTVLikes_count;
- (NSString *)LPTVRecommends_count;
- (NSString *)LPTVFavorites_count;
- (NSString *)LPTVLiked;
- (NSString *)LPTVFavorite;
- (NSString *)LPTVRecommended;
- (NSArray *)LPTVTags;
- (NSString *)LPTVPostType;
- (NSString *)LPTVAudioUrl;
- (NSString *)LPTVVideoUrl;
- (NSInteger)LPTVAudioSize;
- (NSInteger)LPTVVideoSize;
- (NSString *)LPTVContentSummary;
- (NSString *)LPTVContentHTML;
- (NSString *)LPTVVideoSnapshot;
- (NSString *)LPTVvotingOptions;
@end
