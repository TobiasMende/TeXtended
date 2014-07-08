//
//  NSTextView+LatexExtensions.m
//  TMTHelperCollection
//
//  Created by Tobias Mende on 02.07.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "NSTextView+LatexExtensions.h"
#import "NSString+TMTExtensions.h"


static const NSRegularExpression *FIRST_NONWHITESPACE_IN_LINE;

@implementation NSTextView (LatexExtensions)


__attribute__((constructor))
static void initialize_NSTextView_TMTExtensions()
{
      FIRST_NONWHITESPACE_IN_LINE = [NSRegularExpression regularExpressionWithPattern:@"^(?:\\s*)(\\S)(?:.*)$" options:NSRegularExpressionAnchorsMatchLines error:NULL];
}



- (BOOL)isFinalInsertion:(NSInteger)movement
{
    switch (movement) {
        case NSTabTextMovement:
            return YES;
            break;
        case NSRightTextMovement:
            return YES;
            break;
        case NSReturnTextMovement:
            return YES;
            break;
        default:
            return NO;
            break;
    }
}


#pragma mark - Comment & Uncomment

- (void)commentSelectionInRange:(NSRange)range
{
    NSRange lineRange = [self.string lineTextRangeWithRange:range];
    NSRange tmp = lineRange;
    NSMutableString *area = [[self.string substringWithRange:lineRange] mutableCopy];
    NSArray *matches = [FIRST_NONWHITESPACE_IN_LINE matchesInString:area options:0 range:NSMakeRange(0, area.length)];
    for (NSTextCheckingResult *result in [matches reverseObjectEnumerator]) {
        NSRange match = [result rangeAtIndex:1];
        [area replaceCharactersInRange:NSMakeRange(match.location, 0) withString:@"%"];
        lineRange.length += 1;
    }
    if (matches.count == 0) {
        NSBeep();
    }
    [self.undoManager beginUndoGrouping];
    [self.undoManager registerUndoWithTarget:self selector:@selector(uncommentSelectionInRangeString:) object:NSStringFromRange(lineRange)];
    [self replaceCharactersInRange:tmp withString:area];
    [self setSelectedRange:[self.string lineTextRangeWithRange:lineRange]];
    [self.undoManager endUndoGrouping];
    [self didChangeText];
    
}

- (void)uncommentSelectionInRange:(NSRange)range
{
    NSRange lineRange = [self.string lineTextRangeWithRange:range];
    NSRange tmp = lineRange;
    NSMutableString *area = [[self.string substringWithRange:lineRange] mutableCopy];
    NSArray *matches = [FIRST_NONWHITESPACE_IN_LINE matchesInString:area options:0 range:NSMakeRange(0, area.length)];
    BOOL actionDone = NO;
    for (NSTextCheckingResult *result in [matches reverseObjectEnumerator]) {
        NSRange match = [result rangeAtIndex:1];
        if ([[area substringWithRange:match] isEqualToString:@"%"]) {
            [area replaceCharactersInRange:match withString:@""];
            lineRange.length -= 1;
            actionDone = YES;
        }
    }
    [self.undoManager beginUndoGrouping];
    [self.undoManager registerUndoWithTarget:self selector:@selector(commentSelectionInRangeString:) object:NSStringFromRange(lineRange)];
    [self replaceCharactersInRange:tmp withString:area];
    [self setSelectedRange:[self.string lineTextRangeWithRange:lineRange]];
    [self.undoManager endUndoGrouping];
    if (!actionDone) {
        NSBeep();
    } else {
        [self setSelectedRange:lineRange];
    }
    [self didChangeText];
}


- (void)toggleCommentInRange:(NSRange)range
{
    NSRange lineRange = [self.string lineTextRangeWithRange:range];
    NSRange tmp = lineRange;
    NSMutableString *area = [[self.string substringWithRange:lineRange] mutableCopy];
    NSArray *matches = [FIRST_NONWHITESPACE_IN_LINE matchesInString:area options:0 range:NSMakeRange(0, area.length)];
    
    BOOL actionDone = NO;
    for (NSTextCheckingResult *result in [matches reverseObjectEnumerator]) {
        NSRange match = [result rangeAtIndex:1];
        if ([[area substringWithRange:match] isEqualToString:@"%"]) {
            [area replaceCharactersInRange:match withString:@""];
            lineRange.length -= 1;
        } else {
            [area replaceCharactersInRange:NSMakeRange(match.location, 0) withString:@"%"];
            lineRange.length += 1;
        }
        actionDone = YES;
    }
    [self.undoManager beginUndoGrouping];
    [self.undoManager registerUndoWithTarget:self selector:@selector(toggleCommentInRangeString:) object:NSStringFromRange(lineRange)];
    [self replaceCharactersInRange:tmp withString:area];
    [self.undoManager endUndoGrouping];
    if (!actionDone) {
        NSBeep();
    } else {
        [self setSelectedRange:[self.string lineTextRangeWithRange:lineRange]];
    }
    [self didChangeText];
}

- (void)uncommentSelectionInRangeString:(NSString *)range
{
    [self uncommentSelectionInRange:NSRangeFromString(range)];
}

- (void)commentSelectionInRangeString:(NSString *)range
{
    [self commentSelectionInRange:NSRangeFromString(range)];
}

- (void)toggleCommentInRangeString:(NSString *)range
{
    [self toggleCommentInRange:NSRangeFromString(range)];
}

@end
