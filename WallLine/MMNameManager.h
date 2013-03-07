//
//  MMNameManager.h
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/17.
//
//

#import <Foundation/Foundation.h>

@interface MMNameManager : NSObject
+ (MMNameManager *) sharedManager ;

- (void) setValue:(id)obj forKey:(NSString *)key; // Key:ID Value:Name
- (id) objectForKey:(NSString *)key;

@end
