//
//  NSString+CryptoAddtions.h
//

#import <Foundation/Foundation.h>

@interface NSString (CryptoAddtions)
- (NSString *) stringAsMD5Hash;
- (NSData *)dataAsMD5Hash;
- (NSString *) stringAsSHA1;
- (NSData *) dataAsSHA1;
+ (NSString *) stringAsNonce;
@end
