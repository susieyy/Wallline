//
//  NSString+PDRegexEsapce.h
//  RegexOnNSString
//
//  Created by Youhei Sugigami on 12/07/26.
//  Copyright (c) 2012年 PDAgent, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (PDRegexEsapce)

-(NSString *) escapeAsRegexWithIgnore:(NSString*)ignore;
-(NSString *) escapeAsRegex;

@end
