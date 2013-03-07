//
//  FBRequestConnection+SUSIEYY.m
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/11.
//
//

#import "FBRequestConnection+SUSIEYY.h"
#import "FBURLConnection.h"
#import "FBRequestConnection.h"


@interface MMBlockProgressWrapper : NSObject
@property (copy,   nonatomic) SSBlockConnectionProgress blockProgressFetch;
@property (copy,   nonatomic) SSBlockConnectionProgress blockProgressSend;
@property (copy,   nonatomic) NSString* UUID;
@property (nonatomic) float totalbytes;
@property (nonatomic) float loadedbytes;

+ (MMBlockProgressWrapper *) sharedManager;

@end

@implementation MMBlockProgressWrapper
@synthesize blockProgressFetch = _blockProgressFetch;
@synthesize totalbytes = _totalbytes;
@synthesize loadedbytes = _loadedbytes;
@synthesize UUID = _UUID;

+ (MMBlockProgressWrapper *) sharedManager
{
    static dispatch_once_t pred;
    static MMBlockProgressWrapper *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[MMBlockProgressWrapper alloc] init];
    });
    return shared;
}

@end
///////////////////////////////////////////////////////////////////////////////

@interface FBURLConnection ()
//@property (strong, nonatomic) MMBlockProgressWrapper *blockProgressFetchWrapper;
@end

@implementation FBURLConnection (SUSIEYY)
//-NO USE----
/*
- (MMBlockProgressWrapper*)blockProgressFetchWrapper
{
    NSString* name = NSStringFromSelector(_cmd);
    return objc_getAssociatedObject(self, [self associationKeyForPropertyName:name]);
}

- (void)setBlockProgressWrapper:(MMBlockProgressWrapper *)blockProgressFetchWrapper
{
    NSString* name = [NSStringFromSelector(_cmd) getterMethodString];
    objc_setAssociatedObject(self, [self associationKeyForPropertyName:name], blockProgressFetchWrapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
*/ 
//-NO USE----


// override
- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    [self performSelector:@selector(setResponse:) withObject:response];
    NSMutableData *_data = [self performSelector:@selector(data)];
    [_data setLength:0];
    
    //MMBlockProgressWrapper* blockProgressFetchWrapper = [self blockProgressFetchWrapper];
    MMBlockProgressWrapper* blockProgressFetchWrapper = [MMBlockProgressWrapper sharedManager];
    if (blockProgressFetchWrapper == nil || blockProgressFetchWrapper.blockProgressFetch == nil) return;
    
    NSString* UUID = [[self description] stringAsMD5Hash];
    if ([blockProgressFetchWrapper.UUID isEqualToString:UUID] == NO) return;
    
    NSHTTPURLResponse* res = response;
    SSLog(@"Response All Header %@", [res allHeaderFields]);
    NSNumber* contentLength = [[res allHeaderFields] objectForKey:@"Content-Length"];
    blockProgressFetchWrapper.totalbytes = [contentLength integerValue];
    blockProgressFetchWrapper.loadedbytes = 0.0f;
}

// override
- (void)connection:(NSURLResponse *)connection
    didReceiveData:(NSData *)data
{
    NSMutableData *_data = [self performSelector:@selector(data)];
    [_data appendData:data];
    
    //MMBlockProgressWrapper* blockProgressFetchWrapper = [self blockProgressFetchWrapper];
    MMBlockProgressWrapper* blockProgressFetchWrapper = [MMBlockProgressWrapper sharedManager];
    if (blockProgressFetchWrapper == nil || blockProgressFetchWrapper.blockProgressFetch == nil) return;
        
    NSString* UUID = [[self description] stringAsMD5Hash];
    if ([blockProgressFetchWrapper.UUID isEqualToString:UUID] == NO) return;
    blockProgressFetchWrapper.loadedbytes += [data length];
    float p = 0.0f;
    if (blockProgressFetchWrapper.totalbytes > 0.0f) {
        p =  blockProgressFetchWrapper.loadedbytes/blockProgressFetchWrapper.totalbytes;
    }
    blockProgressFetchWrapper.blockProgressFetch(p);
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite;
{
    MMBlockProgressWrapper* blockProgressFetchWrapper = [MMBlockProgressWrapper sharedManager];
    if (blockProgressFetchWrapper == nil || blockProgressFetchWrapper.blockProgressSend == nil) return;

    NSString* UUID = [[self description] stringAsMD5Hash];
    if ([blockProgressFetchWrapper.UUID isEqualToString:UUID] == NO) return;
    if (totalBytesExpectedToWrite == 0) return;
    
    blockProgressFetchWrapper.blockProgressSend(totalBytesWritten/totalBytesExpectedToWrite);
}
@end

///////////////////////////////////////////////////////////////////////////////

@interface FBRequestConnection ()

@end

@implementation FBRequestConnection (SUSIEYY)

- (void)startWithBlockProgress:(SSBlockConnectionProgress)blockProgress
{
    [self performSelector:@selector(startWithCacheIdentity:skipRoundtripIfCached:) withObject:nil withObject:@(NO)];
    
    if (blockProgress == nil) return;
    
    FBURLConnection* connection = [self performSelector:@selector(connection)];
    if (connection) {
        NSString* UUID = [[connection description] stringAsMD5Hash];
        MMBlockProgressWrapper* blockProgressFetchWrapper = [MMBlockProgressWrapper sharedManager];
        blockProgressFetchWrapper.blockProgressFetch = blockProgress;
        blockProgressFetchWrapper.UUID = UUID;
        //[connection setBlockProgressWrapper:blockProgressFetchWrapper];
    }
}

- (void)startWithBlockProgressSend:(SSBlockConnectionProgress)blockProgress
{
    [self performSelector:@selector(startWithCacheIdentity:skipRoundtripIfCached:) withObject:nil withObject:@(NO)];
    
    if (blockProgress == nil) return;
    
    FBURLConnection* connection = [self performSelector:@selector(connection)];
    if (connection) {
        NSString* UUID = [[connection description] stringAsMD5Hash];
        MMBlockProgressWrapper* blockProgressFetchWrapper = [MMBlockProgressWrapper sharedManager];
        blockProgressFetchWrapper.blockProgressSend = blockProgress;
        blockProgressFetchWrapper.UUID = UUID;
        //[connection setBlockProgressWrapper:blockProgressFetchWrapper];
    }
}


@end









