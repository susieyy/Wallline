//
//  MMWebHistoryManager.h
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/24.
//
//

#import <Foundation/Foundation.h>

@interface MMWebHistoryManager : NSObject

@property (strong, nonatomic) NSMutableArray* items;
- (void) saveHistoryTitle:(NSString*)title URL:(NSURL*)URL;

@end
