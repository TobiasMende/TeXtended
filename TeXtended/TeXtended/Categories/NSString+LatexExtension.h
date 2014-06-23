//
//  NSString+LatexExtension.h
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 11.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (LatexExtension)

    - (BOOL)latexLineBreakPreceedingPosition:(NSUInteger)position;

    - (BOOL)numberOfBackslashesBeforePositionIsEven:(NSUInteger)position;

    - (NSUInteger)numberOfBackslashesBeforePosition:(NSUInteger)position;

    - (NSRange)latexCommandPrefixRangeBeforePosition:(NSUInteger)position;

    - (NSRange)blockRangeForPosition:(NSUInteger)position;

    - (NSString *)blockNameForPosition:(NSUInteger)position;

    - (NSRange)beginRangeForPosition:(NSUInteger)position;

    - (NSRange)endRangeForPosition:(NSUInteger)position;

    - (NSRange)endRangeForPosition:(NSUInteger)position inRange:(NSRange)range;

    - (BOOL)rangeContainsBegin:(NSRange)range;

    - (BOOL)rangeContainsEnd:(NSRange)range;

- (NSArray *)goodPositionsToBreakInRange:(NSRange) range;

@end
