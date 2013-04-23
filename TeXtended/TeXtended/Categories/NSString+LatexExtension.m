//
//  NSString+LatexExtension.m
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 11.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "NSString+LatexExtension.h"

@implementation NSString (LatexExtension)


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
@end
