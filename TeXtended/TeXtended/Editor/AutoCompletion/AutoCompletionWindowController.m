//
//  AutoCompletionWindowController.m
//  TeXtended
//
//  Created by Tobias Mende on 28.09.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "AutoCompletionWindowController.h"
#import "TMTLog.h"
#import "Completion.h"

@interface AutoCompletionWindowController ()

- (NSRect) toGlobalCharBounds:(NSRect) localCharBound;

/**
 Calculates an appropriate frame for the completion window (according to the cursor position in global coordinates)
 
 @param globalCharBounds the charBounds of the last typed character
 @return the final window frame
 */
- (NSRect) calculateFinalFrame:(NSRect) globalCharBounds;


- (void) textViewDidEndEditing:(NSNotification *)note;

- (void) updateSelection:(NSInteger)currentIndex;


@end

@implementation AutoCompletionWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)setContent:(NSArray *)content {
    _content = content;

    [self.tableView reloadData];
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

- (void)textViewDidEndEditing:(NSNotification *)note {
    DDLogWarn(@"TV did end editing");
}

- (void)positionWindowWithContent:(NSArray *)content {
    self.content = content;
    NSRange range = NSMakeRange(self.parent.selectedRange.location-1, 1);
    NSRange theTextRange = [self.parent.layoutManager glyphRangeForCharacterRange:range actualCharacterRange:NULL];
    NSRect layoutRect = [self.parent.layoutManager boundingRectForGlyphRange:theTextRange inTextContainer:self.parent.textContainer];
    NSRect globalCharBound = [self toGlobalCharBounds:layoutRect];
    
    
    [self.window setFrame:[self calculateFinalFrame:globalCharBound] display:YES animate:NO];
    [self.window orderFront:self];
    if (content.count > 0) {
        [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    }

}


- (NSRect)calculateFinalFrame:(NSRect)globalCharBounds {
    NSSize estimatedWindowSize = NSMakeSize(self.window.frame.size.width, self.content.count * 17);
    NSPoint origin;
    
    CGFloat screenEnd = NSMaxX([[NSScreen mainScreen] visibleFrame]);
    
    origin.y = (NSMinY(globalCharBounds) - estimatedWindowSize.height >= 0 ? NSMinY(globalCharBounds) - estimatedWindowSize.height : NSMaxY(globalCharBounds));
    origin.x = (NSMaxX(globalCharBounds) + estimatedWindowSize.width <= screenEnd ? NSMaxX(globalCharBounds) : screenEnd - estimatedWindowSize.width);
    
    NSRect finalRect;
    finalRect.size = estimatedWindowSize;
    finalRect.origin = origin;
    return finalRect;
}

- (NSRect)toGlobalCharBounds:(NSRect)localCharBound {
    NSPoint pos = localCharBound.origin;
    NSPoint localPosition = [self.parent convertPoint:pos toView:self.window.contentView];
    NSPoint globalPosition = self.parent.window.frame.origin;
    globalPosition.x += localPosition.x;
    globalPosition.y += localPosition.y;
    return NSMakeRect(globalPosition.x, globalPosition.y-localCharBound.size.height, localCharBound.size.width, localCharBound.size.height);
}

- (id)init {
    self = [super initWithWindowNibName:@"AutoCompletionWindow"];
    if (self) {
        
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

#pragma mark - Table View Delegate Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.content.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (row >= 0 && row < self.content.count) {
        return [self.content objectAtIndex:row];
    }
    return nil;
}

#pragma mark - Key Events

- (void)arrowDown {
    NSInteger count = self.tableView.numberOfRows;
    NSInteger current = [self.tableView selectedRow];
    DDLogWarn(@"%ld - %ld", (long)count, current);
    if (count == 0 || current < 0) {
        return;
    }
    current = (current + 1)% count;
    [self updateSelection:current];
}

- (void)arrowUp {
    NSInteger count = self.tableView.numberOfRows;
    NSInteger current = [self.tableView selectedRow];
    if (count == 0 || current < 0) {
        return;
    }
    current = (current > 0 ? current-1 : count-1);
    [self updateSelection:current];
}


#pragma mark - Helper Methods

- (void)updateSelection:(NSInteger)currentIndex {
    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:currentIndex] byExtendingSelection:NO];
    Completion *completion = [self.content objectAtIndex:currentIndex];
    NSRange prefixRange = [self.parent rangeForUserCompletion];
    if (prefixRange.location == NSNotFound) {
        DDLogWarn(@"Got invalid prefix for user completion");
        return;
    }
    [self.parent.undoManager beginUndoGrouping];
    NSString *replacement = [completion.autoCompletionWord substringFromIndex:prefixRange.length];
    NSUInteger location = self.parent.selectedRange.location;
    [self.parent replaceCharactersInRange:self.parent.selectedRange withString:replacement];
    [self.parent setSelectedRange:NSMakeRange(location, replacement.length)];
    [self.parent.undoManager endUndoGrouping];
}




@end
