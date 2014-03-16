/*
 * RNTextStatistics
 *
 * Created by Ryan Nystrom on 10/2/12.
 * Copyright (c) 2012 Ryan Nystrom. All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#import "NSString+RegexReplace.h"
#import "EditorPlaceholder.h"
#import <TMTHelperCollection/TMTLog.h>
static const NSRegularExpression *PLACEHOLDER_REGEX;
@implementation NSString (RegexReplace)



__attribute__((constructor))
static void initialize_PLACEHOLDER_REGEX() {
    PLACEHOLDER_REGEX = [NSRegularExpression regularExpressionWithPattern:@"@@[^@@]*@@" options:NSRegularExpressionCaseInsensitive error:nil];
}

- (NSString*)stringByReplacingRegularExpression:(NSString*)pattern withString:(NSString*)replace options:(NSRegularExpressionOptions)options {
    NSError *error = nil;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:options error:&error];
    if (error) {
        DDLogError(@"%@",error.localizedDescription);
    }
    return [regex stringByReplacingMatchesInString:self options:kNilOptions range:NSMakeRange(0, [self length]) withTemplate:replace];
}


- (NSMutableAttributedString *)attributedStringBySubstitutingPlaceholders {
    NSMutableAttributedString *extension = [[NSMutableAttributedString alloc] initWithString:self];
        NSArray *matches = [PLACEHOLDER_REGEX matchesInString:self options:0 range:NSMakeRange(0, self.length)];
        NSInteger offset = 0;
        for (NSTextCheckingResult *match in matches) {
            NSRange range = [match range];
            NSRange final = NSMakeRange(range.location+2, range.length-4);
            NSString *title = [self substringWithRange:final];
            NSAttributedString *placeholder = [EditorPlaceholder placeholderAsAttributedStringWithName:title];
            NSRange newRange = NSMakeRange(range.location+offset, range.length);
            [extension replaceCharactersInRange:newRange withAttributedString:placeholder];
            offset += placeholder.length - range.length;
            
            
        }
    return extension;
}

@end
