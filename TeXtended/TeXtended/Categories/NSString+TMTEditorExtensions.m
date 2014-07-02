//
//  NSString+TMTEditorExtensions.m
//  TeXtended
//
//  Created by Tobias Mende on 02.07.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "NSString+TMTEditorExtensions.h"
#import <TMTHelperCollection/NSString+TMTExtensions.h>
#import "SettingsHelper.h"


@interface NSString ()
@end

@implementation NSString (TMTEditorExtensions)
/**
 Method returns a single tab, meaning a \t or a user defined amount of spaces.
 */
+ (NSString *)singleTab
{
    NSString *tab = @"\t";
    if ([[SettingsHelper sharedInstance] shouldUseSpacesAsTabs]) {
        tab = @"";
        NSUInteger num = [[SettingsHelper sharedInstance] numberOfSpacesForTab];
        for (NSUInteger i = 0 ; i < num ; i++) {
            tab = [tab stringByAppendingString:@" "];
        }
    }
    return tab;
}

- (NSString *)lineBreakForPosition:(NSUInteger)position
{
    NSString *lineBreak = @"\n";
    if ([SettingsHelper sharedInstance].shouldAutoIndentLines) {
        NSRange lineRange = [self lineRangeForRange:NSMakeRange(position, 0)];
        NSRange rangeForBegin = NSMakeRange(lineRange.location, position-lineRange.location);
        lineBreak = [lineBreak stringByAppendingString:[self whiteSpacesAtLineBeginning:rangeForBegin]];
        
    }
    return lineBreak;
}

@end
