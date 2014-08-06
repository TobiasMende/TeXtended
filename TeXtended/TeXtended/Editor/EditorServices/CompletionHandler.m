//
//  CompletionHandler.m
//  TeXtended
//
//  Created by Tobias Mende on 18.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "CompletionHandler.h"
#import "HighlightingTextView.h"
#import "CompletionManager.h"
#import "Completion.h"
#import "CommandCompletion.h"
#import "CiteCompletion.h"
#import "EnvironmentCompletion.h"
#import "CodeNavigationAssistant.h"
#import <TMTHelperCollection/TMTLog.h>
#import <TMTHelperCollection/NSString+LatexExtensions.h>
#import <TMTHelperCollection/NSTextView+LatexExtensions.h>
#import "NSString+TMTEditorExtensions.h"
#import "NSTextView+TMTEditorExtension.h"
#import "BibFile.h"
#import "CompletionTableController.h"
#import "OutlineHelper.h"
#import "OutlineElement.h"

LOGGING_DEFAULT

static const NSDictionary *COMPLETION_TYPE_BY_PREFIX;

static const NSDictionary *COMPLETION_BY_PREFIX_TYPE;

static const NSSet *COMPLETION_ESCAPE_INSERTIONS;

static const NSSet *KEYS_TO_UNBIND;




@interface CompletionHandler ()

/**
 Used by [CompletionHandler completionsForPartialWordRange:indexOfSelectedItem:] for handling \command completions.
 
 @param charRange the prefix range
 @param index the selected entry
 @param info an optional dictionary which can be filled during completion
 
 @return an array of CommandCompletion objects
 */

    - (NSArray *)commandCompletionsForPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index additionalInformation:(NSDictionary **)info;

    - (NSArray *)citeCompletionsForPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index additionalInformation:(NSDictionary **)info;

    - (NSArray *)refCompletionsForPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index additionalInformation:(NSDictionary **)info;


/**
 Used by [CompletionHandler completionsForPartialWordRange:indexOfSelectedItem:] for handling \begin{...} and \end{...} completions.
 
 @param charRange the prefix range
 @param index the selected entry
 @param type the type of the completion
 @param info an additional dictionary which can be filled in this method.
 @return an array of EnvironmentCompletion objects
 */
    - (NSArray *)environmentCompletionsForPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index completionType:(TMTCompletionType)type additionalInformation:(NSDictionary **)info;

/**
 Used by [CompletionHandler insertCommandCompletion:forPartialWordRange:movement:isFinal:] for handling \command completions.
 
 @param word the completion word
 @param charRange the prefix range
 @param movement the text movement
 @param flag useless flag
 */
    - (void)insertCommandCompletion:(CommandCompletion *)word forPartialWordRange:(NSRange)charRange movement:(NSInteger)movement isFinal:(BOOL)flag;


/**
 Method for detecting the completion type by the prefix range.
 
 @param charRange the prefix range
 
 @return the completion type or TMTNoCompletion if this class can't handle this completion.
 */
    - (TMTCompletionType)completionTypeForPartialWordRange:(NSRange)charRange;



    - (void)unbindAll;

@end

@implementation CompletionHandler

    + (void)initialize
    {
        KEYS_TO_UNBIND = [NSSet setWithObjects:@"shouldCompleteEnvironments", @"shouldCompleteCommands", @"shouldAutoIndentEnvironment", @"shouldCompleteCites", @"shouldCompleteRefs", nil];

        COMPLETION_TYPE_BY_PREFIX = @{@"\\" : @(TMTCommandCompletion), @"\\begin{" : @(TMTBeginCompletion), @"\\end{" : @(TMTEndCompletion)};
        COMPLETION_ESCAPE_INSERTIONS = [NSSet setWithObjects:@"{", @"}", @"[", @"]", @"(", @")", nil];


        COMPLETION_BY_PREFIX_TYPE = @{CommandTypeCite : @(TMTCiteCompletion), CommandTypeLabel : @(TMTLabelCompletion), CommandTypeRef : @(TMTRefCompletion)};

    }

    - (id)initWithTextView:(HighlightingTextView *)tv
    {
        self = [super initWithTextView:tv];
        if (self) {
            NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];

            self.shouldCompleteEnvironments = [[[defaults values] valueForKey:TMT_SHOULD_COMPLETE_ENVIRONMENTS] boolValue];
            [self bind:@"shouldCompleteEnvironments" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_SHOULD_COMPLETE_ENVIRONMENTS] options:NULL];

            self.shouldCompleteCites = [[[defaults values] valueForKey:TMTShouldCompleteCites] boolValue];
            [self bind:@"shouldCompleteCites" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMTShouldCompleteCites] options:NULL];

            self.shouldCompleteRefs = [[[defaults values] valueForKey:TMTShouldCompleteRefs] boolValue];
            [self bind:@"shouldCompleteRefs" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMTShouldCompleteRefs] options:NULL];

            self.shouldCompleteCommands = [[[defaults values] valueForKey:TMT_SHOULD_COMPLETE_COMMANDS] boolValue];
            [self bind:@"shouldCompleteCommands" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_SHOULD_COMPLETE_COMMANDS] options:NULL];

            self.shouldAutoIndentEnvironment = [[[defaults values] valueForKey:TMT_SHOULD_AUTO_INDENT_ENVIRONMENTS] boolValue];
            [self bind:@"shouldAutoIndentEnvironment" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_SHOULD_AUTO_INDENT_ENVIRONMENTS] options:NULL];
            self.shouldReplacePlaceholders = YES;
        }
        return self;
    }


    - (NSArray *)completionsForPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index additionalInformation:(NSDictionary **)info
    {
        TMTCompletionType type = [self completionTypeForPartialWordRange:charRange];
        switch (type) {
            case TMTCommandCompletion:
                if (!self.shouldCompleteCommands) {
                    return nil;
                }
                return [self commandCompletionsForPartialWordRange:charRange indexOfSelectedItem:index additionalInformation:info];
            case TMTBeginCompletion:
                if (!self.shouldCompleteEnvironments) {
                    return nil;
                }
                return [self environmentCompletionsForPartialWordRange:charRange indexOfSelectedItem:index completionType:type additionalInformation:info];
            case TMTEndCompletion:
                if (!self.shouldCompleteEnvironments) {
                    return nil;
                }
                return [self environmentCompletionsForPartialWordRange:charRange indexOfSelectedItem:index completionType:type additionalInformation:info];
            case TMTCiteCompletion:
                return [self citeCompletionsForPartialWordRange:charRange indexOfSelectedItem:index additionalInformation:info];
            case TMTRefCompletion:
                return [self refCompletionsForPartialWordRange:charRange indexOfSelectedItem:index additionalInformation:info];
            default:
                return nil;
        }
        return nil;
    }

    - (NSArray *)citeCompletionsForPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index additionalInformation:(NSDictionary **)info
    {
        if (!self.shouldCompleteCites || ![view.firstResponderDelegate model].bibFiles) {
            return nil;
        }
        *info = @{TMTShouldShowDBLPKey : @YES, TMTCompletionTypeKey : @(TMTCiteCompletion)};
        charRange = [view.string extendedCiteEntryPrefixRangeFor:charRange];
        NSString *prefix = [[view.string substringWithRange:charRange] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

        NSArray *bibFiles = [view.firstResponderDelegate model].bibFiles;
        NSMutableArray *allEntries = [NSMutableArray new];
        for (BibFile *model in bibFiles) {
            [allEntries addObjectsFromArray:model.entries];
        }
        NSMutableArray *matches = [NSMutableArray new];
        for (id <CompletionProtocol> c in allEntries) {
            if ([c respondsToSelector:@selector(completionMatchesPrefix:)] && [c completionMatchesPrefix:prefix]) {
                [matches addObject:c];
            }
        }
        [matches sortUsingSelector:@selector(compare:)];
        return matches;
    }

    - (NSArray *)refCompletionsForPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index additionalInformation:(NSDictionary * __autoreleasing *)info
    {
        if (!self.shouldCompleteRefs) {
            return nil;
        }
        *info = @{TMTCompletionTypeKey : @(TMTRefCompletion)};
        charRange = [view.string extendedCiteEntryPrefixRangeFor:charRange];
        NSString *prefix = [[view.string substringWithRange:charRange] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

        NSArray *mainDocuments = [view.firstResponderDelegate model].mainDocuments;
        NSMutableArray *matches = [NSMutableArray new];
        for (DocumentModel *model in mainDocuments) {
            NSMutableArray *all = [OutlineHelper flatten:model.outlineElements withPath:[NSMutableSet new]];
            for (OutlineElement *el in all) {
                if (el.type == LABEL && [el completionMatchesPrefix:prefix]) {
                    [matches addObject:el];
                }
            }
        }
        [matches sortUsingSelector:@selector(compare:)];
        return matches;
    }




    - (NSArray *)commandCompletionsForPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index additionalInformation:(NSDictionary * __autoreleasing *)info
    {
        *info = @{TMTCompletionTypeKey : @(TMTCommandCompletion)};
        NSString *prefix = [@"\\" stringByAppendingString:[view.string substringWithRange:charRange]];
        NSArray *completions = [CompletionManager sharedInstance].commandCompletions.completions;
        NSMutableArray *matchingKeys = [[NSMutableArray alloc] init];
        for (CommandCompletion *c in completions) {
            if ([c.key hasPrefix:prefix]) {
                [matchingKeys addObject:c];
            }
        }
        [matchingKeys sortUsingSelector:@selector(compare:)];
        return matchingKeys;
    }

    - (NSArray *)environmentCompletionsForPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index completionType:(TMTCompletionType)type additionalInformation:(NSDictionary * __autoreleasing *)info
    {
        *info = @{TMTCompletionTypeKey : [NSNumber numberWithInt:type]};
        NSString *prefix = [view.string substringWithRange:charRange];
        NSArray *completions = [CompletionManager sharedInstance].environmentCompletions.completions;
        NSMutableArray *matchingCompletions = [[NSMutableArray alloc] init];
        for (EnvironmentCompletion *c in completions) {
            if ([c.key hasPrefix:prefix]) {
                [matchingCompletions addObject:c];
            }
        }
        [matchingCompletions sortUsingSelector:@selector(compare:)];
        if (matchingCompletions.count == 0) {
            [matchingCompletions addObject:[EnvironmentCompletion dummyCompletion:prefix]];
        }
        return matchingCompletions;
    }


    - (void)insertCompletion:(id <CompletionProtocol>)word forPartialWordRange:(NSRange)charRange movement:(NSInteger)movement isFinal:(BOOL)flag
    {
        if (movement == NSRightTextMovement) {
            return;
        }
        TMTCompletionType type = [self completionTypeForPartialWordRange:charRange];

        switch (type) {
            case TMTCommandCompletion:
                if (!self.shouldCompleteCommands) {
                    return;
                }
                [self insertCommandCompletion:(CommandCompletion *) word forPartialWordRange:charRange movement:movement isFinal:flag];
                break;
            case TMTBeginCompletion:
                if (!self.shouldCompleteEnvironments) {
                    return;
                }
                [self insertEnvironmentCompletion:(EnvironmentCompletion *) word forPartialWordRange:charRange movement:movement isFinal:flag];
                break;
            case TMTEndCompletion:
                if (!self.shouldCompleteEnvironments) {
                    return;
                }
                [view insertFinalCompletion:word forPartialWordRange:charRange movement:movement isFinal:flag];
                if (flag && [view isFinalInsertion:movement]) {
                    [view skipClosingBracket];
                }
                break;
            case TMTCiteCompletion:
                [self insertCiteCompletion:(CiteCompletion *) word forPartialWordRange:charRange movement:movement isFinal:flag];
                break;
            case TMTRefCompletion:
                [self insertRefCompletion:(OutlineElement *) word forPartialWordRange:charRange movement:movement isFinal:flag];
                break;
            default:
                DDLogInfo(@"NoCompletion");
                break;
        }
    }

    - (void)insertCiteCompletion:(CiteCompletion *)completion forPartialWordRange:(NSRange)charRange movement:(NSInteger)movement isFinal:(BOOL)flag
    {
        if (flag && [view isFinalInsertion:movement]) {
            [view.undoManager beginUndoGrouping];
            charRange = [view.string extendedCiteEntryPrefixRangeFor:charRange];
            [view setSelectedRange:charRange];
            [view delete:nil];
            [view insertText:completion.key];
            [view.undoManager endUndoGrouping];
        }
    }

    - (void)insertRefCompletion:(OutlineElement *)completion forPartialWordRange:(NSRange)charRange movement:(NSInteger)movement isFinal:(BOOL)flag
    {
        if (flag && [view isFinalInsertion:movement]) {
            [view.undoManager beginUndoGrouping];
            charRange = [view.string extendedCiteEntryPrefixRangeFor:charRange];
            [view setSelectedRange:charRange];
            [view delete:nil];
            [view insertText:completion.key];
            [view.undoManager endUndoGrouping];
        }
    }

    - (void)insertCommandCompletion:(CommandCompletion *)completion forPartialWordRange:(NSRange)charRange movement:(NSInteger)movement isFinal:(BOOL)flag
    {

        if (flag && [view isFinalInsertion:movement]) {
            completion.counter++;
            if ([completion hasPlaceholders] && self.shouldReplacePlaceholders) {


                [view.undoManager beginUndoGrouping];
                NSMutableAttributedString *final = [[NSMutableAttributedString alloc] initWithString:[[completion insertion] substringWithRange:NSMakeRange(1, completion.insertion.length - 1)]];
                if (!(view.currentModifierFlags & NSAlternateKeyMask)) {
                    [final appendAttributedString:[view expandWhiteSpaces:completion.substitutedExtension]];
                }
                [view setSelectedRange:NSUnionRange(view.selectedRange, charRange)];
                [view delete:nil];
                [view insertText:final];
                //[view setSelectedRange:NSMakeRange(NSMaxRange(charRange), 0)];
                if (!(view.currentModifierFlags & NSAlternateKeyMask)) {
                    [view setSelectedRange:NSMakeRange(charRange.location, 0)];
                    [view jumpToNextPlaceholder];
                }
                [view.undoManager endUndoGrouping];
            } else {
                [view insertFinalCompletion:completion forPartialWordRange:charRange movement:movement isFinal:flag];
            }
        } else {
            
            [view insertFinalCompletion:completion forPartialWordRange:charRange movement:movement isFinal:flag];
        }

    }

    - (void)insertEnvironmentCompletion:(EnvironmentCompletion *)completion forPartialWordRange:(NSRange)charRange movement:(NSInteger)movement isFinal:(BOOL)flag
    {


        TMTCompletionType type = [self completionTypeForPartialWordRange:charRange];
        if (type != TMTBeginCompletion && type != TMTNoCompletion) {
            return;
        }
        if (!flag || ![view isFinalInsertion:movement]) {
            [view insertFinalCompletion:completion forPartialWordRange:charRange movement:movement isFinal:flag];
            return;
        }
        completion.counter++;
        NSString *start;
        if (type == TMTNoCompletion) {
            start = [NSString stringWithFormat:@"\\begin{%@}", completion.insertion];
            [view insertText:start replacementRange:charRange];
        } else {
            [view insertFinalCompletion:completion forPartialWordRange:charRange movement:movement isFinal:flag];
        }

        [view skipClosingBracket];
        NSUInteger position = [view selectedRange].location;


        if (!(view.currentModifierFlags & NSAlternateKeyMask) || type == TMTNoCompletion) {
            [view.undoManager beginUndoGrouping];
            [view setSelectedRange:NSMakeRange(position, 0)];
            NSMutableAttributedString *string = [NSMutableAttributedString new];
            if ([completion hasFirstLineExtension]) {
                [string appendAttributedString:[completion substitutedFirstLineExtension]];
            }
            if ([completion hasExtension]) {
                NSAttributedString *singleTab = [[NSAttributedString alloc] initWithString:[NSString singleTab] attributes:nil];
                NSAttributedString *newLine = [[NSAttributedString alloc] initWithString:[view.string lineBreakForPosition:view.selectedRange.location] attributes:nil];
                if (self.shouldAutoIndentEnvironment) {
                    [string appendAttributedString:newLine];
                    [string appendAttributedString:singleTab];
                }
                if (completion && [completion hasPlaceholders] && self.shouldReplacePlaceholders) {
                    [string appendAttributedString:[view expandWhiteSpaces:completion.substitutedExtension]];
                }
            }
            if (self.shouldAutoIndentEnvironment && [completion hasExtension]) {
                [string appendAttributedString:[[NSAttributedString alloc] initWithString:[view.string lineBreakForPosition:view.selectedRange.location] attributes:nil]];
            }
            [string appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\\end{%@}", completion.insertion] attributes:nil]];

            [view insertText:string];
            [view setSelectedRange:NSMakeRange(position, 0)];
            if ([completion hasPlaceholders] && self.shouldReplacePlaceholders) {
                [view setSelectedRange:NSMakeRange(position, 0)];
                [view jumpToNextPlaceholder];
            }
            [view.undoManager endUndoGrouping];
        }


    }


    - (NSArray *)completions:(NSArray *)words forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index
    {
        return nil;
    }


    - (BOOL)willHandleCompletionForPartialWordRange:(NSRange)charRange
    {
        return [self completionTypeForPartialWordRange:charRange] != TMTNoCompletion;
    }


    - (TMTCompletionType)completionTypeForPartialWordRange:(NSRange)charRange
    {

        for (NSString *key in COMPLETION_TYPE_BY_PREFIX) {
            if (charRange.location >= [key length]) {
                NSRange prefixRange = NSMakeRange(charRange.location - key.length, key.length);
                if (prefixRange.location == NSNotFound) {
                    return TMTNoCompletion;
                }
                NSString *prefixString = [view.string substringWithRange:prefixRange];
                if ([prefixString isEqualToString:key]) {
                    return [COMPLETION_TYPE_BY_PREFIX[key] intValue];
                }
            }
        }
        NSRange prefixRange = [view.string latexCommandPrefixRangeBeforePosition:charRange.location];
        if (prefixRange.location == NSNotFound) {
            return TMTNoCompletion;
        }
        for (NSString *type in COMPLETION_BY_PREFIX_TYPE.allKeys) {
            NSSet *commands = [[CompletionManager sharedInstance] commandCompletionsByType:type];
            for (NSValue *value in commands) {
                NSString *key = ((CommandCompletion *) value.nonretainedObjectValue).prefix;
                if (charRange.location >= [key length]) {
                    // NSRange prefixRange = NSMakeRange(charRange.location-key.length, key.length);
                    NSString *prefixString = [view.string substringWithRange:prefixRange];
                    if ([prefixString isEqualToString:key]) {
                        return [COMPLETION_BY_PREFIX_TYPE[type] intValue];
                    }
                }
            }
        }
        return TMTNoCompletion;
    }

    - (BOOL)shouldCompleteForInsertion:(NSString *)insertion
    {
        return ![COMPLETION_ESCAPE_INSERTIONS containsObject:insertion];
    }


    - (void)dealloc
    {
        TMT_TRACE
        [self unbindAll];
    }

    - (void)unbindAll
    {
        for (NSString *key in KEYS_TO_UNBIND) {
            [self unbind:key];
        }
    }
@end
