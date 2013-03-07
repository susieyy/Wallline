//
//  NSString+PDRegexEsapce.m
//  RegexOnNSString
//
//  Created by Youhei Sugigami on 12/07/26.
//  Copyright (c) 2012年 PDAgent, LLC. All rights reserved.
//

#import "NSString+PDRegexEsapce.h"
#import "NSString+PDRegex.h"

@implementation NSString (PDRegexEsapce)

- (NSString*) escapeAsRegexWithIgnore:(NSString*)ignore
{
    NSString* r = @"¥*+.?{}()[]^$-|/";
    NSMutableString* rr = [NSMutableString string];
    [rr appendString:@"("];
    for (NSUInteger i = 0; i < r.length; i++) {
        NSString* c = [r substringWithRange:NSMakeRange(i, 1)];
        if ([ignore matchesPatternRegexPattern:[NSString stringWithFormat:@"\\%@", c]]) continue;
        
        [rr appendFormat:@"\\%@", c];
        if (i < r.length-1) {
            [rr appendString:@"|"];        
        }
    }
    [rr appendString:@")"];    
    return [self stringByReplacingRegexPattern:rr withString:@"\\\\$1"];
}

- (NSString*) escapeAsRegex
{
    return [self escapeAsRegexWithIgnore:nil];
}

@end
