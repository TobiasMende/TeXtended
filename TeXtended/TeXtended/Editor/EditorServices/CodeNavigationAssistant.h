//
//  CodeNavigationAssistant.h
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 11.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EditorService.h"

/**
 The CodeNavigationAssistant can be asked for handling insertions and other actions in an NSTextView. For example: line highlighting, carret highlighting or auto indention and tab conversion are basis tasks of this class.
 
 @author Tobias Mende
 */
@interface CodeNavigationAssistant : EditorService {
    /** The last carret range (needed for deleting highlightes) */
    NSRange lastCarretRange;
    /** The range of the last selected line */
    NSRange lastLineRange;
}
/**
 Method for highlighting the current line
 */
- (void) highlightCurrentLine;

/**
 Highlights the current lines background.
 
 @warning You shouldn't call this method directly. It's called by the view when needed.
 */
- (void) highlightCurrentLineBackground;

/**
 Method for highlighting the current foreground text in a given range
 
 @param range the selected range in the view
 
 */
//- (void) highlightCurrentLineForegroundWithRange:(NSRange)range;

/**
 Method for highlighting the carret's position.
 */
- (void) highlightCarret;

/**
 Method for highlighting the current line as well as the carrets position.
 */
- (void) highlight;

/**
 Handles the insertion of a tab. If activated by the user, tabs will be replaced by a user defined amount of spaces.
 */
- (BOOL) handleTabInsertion;

/**
 Handles a backtab insertion after insert in a proper way: If there is a tab oder a matching amount of spaces before, delete them, if not: do nothing.
 
 @return `YES` if this method has handled the backtab, `NO` otherwise.
 */
- (BOOL) handleBacktabInsertion;

/**
 Handles insertion of a new line. If defined by the user the new line will begin with the same indention as the previous line.
 */
- (void) handleNewLineInsertion;

/**
 Getter for the line range for a provided range
 
 @param range the range to get the entire line range without line terminator.
 
 @return the containing line range or a range of multiple lines if the provided range was bigger than a single line.
 */
- (NSRange) lineTextRangeWithRange:(NSRange) range;


/**
 Getter for the line range for a provided range
 
 @param range the range to get the entire line range.
 @param flag if `YES`, the range contains the line termiantor at the end. 
 
 @return the containing line range or a range of multiple lines if the provided range was bigger than a single line.
 */
- (NSRange) lineTextRangeWithRange:(NSRange) range withLineTerminator:(BOOL)flag;

/**
 Handles automatic hard wrapping of long lines in the provided range
 
 @param textRange the range to check and wrap
 
 @return `YES` if this method has wrapped something.
 */
- (BOOL) handleWrappingInRange:(NSRange) textRange;

/**
 Handles automatic hard wrapping in the provided line
 
 @param lineRange the line to wrap
 
 @return `YES` if this method has wrapped somewhere
 */
- (BOOL) handleWrappingInLine:(NSRange) lineRange;

/**
 Handles automatic hard wrapping in the provided line and string
 
 @param lineRange the line to wrap
 @param string the string to wrap in.
 
 @return `YES` if this method has wrapped somewhere
 */
- (BOOL) handleWrappingInLine:(NSRange) lineRange ofString:(NSMutableString *) string;
/**
 Method returns the white space at the beginning of a given line (Usefull for auto-indention)
 
 @param lineRange the line
 
 @return The whitespaces at the line beginning.
 */
- (NSString *) whiteSpacesAtLineBeginning:(NSRange) lineRange;


/**
 This method toggles the comment in each selected line.
 
 If a line has a comment sign at the beginning, it is removed otherwise a new comment sign is added.
 
 @param range the range to toggle comments for
 */
- (IBAction)toggleCommentInRange:(NSRange)range;
/**
 This method toggles the comment in each selected line.
 
 If a line has a comment sign at the beginning, it is removed otherwise a new comment sign is added.
 
 @warning This method is only used as undo target. Use the method [CodeNavigationAssistant toggleCommentInRange:] instead.
 
 @param range the string to toggle comments in
 */
- (IBAction)toggleCommentInRangeString:(NSString*)range;
/**
 This method adds a comment sign at the beginning of each line within the provided range
 
 @param range the range to comment lines in.
 */
- (IBAction)commentSelectionInRange:(NSRange)range;
/**
 This method adds a comment sign at the beginning of each line within the provided range.
 
  @warning This method is only used as undo target. Use the method [CodeNavigationAssistant commentSelectionInRange:] instead.
 
 @param range the range to comment lines in.
 */
- (IBAction)commentSelectionInRangeString:(NSString*)range;

/**
 This method removes a comment sign at the beginning of each line within the provided range
 
 @param range the range to uncomment lines in.
 */
- (IBAction)uncommentSelectionInRange:(NSRange)range;

/**
 This method removes a comment sign at the beginning of each line within the provided range
 
  @warning This method is only used as undo target. Use the method [CodeNavigationAssistant uncommentSelectionInRange:] instead.
 
 @param range the range to uncomment lines in.
 */
- (IBAction)uncommentSelectionInRangeString:(NSString*)range;

/**
 Builds a string representing a line break at the current cursor position in the text view
 @return a string containing whitespaces for the line break and for preserving the indention
 */
- (NSString*) lineBreak;


/**
 Builds a string representing a single tab
 @return a string containing \t if ![self shouldUseSpacesAsTabs] or a string containing [self numberOfSpacesForTab] spaces otherwise.
 */
- (NSString *) singleTab;

/** Number of spaces which should replace a single tab */
@property NSNumber *numberOfSpacesForTab;

/** The background color for highlighting the current line. */
@property (strong) NSColor* currentLineColor;

/** The text color for highlighting the current line */
@property (strong) NSColor* currentLineTextColor;

/** The color for highlighting the character under the carret */
@property (strong) NSColor* carretColor;

/** If `YES`, line highlighting ist active */
@property BOOL shouldHighlightCurrentLine;

/** If `YES`, carret highlighting is active */
@property BOOL shouldHighlightCarret;

/** If `YES`, the text of the current line is highlighted */
@property BOOL shouldHighlightCurrentLineText;

/** If `YES`, tabs were replaced during writing */
@property BOOL shouldUseSpacesAsTabs;

/** If `YES`, a new line has the same indention as the previous line */
@property BOOL shouldAutoIndentLines;

@end
