//
//  Constants.h
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 10.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>




// --------------------------------------------------------------------------------
#pragma mark - Constants for Document Type

#define TMT_FOLDER_DOCUMENT_TYPE @"TeXtendedProjectFolder"
#define TMT_PROJECT_DOCUMENT_TYPE @"TeXtededProjectFile"
#define TMT_LATEX_DOCUMENT_TYPE @"Latex Document"
#define TMT_LATEX_STYLE_DOCUMENT @"Latex Style Document"
#define TMT_LATEX_CLASS_DOCUMENT @"Latex Class Document"
#define TMTProjectFileExtension @"teXpf"


// --------------------------------------------------------------------------------
#pragma mark - KVC keys for NSColor objects (used for user defaults)

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
#define TMTGridColor @"TMTGridColor"

// --------------------------------------------------------------------------------
#pragma mark - KVC keys for fonts

#define TMT_EDITOR_FONT_NAME @"TMT_EDITOR_FONT_NAME"
#define TMT_EDITOR_FONT_SIZE @"TMT_EDITOR_FONT_SIZE"
#define TMT_EDITOR_FONT_BOLD @"TMT_EDITOR_FONT_BOLD"
#define TMT_EDITOR_FONT_ITALIC @"TMT_EDITOR_FONT_ITALIC"


// --------------------------------------------------------------------------------
#pragma mark - KVC keys for numbers

#define TMT_EDITOR_NUM_TAB_SPACES @"TMTEditorNumTabSpaces"
#define TMT_EDITOR_HARD_WRAP_AFTER @"TMTEditorHardWrapAfter"
#define TMT_EDITOR_LINE_WRAP_MODE @"TMTEditorLineWrapMode"
#define TMTLiveCompileIterations @"TMTLiveCompileIterations"
#define TMTDraftCompileIterations @"TMTDraftCompileIterations"
#define TMTFinalCompileIterations @"TMTFinalCompileIterations"
#define TMTLatexLogLevelKey @"TMTLatexLogLevelKey" 
#define TMTLineSpacing @"TMTLineSpacing"
#define TMTHGridSpacing @"TMTHGridSpacing"
#define TMTVGridSpacing @"TMTVGridSpacing"
#define TMTHGridOffset @"TMTHGridOffset"
#define TMTVGridOffset @"TMTVGridOffset"

// --------------------------------------------------------------------------------
#pragma mark - KVC keys for boolean flags (used for user defaults)

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
#define TMTShouldCompleteCites @"TMTShouldCompleteCites"
#define TMT_SHOULD_LINK_TEXDOC @"TMTShouldLinkTexdoc"
#define TMT_REPLACE_INVISIBLE_SPACES @"TMTReplaceInvisibleSpaces"
#define TMT_REPLACE_INVISIBLE_LINEBREAKS @"TMTReplaceInvisibleLinebreaks"
#define TMTLiveCompileBib @"TMTLiveCompileBib"
#define TMTDraftCompileBib @"TMTDraftCompileBib"
#define TMTFinalCompileBib @"TMTFinalCompileBib"
#define TMTDocumentEnableLiveCompile @"TMTDocumentEnableLiveCompile"
#define TMTDocumentEnableLiveScrolling @"TMTDocumentEnableLiveScrolling"
#define TMTDocumentAutoOpenOnExport @"TMTDocumentAutoOpenOnExport"
/* No for Horizontal order, Yes for Vertical order */
#define TMTViewOrderAppearance @"TMTViewOrderAppearance"
#define TMTdrawHGrid @"TMTdrawHGrid"
#define TMTdrawVGrid @"TMTdrawVGrid"
#define TMTPageNumbers @"TMTPageNumbers"
#define TMTPdfPageAlpha @"TMTPdfPageAlpha"

// --------------------------------------------------------------------------------
#pragma mark - KVC keys for strings (used for user defaults)

#define TMT_ENVIRONMENT_PATH @"TMTEnvironmentPath"
#define TMT_PATH_TO_TEXBIN @"TMTPathToTexbin"
#define TMTLiveCompileFlow @"TMTLiveCompileFlow"
#define TMTDraftCompileFlow @"TMTDraftCompileFlow"
#define TMTFinalCompileFlow @"TMTFinalCompileFlow"
#define TMTLiveCompileArgs @"TMTLiveCompileArgs"
#define TMTDraftCompileArgs @"TMTDraftCompileArgs"
#define TMTFinalCompileArgs @"TMTFinalCompileArgs"
#define TMTGridUnit @"TMTGridUnit"

// --------------------------------------------------------------------------------
#pragma mark - KVC keys for tabview collapsed states

#define TMT_LEFT_TABVIEW_COLLAPSED @"TMTLeftTabviewCollapsed"
#define TMT_RIGHT_TABVIEW_COLLAPSED @"TMTRightTabviewCollapsed"


// --------------------------------------------------------------------------------
#pragma mark - Keys for NSCoding

#define TMTCompletionInsertionKey @"TMTCompletionInsertionKey"
#define TMTCompletionExtensionKey @"TMTCompletionExtensionKey"
#define TMTCompletionHasPlaceholdersKey @"TMTCompletionHasPlaceholdersKey"
#define TMTCompletionsFirstLineExtensionKey @"TMTCompletionFirstLineExtensionKey"
#define TMTCompletionTypeKey @"TMTCompletionTypeKey"
#define TMTCompletionCounterKey @"TMTCompletionCounterKey"
#define TMTCompletionUseExtensionKey @"TMTCompletionUseExtensionKey"


// --------------------------------------------------------------------------------
#pragma mark - Keys for NSNotification Info Dictionaries

#define TMTForwardSynctexKey @"TMTForwardSynctexKey"
#define TMTBackwardSynctexBeginKey @"TMTBackwardSynctexBeginKey"
#define TMTBackwardSynctexEndKey @"TMTBackwardSynctexEndKey"
#define TMTMessageCollectionKey @"TMTMessageCollectionKey"
#define TMTDidSaveDocumentModelContent @"TMTDidSaveDocumentModelContent"
#define TMTDidLoadDocumentModelContent @"TMTDidLoadDocumentModelContent"
#define TMTIntegerKey @"TMTIntegerKey"
#define TMTFirstResponderKey @"TMTFirstResponderKey"
#define TMTConsoleDataKey @"TMTConsoleDataKey"


// --------------------------------------------------------------------------------
#pragma mark - Keys for Dictionaries

#define TMTCompletionTypeKey @"TMTCompletionTypeKey"
#define TMTShouldShowDBLPKey @"TMTShouldShowDBLPKey"
#define TMTDropCompletionKey @"TMTDropCompletionKey"


// --------------------------------------------------------------------------------
#pragma mark - Notification Names

#define TMTCommandCompletionsDidChangeNotification @"TMTCommandCompletionsDidChangeNotification"
#define TMTEnvironmentCompletionsDidChangeNotification @"TMTEnvironmentCompletionsDidChangeNotification"
#define TMTDropCompletionsDidChangeNotification @"TMTDropCompletionsDidChangeNotification"
#define TMTDocumentModelDidChangeNotification @"TMTDocumentModelDidChangeNotification"
#define TMTDocumentModelOutputPipeChangeNotification @"TMTDocumentModelOutputPipeChangeNotification"
#define TMTDocumentModelInputPipeChangeNotification @"TMTDocumentModelInputPipeChangeNotification"
#define TMTCompilerWillStartCompilingMainDocuments @"TMTCompilerWillStartCompilingMainDocuments"
#define TMTCompilerDidStartCompiling @"TMTCompilerDidStartCompiling"
#define TMTCompilerDidEndCompiling @"TMTCompilerDidEndCompiling"
#define TMTCompilerSynctexChanged @"TMTCompilerSynctexChanged"
#define TMTViewSynctexChanged @"TMTViewSynctexChanged"
#define TMTLogMessageCollectionChanged @"TMTLogMessageCollectionChanged"
#define TMTMessageCollectionChanged @"TMTMessageCollectionChanged"
#define TMTShowLineInTextViewNotification @"TMTShowLineInTextViewNotification"
#define TMT_CONSOLE_ADDED_MANAGER_CHANGED @"TMT_CONSOLE_ADDED_MANAGER_CHANGED"
#define TMT_CONSOLE_REMOVED_MANAGER_CHANGED @"TMT_CONSOLE_REMOVED_MANAGER_CHANGED"
#define TMTTabViewDidCloseNotification @"TMTTabViewDidCloseNotification"
#define TMTFirstResponderDelegateChangeNotification @"TMTFirstResponderDelegateChangeNotification"




// --------------------------------------------------------------------------------
# pragma mark - Global Enumerations

typedef enum LineWrappingMode {HardWrap = 0,
                                SoftWrap = 1,
                                    NoWrap = 2} TMTLineWrappingMode;

typedef enum LatexLogLevel {OFF = 0,
                            ERROR = 1,
                            WARNING = 2,
                            INFO = 3,
                            ALL = 4} TMTLatexLogLevel;

typedef enum TrackingMessageType{
    TMTUnknownMessage,
    TMTErrorMessage,
    TMTWarningMessage,
    TMTInfoMessage,
    TMTDebugMessage
    } TMTTrackingMessageType;

typedef enum SplitViewOrderType {
    TMTHorizontal = 0,
    TMTVertical = 1} TMTSplitViewOrderType;

typedef enum TMTCompletionType {
    TMTNoCompletion,
    TMTCommandCompletion,
    TMTBeginCompletion,
    TMTEndCompletion,
    TMTCiteCompletion,
    TMTLabelCompletion,
    TMTRefCompletion,
    TMTDropCompletion
} TMTCompletionType;


/** Defines the different compilemodes that are possible */
typedef enum {
    live = 0,
    draft = 1,
    final = 2
} CompileMode;


typedef enum {
    TMTDocumentTemplate,
    TMTProjectTemplate
} TMTTemplateType;


// --------------------------------------------------------------------------------
#pragma mark - Key Codes

#define TMTTabKeyCode 48
#define TMTArrowDownKeyCode 125
#define TMTArrowUpKeyCode 126
#define TMTBackKeyCode 51
#define TMTReturnKeyCode 36


/**
    This class is our common place for constants and other global definitions.
    E.g. keys used in the user defaults are defined here as global macros.
 
 \author Tobias Mende
 */
@interface Constants : NSObject

@end
