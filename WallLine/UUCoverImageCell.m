//
//  UUCoverImageCell+UITableViewCell.m
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/02.
//
//

#import "UUCoverImageCell.h"

@implementation UUCoverImageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor             = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectionStyle              = UITableViewCellSelectionStyleNone;

        {
            
            UIBlockView* view = [[UIBlockView alloc] initWithFrame:self.contentView.bounds];
            view.backgroundColor = [UIColor clearColor];
            view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            view.blockDrawRect = ^(CGContextRef context, UIView* _view, CGRect dirtyRect) {
                CGRect bounds = _view.bounds;
                
                CGContextSetShadowWithColor(context, CGSizeMake(1.0f, -1.0f), 3.0f, HEXCOLOR(0x000000).CGColor);
                CGContextSetStrokeColorWithColor(context, COLOR_FOR_BACKGROUND_TABLE.CGColor);
                CGContextStrokeRect(context, CGRectMake(0, bounds.size.height, bounds.size.width, 0.5f));
            };
            [view setNeedsDisplay];
            [self.contentView addSubview:view];
        }
    }
    return self;
}


+ (UUCoverImageCell*) cell:(UITableView*)tableView
{
    static NSString* Identifier = @"UUCoverImageCell";
    UUCoverImageCell* cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil) {
        cell = [[UUCoverImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
    }
    return cell;
}



@end
