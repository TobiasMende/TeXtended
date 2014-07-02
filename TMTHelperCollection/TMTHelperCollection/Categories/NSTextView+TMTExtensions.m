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


#pragma mark - Undo Support


- (void)insertText:(NSAttributedString *)insertion
           atIndex:(NSUInteger)index
    withActionName:(NSString *)name
{
    if (index >= self.string.length) {
        [self.textStorage appendAttributedString:insertion];
    } else {
        [self.textStorage insertAttributedString:insertion atIndex:index];
    }
    [[self.undoManager prepareWithInvocationTarget:self] deleteTextInRange:[NSValue valueWithRange:NSMakeRange(index, insertion.length)] withActionName:name];
    [self.undoManager setActionName:name];
    [self didChangeText];
    
}

- (void)insertString:(NSString *)insertion atIndex:(NSUInteger)index withActionName:(NSString *)name
{
    NSDictionary *attributes;
    if (self.textStorage.length > 0 && index < self.string.length) {
        // Do nothing
        attributes = [self.textStorage attributesAtIndex:index effectiveRange:NULL];
    } else if (self.textStorage.length > 0 && index - 1 < self.string.length && index > 0) {
        attributes = [self.textStorage attributesAtIndex:index - 1 effectiveRange:NULL];
    } else {
        attributes = [[NSDictionary alloc] init];
    }
    NSAttributedString *final = [[NSAttributedString alloc] initWithString:insertion attributes:attributes];
    [self insertText:final atIndex:index withActionName:name];
}

- (void)deleteTextInRange:(NSValue *)rangeObject
           withActionName:(NSString *)name
{
    NSRange range = [rangeObject rangeValue];
    NSAttributedString *insertion = [self.textStorage attributedSubstringFromRange:range];
    
    [self.textStorage deleteCharactersInRange:range];
    [[self.undoManager prepareWithInvocationTarget:self] insertText:insertion atIndex:range.location withActionName:name];
    [self.undoManager setActionName:name];
    [self didChangeText];
}

- (void)setString:(NSString *)string withActionName:(NSString *)name
{
    [[self.undoManager prepareWithInvocationTarget:self] setString:[self.string copy] withActionName:name];
    [self.undoManager setActionName:name];
    [self setString:string];
}


#pragma mark - Text Swapping


- (NSRange)firstRangeAfterSwapping:(NSRange)first and:(NSRange)second
{
    if (second.length > first.length) {
        NSUInteger lengthDif = second.length - first.length;
        first.location = second.location + lengthDif;
        return first;
    } else if (first.length > second.length) {
        NSUInteger lengthDif = first.length - second.length;
        first.location = second.location - lengthDif;
        return first;
    }
    return second;
}

- (void)swapTextIn:(NSRange)first and:(NSRange)second
{
    if (first.location > second.location) {
        // Ensure that first range ist before second range
        NSRange tmp = first;
        first = second;
        second = tmp;
    }
    
    NSAttributedString *secondStr;
    if (second.length == 0) {
        NSUInteger pos = second.location > 0 ? second.location - 1 : 0;
        NSDictionary *attr = [self.textStorage attributesAtIndex:pos effectiveRange:NULL];
        secondStr = [[NSAttributedString alloc] initWithString:@"" attributes:attr];
    } else {
        
        secondStr = [self.textStorage attributedSubstringFromRange:second];
    }
    NSAttributedString *firstStr;
    if (first.length == 0) {
        NSUInteger pos = first.location > 0 ? first.location - 1 : 0;
        NSDictionary *attr = [self.textStorage attributesAtIndex:pos effectiveRange:NULL];
        firstStr = [[NSAttributedString alloc] initWithString:@"" attributes:attr];
    } else {
        
        firstStr = [self.textStorage attributedSubstringFromRange:first];
    }
    if (first.length == 0) {
        [self deleteTextInRange:[NSValue valueWithRange:second] withActionName:@""];
    } else {
        [self insertText:firstStr replacementRange:second];
    }
    if (second.length == 0) {
        [self deleteTextInRange:[NSValue valueWithRange:first] withActionName:@""];
    } else {
        [self insertText:secondStr replacementRange:first];
    }
    
}

@end
