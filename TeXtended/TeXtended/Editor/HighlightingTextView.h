//
//  HighlightingTextView.h
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 09.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Constants.h"



@class SyntaxHighlighter, BracketHighlighter, CodeNavigationAssistant, PlaceholderServices, CompletionHandler, CodeExtensionEngine, EditorService;

/**
 The highlighting text view is the main class of the code editor. It provides additional functionality by extending the NSTextView and using a set of EditorService subclasses for delegating the work.
 
 **Author:** Tobias Mende
 
 */

@interface HighlightingTextView : NSTextView <NSTextViewDelegate> {
    /** The SyntaxHighlighter highlights latex code by regular expressions */
    SyntaxHighlighter *regexHighlighter;
    
    /** The BracketHighlighter highlights matching brackets */
    BracketHighlighter *bracketHighlighter;
    
    /** The CodeNavigationAssistant handles line and carret highlighting as well as tab and new line insertion */
    CodeNavigationAssistant *codeNavigationAssistant;
    /** The PlaceholderServices handles placeholder navigation */
    PlaceholderServices *placeholderService;
    
    /** The CompletionHandler contains the auto completion logic */
    CompletionHandler *completionHandler;
    
    /** The CodeExtensionEngine controls auto linking and information adding features */
    CodeExtensionEngine *codeExtensionEngine;
}
@property (nonatomic) TMTLineWrappingMode lineWrapMode;
@property (strong) NSNumber *hardWrapAfter;


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
- (void)insertFinalCompletion:(NSString *)word forPartialWordRange:(NSRange)charRange movement:(NSInteger)movement isFinal:(BOOL)flag;

/**
 Method for jumping to the next visible placeholders (supporting round wrap jumping when at the end of the visible area)
 */
- (void) jumpToNextPlaceholder;
@end
