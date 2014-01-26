//
//  NSString+TMTExtension.m
//  TeXtended
//
//  Created by Tobias Mende on 26.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "NSString+TMTExtension.h"
#import <TMTHelperCollection/TMTLog.h>

@implementation NSString (TMTExtension)


- (NSArray *)lineRanges {
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^.*$" options:NSRegularExpressionAnchorsMatchLines error:&error];
    
    if (error) {
        DDLogError(@"Line Ranges Error: %@", [error userInfo]);
        return nil;
    }
    
    NSArray *ranges = [regex matchesInString:self options:0 range:NSMakeRange(0, self.length)];
    return ranges;
    
}

- (NSUInteger)lineNumberForRange:(NSRange)range {
    NSArray *lines = [self lineRanges];
    for(NSUInteger line = 0; line < lines.count; line++) {
        NSRange lineRange = [lines[line] range];
        if (NSEqualRanges(lineRange, NSUnionRange(lineRange, range))) {
            return line;
        }
    }
    return NSNotFound;
}
@end
