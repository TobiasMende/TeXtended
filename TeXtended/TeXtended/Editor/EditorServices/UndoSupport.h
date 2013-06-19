//
//  UndoSupport.h
//  TeXtended
//
//  Created by Tobias Mende on 25.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "EditorService.h"

/**
 The UndoSupport provides a set of methods providing undo suppor for default methods on the views text storage.
 
 **Author:** Tobias Mende
 
 */
@interface UndoSupport : EditorService


/**
 Provides a method which inserts a given text into the textstorage and adds undo support.
 
 @param insertion the string to insert
 @param index the position where to insert the string
 @param name the name of the undo action.
 */
- (void) insertString:(NSString *)insertion atIndex:(NSUInteger)index withActionName:(NSString*)name;

/**
 Inserts an attributed text into the text storage and adds undo support
 
 @param insertion the attributed text to insert
 @param index the position
 @param name the undo action's name
 */
- (void) insertText:(NSAttributedString *)insertion atIndex:(NSUInteger)index withActionName:(NSString*)name;

/**
 Deletes text from text storage within the given range
 
 @param range the text's range
 @param name the action's name
 */
- (void) deleteTextInRange:(NSValue*)range withActionName:(NSString*)name;


/**
 Method for setting the string in the textview with a given action name
 
 @param string the string to set
 @param name the action name to store
 */
- (void) setString:(NSString *)string withActionName:(NSString*)name;

@end
