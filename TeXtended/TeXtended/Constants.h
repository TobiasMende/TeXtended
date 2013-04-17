//
//  Constants.h
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 10.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>


/*
 KVC keys for NSColor objects (used for user defaults)
 */
#define TMT_INLINE_MATH_COLOR @"TMTInlineMathColor"
#define TMT_COMMAND_COLOR @"TMTCommandColor"
#define TMT_COMMENT_COLOR @"TMTCommentColor"
#define TMT_BRACKET_COLOR @"TMTBracketColor"
#define TMT_ARGUMENT_COLOR @"TMTArgumentColor"
#define TMT_CURRENT_LINE_COLOR @"TMTCurrentLineColor"
#define TMT_CURRENT_LINE_TEXT_COLOR @"TMTCurrentLineTextColor"
#define TMT_CARRET_COLOR @"TMTCarretColor"
#define TMT_EDITOR_BACKGROUND_COLOR @"TMTEditorBackgroundColor"
#define TMT_EDITOR_FOREGROUND_COLOR @"TMTEditorForegroundColor"
#define TMT_EDITOR_SELECTION_BACKGROUND_COLOR @"TMTEditorSelectionBackgroundColor"
#define TMT_EDITOR_SELECTION_FOREGROUND_COLOR @"TMTEditorSelectionForegroundColor"

/*
 KVC keys for fonts
 */
#define TMT_EDITOR_FONT @"TMTEditorFont"


/*
 KVC keys for numbers
 */
#define TMT_EDITOR_NUM_TAB_SPACES @"TMTEditorNumTabSpaces"

/*
 KVC keys for boolean flags (used for user defaults) 
 */
#define TMT_SHOULD_HIGHLIGHT_INLINE_MATH @ "TNTShouldHighlightInlineMath"
#define TMT_SHOULD_HIGHLIGHT_COMMANDS @ "TMTShouldHighlightCommand"
#define TMT_SHOULD_HIGHLIGHT_COMMENTS @ "TMTShouldHighlightComment"
#define TMT_SHOULD_HIGHLIGHT_BRACKETS @ "TMTShouldHighlightBracket"
#define TMT_SHOULD_HIGHLIGHT_ARGUMENTS @ "TMTShouldHighlightArgument"
#define TMT_SHOULD_HIGHLIGHT_CURRENT_LINE @"TMTShouldHighlightCurrentLine"
#define TMT_SHOULD_HIGHLIGHT_CURRENT_LINE_TEXT @"TMTShouldHighlightCurrentLineText"
#define TMT_SHOULD_HIGHLIGHT_MATCHING_BRACKETS @"TMTShouldHighlightMatchingBracket"
#define TMT_SHOULD_AUTO_INSERT_CLOSING_BRACKETS @"TMTShouldAutoInsertClosingBracket"
#define TMT_SHOULD_HIGHLIGHT_CARRET @"TMTShouldHighlightCarret"
#define TMT_SHOULD_USE_SPACES_AS_TABS @"TMTShouldUseSpacesAsTabs"
#define TMT_SHOULD_AUTO_INDENT_LINES @"TMTShouldAutoIndentLines"

/**
    This class is our common place for constants and other global definitions.
    E.g. keys used in the user defaults are defined here as global macros.
 
 \author Tobias Mende
 */
@interface Constants : NSObject

@end
