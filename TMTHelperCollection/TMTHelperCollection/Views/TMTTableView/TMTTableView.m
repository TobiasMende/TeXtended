//
//  ExtendedTableView.m
//  TeXtended
//
//  Created by Tobias Mende on 12.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "TMTTableView.h"
#import "TMTTableViewDelegate.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
@implementation TMTTableView

    - (void)keyDown:(NSEvent *)theEvent
    {
        char keyChar = [[theEvent characters] characterAtIndex:0];
        if (keyChar == NSEnterCharacter || keyChar == NSCarriageReturnCharacter) {
            if (self.enterAction && [self.target respondsToSelector:self.enterAction]) {
                [self.target performSelector:self.enterAction withObject:self];
            }
            return;
        }
        [super keyDown:theEvent];
    }

    - (void)mouseDown:(NSEvent *)theEvent
    {
        [super mouseDown:theEvent];
        if (theEvent.clickCount < 2 && self.singleClickAction && [self.target respondsToSelector:self.singleClickAction]) {
            [self.target performSelector:self.singleClickAction withObject:self];
        }
    }

    - (void)rightMouseDown:(NSEvent *)theEvent
    {
        if (self.rightClickAction && [self.target respondsToSelector:self.rightClickAction]) {
            NSPoint where;
            NSInteger row = -1;

            where = [self convertPoint:[theEvent locationInWindow] fromView:nil];
            row = [self rowAtPoint:where];
            if (row >= 0 && row < self.numberOfRows) {
                [self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
                [self.target performSelector:self.rightClickAction withObject:self];
                return;
            }
        }

        [super rightMouseDown:theEvent];
    }

- (void)editColumn:(NSInteger)column row:(NSInteger)row withEvent:(NSEvent *)theEvent select:(BOOL)select {
    BOOL handled = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:editColumn:row:withEvent:select:)]) {
        handled = [(id<TMTTableViewDelegate>)self.delegate tableView:self editColumn:column row:row withEvent:theEvent select:select];
    }
    if (!handled){
        [super editColumn:column row:row withEvent:theEvent select:select];
    }
}


    - (BOOL)isOpaque
    {
        return _opaque;
    }

    - (void)drawBackgroundInClipRect:(NSRect)clipRect
    {
        if (!self.opaque) {
            return;
        }
        [super drawBackgroundInClipRect:clipRect];
    }


@end
#pragma clang diagnostic pop
