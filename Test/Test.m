//
//  Test.m
//  Test
//
//  Created by 杉上 洋平 on 12/08/02.
//  Copyright (c) 2012年 個人事業主. All rights reserved.
//

#define KIWI_DISABLE_MACRO_API

#import "Kiwi.h"


@interface Hoge : NSFNanoObject

@end


#import "MMFacebookManager.h"

SPEC_BEGIN(NanoStore)

describe(@"Facebook", ^{
    context(@"praseURL", ^{
                
        ///////////////////////////////////////////////////////////////////////////////
        // Group
        it(@"is must group a", ^{
            NSString* url = @"http://www.facebook.com/groups/fbdevelopers/";
            NSURL* URL = [NSURL URLWithString:url];
            NSDictionary* info = [MMFacebookManager parseURL:URL];
            SSLog(@"    RESULT %@", [info description]);
            [[info[@"objectType"] should] equal:@"group"];
            [[info[@"ID"] should] equal:@"fbdevelopers"];         
            [info[@"SUBID"] shouldBeNil];
        });

        it(@"is must group b", ^{
            NSString* url = @"http://www.facebook.com/groups/ikuful/415086981861459/";
            NSURL* URL = [NSURL URLWithString:url];
            NSDictionary* info = [MMFacebookManager parseURL:URL];
            SSLog(@"    RESULT %@", [info description]);
            [[info[@"objectType"] should] equal:@"stream"];
            [[info[@"ID"] should] equal:@"415086981861459"];
            [info[@"SUBID"] shouldBeNil];
        });

        it(@"is must group c", ^{
            NSString* url = @"http://www.facebook.com/groups/ikuful/permalink/415086981861459/";
            NSURL* URL = [NSURL URLWithString:url];
            NSDictionary* info = [MMFacebookManager parseURL:URL];
            SSLog(@"    RESULT %@", [info description]);
            [[info[@"objectType"] should] equal:@"stream"];
            [[info[@"ID"] should] equal:@"415086981861459"];
            [info[@"SUBID"] shouldBeNil];
        });

        
        ///////////////////////////////////////////////////////////////////////////////
        // Event
        it(@"is must event a", ^{
            NSString* url = @"http://www.facebook.com/events/126173984192567";
            NSURL* URL = [NSURL URLWithString:url];
            NSDictionary* info = [MMFacebookManager parseURL:URL];
            SSLog(@"    RESULT %@", [info description]);
            [[info[@"objectType"] should] equal:@"event"];
            [[info[@"ID"] should] equal:@"126173984192567"];
            [info[@"SUBID"] shouldBeNil];
        });

        it(@"is must event b", ^{
            NSString* url = @"http://www.facebook.com/events/126173984192567/permalink/126615834148382/";
            NSURL* URL = [NSURL URLWithString:url];
            NSDictionary* info = [MMFacebookManager parseURL:URL];
            SSLog(@"    RESULT %@", [info description]);
            [[info[@"objectType"] should] equal:@"event"];
            [[info[@"ID"] should] equal:@"126173984192567"];
            [[info[@"SUBID"] should] equal:@"126615834148382"];
        });

        ///////////////////////////////////////////////////////////////////////////////
        // Page app
        it(@"is must page app", ^{
            NSString* url = @"https://www.facebook.com/jwave813fm/app_334096056680321";
            NSURL* URL = [NSURL URLWithString:url];
            NSDictionary* info = [MMFacebookManager parseURL:URL];
            SSLog(@"    RESULT %@", [info description]);
            [info shouldBeNil];
        });

        ///////////////////////////////////////////////////////////////////////////////
        // Friend or Page
        it(@"is must friend or page (friend)", ^{
            NSString* url = @"http://www.facebook.com/mariko.nishijima.9";
            NSURL* URL = [NSURL URLWithString:url];
            NSDictionary* info = [MMFacebookManager parseURL:URL];
            SSLog(@"    RESULT %@", [info description]);
            [[info[@"objectType"] should] equal:@"friend_or_page"];
            [[info[@"ID"] should] equal:@"mariko.nishijima.9"];
            [info[@"SUBID"] shouldBeNil];
        });

        it(@"is must friend or page (friend with ref=nf)", ^{
            NSString* url = @"http://www.facebook.com/kijimasashi?ref=nf";
            NSURL* URL = [NSURL URLWithString:url];
            NSDictionary* info = [MMFacebookManager parseURL:URL];
            SSLog(@"    RESULT %@", [info description]);
            [[info[@"objectType"] should] equal:@"friend_or_page"];
            [[info[@"ID"] should] equal:@"kijimasashi"];
            [info[@"SUBID"] shouldBeNil];
        });

        it(@"is must friend or page (friend with ref=nf_fr)", ^{
            NSString* url = @"http://www.facebook.com/kijimasashi?ref=nf_fr";
            NSURL* URL = [NSURL URLWithString:url];
            NSDictionary* info = [MMFacebookManager parseURL:URL];
            SSLog(@"    RESULT %@", [info description]);
            [[info[@"objectType"] should] equal:@"friend_or_page"];
            [[info[@"ID"] should] equal:@"kijimasashi"];
            [info[@"SUBID"] shouldBeNil];
        });
        

        ///////////////////////////////////////////////////////////////////////////////
        // Stream Friend
        it(@"is must stream need alias to id", ^{
            NSString* url = @"http://www.facebook.com/yasuhiro.fujii/posts/367546739981441";
            NSURL* URL = [NSURL URLWithString:url];
            NSDictionary* info = [MMFacebookManager parseURL:URL];
            SSLog(@"    RESULT %@", [info description]);
            [[info[@"objectType"] should] equal:@"stream"];
            [[info[@"ID"] should] equal:@"yasuhiro.fujii"];
            [[info[@"SUBID"] should] equal:@"367546739981441"];
        });

        it(@"is must stream", ^{
            NSString* url = @"http://www.facebook.com/100002395383603/posts/367546739981441";
            NSURL* URL = [NSURL URLWithString:url];
            NSDictionary* info = [MMFacebookManager parseURL:URL];
            SSLog(@"    RESULT %@", [info description]);
            [[info[@"objectType"] should] equal:@"stream"];
            [[info[@"ID"] should] equal:@"100002395383603_367546739981441"];
            [info[@"SUBID"] shouldBeNil];
        });

/*
        it(@"is must friend b", ^{
            NSString* url = @"http://www.facebook.com/100002395383603";
            NSURL* URL = [NSURL URLWithString:url];
            NSDictionary* info = [MMFacebookManager parseURL:URL];
            SSLog(@"    RESULT %@", [info description]);
            [[info[@"objectType"] should] equal:@"friend"];
            [[info[@"ID"] should] equal:@"100002395383603"];
            [info[@"SUBID"] shouldBeNil];
        });
        */

        ///////////////////////////////////////////////////////////////////////////////
        // Photo
        it(@"is must photo a", ^{
            NSString* url = @"http://www.facebook.com/photo.php?fbid=10151068382269153&set=a.10150268493399153.339817.822384152&type=1";
            NSURL* URL = [NSURL URLWithString:url];
            NSDictionary* info = [MMFacebookManager parseURL:URL];
            SSLog(@"    RESULT %@", [info description]);
            [[info[@"objectType"] should] equal:@"photo"];
            [[info[@"ID"] should] equal:@"10151068382269153"];
            [info[@"SUBID"] shouldBeNil];
        });

        it(@"is must photo b", ^{
            NSString* url = @"http://www.facebook.com/photo.php?fbid=10151068382269153&set=a.10150268493399153.339817.822384152&type=1&comment_id=7275798";
            NSURL* URL = [NSURL URLWithString:url];
            NSDictionary* info = [MMFacebookManager parseURL:URL];
            SSLog(@"    RESULT %@", [info description]);
            [[info[@"objectType"] should] equal:@"photo"];
            [[info[@"ID"] should] equal:@"10151068382269153"];
            [[info[@"SUBID"] should] equal:@"7275798"];
        });

    });
});

describe(@"NanoStore", ^{
    context(@"create ", ^{
        
        beforeAll(^{ // Occurs once
            NSFSetIsDebugOn(YES);            
            
            NSString *path = [[UIApplication pathForDocuments] stringByAppendingPathComponent:@"data.sql"];
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        });
        
        it(@"get user name to collect", ^{
            NSString *path = [[UIApplication pathForDocuments] stringByAppendingPathComponent:@"data.sql"];
            NSError * error = nil;
            NSFNanoStore *nanoStore = [NSFNanoStore createAndOpenStoreWithType:NSFPersistentStoreType path:path error:&error];            
            [nanoStore shouldNotBeNil];
            
            BOOL isOpend = [nanoStore openWithError:nil];
            [[theValue(isOpend) should] beYes];
            
            {
                NSDictionary *info = @{@"key":@"hoge1"};
                NSFNanoObject *object = [NSFNanoObject nanoObjectWithDictionary:info];
                [nanoStore addObject:object error:nil];
            }
            {
                NSDictionary *info = @{@"key":@"hoge2"};
                NSFNanoObject *object = [NSFNanoObject nanoObjectWithDictionary:info];
                [nanoStore addObject:object error:nil];
            }
            
            [nanoStore saveStoreAndReturnError:&error];
            
            
            NSFNanoSearch *search = [NSFNanoSearch searchWithStore:nanoStore];
            NSDictionary *objects = [search searchObjectsWithReturnType:NSFReturnObjects error:&error];
            for (NSFNanoObject *object in objects.allValues) {
                NSLog([object description]);
                NSLog([[object info] description]);
            }
        });
    });
});


SPEC_END