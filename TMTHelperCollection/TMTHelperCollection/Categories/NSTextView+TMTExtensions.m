//
//  NSTextView+TMTExtensions.m
//  TMTHelperCollection
//
//  Created by Tobias Mende on 02.07.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "NSTextView+TMTExtensions.h"
#import "TMTLog.h"
@implementation NSTextView (TMTExtensions)




- (NSRange)visibleRange
{
    NSRect visibleRect = [self visibleRect];
    NSLayoutManager *lm = [self layoutManager];
    NSTextContainer *tc = [self textContainer];
    
    NSRange glyphVisibleRange = [lm glyphRangeForBoundingRect:visibleRect inTextContainer:tc];;
    NSRange charVisibleRange = [lm characterRangeForGlyphRange:glyphVisibleRange actualGlyphRange:nil];
    return charVisibleRange;
}

- (NSUInteger)currentCol
{
    return [self colForRange:self.selectedRange];
}

- (NSUInteger)colForRange:(NSRange)range
{
    NSUInteger location = 0;
    
    NSRange window = NSMakeRange(range.location, 1);
    while (window.location > 0 && NSMaxRange(window) < self.string.length) {
        if ([[self.string substringWithRange:window] isEqualToString:@"\n"]) {
            return location;
        } else {
            location++;
            window.location--;
        }
    }
    return location;
}

- (NSUInteger)characterIndexOfPoint:(NSPoint)aPoint
{
    NSUInteger glyphIndex;
    NSLayoutManager *layoutManager = [self layoutManager];
    CGFloat fraction;
    NSRange range;
    
    range = [layoutManager glyphRangeForTextContainer:[self textContainer]];
    aPoint.x -= [self textContainerOrigin].x;
    aPoint.y -= [self textContainerOrigin].y;
    glyphIndex = [layoutManager glyphIndexForPoint:aPoint
                                   inTextContainer:[self textContainer]
                    fractionOfDistanceThroughGlyph:&fraction];
    
    if (glyphIndex == NSMaxRange(range) - 1)
        return [[self textStorage]
                length];
    else return [layoutManager characterIndexForGlyphAtIndex:glyphIndex];
    
}


- (void)skipClosingBracket
{
    NSUInteger position = self.selectedRange.location;
    if (position < self.string.length) {
        NSRange r = NSMakeRange(position, 1);
        if ([[self.string substringWithRange:r] isEqualToString:@"}"]) {
            self.selectedRange = NSMakeRange(position + 1, 0);
        }
    }
}

#pragma mark - Line Getter

- (NSRect)lineRectforRange:(NSRange)r
{
    NSRange startLineRange = [self.string lineRangeForRange:NSMakeRange(r.location, 0)];
    NSInteger er = NSMaxRange(r) - 1;
    NSString *text = self.string;
    
    if (er >= [text length]) {
        return NSZeroRect;
    }
    if (er < r.location) {
        er = r.location;
    }
    
    NSRange endLineRange = [self.string lineRangeForRange:NSMakeRange(er, 0)];
    
    NSRange gr = [self.layoutManager glyphRangeForCharacterRange:NSMakeRange(startLineRange.location, NSMaxRange(endLineRange) - startLineRange.location - 1)
                                              actualCharacterRange:NULL];
    NSRect br = [self.layoutManager boundingRectForGlyphRange:gr inTextContainer:self.textContainer];
    NSRect b = self.bounds;
    CGFloat h = br.size.height;
    CGFloat w = b.size.width;
    CGFloat y = br.origin.y;
    NSPoint containerOrigin = self.textContainerOrigin;
    NSRect aRect = NSMakeRect(0, y, w, h);
    // Convert from view coordinates to container coordinates
    aRect = NSOffsetRect(aRect, containerOrigin.x, containerOrigin.y);
    return aRect;
}

@end
