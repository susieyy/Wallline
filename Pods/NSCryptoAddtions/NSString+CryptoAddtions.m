//
//  NSString+CryptoAddtions.m
//

#import "NSString+CryptoAddtions.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (CryptoAddtions)

- (NSString *)stringAsMD5Hash
{    
	CC_MD5_CTX md5;
	CC_MD5_Init (&md5);
	CC_MD5_Update (&md5, [self UTF8String], [self length]);
    
	unsigned char digest[CC_MD5_DIGEST_LENGTH];
	CC_MD5_Final (digest, &md5);
	NSString *s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
				   digest[0],  digest[1], 
				   digest[2],  digest[3],
				   digest[4],  digest[5],
				   digest[6],  digest[7],
				   digest[8],  digest[9],
				   digest[10], digest[11],
				   digest[12], digest[13],
				   digest[14], digest[15]];
    
	return s;    
}

- (NSData *)dataAsMD5Hash
{    
	CC_MD5_CTX md5;
	CC_MD5_Init (&md5);
	CC_MD5_Update (&md5, [self UTF8String], [self length]);
    
	unsigned char digest[CC_MD5_DIGEST_LENGTH];
	CC_MD5_Final (digest, &md5);
    return [NSData dataWithBytes: digest length: CC_MD5_DIGEST_LENGTH];    
}

- (NSString *)stringAsSHA1
{
    const char *cStr = [self UTF8String];
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(cStr, strlen(cStr), result);
    NSString *s = [NSString  stringWithFormat:
                   @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                   result[0], result[1], result[2], result[3], result[4],
                   result[5], result[6], result[7],
                   result[8], result[9], result[10], result[11], result[12],
                   result[13], result[14], result[15],
                   result[16], result[17], result[18], result[19]
                   ];
    
    return [s lowercaseString];
}

- (NSData *)dataAsSHA1
{
    const char *cStr = [self UTF8String];
    unsigned char sha1_cStr[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1( cStr, strlen(cStr), sha1_cStr );
    return [NSData dataWithBytes: sha1_cStr length: CC_SHA1_DIGEST_LENGTH];
}


+ (NSString *)stringAsNonce;
{
    srand((unsigned)time(NULL));
    NSString* tmp = [NSString stringWithFormat:@"%d", rand()];
    NSString* nonce = [tmp stringAsSHA1]; 
    return nonce;
}

@end

