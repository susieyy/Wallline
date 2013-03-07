//
//  MMWebHistoryManager.m
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/24.
//
//

#import "MMWebHistoryManager.h"

@implementation MMWebHistoryManager

- (id) init
{
	self = [super init];
	if (self) {
		self.items = [NSMutableArray arrayWithArray:[self unarchiveItems]];
	}
	return self;
}

- (void) archiveItems:(NSArray*)datas;
{
    SS_MLOG(self);
    if (datas == nil) return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString* path = [[UIApplication pathForDocuments] stringByAppendingPathComponent:@"webhistory.dat"];
        [NSKeyedArchiver archiveRootObject:datas toFile:path];
    });
}

- (NSArray*) unarchiveItems;
{
    SS_MLOG(self);
    NSString* path = [[UIApplication pathForDocuments] stringByAppendingPathComponent:@"webhistory.dat"];
    NSArray* array = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if (array == nil) array = @[];
    return array;
}

- (void) saveHistoryTitle:(NSString*)title URL:(NSURL*)URL;
{
    BOOL isExist = NO;
    for (NSDictionary* info in [self.items copy]) {
        NSURL* _URL = info[@"URL"];
        if ([[_URL absoluteString] isEqualToString:[URL absoluteString]]) {
            isExist = YES;
            [self.items removeObject:info];
            break;
        }
    }
    
    NSDictionary* info = @{@"title":title, @"URL":URL, @"date":[NSDate date]};
    [self.items addObject:info];
    
    [self archiveItems:self.items];
}

@end



