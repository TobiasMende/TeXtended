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
#import "EnvironmentCompletion.h"
NSDictionary *COMPLETION_TYPE_BY_PREFIX;

typedef enum {
    TMTNoCompletion,
    TMTCommandCompletion,
    TMTBeginCompletion,
    TMTEndCompletion
    } TMTCompletionType;

@interface CompletionHandler()

/**
 Used by [CompletionHandler completionsForPartialWordRange:indexOfSelectedItem:] for handling \command completions.
 
 @param charRange the prefix range
 @param index the selected entry
 
 @return an array of command completions
 */

- (NSArray *)commandCompletionsForPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index;

- (NSArray *)environmentCompletionsForPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index;

/**
 Used by [CompletionHandler insertCommandCompletion:forPartialWordRange:movement:isFinal:] for handling \command completions.
 
 @param word the completion word
 @param charRange the prefix range
 @param movement the text movement
 @param flag useless flag
 */
- (void)insertCommandCompletion:(NSString *)word forPartialWordRange:(NSRange)charRange movement:(NSInteger)movement isFinal:(BOOL)flag;

- (void)insertEnvironmentCompletion:(NSString *)word forPartialWordRange:(NSRange)charRange movement:(NSInteger)movement isFinal:(BOOL)flag;

/**
 Method for detecting the completion type by the prefix range.
 
 @param charRange the prefix range
 
 @return the completion type or TMTNoCompletion if this class can't handle this completion.
 */
- (TMTCompletionType) completionTypeForPartialWordRange:(NSRange) charRange;

- (void) skipClosingBracket;

@end

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
            return [self environmentCompletionsForPartialWordRange:charRange indexOfSelectedItem:index];
            break;
        case TMTEndCompletion:
            return [self environmentCompletionsForPartialWordRange:charRange indexOfSelectedItem:index];
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
    for (NSString *key in completions) {
        if ([key hasPrefix:prefix]) {
            [matchingKeys addObject:key];
        }
    }
    return matchingKeys;
}

- (NSArray *)environmentCompletionsForPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index {
    NSString *prefix = [view.string substringWithRange:charRange];
    NSDictionary *completions = [[ApplicationController sharedApplicationController] systemEnvironmentCompletions] ;
    NSMutableArray *matchingCompletions = [[NSMutableArray alloc] init];
    for (NSString *key in completions) {
        if ([key hasPrefix:prefix]) {
            [matchingCompletions addObject:[[completions objectForKey:key] insertion]];
        }
    }
    return matchingCompletions;
}


- (void)insertCompletion:(NSString *)word forPartialWordRange:(NSRange)charRange movement:(NSInteger)movement isFinal:(BOOL)flag {
    TMTCompletionType type = [self completionTypeForPartialWordRange:charRange];
    
    switch (type) {
        case TMTCommandCompletion:
            [self insertCommandCompletion:word forPartialWordRange:charRange movement:movement isFinal:flag];
            break;
        case TMTBeginCompletion:
            [self insertEnvironmentCompletion:word forPartialWordRange:charRange movement:movement isFinal:flag];
            break;
        case TMTEndCompletion:
            [view insertFinalCompletion:word forPartialWordRange:charRange movement:movement isFinal:flag];
            if (flag && [self isFinalInsertion:movement]) {
                [self skipClosingBracket];
            }
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

- (void)insertEnvironmentCompletion:(NSString *)word forPartialWordRange:(NSRange)charRange movement:(NSInteger)movement isFinal:(BOOL)flag {
    TMTCompletionType type = [self completionTypeForPartialWordRange:charRange];
    if (type != TMTBeginCompletion) {
        return;
    }
    if (!flag || ![self isFinalInsertion:movement]) {
        [view insertFinalCompletion:word forPartialWordRange:charRange movement:movement isFinal:flag];
        return;
    }
    [view insertFinalCompletion:word forPartialWordRange:charRange movement:movement isFinal:flag];
    [self skipClosingBracket];
    NSDictionary *completions = [[ApplicationController sharedApplicationController] systemEnvironmentCompletions];
    EnvironmentCompletion *completion = [completions objectForKey:word];
    NSUInteger position = [view selectedRange].location;
    NSRange visible = [view visibleRange];
    NSRange range;
    if (position > visible.location) {
        NSUInteger dif = position - visible.location;
        range = NSMakeRange(position, visible.length-dif);
    } else {
        range = visible;
    }
    NSRange endRange = NSMakeRange(NSNotFound, 0);//[self matchingEndForEnvironment:word inRange:range];
    NSMutableAttributedString *further = [[NSMutableAttributedString alloc] init];
    if (completion && [completion hasPlaceholders]) {
        [further appendAttributedString:[completion substitutedExtension]];
    }
    if (endRange.location == NSNotFound) {
        [further appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\\end{%@}", word]]];
    }
    [view.textStorage insertAttributedString:further atIndex:position];
    [view setSelectedRange:NSMakeRange(position, 0)];
    [view jumpToNextPlaceholder];
    
    
}

- (NSRange) matchingEndForEnvironment:(NSString*) name inRange:(NSRange) range {
    //FIXME: doesn't work.
    NSLog(@"Range: %@, total: %@", NSStringFromRange(range), NSStringFromRange(view.visibleRange));
    
    NSString *start = [NSString stringWithFormat:@"\\begin{%@}", name];
    NSString *end = [NSString stringWithFormat:@"\\end{%@}", name];
    NSUInteger totalLength = [view string].length;
    NSUInteger counter = 0;
    for (NSUInteger position = range.location; position < range.location+range.length; position++) {
        if (position+start.length < totalLength && [[view.string substringWithRange:NSMakeRange(position, start.length)] isEqualToString:start]) {
            NSLog(@"Found Begin");
            counter ++;
            continue;
        }
        if (position+end.length < totalLength && [[view.string substringWithRange:NSMakeRange(position, end.length)] isEqualToString:end]) {
            if (counter == 0) {
                NSLog(@"Match!");
                return NSMakeRange(position, end.length);
            }
            NSLog(@"Found End");
            counter --;
            continue;
        }
    }
    return NSMakeRange(NSNotFound, 0);
}

- (void) skipClosingBracket {
    NSUInteger position = [view selectedRange].location;
    if (position < view.string.length) {
        NSRange r = NSMakeRange(position, 1);
        if ([[view.string substringWithRange:r] isEqualToString:@"}"]) {
            [view setSelectedRange:NSMakeRange(position+1, 0)];
        }
    }
}

- (NSArray *)completions:(NSArray *)words forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index {
    return nil;
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
