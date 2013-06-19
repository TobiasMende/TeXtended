//
//  CompletionHandler.h
//  TeXtended
//
//  Created by Tobias Mende on 18.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "EditorService.h"

@interface CompletionHandler : EditorService

/** if `YES` the environment content is automatically indended on the next line */
@property BOOL shouldAutoIndentEnvironment;

/** if `YES` commands where automatically completed */
@property BOOL shouldCompleteCommands;

/** if `YES` environments where automatically compelted */
@property BOOL shouldCompleteEnvironments;


/**
 Method for retreiving matching completions for a given word.
 
 @param words the prefix to get the completion for
 @param charRange the words range in the text
 @param index the index of the selected completion item
 
 @return an array of matching completions (in this case: strings that can be used as keys in the completion dictionaries)
 
 */
- (NSArray*) completions:(NSArray *)words forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index;

/**
 Method for getting completions for a given range
 
 @param charRange the range to get the completions for.
 @param index the selected completion
 
 @return an array of matching completions (in this case: strings that can be used as keys in the completion dictionaries)
 
 */
- (NSArray *)completionsForPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index;


/**
 Method for checking whethter this class can handle the completion for the provided range or not.
 
 @param charRange the range to check
 
 @return `YES` if this class will handle the completion. `NO` otherwise.
 */
- (BOOL) willHandleCompletionForPartialWordRange:(NSRange)charRange;

/**
 Method for inserting a completion. This method checks whether the completion must be extended before insertion and handles the final insertion of the correct completion.
 
 @param word the completion to insert
 @param charRange the range of the prefix
 @param movement the text movement type specified in [NSText]
 @param flag if `YES` the completion is final
 
 */
- (void)insertCompletion:(NSString *)word forPartialWordRange:(NSRange)charRange movement:(NSInteger)movement isFinal:(BOOL)flag;

/**
 Method for detecting whether the insertion is final or not depending on the text movement type
 
 @param movement the text movement
 
 @return `YES` if the insertion is final, `NO` otherwise.
 
 */
- (BOOL) isFinalInsertion:(NSUInteger) movement;
/** Checks whether the given insertion is contained in a black list
 
 @param insertion the insertion to check
 
 @return `YES` if the insertion should be completed, `NO` otherwise.
 */
- (BOOL) shouldCompleteForInsertion:(NSString*) insertion;
@end
