//
//  CompletionHandler.m
//  TeXtended
//
//  Created by Tobias Mende on 18.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "CompletionHandler.h"
#import "HighlightingTextView.h"

@implementation CompletionHandler

- (NSArray *)completions:(NSArray *)words forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index {
    for(NSString *word in words) {
        NSLog(@"Word: %@", word);
    }
    return nil;
}

- (NSArray *)completionsForPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index {
    NSLog(@"charRange: %@", NSStringFromRange(charRange));
    NSString *word = [view.string substringWithRange:charRange];
    NSLog(@"%@", word);
    return nil;
}

@end
