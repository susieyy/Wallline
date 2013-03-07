//
//  MMEventModel.m
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/03.
//
//

#import "MMEventModel.h"

@implementation MMEventModel

- (id) initWithData:(NSDictionary*)data
{
	self = [super initWithData:data ];
	if (self) {
        self.items = [NSMutableArray array];
        
        if (self.data[@"name"]) {
            NSString* name = NSLocalizedString(@"Name", @"");
            NSString* detail = self.data[@"name"];
            [self.items addObject:@{@"name":name, @"detail":detail}];
        }

        if (self.data[@"owner"]) {
            NSString* event = [NSString stringWithFormat:@"%@ Event", [self.data[@"privacy"] capitalizedString]];
            NSString* privacy = NSLocalizedString(event, @"");
            NSString* name = NSLocalizedString(@"Owner", @"");
            NSString* detail = [NSString stringWithFormat:@"%@ / <a href='friend://%@'>%@</a>",
                      privacy,
                      self.data[@"owner"][@"id"],
                      self.data[@"owner"][@"name"]];

            
            [self.items addObject:@{@"name":name, @"detail":detail}];
        }

        if (self.data[@"start_time"]) {
            NSString* name = NSLocalizedString(@"StartTime", @"");
            NSString* time = self.data[@"start_time"];
            NSDate* date = [self dateFromString:time];
            NSDateFormatter* df = [[NSDateFormatter alloc] init];
            df.dateFormat = @"MM/dd (E)";
            NSString* detail = [df stringFromDate:date];
            [self.items addObject:@{@"name":name, @"detail":detail}];
        }
        
        if (self.data[@"location"]) {
            NSString* name = NSLocalizedString(@"Location", @"");
            NSString* detail = self.data[@"location"];
            [self.items addObject:@{@"name":name, @"detail":detail}];
        }
        
        if (self.data[@"description"]) {
            NSString* name = NSLocalizedString(@"Description", @"");
            NSString* detail = [self.data[@"description"] stringAsHREFWithRegex];
            [self.items addObject:@{@"name":name, @"detail":detail}];
        }
    }
    return self;
}

@end

/*
{
    description = "\U6075\U6bd4\U5bff\U306e\U30ae\U30e3\U30e9\U30ea\U30fcMalle\U3055\U3093\U3067\U3001\n\Uff16\U4eba\U306e\U4f5c\U5bb6\U306b\U3088\U308b\U30b0\U30eb\U30fc\U30d7\U5c55\U306b\U53c2\U52a0\U3057\U307e\U3059\U3002\n\n\U4eca\U56de\U3001\U521d\U3081\U307e\U3057\U3066\U306e\U4f5c\U5bb6\U3055\U3093\U540c\U58eb\U306e\U30b0\U30eb\U30fc\U30d7\U5c55\U3002\n\U305d\U308c\U305e\U308c\U3001\U3069\U3093\U306a\U30c9\U30e9\U30a4\U30d6\U306b\U306a\U308b\U306e\U304b\U3001\U305c\U3072\U898b\U306b\U6765\U3066\U4e0b\U3055\U3044\Uff01\n\n\U79c1\U306f\Uff15\U70b9\U51fa\U54c1\U3057\U3066\U307e\U3059\U3002\n\U5728\U5eca\U306e\U65e5\U306f\U300131\U65e5\Uff08\U706b\Uff09\U3001\Uff14\Uff08\U571f\Uff09\U3001\Uff15\Uff08\U65e5\Uff09\n\U305d\U306e\U4ed6\U306e\U65e5\U3082\U5b50\U9023\U308c\U3067\U3077\U3089\U3063\U3068\U884c\U304d\U307e\U3059\U3002\n\n\U53c2\U52a0\U4f5c\U5bb6\Uff0850\U97f3\U9806\Uff09\Uff1a\U3044\U3061\U4e38\U3000\U7a32\U5dba\U771f\U5b50\U3000\U304a\U304c\U308f\U3053\U3046\U3078\U3044\n\U3000\U3000\U3000\U3000\U3000\U3000\U3000\U3000\U3000\U3000\U5c0f\U5ddd\U771f\U4e8c\U90ce\U3000\U6c34\U91ce\U670b\U5b50\U3000\U5c71\U672c\U7965\U5b50\n\n\U4f1a\U5834\Uff1a\U30ae\U30e3\U30e9\U30ea\U30fcMalle(JR\U6075\U6bd4\U5bff\U99c5\U6771\U53e3\U4e0b\U8eca\U5f92\U6b69\Uff13\U5206\Uff09\n\n\U4f1a\U671f\Uff1a2012\U5e747/31\Uff08\U706b\Uff09\U301c8/5\Uff08\U65e5\Uff0912\Uff1a00\U301c19\Uff1a00\Uff08\U6700\U7d42\U65e5\U301c16\Uff1a00\Uff09\n\nhttp://galeriemalle.jp/";
    "end_time" = "2012-08-01T02:00:00";
    id = 181461661987489;
    location = "\U30ae\U30e3\U30e9\U30ea\U30fc\U307e\U3041\U308b";
    name = "\U30c9\U30e9\U30a4\U30d6\U3057\U3088\U3046\U3088\U3002at \U30ae\U30e3\U30e9\U30ea\U30fc\U307e\U3041\U308b";
    owner =     {
        id = 100002699650482;
        name = "\U7a32\U5dba \U771f\U5b50";
    };
    privacy = OPEN;
    "start_time" = "2012-07-31T02:00:00";
    "updated_time" = "2012-07-30T22:51:50+0000";
    venue =     {
        id = 313557935346843;
    };
    
}
*/
