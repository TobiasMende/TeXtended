//
//  NSTextView+TMTEditorExtension.m
//  TeXtended
//
//  Created by Tobias Mende on 02.07.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "NSTextView+TMTEditorExtension.h"
#import "NSString+TMTEditorExtensions.h"
#import "EditorPlaceholder.h"
#import <TMTHelperCollection/NSTextView+TMTExtensions.h>

static const NSRegularExpression *TAB_REGEX, *NEW_LINE_REGEX;

@implementation NSTextView (TMTEditorExtension)

__attribute__((constructor))
static void initialize_NSTextView_TMTEditorExtensions()
{
    TAB_REGEX = [NSRegularExpression regularExpressionWithPattern:@"(\\\\t)\\b" options:0 error:nil];
    NEW_LINE_REGEX = [NSRegularExpression regularExpressionWithPattern:@"\\\\n\\b" options:0 error:nil];
}


- (NSAttributedString *)expandWhiteSpaces:(NSAttributedString *)string
{
    NSAttributedString *singleTab = [[NSAttributedString alloc] initWithString:[NSString singleTab] attributes:nil];
    NSAttributedString *newLine = [[NSAttributedString alloc] initWithString:[self.string lineBreakForPosition:self.selectedRange.location] attributes:nil];
    NSMutableAttributedString *extension = [self mutableCopy];
    NSArray *tabs = [TAB_REGEX matchesInString:extension.string options:0 range:NSMakeRange(0, extension.string.length)];
    for (NSTextCheckingResult *r in [tabs reverseObjectEnumerator]) {
        [extension replaceCharactersInRange:r.range withAttributedString:singleTab];
    }
    NSArray *newlines = [NEW_LINE_REGEX matchesInString:extension.string options:0 range:NSMakeRange(0, extension.string.length)];
    for (NSTextCheckingResult *r in [newlines reverseObjectEnumerator]) {
        [extension replaceCharactersInRange:r.range withAttributedString:newLine];
    }
    return extension;
}

- (BOOL)isPlaceholderAtIndex:(NSUInteger)index
{
    if (index >= self.textStorage.length) {
        return NO;
    }
    NSRange range;
    NSDictionary *dict = [self.textStorage attributesAtIndex:index effectiveRange:&range];
    if (range.length != 1) {
        return NO;
    }
    id attachment = dict[NSAttachmentAttributeName];
    return [attachment isKindOfClass:[EditorPlaceholder class]];
}

- (NSRange)rangeOfNextPlaceholderStartIndex:(NSUInteger)index inRange:(NSRange)range
{
    if (index < range.location || index > NSMaxRange(range)) {
        [NSException raise:@"IndexOutOfRange" format:@"The index %ld is not within the range %@", index, NSStringFromRange(range)];
    }
    NSUInteger dif = 0;
    if (index > range.location) {
        dif = index - range.location;
        
    }
    for (NSUInteger idx = range.location + dif ; idx < NSMaxRange(range) ; idx++) {
        if ([self isPlaceholderAtIndex:idx]) {
            return NSMakeRange(idx, 1);
        }
    }
    // No Placeholder found. Round wrap!:
    for (NSUInteger idx = range.location ; idx < range.location + dif ; idx++) {
        if ([self isPlaceholderAtIndex:idx]) {
            return NSMakeRange(idx, 1);
        }
    }
    
    return NSMakeRange(NSNotFound, 0);
}

- (NSRange)rangeOfPreviousPlaceholderStartIndex:(NSUInteger)index inRange:(NSRange)range
{
    if (index < range.location || index > NSMaxRange(range)) {
        index = NSMaxRange(range) - 1;
    }
    NSUInteger dif = 0;
    if (index > range.location && index < NSMaxRange(range)) {
        dif = index - range.location;
        
    }
    for (NSUInteger idx = range.location + dif ; idx > range.location ; idx--) {
        if ([self isPlaceholderAtIndex:idx]) {
            return NSMakeRange(idx, 1);
        }
    }
    // No Placeholder found. Round wrap!:
    for (NSUInteger idx = NSMaxRange(range) ; idx > range.location + dif ; idx--) {
        if ([self isPlaceholderAtIndex:idx]) {
            return NSMakeRange(idx, 1);
        }
    }
    
    return NSMakeRange(NSNotFound, 0);
}

- (BOOL)handleInsertTab
{
    if (self.selectedRanges.count > 1 || self.selectedRange.length > 1) {
        return NO;
    }
    NSRange next;
    if ([self isPlaceholderAtIndex:self.selectedRange.location] && self.selectedRange.length == 1) {
        next = [self rangeOfNextPlaceholderStartIndex:self.selectedRange.location + 1 inRange:self.visibleRange];
    } else {
        next = [self rangeOfNextPlaceholderStartIndex:self.selectedRange.location inRange:self.visibleRange];
    }
    if (next.location != NSNotFound) {
        self.selectedRange = next;
        return YES;
    }
    return NO;
    
}

- (BOOL)handleInsertBacktab
{
    
    if (self.selectedRanges.count > 1 || self.selectedRange.length > 1) {
        return NO;
    }
    
    NSRange next;
    if ([self isPlaceholderAtIndex:self.selectedRange.location]) {
        next = [self rangeOfPreviousPlaceholderStartIndex:self.selectedRange.location - 1 inRange:self.visibleRange];
        
    } else {
        next = [self rangeOfPreviousPlaceholderStartIndex:self.selectedRange.location inRange:self.visibleRange];
    }
    if (next.location != NSNotFound) {
        self.selectedRange= next;
        return YES;
    }
    
    return NO;
}

@end
