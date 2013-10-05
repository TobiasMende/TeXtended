//
//  HighlightingTextView.h
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 09.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Constants.h"
#import "SyntaxHighlighter.h"

@class BracketHighlighter, CodeNavigationAssistant, PlaceholderServices, CompletionHandler, CodeExtensionEngine, EditorService, UndoSupport,SpellCheckingService, GoToLineSheetController, AutoCompletionWindowController, Completion;

/**
 The highlighting text view is the main class of the code editor. It provides additional functionality by extending the NSTextView and using a set of EditorService subclasses for delegating the work.
 
 **Author:** Tobias Mende
 
 */

@interface HighlightingTextView : NSTextView {
    /** The SyntaxHighlighter highlights latex code by regular expressions */
    
    /** The BracketHighlighter highlights matching brackets */
    BracketHighlighter *bracketHighlighter;
    
    /** The CodeNavigationAssistant handles line and carret highlighting as well as tab and new line insertion */
    /** The PlaceholderServices handles placeholder navigation */
    PlaceholderServices *placeholderService;
    
    /** The CompletionHandler contains the auto completion logic */
    CompletionHandler *completionHandler;
    
    /** The CodeExtensionEngine controls auto linking and information adding features */
GoToLineSheetController *goToLineSheet;
    
    AutoCompletionWindowController *autoCompletionController;
    NSTimer *scrollTimer;

}

@property NSUInteger currentModifierFlags;

/** The code navigation assistant */
@property (readonly) CodeNavigationAssistant *codeNavigationAssistant;

/** The syntax highlighter */
@property  (strong)id<SyntaxHighlighter> syntaxHighlighter;

/** The code extension engine, adding linking like texdoc etc. */
@property (strong) CodeExtensionEngine *codeExtensionEngine;

/** property for the current row 
 
 @warning This property is set by the LineNumberView and might be outdated.
 */
@property NSUInteger currentRow;

/** Property for the first visble row in the visible area */
@property NSUInteger firstVisibleRow;

/** The undo support instance */
@property (strong) UndoSupport* undoSupport;

/** The spell checker */
@property (strong) SpellCheckingService *spellCheckingService;

/** if `YES` all services are on, if `NO` this object behaves in general like a normal NSTextView. */
@property BOOL servicesOn;
/** The active line wrap mode */
@property (nonatomic) TMTLineWrappingMode lineWrapMode;

/** The number of characters to break after in HardWrapMode */
@property (strong) NSNumber *hardWrapAfter;


/**
 Method to be called for force hardwrapping the text.
 @param sender the caller of this action.
 */
- (IBAction)hardWrapText:(id)sender;

/**
 Method can be called to delete the lines containing the selected text.
 
 @param sender the calling object
 */
- (IBAction)deleteLines:(id)sender;

/**
 Method moves the lines containing the selected text downwards
 
 @param sender the method caller
 */
- (IBAction)moveLinesDown:(id)sender;

/**
 Method moves the lines containing the selected text upwards
 
 @param sender the method caller
 */
- (IBAction)moveLinesUp:(id)sender;
/**
 Called when the syntax highlighting should be updated
 */
- (void) updateSyntaxHighlighting;


/**
 Getter for the visible range
 @return the visible range
 */
- (NSRange) visibleRange;

/**
 Method for finally inserting the completion
 
 @param word the word to insert the completion for
 @param charRange the range
 @param movement the movement constant
 @param flag is this insertion realy final?
 */
- (void)insertFinalCompletion:(Completion *)word forPartialWordRange:(NSRange)charRange movement:(NSInteger)movement isFinal:(BOOL)flag;

- (void)insertCompletion:(Completion *)word forPartialWordRange:(NSRange)charRange movement:(NSInteger)movement isFinal:(BOOL)flag;

/**
 Method for jumping to the next visible placeholders (supporting round wrap jumping when at the end of the visible area)
 */
- (void) jumpToNextPlaceholder;

/** Method for jumping to the previous placeholder (supporting round wrap jumping when at the beginning of the visible area) 
 */
- (void) jumpToPreviousPlaceholder;

/** Method for toggling the comment state for the selected lines 
 
 @param sender the sender
 */
- (IBAction)toggleComment:(id)sender;

/**
 Method for adding a comment sign (%) at the beginning of every selected line
 
 @param sender the sender
 */
- (IBAction)commentSelection:(id)sender;

/**
 Method for deleting a comment sign (%) at the beginning of every selected line
 
 @param sender the sender
 */
- (IBAction)uncommentSelection:(id)sender;

/**
 Getter for an extended visible range (adding some additional lines at begin and end of the visible range)
 
 @return a range which has a larger size or the same size as the visible range.
 */
- (NSRange) extendedVisibleRange;


/** Getter for the currently selected column
 
 @return the selected column
 */
- (NSUInteger) currentCol;

/** Getter for the column for the selected range
 @param range the range to get the column for.
 
 @return the column of the provided ranges location
 */
- (NSUInteger) colForRange:(NSRange) range;

/**
 Method for showing a given line in the view.
 
 @param line the line to scroll to.
 */
- (void) showLine:(NSUInteger)line;
/**
 Action for starting the GoToLineSheetController's dialog.
 
 @param sender the sender
 */
- (IBAction)goToLine:(id)sender;

/**
 Getter for an array of NSTextCheckingResult object where each object has a single range with the meaning of the range of the line indexed by the arrays inded.
 
 @return the line ranges.
 */
- (NSArray*) lineRanges;

/**
 Getter for a line range for a given line index.
 
 @param line the lines 1-based index
 
 @return the range of the given line
 */
- (NSRange) rangeForLine:(NSUInteger)index;

/**
 Notification about the end of the GoToLineSheetController's sheet.
 
 
 @param sheet the sheet which ends.
 @param returnCode the termination state of the sheet.
@param context `NULL` in most cases.
 */
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)context;

/** Method for jumping to the next anchor in the line number view
 
 @param sender the actions calller
 
 */
- (IBAction)jumpNextAnchor:(id)sender;


/** Method for jumping to the previous anchor in the line number view
 
 @param sender the actions calller
 
 */
- (IBAction)jumpPreviousAnchor:(id)sender;
@end
