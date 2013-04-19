//
//  CompletionHandler.m
//  TeXtended
//
//  Created by Tobias Mende on 18.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "CompletionHandler.h"
#import "HighlightingTextView.h"
#import "SyntaxHighlighter.h"
NSDictionary *COMPLETION_TYPE_BY_PREFIX;

typedef enum {
    TMTNoCompletion,
    TMTCommandCompletion,
    TMTBeginCompletion,
    TMTEndCompletion
    } TMTCompletionType;

@implementation CompletionHandler

+ (void)initialize {
    COMPLETION_TYPE_BY_PREFIX = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:TMTCommandCompletion], @"\\", [NSNumber numberWithInt:TMTBeginCompletion],@"\\begin{", [NSNumber numberWithInt:TMTEndCompletion],@"\\end{", nil];
}




- (NSArray *)completionsForPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index {
    NSLog(@"Range: %@, Substring: %@", NSStringFromRange(charRange), [view.string substringWithRange:charRange]);
    
    TMTCompletionType type = [self completionTypeForPartialWordRange:charRange];
    switch (type) {
        case TMTCommandCompletion:
            NSLog(@"CommandCompletion");
            break;
        case TMTBeginCompletion:
            NSLog(@"BeginCompletion");
            break;
        case TMTEndCompletion:
            NSLog(@"EndCompletion");
            break;
        default:
            NSLog(@"NoCompletion");
            return [view completionsForPartialWordRange:charRange indexOfSelectedItem:index];
            break;
    }
    return nil;
}

- (NSArray *)completions:(NSArray *)words forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index {
    return nil;
}

- (void)complete {
    
}

- (BOOL)willHandleCompletionForPartialWordRange:(NSRange)charRange{
    return [self completionTypeForPartialWordRange:charRange] != TMTNoCompletion;
}


- (TMTCompletionType) completionTypeForPartialWordRange:(NSRange) charRange {
    for(NSString *key in COMPLETION_TYPE_BY_PREFIX) {
        if (charRange.location >= [key length]) {
            NSRange prefixRange = NSMakeRange(charRange.location-key.length, key.length);
            NSString *prefixString = [view.string substringWithRange:prefixRange] ;
            if ([prefixString isEqualToString:key]) {
                return [[COMPLETION_TYPE_BY_PREFIX objectForKey:key] intValue];
            }
        }
    }
    return TMTNoCompletion;
}

- (void)dealloc {
    
}
@end
