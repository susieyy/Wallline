//
//  MMCacheManager.h
//  Pickupps
//
//  Created by 杉上 洋平 on 12/06/01.
//  Copyright (c) 2012年 個人事業主. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMCacheManager : NSObject <NSCacheDelegate>
+ (MMCacheManager *) sharedManager;

- (NSCache*) cacheForKey:(NSString*)key;

@end
