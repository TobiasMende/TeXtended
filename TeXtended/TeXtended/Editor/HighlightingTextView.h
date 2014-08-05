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
#import "FirstResponderDelegate.h"
#import "CompletionProtocol.h"
#import "LightHighlightingTextView.h"

@class BracketHighlighter, CodeNavigationAssistant, CompletionHandler, CodeExtensionEngine, EditorService, GoToLineSheetController, AutoCompletionWindowController, Completion, DBLPIntegrator, QuickPreviewManager;

/**
 The highlighting text view is the main class of the code editor. It provides additional functionality by extending the NSTextView and using a set of EditorService subclasses for delegating the work.
 
 **Author:** Tobias Mende
 
 */

@interface HighlightingTextView : LightHighlightingTextView
    {
        /** The SyntaxHighlighter highlights latex code by regular expressions */

        /** The BracketHighlighter highlights matching brackets */
        BracketHighlighter *bracketHighlighter;

        /** The CodeNavigationAssistant handles line and carret highlighting as well as tab and new line insertion */

        /** The CompletionHandler contains the auto completion logic */
        CompletionHandler *completionHandler;

        /** The CodeExtensionEngine controls auto linking and information adding features */
        GoToLineSheetController *goToLineSheet;


        AutoCompletionWindowController *autoCompletionController;

        NSTimer *scrollTimer;

        DBLPIntegrator *dblpIntegrator;

        QuickPreviewManager *quickPreview;

    }

    @property BOOL completionEnabled;

    @property (assign) id <FirstResponderDelegate> firstResponderDelegate;

    @property NSUInteger currentModifierFlags;

/** The code navigation assistant */
    @property (readonly) CodeNavigationAssistant *codeNavigationAssistant;



/** The code extension engine, adding linking like texdoc etc. */
    @property (strong) CodeExtensionEngine *codeExtensionEngine;

/** property for the current row 
 
 @warning This property is set by the LineNumberView and might be outdated.
 */
    @property NSUInteger currentRow;

/** Property for the first visble row in the visible area */
    @property NSUInteger firstVisibleRow;


/** if `YES` all services are on, if `NO` this object behaves in general like a normal NSTextView. */
    @property BOOL servicesOn;

    @property BOOL enableQuickPreviewAssistant;

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
 Method for finally inserting the completion
 
 @param word the word to insert the completion for
 @param charRange the range
 @param movement the movement constant
 @param flag is this insertion realy final?
 */
    - (void)insertFinalCompletion:(id <CompletionProtocol>)word forPartialWordRange:(NSRange)charRange movement:(NSInteger)movement isFinal:(BOOL)flag;

    - (void)insertCompletion:(id <CompletionProtocol>)word forPartialWordRange:(NSRange)charRange movement:(NSInteger)movement isFinal:(BOOL)flag;

/**
 Method for jumping to the next visible placeholders (supporting round wrap jumping when at the end of the visible area)
 */
    - (void)jumpToNextPlaceholder;

/** Method for jumping to the previous placeholder (supporting round wrap jumping when at the beginning of the visible area) 
 */
    - (void)jumpToPreviousPlaceholder;




#pragma mark - Go To Line
/**
 Method for showing a given line in the view.
 
 @param line the line to scroll to.
 */
    - (void)showLine:(NSUInteger)line;

/**
 Action for starting the GoToLineSheetController's dialog.
 
 @param sender the sender
 */
    - (IBAction)goToLine:(id)sender;

/**
 Notification about the end of the GoToLineSheetController's sheet.
 
 
 @param sheet the sheet which ends.
 @param returnCode the termination state of the sheet.
 @param context `NULL` in most cases.
 */
- (void)goToLineSheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)context;



#pragma mark - Anchors
/** Method for jumping to the next anchor in the line number view
 
 @param sender the actions calller
 
 */
    - (IBAction)jumpNextAnchor:(id)sender;


/** Method for jumping to the previous anchor in the line number view
 
 @param sender the actions calller
 
 */
    - (IBAction)jumpPreviousAnchor:(id)sender;

    - (IBAction)showQuickPreviewAssistant:(id)sender;

    

    - (void)makeKeyView;

    - (IBAction)selectCurrentBlock:(id)sender;

    - (IBAction)gotoBlockBegin:(id)sender;

    - (IBAction)gotoBlockEnd:(id)sender;

- (void)setPlaceholderReplacementEnabled:(BOOL)enable;

@end
