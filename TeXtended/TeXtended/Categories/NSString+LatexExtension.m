//
//  NSString+LatexExtension.m
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 11.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "NSString+LatexExtension.h"

static NSSet *COMPLETION_ESCAPE_INSERTIONS;
#define COMMAND_PREFIX_SIZE 100
@implementation NSString (LatexExtension)

+ (void)initialize {
    COMPLETION_ESCAPE_INSERTIONS = [NSSet setWithObjects:@"{",@"}", @"[", @"]", @"(", @")", @" ", nil];
}

- (BOOL) latexLineBreakPreceedingPosition:(NSUInteger) position {
    if (position < 2) {
        return false;
    }
    return [self numberOfBackslashesBeforePosition:position] >0 && [self numberOfBackslashesBeforePositionIsEven:position];
}

- (BOOL) numberOfBackslashesBeforePositionIsEven:(NSUInteger)position {
    if(position < 1) {
        // No place for backslashes
        return true;
    }
    NSUInteger backslashCounter = 0;
    while (position > 0 && [[self substringWithRange:NSMakeRange(position-1, 1)] isEqualToString:@"\\"]) {
        position--;
        backslashCounter ++;
    }
    return backslashCounter%2 ==0;
}

- (NSUInteger) numberOfBackslashesBeforePosition:(NSUInteger) position {
    if(position < 1) {
        // No place for backslashes
        return 0;
    }
    NSUInteger backslashCounter = 0;
    while (position > 0 && [[self substringWithRange:NSMakeRange(position-1, 1)] isEqualToString:@"\\"]) {
        position--;
        backslashCounter ++;
    }
    return backslashCounter;
}

- (NSRange)latexCommandPrefixRangeBeforePosition:(NSUInteger)position {
    NSUInteger startPosition = position < COMMAND_PREFIX_SIZE ? 0 : position - COMMAND_PREFIX_SIZE;
    NSUInteger endPosition = position < COMMAND_PREFIX_SIZE ? position : COMMAND_PREFIX_SIZE;
    NSRange lineRange = NSMakeRange(startPosition, endPosition);
    __block NSRange result = NSMakeRange(NSNotFound, 0);
    __block BOOL resultEnd = NO;
    __block BOOL resultStart = NO;
    __unsafe_unretained id weakSelf = self;
    [self enumerateSubstringsInRange:lineRange options:NSStringEnumerationReverse|NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        if ([substring isEqualToString:@"}"]) {
            result = NSMakeRange(NSNotFound, 0);
            *stop = YES;
        } else if ([substring isEqualToString:@"{"] && !resultEnd) {
            result = substringRange;
            resultEnd = YES;
        } else if ([substring isEqualToString:@"\\"] && resultEnd) {
            resultStart = YES;
            result.location--;
            result.length++;
            __block NSRange tmp = NSMakeRange(result.location, 0);
            [weakSelf enumerateSubstringsInRange:result options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                if ([COMPLETION_ESCAPE_INSERTIONS containsObject:substring]) {
                    *stop = YES;
                } else {
                    tmp.length++;
                }
            }];
            result = tmp;
            *stop = YES;
        } else if(resultEnd) {
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
@end
