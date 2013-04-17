//
//  HighlightingTextView.h
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 09.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class SyntaxHighlighter, BracketHighlighter, CodeNavigationAssistant;
@interface HighlightingTextView : NSTextView {
    SyntaxHighlighter *regexHighlighter;
    BracketHighlighter *bracketHighlighter;
    CodeNavigationAssistant *codeNavigationAssistant;
}
- (void) updateSyntaxHighlighting;
@end
