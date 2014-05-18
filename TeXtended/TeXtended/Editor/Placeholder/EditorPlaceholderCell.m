//
//  EditorPlaceholderCell.m
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 17.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "EditorPlaceholderCell.h"
#import "Constants.h"

@implementation EditorPlaceholderCell

    - (id)initTextCell:(NSString *)aString
    {
        self = [super initTextCell:aString];
        if (self) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

            NSFont *textFont = [NSFont fontWithName:[defaults valueForKey:TMT_EDITOR_FONT_NAME] size:[[defaults valueForKey:TMT_EDITOR_FONT_SIZE] floatValue]];
            [dict setValue:textFont forKey:NSFontAttributeName];
            NSAttributedString *str = [[NSAttributedString alloc] initWithString:aString attributes:dict];
            [self setAttributedStringValue:str];
            [self setEditable:NO];
        }
        return self;
    }


    - (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
    {
        [super drawWithFrame:cellFrame inView:controlView];
        NSColor *cellColor = [NSColor colorWithSRGBRed:169.0 / 255.0 green:176.0 / 255.0 blue:191.0 / 255.0 alpha:1.0];
        [cellColor set];
        //	NSRectFill(cellFrame);
        NSBezierPath *bp = [NSBezierPath bezierPath];
        NSRect irect = NSInsetRect(cellFrame, 3, 3);
        [bp appendBezierPathWithRoundedRect:NSMakeRect(irect.origin.x,
                irect.origin.y,
                irect.size.width,
                irect.size.height)
                                    xRadius:0.5 * irect.size.height
                                    yRadius:0.5 * irect.size.height];

        [bp fill];
        [[NSColor colorWithSRGBRed:127.0 / 255.0 green:146.0 / 255.0 blue:182.0 / 255.0 alpha:1.0] set];
        [bp setLineWidth:1.0];
        [bp stroke];
        NSAttributedString *string = [self attributedStringValue];
        NSMutableAttributedString *smallerString = [[NSMutableAttributedString alloc] initWithAttributedString:string];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSFont *textFont = [NSFont fontWithName:[defaults valueForKey:TMT_EDITOR_FONT_NAME] size:[[defaults valueForKey:TMT_EDITOR_FONT_SIZE] floatValue]];
        [smallerString addAttribute:NSFontAttributeName
                              value:[NSFont fontWithName:[textFont fontName] size:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]
                              range:NSMakeRange(0, [string length])];
        NSColor *textColor;
        if ([self isSelectedInRect:cellFrame ofView:controlView]) {
            textColor = [NSColor blackColor];
        } else {
            textColor = [NSColor whiteColor];
        }
        [smallerString addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, string.length)];
        NSSize strSize = [smallerString size];
        NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        [ps setAlignment:NSCenterTextAlignment];
        [smallerString addAttribute:NSParagraphStyleAttributeName value:ps range:NSMakeRange(0, [smallerString length])];
        NSRect r = NSMakeRect(irect.origin.x + (irect.size.width - strSize.width) / 2.0,
                irect.origin.y + (irect.size.height - strSize.height) / 1.5,
                strSize.width, strSize.height);
        [[NSColor blackColor] set];
        [smallerString drawInRect:r];
    }

    - (NSSize)cellSize
    {
        NSAttributedString *str = [self attributedStringValue];
        NSSize size = [str size];
        return NSMakeSize(1.2 * size.width, size.height);
    }

    - (NSPoint)cellBaselineOffset
    {
        return NSMakePoint(0, -6);
    }

    - (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView atCharacterIndex:(NSUInteger)charIndex untilMouseUp:(BOOL)flag
    {
        if ([controlView isKindOfClass:[NSTextView class]]) {
            NSTextView *tv = (NSTextView *) controlView;
            [tv setSelectedRange:NSMakeRange(charIndex, 1)];
        }

        return [super trackMouse:theEvent inRect:cellFrame ofView:controlView atCharacterIndex:charIndex untilMouseUp:flag];
    }

    - (BOOL)isSelectedInRect:(NSRect)cellFrame ofView:(NSView *)controlView
    {
        if ([controlView isKindOfClass:[NSTextView class]]) {
            NSTextView *tv = (NSTextView *) controlView;
            NSArray *ranges = [tv selectedRanges];
            for (id rangeObject in ranges) {
                NSRange range = [rangeObject rangeValue];
                NSRange glyphRange = [tv.layoutManager glyphRangeForCharacterRange:range actualCharacterRange:NULL];
                NSRect glyphRect = [tv.layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:tv.textContainer];
                if (NSPointInRect(cellFrame.origin, glyphRect)) {
                    return YES;
                }
            }

        }
        return NO;
    }

@end
