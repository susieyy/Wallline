//
//  NSString+HREF.m
//  Wallline
//
//  Created by 杉上 洋平 on 12/07/19.
//  Copyright (c) 2012年 個人事業主. All rights reserved.
//

#import "NSString+HREF.h"

@implementation NSString (HREF)


- (NSString*) stringAsHREF;
{
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink | NSTextCheckingTypePhoneNumber error:nil]; 
    NSArray *matches = [detector matchesInString:self
                                         options:0
                                           range:NSMakeRange(0, self.length)];
    NSString* text = self;
    for (NSTextCheckingResult *match in matches) {
        if ([match resultType] == NSTextCheckingTypeLink) {
            NSURL *url = [match URL];
            NSString* link = [url absoluteString];
            NSString* atag = [NSString stringWithFormat:@"<a href='%@'>%@</a>", link, link];
            text = [self stringByReplacingOccurrencesOfString:link withString:atag];
            
        } else if ([match resultType] == NSTextCheckingTypePhoneNumber) {
            NSString *phoneNumber = [match phoneNumber];
            NSString* atag = [NSString stringWithFormat:@"<a href='%@'>%@</a>", phoneNumber, phoneNumber];                    
            text = [self stringByReplacingOccurrencesOfString:phoneNumber withString:atag];                    
        }
    }
    return text;
    
}

- (NSRegularExpression*) __regex
{
    static NSRegularExpression *_regex = nil;
    if (_regex == nil) {
        NSString *regexToReplaceRawLinks = @"(\\b(https?):\\/\\/[-A-Z0-9+&@#\\/%?=~_|!:,.;]*[-A-Z0-9+&@#\\/%=~_|])";           
        NSError *error = NULL;
        _regex = [NSRegularExpression regularExpressionWithPattern:regexToReplaceRawLinks
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
    }
    return _regex;    
}

- (NSString*) stringAsHREFWithRegex;
{
    NSRegularExpression* regex = [self __regex];               
    NSString *modifiedString = [regex stringByReplacingMatchesInString:self
                                                               options:0
                                                                 range:NSMakeRange(0, [self length])
                                                          withTemplate:@"<a href='$1'>$1</a>"];
    return modifiedString;
}

    
@end
