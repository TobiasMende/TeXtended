//
//  MainDocumentCompletionWindow.m
//  TeXtended
//
//  Created by Tobias Hecht on 05.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "MainDocumentCompletionWindow.h"

@interface MainDocumentCompletionWindow ()

@end

@implementation MainDocumentCompletionWindow

- (id)init
{
    self = [super initWithWindowNibName:@"MainDocumentCompletionWindow"];
    if (self) {
        // Initialization code here.
    }
    return self;
}


- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)setParent:(NSTextView *)parent {
    if (_parent) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSTextDidEndEditingNotification object:_parent];
    }
    _parent = parent;
    if (_parent) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidEndEditing:) name:NSTextDidEndEditingNotification object:_parent
         ];
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.content.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return [self.content objectAtIndex:row];
}

- (void)setContent:(NSArray *)content {
    _content = content;
    
    [self.tableView reloadData];
}

- (void)positionWindowWithContent:(NSArray *)content {
    self.content = content;
    NSRange range = NSMakeRange(self.parent.selectedRange.location-1, 1);
    NSRange theTextRange = [self.parent.layoutManager glyphRangeForCharacterRange:range actualCharacterRange:NULL];
    NSRect layoutRect = [self.parent.layoutManager boundingRectForGlyphRange:theTextRange inTextContainer:self.parent.textContainer];
    NSRect globalCharBound = [self toGlobalCharBounds:layoutRect];
    
    [self.window setFrame:[self calculateFinalFrame:globalCharBound] display:YES animate:NO];
    [self.window orderFront:self];
    if (self.tableView.numberOfRows > 0) {
        [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    }
    
}

- (NSRect)calculateFinalFrame:(NSRect)globalCharBounds {
    NSSize estimatedWindowSize = NSMakeSize(self.window.frame.size.width, [self totalWindowHeight]);
    NSPoint origin;
    
    CGFloat screenEnd = NSMaxX([[NSScreen mainScreen] visibleFrame]);
    
    origin.y = (NSMinY(globalCharBounds) - estimatedWindowSize.height >= 0 ? NSMinY(globalCharBounds) - estimatedWindowSize.height : NSMaxY(globalCharBounds));
    origin.x = (NSMaxX(globalCharBounds) + estimatedWindowSize.width <= screenEnd ? NSMaxX(globalCharBounds) : screenEnd - estimatedWindowSize.width);
    
    NSRect finalRect;
    finalRect.size = estimatedWindowSize;
    finalRect.origin = origin;
    return finalRect;
}

- (NSInteger)totalWindowHeight {
    CGFloat rowHeight = self.tableView.rowHeight;

    return self.content.count * (rowHeight+2);
}

- (NSRect)toGlobalCharBounds:(NSRect)localCharBound {
    NSPoint pos = localCharBound.origin;
    NSPoint localPosition = [self.parent convertPoint:pos toView:self.window.contentView];
    NSPoint globalPosition = self.parent.window.frame.origin;
    globalPosition.x += localPosition.x;
    globalPosition.y += localPosition.y;
    return NSMakeRect(globalPosition.x, globalPosition.y-localCharBound.size.height, localCharBound.size.width, localCharBound.size.height);
}

#pragma mark - Key Events

- (void)arrowDown {
    NSInteger count = self.tableView.numberOfRows;
    NSInteger current = [self.tableView selectedRow];
    if (count == 0 || current < 0) {
        return;
    }
    current = (current + 1)% count;
    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:current] byExtendingSelection:NO];
    [self.tableView scrollRowToVisible:current];
}

- (void)arrowUp {
    NSInteger count = self.tableView.numberOfRows;
    NSInteger current = [self.tableView selectedRow];
    if (count == 0 || current < 0) {
        return;
    }
    current = (current > 0 ? current-1 : count-1);
    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:current] byExtendingSelection:NO];
    [self.tableView scrollRowToVisible:current];
}

- (void)enter {
    
}


@end
