//
//  NSString+TMTExtension.m
//  TeXtended
//
//  Created by Tobias Mende on 26.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "NSString+TMTExtension.h"

@implementation NSString (TMTExtension)


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
@end
