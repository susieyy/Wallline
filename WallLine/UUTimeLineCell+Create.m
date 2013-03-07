//
//  UUTimeLineCell+Create.m
//  Wallline
//
//  Created by 杉上 洋平 on 12/07/31.
//  Copyright (c) 2012年 個人事業主. All rights reserved.
//

#import "UUTimeLineCell+Create.h"
#import "UUTimeLineCell+Define.h"
#import "UUUserProfileButton.h"
#import "UIButton+TapDownTintImage.h"

#define COLOR_FOR_LABEL [UIColor clearColor]; 

@implementation UUTimeLineCell (Create)

- (void) updateFontSize
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSUInteger fontSize = [userDefaults integerForKey:@"FontSizeForTimeLine"];
    if (self.fontSizeLast == fontSize) return;
    
    self.labelForMessage.font = [UIFont fontWithName:FONT_NAME size:fontSize];
    self.labelForLink.font = [UIFont fontWithName:FONT_NAME size:fontSize-2];
    self.labelForDescription.font = [UIFont fontWithName:FONT_NAME size:fontSize-2];
    
    self.fontSizeLast = fontSize;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.contentView.backgroundColor = HEXCOLOR(0xFFFFFF);
        
        UIImage* imagepaper = [UIImage imageNamed:@"paper.png"];
        
        // back
        if (YES) {
            UIBlockView* view = [[UIBlockView alloc] initWithFrame:self.contentView.bounds];
            view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            view.blockDrawRect = ^(CGContextRef context, UIView* _view, CGRect dirtyRect) { 
                CGRect bounds = _view.bounds;
                CGContextDrawTiledImage(context, CGRectOfSize(imagepaper.size), imagepaper.CGImage);
                
                UIColor* color = HEXCOLOR(0xE9E6DF);
                CGContextSetStrokeColorWithColor(context, color.CGColor);
                CGContextStrokeRect(context, CGRectMake(0, 0, bounds.size.width, 1.0f));
                
                CGContextSetStrokeColorWithColor(context, color.CGColor);
                CGContextStrokeRect(context, CGRectMake(OFFSET_MARGIN + 30.0f/2, 0, 1.0f, bounds.size.height));
                
            };
            [view setNeedsDisplay];
            self.viewForBackground = view;
            [self.contentView addSubview:view];
        }
        
        // LinkLine
        {
            UIView* view = [[UIView alloc] initWithFrame:CGRectZero];
            view.backgroundColor = HEXCOLOR(0xE9E6DF);
            self.viewForLinkLine = view;
            [self.contentView addSubview:view];
        }
                
        // Date
        {
            UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
            label.textColor = HEXCOLOR(0x999999);
            label.font = [UIFont systemFontOfSize:10];
            label.lineBreakMode = UILineBreakModeTailTruncation;
            label.textAlignment = UITextAlignmentRight;
            label.backgroundColor = COLOR_FOR_LABEL;
            label.size = CGSizeMake(100.0f, 10.0f);
            [self.contentView addSubview:label];
            self.labelForDate = label;
        }
        
        // Message
        {            
            RTLabel* view = [[self class] rtlabel];
            view.delegate = self;
            view.size = CGSizeMake(WIDTH_FOR_TEXT, INT_MAX);
            [self.contentView addSubview:view];
            self.labelForMessage = view;
//            [view setLineSpacing:3.0f];
        }
        
        // Link
        {
            RTLabel* view = [[self class] rtlabel];
            view.delegate = self;
            view.size = CGSizeMake(WIDTH_FOR_TEXT-WIDTH_FOR_LINK_INDENT, INT_MAX);            
            [self.contentView addSubview:view];
            self.labelForLink = view;
            view.font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE_FOR_LINK];
//            [view setLineSpacing:2.0f];
        }
        
        // Description
        {
            RTLabel* view = [[self class] rtlabel];
            view.delegate = self;
            view.size = CGSizeMake(WIDTH_FOR_TEXT, INT_MAX);            
            [self.contentView addSubview:view];
            self.labelForDescription = view;
            view.textColor = HEXCOLOR(0x666666);
            view.font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE_FOR_DESCRIPTION];         
//            [view setLineSpacing:2.0f];
        }
        
        [self updateFontSize];

        // UserProfile
        {
            UUUserProfileButton* view = [[UUUserProfileButton alloc] initWithFrame:CGRectZero];
            view.isIconRounded = YES;
            [view tapDownTintImage];
            [view addTarget:self action:@selector(tapUserProfile:) forControlEvents:UIControlEventTouchUpInside];
            view.size = CGSizeMake(30, 30);
            self.buttonForUserProfile = view;
            [self.contentView addSubview:view];
        }
        
        // Picture
        {
            UIButton* view = [[UIButton alloc] initWithFrame:CGRectZero];
            view.backgroundColor = HEXCOLOR(0xE9E6DF);
            view.size = CGSizeMake(130.0f/2, 130.0f/2);
            [view tapDownTintImage];
            [view addTarget:self action:@selector(tapPicture:) forControlEvents:UIControlEventTouchUpInside];            
            view.contentMode = UIViewContentModeScaleAspectFit;            
            self.buttonForPicture = view;
            [self.contentView addSubview:view];            
        }
        
        // Photo
        {
            CGFloat margin = 1.0f;
            UIView* viewForTarget = nil;
            {                
                UIBlockView* view = [[UIBlockView alloc] initWithFrame:CGRectMake(0, 0, SIZE_FOR_ORIGIN_PHOTO/2 + margin *2, SIZE_FOR_ORIGIN_PHOTO/2 + margin *2)];
                view.userInteractionEnabled = YES;
                [self.contentView addSubview:view];
                self.viewForPhotoOuter = view;
                view.blockDrawRect = ^(CGContextRef context, UIView* _view, CGRect dirtyRect) { 
                    CGRect bounds = _view.bounds;
                    
                    CGContextSetFillColorWithColor(context, HEXCOLOR(0x999999).CGColor); 
                    CGContextFillRect(context, bounds);        
                    
                    CGRect rect = CGRectInset(bounds, 1, 1);
                    
                    CGContextSetFillColorWithColor(context, HEXCOLOR(0xEFEFEF).CGColor); 
                    CGContextFillRect(context, rect);        
                };
                [view setNeedsDisplay];
                viewForTarget = view;
            }
            {
                UIButton* view = [[UIButton alloc] initWithFrame:CGRectMake(margin, margin, SIZE_FOR_ORIGIN_PHOTO/2, SIZE_FOR_ORIGIN_PHOTO/2)];
                [view tapDownTintImage];
                [view addTarget:self action:@selector(tapPhoto:) forControlEvents:UIControlEventTouchUpInside];                
                //                view.contentMode = UIViewContentModeScaleAspectFit;
                self.buttonForPhoto = view;
                [viewForTarget addSubview:view];                          
            }
            {
                RTLabel* view = [[RTLabel alloc] initWithFrame:CGRectMake(0, 0, viewForTarget.width, 30)];
                self.labelForPhotoTags = view;
                
                view.backgroundColor = HEXCOLORA(0x00000033);
                view.textColor = HEXCOLOR(0x666666);
                view.delegate = self;
                view.font = [UIFont fontWithName:FONT_NAME size:10];         
                // [viewForTarget addSubview:view];
                
                NSMutableDictionary *linkAttributes = [NSMutableDictionary dictionary];
                [linkAttributes setObject:@"bold" forKey:@"style"];
                [linkAttributes setObject:@"#2B4584" forKey:@"color"];
                [linkAttributes setObject:@"0" forKey:@"underline"];
                
                NSMutableDictionary *selectedLinkAttributes = [NSMutableDictionary dictionary];
                [selectedLinkAttributes setObject:@"bold" forKey:@"style"];
                [selectedLinkAttributes setObject:@"#994584" forKey:@"color"];
                [selectedLinkAttributes setObject:@"0" forKey:@"underline"];
                
                [view setLinkAttributes:linkAttributes];
                [view setSelectedLinkAttributes:selectedLinkAttributes];
            }
        }
        
        // Buttons
        {
            UIImage* image = imagepaper;
            UIImage* imageHighlight = [imagepaper tintedImageUsingColor:[UIColor colorWithWhite:0.0 alpha:0.3]];
            
            
            CGFloat width = WIDTH_FOR_TEXT;
            CGFloat lineWidth = 2.0f;
            CGFloat buttonsWidth = WIDTH_FOR_TEXT - lineWidth * 3;
            UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, HEIGHT_FOR_BUTTONS)];
            view.backgroundColor = HEXCOLOR(0xE9E6DF);
            view.size = CGSizeMake(WIDTH_FOR_TEXT, HEIGHT_FOR_BUTTONS);
            [self.contentView addSubview:view];
            self.viewForButtonsOuter = view;


            {
                UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];                
                [button setTitleColor:COLOR_FOR_TEXT_LINK forState:UIControlStateNormal]; 
                [button setTitleColor:COLOR_FOR_TEXT_LINK_HIGHLIGHTED forState:UIControlStateHighlighted];                  
                [button setSize:CGSizeMake(buttonsWidth*2/3, HEIGHT_FOR_BUTTONS)];
                [button setBackgroundImage:image forState:UIControlStateNormal];                                    
                [button setBackgroundImage:imageHighlight forState:UIControlStateHighlighted];                    
                [view addSubview:button];
                
                button.left = lineWidth;
                
                UILabel* label = button.titleLabel;
                label.font = [UIFont fontWithName:FONT_NAME_BOLD size:12];
                
                self.buttonForComment = button;
                
                [button addTarget:self action:@selector(tapComment:) forControlEvents:UIControlEventTouchUpInside];                
            }
            {
                UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
                [button setTitleColor:COLOR_FOR_TEXT_LINK forState:UIControlStateNormal];
                [button setTitleColor:COLOR_FOR_TEXT_LINK_HIGHLIGHTED forState:UIControlStateHighlighted];
                [button setSize:CGSizeMake(buttonsWidth/3, HEIGHT_FOR_BUTTONS)];
                [button setBackgroundImage:image forState:UIControlStateNormal];
                [button setBackgroundImage:imageHighlight forState:UIControlStateHighlighted];
                [view addSubview:button];
                
                button.right = width - lineWidth;
                
                UILabel* label = button.titleLabel;
                label.font = [UIFont fontWithName:FONT_NAME_BOLD size:12];
                
                self.buttonForLike = button;
                
                [button addTarget:self action:@selector(tapLike:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
        
        // Action
        {
            UIImage* image = [[[UIImage imageNamed:@"add.png"] imageAsMaskedColor:HEXCOLOR(0xCCCCCC)] imageAsInnerResizeTo:CGSizeMake(60*0.60, 60*0.60)];            
            UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.size = CGSizeMake(30, 30);            
            [button addTarget:self action:@selector(doAction:) forControlEvents:UIControlEventTouchUpInside];
            [button setImage:image forState:UIControlStateNormal];
            self.buttonForAction = button;
            [self.contentView addSubview:button];
        }
        
        // Privacy
        {
            UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.size = CGSizeMake(30, 30);
            [button addTarget:self action:@selector(doPrivacyAction:) forControlEvents:UIControlEventTouchUpInside];
            self.buttonForPrivacy = button;
            [self.contentView addSubview:button];
        }
    }
    return self;
}

+ (RTLabel*) rtlabel
{
    UIColor* colorForBack = COLOR_FOR_LABEL;
    RTLabel* view = [[RTLabel alloc] initWithFrame:CGRectZero];    
    view.backgroundColor = colorForBack;
    view.textColor = COLOR_FOR_TEXT_BLACK;
    
    NSMutableDictionary *linkAttributes = [NSMutableDictionary dictionary];
    [linkAttributes setObject:@"bold" forKey:@"style"];
    [linkAttributes setObject:@"#2B4584" forKey:@"color"];
    [linkAttributes setObject:@"0" forKey:@"underline"];
    
    NSMutableDictionary *selectedLinkAttributes = [NSMutableDictionary dictionary];
    [selectedLinkAttributes setObject:@"bold" forKey:@"style"];
    [selectedLinkAttributes setObject:@"#994584" forKey:@"color"];
    [selectedLinkAttributes setObject:@"0" forKey:@"underline"];
    
    [view setLinkAttributes:linkAttributes];
    [view setSelectedLinkAttributes:selectedLinkAttributes];
    return view;
    
}


@end
