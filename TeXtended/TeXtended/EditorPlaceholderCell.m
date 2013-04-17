//
//  EditorPlaceholderCell.m
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 17.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "EditorPlaceholderCell.h"
#import "EditorPlaceholder.h"
#import "Constants.h"

@implementation EditorPlaceholderCell

- (id)initTextCell:(NSString *)aString {
    self = [super initTextCell:aString];
    if (self) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSFont *textFont = [NSUnarchiver unarchiveObjectWithData:[defaults valueForKey:TMT_EDITOR_FONT]];
        [dict setValue:textFont forKey:NSFontAttributeName];
        NSAttributedString *str = [[NSAttributedString alloc] initWithString:aString attributes:dict];
        [self setAttributedStringValue:str];
        [self setEditable:YES];
    }
    return self;
}


- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    NSColor *cellColor = [NSColor colorWithSRGBRed:169.0/255.0 green:176.0/255.0 blue:191.0/255.0 alpha:1.0];
    [cellColor set];
    //	NSRectFill(cellFrame);
	NSBezierPath *bp = [NSBezierPath bezierPath];
	NSRect irect = NSInsetRect(cellFrame, 3, 3);
	[bp appendBezierPathWithRoundedRect:NSMakeRect(irect.origin.x,
                                                   irect.origin.y,
                                                   irect.size.width,
                                                   irect.size.height)
                                xRadius:0.5*irect.size.height
                                yRadius:0.5*irect.size.height];
	
	[bp fill];
    [[NSColor colorWithSRGBRed:127.0/255.0 green:146.0/255.0 blue:182.0/255.0 alpha:1.0] set];
    [bp setLineWidth:1.0];
    [bp stroke];
    NSAttributedString *string = [self attributedStringValue];
    NSMutableAttributedString *smallerString = [[NSMutableAttributedString alloc] initWithAttributedString:string];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSFont *textFont = [NSUnarchiver unarchiveObjectWithData:[defaults valueForKey:TMT_EDITOR_FONT]];
    [smallerString addAttribute:NSFontAttributeName
                          value:[NSFont fontWithName:[textFont fontName] size:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]
                          range:NSMakeRange(0, [string length])];
    NSSize strSize = [smallerString size];
    NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [ps setAlignment:NSCenterTextAlignment];
    [smallerString addAttribute:NSParagraphStyleAttributeName value:ps range:NSMakeRange(0, [smallerString length])];
    NSRect r = NSMakeRect(irect.origin.x+(irect.size.width-strSize.width)/2.0,
                          irect.origin.y+(irect.size.height-strSize.height)/1.5,
                          strSize.width, strSize.height);
	[smallerString drawInRect:r];
}

- (NSSize)cellSize {
    NSAttributedString *str = [self attributedStringValue];
    NSSize size = [str size];
    return NSMakeSize(1.2*size.width, size.height);
}

- (NSPoint)cellBaselineOffset {
    return NSMakePoint(0, -6);
}

- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView atCharacterIndex:(NSUInteger)charIndex untilMouseUp:(BOOL)flag {
    NSLog(@"TRack");
    if ([controlView isKindOfClass:[NSTextView class]]) {
        NSTextView *tv = (NSTextView*)controlView;
        [tv setSelectedRange:NSMakeRange(charIndex, 1)];
    }
    
    return [super trackMouse:theEvent inRect:cellFrame ofView:controlView atCharacterIndex:charIndex untilMouseUp:flag];
}

@end
