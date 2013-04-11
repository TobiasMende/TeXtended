//
//  NSTextStorage+SubstringRange.m
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 11.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "NSString+SubstringRange.h"

@implementation NSString (SubstringRange)

- (NSString *) substringWithRange:(NSRange) range {
    if (range.location+range.length > self.length) {
        [NSException raise:@"Invalid substring range" format:@"Invalid range: %@ for text length %ld", NSStringFromRange(range), self.length];
    }
    NSMutableString *result = [NSMutableString stringWithCapacity:range.length];
    for (NSUInteger pos = range.location; pos < range.length+range.location; pos++) {
        [result appendString:[NSString stringWithFormat:@"%C", [self characterAtIndex:pos]]];
    }
    return result;
}

@end
