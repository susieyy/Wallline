//
//  MMCacheManager.m
//  Pickupps
//
//  Created by 杉上 洋平 on 12/06/01.
//  Copyright (c) 2012年 個人事業主. All rights reserved.
//

#import "MMCacheManager.h"

@interface MMCacheManager ()
@property (strong, nonatomic) NSMutableDictionary* caches;
@end


@implementation MMCacheManager


+ (MMCacheManager *) sharedManager 
{
    static dispatch_once_t pred;
    static MMCacheManager *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[MMCacheManager alloc] init];
    });
    return shared;
}

- (id) init
{
	self = [super init];
	if (self) {
		self.caches = [NSMutableDictionary dictionary];
	}
	return self;
}

- (NSCache*) cacheForKey:(NSString*)key;
{
    NSCache* cache = [self.caches valueForKey:key];
    if (cache == nil) {
        cache = [[NSCache alloc] init];
        cache.delegate = self;
        [self.caches setObject:cache forKey:key];
    }
    return cache;
}

#pragma -
#pragma NSCacheDelegate

- (void)cache:(NSCache *)cache willEvictObject:(id)obj;
{
    SS_MLOG(self);
    
    
}
@end
