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
 Method for highlighting the carret's position.
 */
- (void) highlightCarret;

- (void) highlight;

/**
 Handles the insertion of a tab. If activated by the user, tabs will be replaced by a user defined amount of spaces.
 */
- (void) handleTabInsertion;

- (BOOL) handleBacktabInsertion;

/**
 Handles insertion of a new line. If defined by the user the new line will begin with the same indention as the previous line.
 */
- (void) handleNewLineInsertion;


/** Number of spaces which should replace a single tab */
@property NSNumber *numberOfSpacesForTab;

/** The background color for highlighting the current line. */
@property (strong,nonatomic) NSColor* currentLineColor;

/** The text color for highlighting the current line */
@property (strong,nonatomic) NSColor* currentLineTextColor;

/** The color for highlighting the character under the carret */
@property (strong, nonatomic) NSColor* carretColor;

/** If `YES`, line highlighting ist active */
@property (nonatomic) BOOL shouldHighlightCurrentLine;

/** If `YES`, carret highlighting is active */
@property (nonatomic) BOOL shouldHighlightCarret;

/** If `YES`, the text of the current line is highlighted */
@property (nonatomic) BOOL shouldHighlightCurrentLineText;

/** If `YES`, tabs were replaced during writing */
@property BOOL shouldUseSpacesAsTabs;

/** If `YES`, a new line has the same indention as the previous line */
@property BOOL shouldAutoIndentLines;
@end
