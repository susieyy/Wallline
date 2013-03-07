//
//  MMMeModel.m
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/08.
//
//

#import "MMMeModel.h"

@interface MMMeModel ()
@property (strong, nonatomic) FBRequestConnection* requestConnection;
@end

@implementation MMMeModel

+ (MMMeModel *) sharedManager
{
    static dispatch_once_t pred;
    static MMMeModel *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[MMMeModel alloc] init];
    });
    return shared;
}

- (id) init
{
	self = [super init];
	if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didLogout) name:NFDidLogout object:nil];
        self.data = [[self class] unarchive];
	}
	return self;
}

- (void) _didLogout
{
    SS_MLOG(self);
    NSString* path = [[UIApplication pathForDocuments] stringByAppendingPathComponent:@"me.dat"];
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma -
#pragma Archive

- (void) archive
{
    SS_MLOG(self);
    NSString* path = [[UIApplication pathForDocuments] stringByAppendingPathComponent:@"me.dat"];
    [NSKeyedArchiver archiveRootObject:self.data toFile:path];
}

+ (NSDictionary*) unarchive
{
    SS_MLOG(self);
    NSString* path = [[UIApplication pathForDocuments] stringByAppendingPathComponent:@"me.dat"];
    return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
}

@end
