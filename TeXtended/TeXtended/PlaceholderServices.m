//
//  PlaceholderServices.m
//  TeXtended
//
//  Created by Tobias Mende on 18.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "PlaceholderServices.h"
#import "HighlightingTextView.h"
#import "EditorPlaceholder.h"

@implementation PlaceholderServices

- (BOOL)handleInsertTab {
    if (view.selectedRanges.count > 1 || view.selectedRange.length != 1) {
        return NO;
    }
    
    if ([self isPlaceholderAtIndex:view.selectedRange.location]) {
        //TODO: next placeholder
        NSRange next = [self rangeOfNextPlaceholderStartIndex:view.selectedRange.location+1 inRange:[view visibleRange]];
        if (next.location != NSNotFound) {
            [view setSelectedRange:next];
            return YES;
        }
    }
    return NO;
    
}

- (BOOL)handleInsertBacktab {
    //TODO: step through placeholders backward.
    return NO;
}

- (NSRange)rangeOfNextPlaceholderStartIndex:(NSUInteger)index inRange:(NSRange)range{
    if (index < range.location || index > NSMaxRange(range)) {
        [NSException raise:@"IndexOutOfRange" format:@"The index %ld is not within the range %@", index, NSStringFromRange(range)];
    }
    NSUInteger dif = 0;
    if (index > range.location) {
        dif = index-range.location;
        
    }
    NSLog(@"%ld", dif);
    for(NSUInteger idx = range.location+dif; idx < NSMaxRange(range); idx++ ) {
        if ([self isPlaceholderAtIndex:idx]) {
            return NSMakeRange(idx, 1);
        }
    }
    // No Placeholder found. Round wrap!:
    for(NSUInteger idx = range.location; idx < range.location+dif; idx++ ) {
        if ([self isPlaceholderAtIndex:idx]) {
            return NSMakeRange(idx, 1);
        }
    }
    
    return NSMakeRange(NSNotFound, 0);
}

- (BOOL)isPlaceholderAtIndex:(NSUInteger)index {
    if (index >= view.textStorage.length) {
        return NO;
    }
    NSRange range;
    NSDictionary *dict =[view.textStorage attributesAtIndex:index effectiveRange:&range];
    if (range.length != 1) {
        return NO;
    }
    id attachment = [dict objectForKey:NSAttachmentAttributeName];
    return [attachment isKindOfClass:[EditorPlaceholder class]];
}
@end
