//
//  NSTextView+TMTExtensions.h
//  TMTHelperCollection
//
//  Created by Tobias Mende on 02.07.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSTextView (TMTExtensions)
/**
 Getter for the visible range
 @return the visible range
 */
- (NSRange)visibleRange;


/** Getter for the currently selected column
 
 @return the selected column
 */
- (NSUInteger)currentCol;

/** Getter for the column for the selected range
 @param range the range to get the column for.
 
 @return the column of the provided ranges location
 */
- (NSUInteger)colForRange:(NSRange)range;

- (NSUInteger)characterIndexOfPoint:(NSPoint)aPoint;

- (void)skipClosingBracket;
#pragma mark - Line Getter
- (NSRect)lineRectforRange:(NSRange)r;


#pragma mark - Undo Support

/**
 Provides a method which inserts a given text into the textstorage and adds undo support.
 
 @param insertion the string to insert
 @param index the position where to insert the string
 @param name the name of the undo action.
 */
- (void)insertString:(NSString *)insertion atIndex:(NSUInteger)index withActionName:(NSString *)name;

/**
 Inserts an attributed text into the text storage and adds undo support
 
 @param insertion the attributed text to insert
 @param index the position
 @param name the undo action's name
 */
- (void)insertText:(NSAttributedString *)insertion atIndex:(NSUInteger)index withActionName:(NSString *)name;

/**
 Deletes text from text storage within the given range
 
 @param range the text's range
 @param name the action's name
 */
- (void)deleteTextInRange:(NSValue *)range withActionName:(NSString *)name;


/**
 Method for setting the string in the textview with a given action name
 
 @param string the string to set
 @param name the action name to store
 */
- (void)setString:(NSString *)string withActionName:(NSString *)name;

@end
