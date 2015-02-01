//
//  NSString+LatexExtensions.m
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 11.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "NSString+LatexExtensions.h"
#import "NSString+TMTExtensions.h"

static NSSet *COMPLETION_ESCAPE_INSERTIONS;

static NSRegularExpression *BLOCK_REGEX, *GOOD_BREAK_POSITIONS;

#define COMMAND_PREFIX_SIZE 100

@implementation NSString (LatexExtensions)

    __attribute__((constructor))
    static void initialize_COMPLETION_ESCAPE_INSERTIONS()
    {
        COMPLETION_ESCAPE_INSERTIONS = [NSSet setWithObjects:@"{", @"}", @"[", @"]", @"(", @")", @" ", nil];
    }

    __attribute__((constructor))
    static void initialize_BLOCK_REGEXS()
    {
        NSError *error;
        BLOCK_REGEX = [NSRegularExpression regularExpressionWithPattern:@"\\\\begin\\W*\\{(.*?)\\}|\\\\end\\W*\\{(.*?)\\}" options:0 error:&error];
        GOOD_BREAK_POSITIONS = [NSRegularExpression regularExpressionWithPattern:@"\\w(\\s+)" options:NSRegularExpressionAnchorsMatchLines error:&error];
        if (error) {
            NSLog(@"Wrong Regex");
        }
    }

    - (BOOL)latexLineBreakPreceedingPosition:(NSUInteger)position
    {
        if (position < 2) {
            return false;
        }
        return [self numberOfBackslashesBeforePosition:position] > 0 && [self numberOfBackslashesBeforePositionIsEven:position];
    }

    - (BOOL)numberOfBackslashesBeforePositionIsEven:(NSUInteger)position
    {
        return [self numberOfBackslashesBeforePosition:position] % 2 == 0;
    }

    - (NSUInteger)numberOfBackslashesBeforePosition:(NSUInteger)position
    {
        if (position < 1) {
            // No place for backslashes
            return 0;
        }
        NSUInteger backslashCounter = 0;
        while (position > 0 && [[self substringWithRange:NSMakeRange(position - 1, 1)] isEqualToString:@"\\"]) {
            position--;
            backslashCounter++;
        }
        return backslashCounter;
    }

- (BOOL)lineIsCommentForPosition:(NSUInteger)position {
    NSRange lineRange = [self lineRangeForPosition:position];
    for (NSInteger pos = position; pos >= lineRange.location && pos >= 0; pos--) {
        if ([[self substringWithRange:NSMakeRange(pos, 1)] isEqualToString:@"\%"] && [self numberOfBackslashesBeforePositionIsEven:pos]) {
            return YES;
        }
    }
    return NO;
}

    - (NSRange)latexCommandPrefixRangeBeforePosition:(NSUInteger)position
    {
        NSUInteger startPosition = position < COMMAND_PREFIX_SIZE ? 0 : position - COMMAND_PREFIX_SIZE;
        NSUInteger endPosition = position < COMMAND_PREFIX_SIZE ? position : COMMAND_PREFIX_SIZE;
        NSRange lineRange = NSMakeRange(startPosition, endPosition);
        __block NSRange result = NSMakeRange(NSNotFound, 0);
        __block BOOL resultEnd = NO;
        __block BOOL resultStart = NO;
        __unsafe_unretained id weakSelf = self;
        [self enumerateSubstringsInRange:lineRange options:NSStringEnumerationReverse | NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop)
        {
            if ([substring isEqualToString:@"}"]) {
                result = NSMakeRange(NSNotFound, 0);
                *stop = YES;
            } else if (([substring isEqualToString:@"{"] || [substring isEqualToString:@"["])
                    && !resultEnd) {
                result = substringRange;
                resultEnd = YES;
            } else if ([substring isEqualToString:@"]"]) {
                if (resultEnd) {
                    resultEnd = NO;
                } else {
                    result = NSMakeRange(NSNotFound, 0);
                    *stop = YES;
                }
            } else if ([substring isEqualToString:@"\\"] && resultEnd) {
                resultStart = YES;
                result.location--;
                result.length++;
                __block NSRange tmp = NSMakeRange(result.location, 0);
                [weakSelf enumerateSubstringsInRange:result options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *subs, NSRange substringRange, NSRange enclosingRange, BOOL *stop)
                {
                    if ([COMPLETION_ESCAPE_INSERTIONS containsObject:subs]) {
                        *stop = YES;
                    } else {
                        tmp.length++;
                    }
                }];
                result = tmp;
                *stop = YES;
            } else if (resultEnd) {
                result.location--;
                result.length++;
            }
        }];
        if (resultStart && resultEnd) {
            return result;
        } else {
            return NSMakeRange(NSNotFound, 0);
        }
    }

    - (NSRange)beginRangeForPosition:(NSUInteger)position
    {
        NSUInteger currentPosition = position;
        NSInteger counter = 0;

        NSRange lineRange = [self lineRangeForPosition:position];
        if ([self rangeContainsBegin:lineRange]) {
            currentPosition = NSMaxRange(lineRange);
        } else if ([self rangeContainsEnd:lineRange]) {
            currentPosition = lineRange.location;
        }

        NSArray *matches = [BLOCK_REGEX matchesInString:self options:0 range:NSMakeRange(0, currentPosition)];
        for (NSTextCheckingResult *next in matches.reverseObjectEnumerator) {
            if ([next rangeAtIndex:1].location == NSNotFound) {
                // END RANGE
                counter++;
            } else {
                // BEGIN RANGE
                if (counter > 0) {
                    counter--;
                } else {
                    return next.range;
                }

            }
        }
        return NSMakeRange(NSNotFound, 0);
    }


    - (BOOL)rangeContainsBegin:(NSRange)range
    {
        NSTextCheckingResult *result = [BLOCK_REGEX firstMatchInString:self options:0 range:range];
        return result && result.range.location != NSNotFound && [result rangeAtIndex:1].location != NSNotFound;
    }

    - (BOOL)rangeContainsEnd:(NSRange)range
    {
        NSTextCheckingResult *result = [BLOCK_REGEX firstMatchInString:self options:0 range:range];
        return result && result.range.location != NSNotFound && [result rangeAtIndex:1].location == NSNotFound;
    }

    - (NSRange)endRangeForPosition:(NSUInteger)position
    {
        return [self endRangeForPosition:position inRange:NSMakeRange(0, self.length)];
    }

    - (NSRange)endRangeForPosition:(NSUInteger)position inRange:(NSRange)range
    {
        NSUInteger currentPosition = position;
        NSInteger counter = 0;

        NSRange lineRange = [self lineRangeForPosition:position];
        if ([self rangeContainsBegin:lineRange]) {
            currentPosition = NSMaxRange(lineRange);
        } else if ([self rangeContainsEnd:lineRange]) {
            currentPosition = lineRange.location;
        }

        while (currentPosition < NSMaxRange(range)) {
            NSRange current = NSMakeRange(currentPosition, self.length - currentPosition);
            NSTextCheckingResult *next = [BLOCK_REGEX firstMatchInString:self options:0 range:current];

            if (!next || next.range.location == NSNotFound) {
                return NSMakeRange(NSNotFound, 0);
            }
            if ([next rangeAtIndex:1].location == NSNotFound) {
                // END RANGE
                if (counter > 0) {
                    counter--;
                } else {
                    return next.range;
                }
            } else {
                // BEGIN RANGE
                counter++;

            }
            currentPosition = NSMaxRange(next.range);
        }
        return NSMakeRange(NSNotFound, 0);
    }

    - (NSRange)blockRangeForPosition:(NSUInteger)position
    {
        NSRange beginRange = [self beginRangeForPosition:position];
        beginRange.location = beginRange.location != NSNotFound ? beginRange.location : 0;

        NSRange endRange = [self endRangeForPosition:position];
        if (endRange.location == NSNotFound) {
            endRange = NSMakeRange(self.length - 1, 1);
        }

        return NSUnionRange(beginRange, endRange);

    }

    - (NSString *)blockNameForPosition:(NSUInteger)position
    {

        NSRange beginRange = [self beginRangeForPosition:position];
        NSTextCheckingResult *result = [BLOCK_REGEX firstMatchInString:self options:0 range:beginRange];
        return [self substringWithRange:[result rangeAtIndex:1]];
    }

-(NSArray *)goodPositionsToBreakInRange:(NSRange) range {
    return [GOOD_BREAK_POSITIONS matchesInString:self options:0 range:range];
}

- (NSRange)extendedCiteEntryPrefixRangeFor:(NSRange)charRange
{
    while (charRange.location > 0 && ![[self substringWithRange:NSMakeRange(charRange.location - 1, 1)] isEqualToString:@"{"] && ![[self substringWithRange:NSMakeRange(charRange.location - 1, 1)] isEqualToString:@","]) {
        charRange.location--;
        charRange.length++;
    }
    return charRange;
}

@end
