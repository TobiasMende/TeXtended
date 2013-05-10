//
//  SyntaxHighlighter.h
//  TeXtended
//
//  Created by Tobias Mende on 10.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SyntaxHighlighter
/**
 Method can be called to highlight (or re-highlight) the entire document, meaning the entire string of the text views text storage.
 */
- (void) highlightEntireDocument;

/**
 Method for highlighting (or re-highlighting) only the visible area. In general much more efficient than the highlightEntireDocument method.
 */
- (void) highlightVisibleArea;

/**
 Method for highlighting only a small area around the cursor area. This method only colors a few lines, which might be more efficient than coloring the visible area or the entire document.
 
 @warning Using this method when changing more than one line per call might cause wrong highlighting.
 */
- (void) highlightNarrowArea;

/**
 Highlights text in the given text range
 
 @param range the range to highlight
 */
- (void) highlightRange:(NSRange) range;
@end
