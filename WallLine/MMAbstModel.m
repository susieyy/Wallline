//
//  MMAbstModel.m
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/03.
//
//

#import "MMAbstModel.h"

@implementation MMAbstModel

- (void) initializeData;
{
    
}

- (id) initWithData:(NSDictionary*)data
{
	self = [super init];
	if (self) {
		self.data = [NSMutableDictionary dictionaryWithDictionary:data];
        [self initializeData];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super init]) {
        self.data = [coder decodeObjectForKey:@"data"];
        self.items = [coder decodeObjectForKey:@"items"];        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    if (self.data) {
        [coder encodeObject:self.data forKey:@"data"];
    }
    if (self.items) {
        [coder encodeObject:self.items forKey:@"items"];
    }
}

- (NSString*) description
{
    return @"";
    NSError* error = nil;
    NSData* _data = [NSJSONSerialization dataWithJSONObject:self.data options:NSJSONWritingPrettyPrinted error:&error];
    NSString* json = [NSString stringWithDataAsUTF8:_data];
    return [NSString stringWithFormat:@"%@ %@", [super description], json];
}

- (id) objectForKey:(NSString *)key
{
    return [self.data objectForKey:key];
}

- (NSDate*) dateFromString:(NSString*)value
{
    if (value == nil) return nil;
    //2012-07-31T02:00:00
    //2010-12-01T21:35:43+0000
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    if (value.length == 19) {
        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];        
    } else {
        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
    }
    NSDate* date = [df dateFromString:value];
    return date;
}
@end

@implementation MMAbstModel (subscripts)

- (id)objectForKeyedSubscript:(id)key;
{
    return [self objectForKey:key];
}

@end
