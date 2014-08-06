//
//  NSString+TMTExtension.m
//  TeXtended
//
//  Created by Tobias Mende on 26.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "NSString+TMTExtensions.h"
#import "TMTLog.h"

LOGGING(LOG_LEVEL_NOTICE)
static const NSRegularExpression *SPACE_AT_LINE_BEGINNING;

@implementation NSString (TMTExtensions)


__attribute__((constructor))
static void initialize_NSString_TMTExtensions()
{
    SPACE_AT_LINE_BEGINNING = [NSRegularExpression regularExpressionWithPattern:@"^(?:\\p{z}|\\t)*" options:NSRegularExpressionAnchorsMatchLines error:NULL];
}

    - (NSArray *)tmplineRanges
    {
        return [self componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

    }

    - (NSUInteger)lineNumberForRange:(NSRange)range
    {
        NSUInteger numberOfLines, index, stringLength = [self length];
        for (index = 0, numberOfLines = 0 ; index < stringLength ; numberOfLines++) {
            NSRange line = [self lineRangeForRange:NSMakeRange(index, 0)];
            if (NSUnionRange(line, range).length == line.length) {
                return numberOfLines;
            }
            index = NSMaxRange(line);

        }
        return NSNotFound;

    }

    - (NSUInteger)numberOfLines
    {
        NSUInteger numberOfLines, index, stringLength = [self length];
        for (index = 0, numberOfLines = 0 ; index < stringLength ; numberOfLines++)
            index = NSMaxRange([self lineRangeForRange:NSMakeRange(index, 0)]);
        return numberOfLines;
    }

    - (NSRange)rangeForLine:(NSUInteger)lineNumber
    {
        NSUInteger numberOfLines, index, stringLength = [self length];
        for (index = 0, numberOfLines = 0 ; index < stringLength ; numberOfLines++) {
            NSRange range = [self lineRangeForRange:NSMakeRange(index, 0)];
            if (numberOfLines == lineNumber) {
                return range;
            }
            index = NSMaxRange(range);
        }
        return NSMakeRange(NSNotFound, 0);
    }


    - (NSRange)lineRangeForPosition:(NSUInteger)position
    {
        return [self lineRangeForRange:NSMakeRange(position, 0)];
    }



- (NSRange)lineTextRangeWithRange:(NSRange)range
{
    return [self lineTextRangeWithRange:range withLineTerminator:NO];
}

- (NSRange)lineTextRangeWithRange:(NSRange)range withLineTerminator:(BOOL)flag
{
    NSUInteger rangeStart, contentsEnd, rangeEnd;
    NSRange result;
    if (range.location != NSNotFound && NSMaxRange(range) <= self.length) {
        [self getLineStart:&rangeStart end:&rangeEnd contentsEnd:&contentsEnd forRange:range];
        
        
        if (flag) {
            NSUInteger length = rangeEnd - rangeStart;
            result = NSMakeRange(rangeStart, length);
            
        } else {
            NSUInteger length = contentsEnd - rangeStart;
            result = NSMakeRange(rangeStart, length);
        }
    } else {
        result = NSMakeRange(NSNotFound, 0);
        DDLogError(@"Error for provided range: %@", NSStringFromRange(range));
    }
    return result;
}


- (NSString *)whiteSpacesAtLineBeginning:(NSRange)lineRange
{
    NSRange rangeOfFirstMatch = [SPACE_AT_LINE_BEGINNING rangeOfFirstMatchInString:self options:0 range:lineRange];
    if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
        return [self substringWithRange:rangeOfFirstMatch];
        
    }
    return @"";
}

- (NSRange)extendRange:(NSRange)range byLines:(NSUInteger)numLines
{
    for (NSUInteger iteration = 0 ; iteration < numLines ; iteration++) {
        BOOL update = NO;
        if (range.location > 0) {
            range.location -= 1;
            range.length += 1;
            update = YES;
        }
        if (NSMaxRange(range) < self.length - 1 && NSMaxRange(range) > 0) {
            range.length += 1;
            update = YES;
        }
        if (update) {
            range = [self lineTextRangeWithRange:range withLineTerminator:YES];
        } else {
            break;
        }
    }
    return range;
}

@end
