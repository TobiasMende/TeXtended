//
//  CodeExtensionEngine.m
//  TeXtended
//
//  Created by Tobias Mende on 22.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "CodeExtensionEngine.h"
#import "HighlightingTextView.h"
NSRegularExpression *TEXDOC_LINKS;
NSString *TEXDOC_PREFIX = @"texdoc://";
@implementation CodeExtensionEngine


+(void)initialize {
    NSString *backslash = [NSRegularExpression escapedPatternForString:@"\\"];
    NSString *pattern = [NSString stringWithFormat:@"%@(usepackage|RequirePackage)\\{(.*)\\}", backslash];
    NSError *error;
    TEXDOC_LINKS = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    if (error) {
        NSLog(@"Error!");
    }
}


- (void)addLinksForRange:(NSRange)range {
    NSArray *texdocRanges = [TEXDOC_LINKS matchesInString:view.string options:0 range:range];
    for (NSTextCheckingResult *match in texdocRanges) {
        if ([match numberOfRanges] > 2) {
            NSRange mRange = [match rangeAtIndex:2];
            NSString *link = [NSString stringWithFormat:@"%@%@", TEXDOC_PREFIX, [view.string substringWithRange:mRange]];
            [view.textStorage removeAttribute:NSLinkAttributeName range:mRange];
            [view.textStorage addAttribute:NSLinkAttributeName value:link range:mRange];
        }
    }
}

- (BOOL)clickedOnLink:(id)link atIndex:(NSUInteger)charIndex {
    NSString *url = (NSString*) link;
    if ([[url substringToIndex:TEXDOC_PREFIX.length] isEqualToString:TEXDOC_PREFIX]) {
        NSString *packageName = [url substringFromIndex:TEXDOC_PREFIX.length];
        NSLog(@"Package: %@", packageName);
        NSTask *task = [[NSTask alloc] init];
        //FIXME: Don't hard code!
        [task setEnvironment:[NSDictionary dictionaryWithObjectsAndKeys:@"/usr/local/bin:/usr/bin:/usr/texbin", @"PATH",  nil]];
        [task setLaunchPath:@"/usr/texbin/texdoc"];
        NSArray	*args = [NSArray arrayWithObjects:@"-q", @"-M", packageName,
                         nil];
        [task setArguments: args];
        [task launch];
        return YES;
    }
    return NO;
}
@end
