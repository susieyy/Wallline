//
//  MMAbstModel.h
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/03.
//
//

#import <Foundation/Foundation.h>

@interface MMAbstModel : NSObject <NSCoding>
@property (strong, nonatomic) NSMutableDictionary* data;
@property (strong, nonatomic) NSMutableArray* items;

- (id) initWithData:(NSDictionary*)data;
- (id) objectForKey:(NSString *)key;

- (NSDate*) dateFromString:(NSString*)value;

- (void) initializeData;
@end


@interface MMAbstModel (subscripts)
- (id)objectForKeyedSubscript:(id)key;
@end
