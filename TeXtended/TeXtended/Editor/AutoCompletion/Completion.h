//
//  Completion.h
//  TeXtended
//
//  Created by Tobias Mende on 18.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 This class represents a posible completion for the auto completion feature.
 
 @author Tobias Mende
 */
@interface Completion : NSObject <NSCoding>
/** The basic insertion (e.g. a \command or an environment name) */
@property (strong,nonatomic) NSString *insertion;
/** Counter for the number of insertions */
@property NSUInteger counter;
/** A possibly empty extension (e.g. {@@placeholder@@}) */
@property (strong) NSString* extension;

/** If `YES` [Completion substitutedExtension] will substitute all placeholders in the [Completion extension] */
@property BOOL hasPlaceholders;

/**
 Method for initializing a new completion with a simple insertion
 
 @param insertion the completion itself
 
 @return a new completion object
 */
- (id)initWithInsertion:(NSString*) insertion;

/**
 An intializer for a new completion with placeholders
 
 @param insertion the insertions name
 @param flag if `YES` placeholders in the insertion where automatically substituted
 
 @return a new completion
 */
- (id)initWithInsertion:(NSString*) insertion containingPlaceholders:(BOOL)flag;

/**
 Initializer for an insertion with an extension.
 
 @param insertion the insertions name
 @param flag if `YES` placeholders where substituted automatically
 @param extension the extension of the completion
 
 @return a new completion object
 */
- (id)initWithInsertion:(NSString*) insertion containingPlaceholders:(BOOL)flag andExtension:(NSString*) extension;

/**
 Methods inserts all attributes of an instance in a dictionary and returns it (good for saving with a human readable format)
 @return the dictionary representation
 */
- (NSMutableDictionary*) dictionaryRepresentation;

/**
 Method for initializing a completion with a dictionary completion
 
 @param dict the dictionary to extract the attributes from
 @return self
 */
- (id) initWithDictionary:(NSDictionary*) dict;

/**
 If [Completion hasPlaceholders] returns `YES`, this method return the [Completion extension] after substituting all placeholders (substrings starting with `@@` and ending with `@@`) with EditorPlaceholder objects.
 
 e.g. @@bla@@ will turn into a placeholder with name "bla"
 
 @return the substituted extension
 */
- (NSAttributedString*) substitutedExtension;

/**
 Method for substituting placeholders (e.g. @@placeholder@@) with an EditorPlaceholder.
 
 @param string the string to substite
 
 @return an attributed string containing the replaced placeholders.
 */
- (NSAttributedString*) substitutePlaceholdersInString:(NSString *) string;

/**
 Method for checking whether [Completion extension] is neither nil nor empty.
 @return `YES` if there is a meaningfull extension
 */
- (BOOL) hasExtension;



/**
 Method for retreiving a key which represents the completion and can be shown to the user to identify this completion.
 @return a key string
 */
- (NSString*)key;

/** Method returns the word which is used during auto completion */
- (NSString*)autoCompletionWord;
@end