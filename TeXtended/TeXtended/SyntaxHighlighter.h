//
//  RegexHighlighter.h
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 09.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "EditorService.h"
/**
 The SyntaxHighlighter provides a simple regex based highlighter for latex syntax.
 
 All kinds of syntax highlighting are optional. Furthermore the color for each highlighting is customizable. 
 
 @author Tobias Mende
 */
@interface SyntaxHighlighter : EditorService {
}
/** The color in which to highlight math (text between $ and $ or \[ and \] */
@property (strong,nonatomic) NSColor *inlineMathColor;

/** The color in which to highlight commands (e.g. \text) */
@property (strong,nonatomic) NSColor *commandColor;

/** The color in which to highlight brackets like (, ), [ and ] */
@property (strong,nonatomic) NSColor *bracketColor;

/** The color for curly brackets */
@property (strong,nonatomic) NSColor *curlyBracketColor;

/** The color for comments */
@property (strong,nonatomic) NSColor *commentColor;

/** Flag activativating highlighting of curly brackets (the argument area) */
@property (nonatomic) BOOL shouldHighlightArguments;

/** Flag activating highlighting of commands */
@property (nonatomic) BOOL shouldHighlightCommands;

/** Flag activating highlighting of comments */
@property (nonatomic) BOOL shouldHighlightComments;

/** Flag activating highlighting of other than curly brackets */
@property (nonatomic) BOOL shouldHighlightBrackets;

/** Flag activating highlighting of inline math */
@property (nonatomic) BOOL shouldHighlightInlineMath;

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

/** Initializer for this class.
 @param tv The textview to deal with.
 @warning Instances of this class might be useless if created by another method.
 */
- (id) initWithTextView:(NSTextView* )tv;

/**
 Method for invalidating and deleting the highlighting of the entire document.
 */
- (void) invalidateHighlighting;
@end
