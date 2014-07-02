//
//  LightHighlightingTextView.h
//  TeXtended
//
//  Created by Tobias Mende on 02.07.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SyntaxHighlighter.h"

@interface LightHighlightingTextView : NSTextView
/** The syntax highlighter */
@property (strong) id <SyntaxHighlighter> syntaxHighlighter;

- (void)updateSyntaxHighlighting;
- (NSRange)extendedVisibleRange;
@end
