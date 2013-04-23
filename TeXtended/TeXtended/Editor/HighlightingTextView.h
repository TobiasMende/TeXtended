//
//  HighlightingTextView.h
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 09.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class SyntaxHighlighter, BracketHighlighter, CodeNavigationAssistant, PlaceholderServices, CompletionHandler, CodeExtensionEngine;
@interface HighlightingTextView : NSTextView <NSTextViewDelegate> {
    SyntaxHighlighter *regexHighlighter;
    BracketHighlighter *bracketHighlighter;
    CodeNavigationAssistant *codeNavigationAssistant;
    PlaceholderServices *placeholderService;
    CompletionHandler *completionHandler;
    CodeExtensionEngine *codeExtensionEngine;
}
- (void) updateSyntaxHighlighting;
- (NSRange) visibleRange;
- (void)insertFinalCompletion:(NSString *)word forPartialWordRange:(NSRange)charRange movement:(NSInteger)movement isFinal:(BOOL)flag;
- (void) jumpToNextPlaceholder;
@end