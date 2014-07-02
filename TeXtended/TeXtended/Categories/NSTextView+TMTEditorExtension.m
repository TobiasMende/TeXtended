//
//  NSTextView+TMTEditorExtension.m
//  TeXtended
//
//  Created by Tobias Mende on 02.07.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "NSTextView+TMTEditorExtension.h"
#import "NSString+TMTEditorExtensions.h"

static const NSRegularExpression *TAB_REGEX, *NEW_LINE_REGEX;

@implementation NSTextView (TMTEditorExtension)

__attribute__((constructor))
static void initialize_NSTextView_TMTEditorExtensions()
{
    TAB_REGEX = [NSRegularExpression regularExpressionWithPattern:@"(\\\\t)\\b" options:0 error:nil];
    NEW_LINE_REGEX = [NSRegularExpression regularExpressionWithPattern:@"\\\\n\\b" options:0 error:nil];
}


- (NSAttributedString *)expandWhiteSpaces:(NSAttributedString *)string
{
    NSAttributedString *singleTab = [[NSAttributedString alloc] initWithString:[NSString singleTab] attributes:nil];
    NSAttributedString *newLine = [[NSAttributedString alloc] initWithString:[self.string lineBreakForPosition:self.selectedRange.location] attributes:nil];
    NSMutableAttributedString *extension = [self mutableCopy];
    NSArray *tabs = [TAB_REGEX matchesInString:extension.string options:0 range:NSMakeRange(0, extension.string.length)];
    for (NSTextCheckingResult *r in [tabs reverseObjectEnumerator]) {
        [extension replaceCharactersInRange:r.range withAttributedString:singleTab];
    }
    NSArray *newlines = [NEW_LINE_REGEX matchesInString:extension.string options:0 range:NSMakeRange(0, extension.string.length)];
    for (NSTextCheckingResult *r in [newlines reverseObjectEnumerator]) {
        [extension replaceCharactersInRange:r.range withAttributedString:newLine];
    }
    return extension;
}
@end
