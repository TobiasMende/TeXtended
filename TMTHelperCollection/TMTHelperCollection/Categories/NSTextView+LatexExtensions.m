//
//  NSTextView+LatexExtensions.m
//  TMTHelperCollection
//
//  Created by Tobias Mende on 02.07.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "NSTextView+LatexExtensions.h"

@implementation NSTextView (LatexExtensions)


- (BOOL)isFinalInsertion:(NSUInteger)movement
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

@end
