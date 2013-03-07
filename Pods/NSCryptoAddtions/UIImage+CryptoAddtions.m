//
//  UIImage+CryptoAddtions.m
//

#import "UIImage+CryptoAddtions.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSData+CryptoAddtions.h"


@implementation UIImage (CryptoAddtions)

- (NSString *)stringAsMD5Hash
{
    NSData* pngData = [[NSData alloc] initWithData:UIImagePNGRepresentation(self)];
    return [pngData stringAsMD5Hash];
}

@end