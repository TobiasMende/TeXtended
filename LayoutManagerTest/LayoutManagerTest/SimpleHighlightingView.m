//
//  SimpleHighlightingView.m
//  LayoutManagerTest
//
//  Created by Tobias Mende on 08.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "SimpleHighlightingView.h"

@implementation SimpleHighlightingView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)awakeFromNib {
    NSLog(@"textView: Awake from nib");
    [[self window] setAcceptsMouseMovedEvents:YES];
}


- (void)keyDown:(NSEvent *)theEvent {
    [super keyDown:theEvent];
    [self handleLineHighlighting:theEvent];
}

- (void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
    [self handleLineHighlighting:theEvent];
}


- (void) handleLineHighlighting: (NSEvent*) theEvent {
    NSUInteger insertionPoint = [self selectedRange].location;
    NSLayoutManager *lm = [self layoutManager];
    NSRange lineRange;
    [lm lineFragmentRectForGlyphAtIndex:insertionPoint effectiveRange:&lineRange];
    NSUInteger textLength = [[self textStorage] length];
    NSRange textRange = NSMakeRange(0, textLength);
    [lm removeTemporaryAttribute:NSBackgroundColorAttributeName forCharacterRange:textRange];
    NSRange lineCharRange = [lm characterRangeForGlyphRange:lineRange actualGlyphRange:NULL];
    [lm addTemporaryAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor greenColor], NSBackgroundColorAttributeName, nil] forCharacterRange:lineCharRange];
    
}
@end
