//
//  MMPhotoModel.h
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/21.
//
//

#import "MMAbstModel.h"

@interface MMPhotoModel : MMAbstModel

- (NSString*) albumID;

// Count
- (NSUInteger) countForLike;
- (NSUInteger) countForComment;

- (void) setLiked:(BOOL)isLiked;
- (BOOL) isLiked;

- (void) addComment:(NSString*)comment;

@end
