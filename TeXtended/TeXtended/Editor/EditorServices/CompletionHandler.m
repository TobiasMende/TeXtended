//
//  CompletionHandler.m
//  TeXtended
//
//  Created by Tobias Mende on 18.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "CompletionHandler.h"
#import "HighlightingTextView.h"
#import "LatexSyntaxHighlighter.h"
#import "ApplicationController.h"
#import "CompletionsController.h"
#import "Completion.h"
#import "CommandCompletion.h"
#import "EnvironmentCompletion.h"
#import "UndoSupport.h"
#import "CodeNavigationAssistant.h";
static const NSDictionary *COMPLETION_TYPE_BY_PREFIX;
static const NSSet *COMPLETION_ESCAPE_INSERTIONS;
static const NSSet *KEYS_TO_UNBIND;
static const NSRegularExpression *TAB_REGEX, *NEW_LINE_REGEX;
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
 
 @return an array of CommandCompletion objects
 */

- (NSArray *)commandCompletionsForPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index;


/**
 Used by [CompletionHandler completionsForPartialWordRange:indexOfSelectedItem:] for handling \begin{...} and \end{...} completions.
 
 @param charRange the prefix range
 @param index the selected entry
 @param type the type of the completion
 
 @return an array of EnvironmentCompletion objects
 */
- (NSArray *)environmentCompletionsForPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index completionType:(TMTCompletionType)type;

/**
 Used by [CompletionHandler insertCommandCompletion:forPartialWordRange:movement:isFinal:] for handling \command completions.
 
 @param word the completion word
 @param charRange the prefix range
 @param movement the text movement
 @param flag useless flag
 */
- (void)insertCommandCompletion:(NSString *)word forPartialWordRange:(NSRange)charRange movement:(NSInteger)movement isFinal:(BOOL)flag;


/**
 Used by [CompletionHandler insertCommandCompletion:forPartialWordRange:movement:isFinal:] for handling \begin{...} and \end{...} completions.
 
 @param word the completion word
 @param charRange the prefix range
 @param movement the text movement
 @param flag useless flag
 */
- (void)insertEnvironmentCompletion:(NSString *)word forPartialWordRange:(NSRange)charRange movement:(NSInteger)movement isFinal:(BOOL)flag;

/**
 Method for detecting the completion type by the prefix range.
 
 @param charRange the prefix range
 
 @return the completion type or TMTNoCompletion if this class can't handle this completion.
 */
- (TMTCompletionType) completionTypeForPartialWordRange:(NSRange) charRange;

/** Method for detecting and skipping the closing bracket of a \begin{...} statement */
- (void) skipClosingBracket;

- (NSAttributedString*)expandWhiteSpacesInAttrString:(NSAttributedString *) string;

- (void) unbindAll;

@end

@implementation CompletionHandler

+ (void)initialize {
    KEYS_TO_UNBIND = [NSSet setWithObjects:@"shouldCompleteEnvironments",@"shouldCompleteCommands",@"shouldAutoIndentEnvironment", nil];
    
    COMPLETION_TYPE_BY_PREFIX = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:TMTCommandCompletion], @"\\", [NSNumber numberWithInt:TMTBeginCompletion],@"\\begin{", [NSNumber numberWithInt:TMTEndCompletion],@"\\end{", nil];
    COMPLETION_ESCAPE_INSERTIONS = [NSSet setWithObjects:@"{",@"}", @"[", @"]", @"(", @")", @" ", nil];
    NSError *error;
    TAB_REGEX = [NSRegularExpression regularExpressionWithPattern:@"(\\t|\\\\t)" options:0 error:&error];
    NEW_LINE_REGEX = [NSRegularExpression regularExpressionWithPattern:@"\\n|\\\\n" options:0 error:&error];
    
    if (error) {
        NSLog(@"CompletionHandler: Can't creat regular expressions: %@", error.userInfo);
    }
    
}

- (id)initWithTextView:(HighlightingTextView *)tv {
    self = [super initWithTextView:tv];
    if (self) {
         NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController]; 
        
        self.shouldCompleteEnvironments = [[[defaults values] valueForKey:TMT_SHOULD_COMPLETE_ENVIRONMENTS] boolValue];
        [self bind:@"shouldCompleteEnvironments" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_SHOULD_COMPLETE_ENVIRONMENTS] options:NULL];
    
    
    
        self.shouldCompleteCommands = [[[defaults values] valueForKey:TMT_SHOULD_COMPLETE_COMMANDS] boolValue];
        [self bind:@"shouldCompleteCommands" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_SHOULD_COMPLETE_COMMANDS] options:NULL];
        
        self.shouldAutoIndentEnvironment = [[[defaults values] valueForKey:TMT_SHOULD_AUTO_INDENT_ENVIRONMENTS] boolValue];
        [self bind:@"shouldAutoIndentEnvironment" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_SHOULD_AUTO_INDENT_ENVIRONMENTS] options:NULL];
    }
    return self;
}




- (NSArray *)completionsForPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index {
    TMTCompletionType type = [self completionTypeForPartialWordRange:charRange];
    switch (type) {
        case TMTCommandCompletion:
            if (!self.shouldCompleteCommands) {
                return nil;
            }
            return [self commandCompletionsForPartialWordRange:charRange indexOfSelectedItem:index];
            break;
        case TMTBeginCompletion:
            if (!self.shouldCompleteEnvironments) {
                return nil;
            }
            return [self environmentCompletionsForPartialWordRange:charRange indexOfSelectedItem:index completionType:type];
            break;
        case TMTEndCompletion:
            if (!self.shouldCompleteEnvironments) {
                return nil;
            }
            return [self environmentCompletionsForPartialWordRange:charRange indexOfSelectedItem:index completionType:type];
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
    NSDictionary *completions = [[[ApplicationController sharedApplicationController] completionsController] commandCompletions] ;
    NSMutableArray *matchingKeys = [[NSMutableArray alloc] init];
    for (NSString *key in completions) {
        if ([key hasPrefix:prefix]) {
            [matchingKeys addObject:[completions objectForKey:key]];
        }
    }
    [matchingKeys sortUsingSelector:@selector(compare:)];
    return matchingKeys;
}

- (NSArray *)environmentCompletionsForPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index completionType:(TMTCompletionType)type{
    NSString *prefix = [view.string substringWithRange:charRange];
    NSDictionary *completions = [[[ApplicationController sharedApplicationController] completionsController] environmentCompletions] ;
    NSMutableArray *matchingCompletions = [[NSMutableArray alloc] init];
    for (NSString *key in completions) {
        if ([key hasPrefix:prefix]) {
                [matchingCompletions addObject:[completions objectForKey:key]];
        }
    }
    [matchingCompletions sortUsingSelector:@selector(compare:)];
    return matchingCompletions;
}



- (void)insertCompletion:(NSString *)word forPartialWordRange:(NSRange)charRange movement:(NSInteger)movement isFinal:(BOOL)flag {
    if (movement == NSRightTextMovement) {
        return;
    }
    TMTCompletionType type = [self completionTypeForPartialWordRange:charRange];
    
    switch (type) {
        case TMTCommandCompletion:
            if (!self.shouldCompleteCommands) {
                return;
            }
            [self insertCommandCompletion:word forPartialWordRange:charRange movement:movement isFinal:flag];
            break;
        case TMTBeginCompletion:
            if (!self.shouldCompleteEnvironments) {
                return;
            }
            [self insertEnvironmentCompletion:word forPartialWordRange:charRange movement:movement isFinal:flag];
            break;
        case TMTEndCompletion:
            if (!self.shouldCompleteEnvironments) {
                return;
            }
            [view insertFinalCompletion:[(Completion*)word insertion] forPartialWordRange:charRange movement:movement isFinal:flag];
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
     
    CommandCompletion *completion = (CommandCompletion *)word;
    if (flag && [self isFinalInsertion:movement]) {
        completion.counter++;
        if ([completion hasPlaceholders]) {
        
        
        NSMutableAttributedString *final = [[NSMutableAttributedString alloc] initWithString:[[completion insertion] substringWithRange:NSMakeRange(1, completion.insertion.length-1)]];
            [final appendAttributedString:[self expandWhiteSpacesInAttrString:[completion substitutedExtension]]];
            [view.undoManager beginUndoGrouping];
            [view setSelectedRange:NSUnionRange(view.selectedRange, charRange)];
            [view delete:nil];
            [view  insertText:final];
            //[view setSelectedRange:NSMakeRange(NSMaxRange(charRange), 0)];
            [view setSelectedRange:NSMakeRange(charRange.location, 0)];
            [view jumpToNextPlaceholder];
            [view.undoManager endUndoGrouping];
        } else {
            [view insertFinalCompletion:[word substringWithRange:NSMakeRange(1, word.length-1)] forPartialWordRange:charRange movement:movement isFinal:flag];
        }
    } else {
        if ([completion respondsToSelector:@selector(insertion)]) {
            [view insertFinalCompletion:[completion.insertion substringWithRange:NSMakeRange(1, completion.insertion.length-1)] forPartialWordRange:charRange movement:movement isFinal:flag];
        } else {
            [view insertFinalCompletion:[completion substringWithRange:NSMakeRange(1, completion.length-1)] forPartialWordRange:charRange movement:movement isFinal:flag];
        }
    }
    
}

- (void)insertEnvironmentCompletion:(NSString *)word forPartialWordRange:(NSRange)charRange movement:(NSInteger)movement isFinal:(BOOL)flag {
    //Attention: Word isn't a string. its an EnvironmentCompletion ;)
    
    EnvironmentCompletion *completion = (EnvironmentCompletion*)word;
    TMTCompletionType type = [self completionTypeForPartialWordRange:charRange];
    if (type != TMTBeginCompletion) {
        return;
    }
    if (!flag || ![self isFinalInsertion:movement]) {
        if([completion respondsToSelector:@selector(insertion)]) {
            [view insertFinalCompletion:completion.insertion forPartialWordRange:charRange movement:movement isFinal:flag];
        } else {
            [view insertFinalCompletion:completion forPartialWordRange:charRange movement:movement isFinal:flag];
        }
        return;
    }
    completion.counter++;
    [view insertFinalCompletion:completion.insertion forPartialWordRange:charRange movement:movement isFinal:flag];
    [self skipClosingBracket];
    NSUInteger position = [view selectedRange].location;
    // NSRange visible = [view visibleRange];
//    NSRange range;
//    if (position > visible.location) {
//        NSUInteger dif = position - visible.location;
//        range = NSMakeRange(position, visible.length-dif);
//    } else {
//        range = visible;
//    }
    
   
    NSRange endRange = NSMakeRange(NSNotFound, 0);//TODO: [self matchingEndForEnvironment:word inRange:range];
    [view.undoManager beginUndoGrouping];
    [view setSelectedRange:NSMakeRange(position, 0)];
    NSMutableAttributedString *string = [NSMutableAttributedString new];
    if ([completion hasFirstLineExtension]) {
        [string appendAttributedString:[completion substitutedFirstLineExtension]];
    }
    if ([completion hasExtension]) {
        NSAttributedString *singleTab = [[NSAttributedString alloc] initWithString:[view.codeNavigationAssistant singleTab] attributes:nil];
        NSAttributedString *newLine = [[NSAttributedString alloc] initWithString:[view.codeNavigationAssistant lineBreak] attributes:nil];
    if (self.shouldAutoIndentEnvironment) {
        [string appendAttributedString:newLine];
        [string appendAttributedString:singleTab];
    }
    if (completion && [completion hasPlaceholders]) {
        [string appendAttributedString:[self expandWhiteSpacesInAttrString:[completion substitutedExtension]]];
    }
    }
    if (endRange.location == NSNotFound) {
        if (self.shouldAutoIndentEnvironment && [completion hasExtension]) {
            [string appendAttributedString:[[NSAttributedString alloc] initWithString:[view.codeNavigationAssistant lineBreak] attributes:nil]];
        }
        [string appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\\end{%@}", completion.insertion] attributes:nil]];
        
    }
    [view insertText:string];
    [view setSelectedRange:NSMakeRange(position, 0)];
    if ([completion hasPlaceholders]) {
        [view setSelectedRange:NSMakeRange(position, 0)];
        [view jumpToNextPlaceholder];
    }
    [view.undoManager endUndoGrouping];
    
    
    
}

- (NSAttributedString*)expandWhiteSpacesInAttrString:(NSAttributedString *) string {
    NSAttributedString *singleTab = [[NSAttributedString alloc] initWithString:[view.codeNavigationAssistant singleTab] attributes:nil];
    NSAttributedString *newLine = [[NSAttributedString alloc] initWithString:[view.codeNavigationAssistant lineBreak] attributes:nil];
    NSMutableAttributedString *extension = [string mutableCopy];
    NSArray *tabs = [TAB_REGEX matchesInString:extension.string options:0 range:NSMakeRange(0, extension.string.length)];
    for(NSTextCheckingResult *r in [tabs reverseObjectEnumerator]) {
        [extension replaceCharactersInRange:r.range withAttributedString:singleTab];
    }
    NSArray *newlines = [NEW_LINE_REGEX matchesInString:extension.string options:0 range:NSMakeRange(0, extension.string.length)];
    for(NSTextCheckingResult *r in [newlines reverseObjectEnumerator]) {
        [extension replaceCharactersInRange:r.range withAttributedString:newLine];
    }
    return extension;
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
            break;
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

- (BOOL)shouldCompleteForInsertion:(NSString *)insertion {
    return ![COMPLETION_ESCAPE_INSERTIONS containsObject:insertion];
}


- (void)dealloc {
#ifdef DEBUG
    NSLog(@"CompletionHandler dealloc");
#endif
    [self unbindAll];
}

- (void)unbindAll {
    for(NSString *key in KEYS_TO_UNBIND) {
        [self unbind:key];
    }
}
@end
