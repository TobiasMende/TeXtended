//
//  SpellCheckingService.h
//  TeXtended
//
//  Created by Tobias Mende on 26.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "EditorService.h"

/**
This class provides a service for customizing the behaviour of the mac spell checker by adding custom words to ignore.
 
 **Author:** Tobias Mende
 
*/

@interface SpellCheckingService : EditorService {
    /** A set of commands to ignore */
    NSMutableSet *commandsToIgnore;
    
    /** A set of environments to ignore */
    NSMutableSet *environmentsToIgnore;
    
    /** A set of custom words to ignore */
    NSMutableSet *wordsToIgnore;
    
    /** Date storing the last update of the NSSpellChecker */
    NSDate *lastUpdated;
    
    NSOperationQueue *backgroundQueue;
}
/**
 Setups the words and completions to ignore
 */
- (void) setupSpellChecker;

/**
 Method for adding a word to ignore when spell checking
 
 @param string the word to ignore
 */
- (void) addWordToIgnore:(NSString*)string;

/**
 Method for removing a word
 
 @param string the word to remove
 */
- (void) removeWordToIgnore:(NSString*)string;
@end
