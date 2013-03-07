//
//  MMNameManager.m
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/17.
//
//

#import "MMNameManager.h"

@interface MMNameManager ()
@property (strong, nonatomic) NSMutableDictionary* data;
@end

@implementation MMNameManager
@synthesize data = _data;

+ (MMNameManager *) sharedManager
{
    static dispatch_once_t pred;
    static MMNameManager *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[MMNameManager alloc] init];
    });
    return shared;
}

- (id) init
{
	self = [super init];
	if (self) {
		self.data = [NSMutableDictionary dictionary];
	}
	return self;
}

- (void) setValue:(id)obj forKey:(NSString *)key;
{
    if ([key isKindOfClass:[NSNumber class]]) {
        NSNumber* n = key;
        key = [n stringValue];
    }
    [self.data setValue:obj forKey:key];
}

- (id) objectForKey:(NSString *)key;
{
    return [self.data objectForKey:key];
}

@end
