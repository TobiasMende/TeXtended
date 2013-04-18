//
//  HighlightingTextView.h
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 09.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class SyntaxHighlighter, BracketHighlighter, CodeNavigationAssistant, PlaceholderServices, CompletionHandler;
@interface HighlightingTextView : NSTextView <NSTextViewDelegate> {
    SyntaxHighlighter *regexHighlighter;
    BracketHighlighter *bracketHighlighter;
    CodeNavigationAssistant *codeNavigationAssistant;
    PlaceholderServices *placeholderService;
    CompletionHandler *completionHandler;
}
- (void) updateSyntaxHighlighting;
- (NSRange) visibleRange;
@end
