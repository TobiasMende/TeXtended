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
#import "ApplicationController.h"
#import "Completion.h"
#import "CommandCompletion.h"
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
    

    
    TMTCompletionType type = [self completionTypeForPartialWordRange:charRange];
    switch (type) {
        case TMTCommandCompletion:
            return [self commandCompletionsForPartialWordRange:charRange indexOfSelectedItem:index];
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

- (NSArray *)commandCompletionsForPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index {
    NSString *prefix = [@"\\" stringByAppendingString:[view.string substringWithRange:charRange]];
    NSDictionary *completions = [[ApplicationController sharedApplicationController] systemCommandCompletions] ;
    NSMutableArray *matchingKeys = [[NSMutableArray alloc] init];
    BOOL stop = NO;
    BOOL start = NO;
    for (NSString *key in completions) {
        if ([key hasPrefix:prefix]) {
            [matchingKeys addObject:key];
            start = YES;
        } else if (start) {
            // Keys are orderd. So if we found matching keys and than a non matching key, we don't need to look ahead.
            stop = YES;
        }
        if (stop) {
            break;
        }
    }
    return matchingKeys;
}


- (void)insertCompletion:(NSString *)word forPartialWordRange:(NSRange)charRange movement:(NSInteger)movement isFinal:(BOOL)flag {
    TMTCompletionType type = [self completionTypeForPartialWordRange:charRange];
    
    switch (type) {
        case TMTCommandCompletion:
            [self insertCommandCompletion:word forPartialWordRange:charRange movement:movement isFinal:flag];
            break;
        case TMTBeginCompletion:
            NSLog(@"BeginCompletion");
            break;
        case TMTEndCompletion:
            NSLog(@"EndCompletion");
            break;
        default:
            NSLog(@"NoCompletion");
            break;
    }
}

- (void)insertCommandCompletion:(NSString *)word forPartialWordRange:(NSRange)charRange movement:(NSInteger)movement isFinal:(BOOL)flag {

    NSDictionary *completions = [[ApplicationController sharedApplicationController] systemCommandCompletions] ;
    CommandCompletion *completion = [completions objectForKey:word];
    if (flag && [self isFinalInsertion:movement]) {
        if ([completion hasPlaceholders]) {
        
        
        NSMutableAttributedString *final = [[NSMutableAttributedString alloc] initWithString:[[completion insertion] substringWithRange:NSMakeRange(1, completion.insertion.length-1)]];
            [final appendAttributedString:[completion substitutedExtension]];
            [view delete:nil];
            [view.textStorage replaceCharactersInRange:charRange withAttributedString:final];
            [view setSelectedRange:NSMakeRange(charRange.location, 0)];
            [view jumpToNextPlaceholder];
        } else {
            [view insertFinalCompletion:[word substringWithRange:NSMakeRange(1, word.length-1)] forPartialWordRange:charRange movement:movement isFinal:flag];
        }
    } else {
        [view insertFinalCompletion:[completion.insertion substringWithRange:NSMakeRange(1, completion.insertion.length-1)] forPartialWordRange:charRange movement:movement isFinal:flag];
    }
    
    }

- (NSArray *)completions:(NSArray *)words forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index {
    return nil;
}

- (void)complete {
    
}

- (BOOL) isFinalInsertion:(NSUInteger) movement {
    switch (movement) {
        case NSTabTextMovement:
            return YES;
            break;
        case NSRightTextMovement:
            return YES;
            break;
        case NSReturnTextMovement:
            return YES;
        default:
            return NO;
            break;
    }
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
