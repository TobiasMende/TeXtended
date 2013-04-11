//
//  HighlightingTextView.m
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 09.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "HighlightingTextView.h"
#import "SyntaxHighlighter.h"
#import "BracketHighlighter.h"
@implementation HighlightingTextView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    
    return self;
}

- (void)awakeFromNib {
    regexHighlighter = [[SyntaxHighlighter alloc] initWithTextView:self];
    bracketHighlighter = [[BracketHighlighter alloc] initWithTextView:self];
    if(self.string.length > 0) {
        [regexHighlighter highlightEntireDocument];
    }

}

- (void)updateTrackingAreas {
    [super updateTrackingAreas];
    [regexHighlighter highlightVisibleArea];
}

- (void)insertText:(id)str {
    [super insertText:str];
    [bracketHighlighter highlightOnInsertWithInsertion:str];
}

- (void)paste:(id)sender {
    [super paste:sender];
    [regexHighlighter highlightEntireDocument];
}

-(void)setString:(NSString *)string {
    [super setString:string];
    [regexHighlighter highlightEntireDocument];
}



- (void)moveLeft:(id)sender {
    [super moveLeft:sender];
    [bracketHighlighter highlightOnMoveLeft];
    
}

- (void)moveRight:(id)sender {
    [super moveRight:sender];
    [bracketHighlighter highlightOnMoveRight];
}



@end
