//
//  MMMeModel.h
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/08.
//
//

#import "MMAbstModel.h"

@interface MMMeModel : MMAbstModel

+ (MMMeModel *) sharedManager;

- (void) archive;
+ (NSDictionary*) unarchive;

@end
