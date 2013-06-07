//
//  Constants.h
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 10.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>


/*
 Constants for Document Type
*/

#define TMT_FOLDER_DOCUMENT_TYPE @"TeXtendedProjectFolder"
#define TMT_PROJECT_DOCUMENT_TYPE @"TeXtededProjectFile"
#define TMT_LATEX_DOCUMENT_TYPE @"Latex Document"
#define TMT_LATEX_STYLE_DOCUMENT @"Latex Style Document"
#define TMT_LATEX_CLASS_DOCUMENT @"Latex Class Document"

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
#define TMT_TEXDOC_LINK_COLOR @"TMTTexdocLinkColor"

/*
 KVC keys for fonts
 */
#define TMT_EDITOR_FONT @"TMTEditorFont"


/*
 KVC keys for numbers
 */
#define TMT_EDITOR_NUM_TAB_SPACES @"TMTEditorNumTabSpaces"
#define TMT_EDITOR_HARD_WRAP_AFTER @"TMTEditorHardWrapAfter"
#define TMT_EDITOR_LINE_WRAP_MODE @"TMTEditorLineWrapMode"
#define TMTLiveCompileIterations @"TMTLiveCompileIterations"
#define TMTDraftCompileIterations @"TMTDraftCompileIterations"
#define TMTFinalCompileIterations @"TMTFinalCompileIterations"

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
#define TMT_SHOULD_COMPLETE_COMMANDS @"TMTShouldCompleteCommands"
#define TMT_SHOULD_COMPLETE_ENVIRONMENTS @"TMTShouldCompleteEnvironments"
#define TMT_SHOULD_AUTO_INDENT_ENVIRONMENTS @"TMTShouldAutoIndentEnvironments"
#define TMT_SHOULD_UNDERLINE_TEXDOC_LINKS @"TMTShouldUnderlineTexdocLinks"
#define TMT_SHOULD_LINK_TEXDOC @"TMTShouldLinkTexdoc"
#define TMTLiveCompileBib @"TMTLiveCompileBib"
#define TMTDraftCompileBib @"TMTDraftCompileBib"
#define TMTFinalCompileBib @"TMTFinalCompileBib"


/*
 KVC keys for strings (used for user defaults)
 */

#define TMT_ENVIRONMENT_PATH @"TMTEnvironmentPath"
#define TMT_PATH_TO_TEXDOC @"TMTPathToTexdoc"
#define TMTLiveCompileFlow @"TMTLiveCompileFlow"
#define TMTDraftCompileFlow @"TMTDraftCompileFlow"
#define TMTFinalCompileFlow @"TMTFinalCompileFlow"
#define TMTLiveCompileArgs @"TMTLiveCompileArgs"
#define TMTDraftCompileArgs @"TMTDraftCompileArgs"
#define TMTFinalCompileArgs @"TMTFinalCompileArgs"

/*
 Keys for NSCoding
 */
#define TMTCompletionInsertionKey @"TMTCompletionInsertionKey"
#define TMTCompletionExtensionKey @"TMTCompletionExtensionKey"
#define TMTCompletionHasPlaceholdersKey @"TMTCompletionHasPlaceholdersKey"
#define TMTCompletionsFirstLineExtensionKey @"TMTCompletionFirstLineExtensionKey"
#define TMTCompletionTypeKey @"TMTCompletionTypeKey"


/*
 Notification Names
 */
#define TMTCommandCompletionsDidChangeNotification @"TMTCommandCompletionsDidChangeNotification"
#define TMTEnvironmentCompletionsDidChangeNotification @"TMTEnvironmentCompletionsDidChangeNotification"
#define TMTDocumentModelDidChangeNotification @"TMTDocumentModelDidChangeNotification"
#define TMTDocumentModelOutputPipeChangeNotification @"TMTDocumentModelOutputPipeChangeNotification"
#define TMTDocumentModelInputPipeChangeNotification @"TMTDocumentModelInputPipeChangeNotification"
#define TMTCompilerDidStartCompiling @"TMTCompilerDidStartCompiling"
#define TMTCompilerDidEndCompiling @"TMTCompilerDidEndCompiling"

typedef enum LineWrappingMode {HardWrap = 0,
                                SoftWrap = 1,
                                    NoWrap = 2} TMTLineWrappingMode;

/**
    This class is our common place for constants and other global definitions.
    E.g. keys used in the user defaults are defined here as global macros.
 
 \author Tobias Mende
 */
@interface Constants : NSObject

@end
