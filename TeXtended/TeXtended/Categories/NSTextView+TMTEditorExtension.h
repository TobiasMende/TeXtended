//
//  NSTextView+TMTEditorExtension.h
//  TeXtended
//
//  Created by Tobias Mende on 02.07.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSTextView (TMTEditorExtension)

- (NSAttributedString *)expandWhiteSpaces:(NSAttributedString *)string;

/** Checks whether a placeholder is placed at the given position in the text view
 
 @param index the location
 
 @return `YES` if a placeholder is placed at the given positon `NO` otherwise. */
- (BOOL)isPlaceholderAtIndex:(NSUInteger)index;

/**
 Method for getting the range of the next placeholder (uses round wrap and starts at @a range.location if no placeholder was found after @a index
 
 @param index The index to start at (must lay within the provided range)
 @param range the search range
 @return range of the next placeholder if one was found or a range with location NSNotFound.
 
 @warning *Throws IndexOutOfRange Exception* if the provided index is not within the provided range
 
 */
- (NSRange)rangeOfNextPlaceholderStartIndex:(NSUInteger)index inRange:(NSRange)range;

/**
 Method for getting the range of the previous placeholder (uses round wrap and starts at @a range.location if no placeholder was found after @a index
 
 @param index The index to start at (must lay within the provided range)
 @param range the search range
 @return range of the previous placeholder if one was found or a range with location NSNotFound.
 
 @warning *Throws IndexOutOfRange Exception* if the provided index is not within the provided range
 
 */
- (NSRange)rangeOfPreviousPlaceholderStartIndex:(NSUInteger)index inRange:(NSRange)range;

/**
 Method for handling the insertion of a single tab
 @return `YES` if the tab was handled by this class, `NO` if the tab should be handled as usual.
 */
- (BOOL)handleInsertTab;

/**
 Method for handling the insertion of a single backtab
 @return `YES` if the backtab was handled by this class, `NO` if the tab should be handled as usual.
 */
- (BOOL)handleInsertBacktab;

@end
