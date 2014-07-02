//
//  CompletionHandler.h
//  TeXtended
//
//  Created by Tobias Mende on 18.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "EditorService.h"
#import "CompletionProtocol.h"

@class Completion, EnvironmentCompletion, CiteCompletion;

@interface CompletionHandler : EditorService

/** if `YES` the environment content is automatically indended on the next line */
    @property BOOL shouldAutoIndentEnvironment;

/** if `YES` commands where automatically completed */
    @property BOOL shouldCompleteCommands;

/** if `YES` environments where automatically completed */
    @property BOOL shouldCompleteEnvironments;

/** if `YES` cites where automatically completed */
    @property BOOL shouldCompleteCites;

    @property BOOL shouldCompleteRefs;

    @property BOOL shouldReplacePlaceholders;

/**
 Method for retreiving matching completions for a given word.
 
 @param words the prefix to get the completion for
 @param charRange the words range in the text
 @param index the index of the selected completion item
 
 @return an array of matching completions (in this case: strings that can be used as keys in the completion dictionaries)
 
 */
    - (NSArray *)completions:(NSArray *)words forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index;

/**
 Method for getting completions for a given range
 
 @param charRange the range to get the completions for.
 @param index the selected completion
 @param info an optional dictionary which can be filled by the handler during completion
 
 @return an array of matching completions (in this case: strings that can be used as keys in the completion dictionaries)
 
 */
    - (NSArray *)completionsForPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index additionalInformation:(NSDictionary **)info;


/**
 Method for checking whethter this class can handle the completion for the provided range or not.
 
 @param charRange the range to check
 
 @return `YES` if this class will handle the completion. `NO` otherwise.
 */
    - (BOOL)willHandleCompletionForPartialWordRange:(NSRange)charRange;

/**
 Method for inserting a completion. This method checks whether the completion must be extended before insertion and handles the final insertion of the correct completion.
 
 @param word the completion to insert
 @param charRange the range of the prefix
 @param movement the text movement type specified in [NSText]
 @param flag if `YES` the completion is final
 
 */
    - (void)insertCompletion:(id <CompletionProtocol>)word forPartialWordRange:(NSRange)charRange movement:(NSInteger)movement isFinal:(BOOL)flag;

/**
 Method for detecting whether the insertion is final or not depending on the text movement type
 
 @param movement the text movement
 
 @return `YES` if the insertion is final, `NO` otherwise.
 
 */
    - (BOOL)isFinalInsertion:(NSUInteger)movement;

/** Checks whether the given insertion is contained in a black list
 
 @param insertion the insertion to check
 
 @return `YES` if the insertion should be completed, `NO` otherwise.
 */
    - (BOOL)shouldCompleteForInsertion:(NSString *)insertion;

/**
 Used by [CompletionHandler insertCommandCompletion:forPartialWordRange:movement:isFinal:] for handling \begin{...} and \end{...} completions.
 
 @param word the completion word
 @param charRange the prefix range
 @param movement the text movement
 @param flag useless flag
 */
    - (void)insertEnvironmentCompletion:(EnvironmentCompletion *)word forPartialWordRange:(NSRange)charRange movement:(NSInteger)movement isFinal:(BOOL)flag;

    - (void)insertCiteCompletion:(CiteCompletion *)word forPartialWordRange:(NSRange)charRange movement:(NSInteger)movement isFinal:(BOOL)flag;

    - (void)insertRefCompletion:(CiteCompletion *)word forPartialWordRange:(NSRange)charRange movement:(NSInteger)movement isFinal:(BOOL)flag;


    - (NSAttributedString *)expandWhiteSpacesInAttrString:(NSAttributedString *)string;
@end
