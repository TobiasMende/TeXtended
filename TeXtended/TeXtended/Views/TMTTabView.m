//
//  TMTTabView.m
//  TeXtended
//
//  Created by Tobias Mende on 22.09.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "TMTTabView.h"

@implementation TMTTabView


- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
}


- (void) addTabViewItem:(NSTabViewItem *)tabViewItem {
    [super addTabViewItem:tabViewItem];
}

- (void) mouseDown:(NSEvent *)theEvent {
    NSPoint p = [self convertPoint: [theEvent locationInWindow]
                          fromView: nil];
    
    // reset last dragging action
    [self setDraggedItem:nil];
    
    if ([self tabViewItemAtPoint:p]) {
        [self selectTabViewItem:[self tabViewItemAtPoint:p]];
        // hitted a tabView
        if ([self.selectedTabViewItem isEqual:[self tabViewItemAtPoint:p]]) {
            // drag it, if it was selected
            NSLog(@"start dragging: %@", [[self tabViewItemAtPoint:p] label]);
            [self setDraggedItem:[self tabViewItemAtPoint:p]];
        }
    }
}


- (void) mouseDragged:(NSEvent *)theEvent {
    NSPoint p = [self convertPoint: [theEvent locationInWindow]
                          fromView: nil];
    mouse = p;
    
    if ([self draggedItem] && [self tabViewItemAtPoint:p] && ![self.draggedItem isEqual:[self tabViewItemAtPoint:p]]) {
        long i = [self indexOfTabViewItem:self.draggedItem];
        long j = [self indexOfTabViewItem:[self tabViewItemAtPoint:p]];
        
        NSTabViewItem* tmp1 = [self tabViewItemAtIndex:i];
        NSTabViewItem* tmp2 = [self tabViewItemAtIndex:j];
        
        [self removeTabViewItem:tmp1];
        [self removeTabViewItem:tmp2];
        if (i < j) {
            [self insertTabViewItem:tmp2 atIndex:i];
            [self insertTabViewItem:tmp1 atIndex:j];
        } else {
            [self insertTabViewItem:tmp1 atIndex:j];
            [self insertTabViewItem:tmp2 atIndex:i];
        }
        [self selectTabViewItem:tmp1];
        
        NSLog(@"dragging: %@", [self.draggedItem label]);
    }
    
}

- (void) mouseUp:(NSEvent *)theEvent {
    NSPoint p = [self convertPoint: [theEvent locationInWindow]
                          fromView: nil];
    
    if ([self draggedItem] && [self tabViewItemAtPoint:p] && ![self.draggedItem isEqual:[self tabViewItemAtPoint:p]]) {
        long i = [self indexOfTabViewItem:self.draggedItem];
        long j = [self indexOfTabViewItem:[self tabViewItemAtPoint:p]];
        
        NSTabViewItem* tmp1 = [self tabViewItemAtIndex:i];
        NSTabViewItem* tmp2 = [self tabViewItemAtIndex:j];
        
        [self removeTabViewItem:tmp1];
        [self removeTabViewItem:tmp2];
        if (i < j) {
            [self insertTabViewItem:tmp2 atIndex:i];
            [self insertTabViewItem:tmp1 atIndex:j];
        } else {
            [self insertTabViewItem:tmp1 atIndex:j];
            [self insertTabViewItem:tmp2 atIndex:i];
        }
        [self selectTabViewItem:tmp1];
        
        NSLog(@"stop dragging: %@", [self.draggedItem label]);
        [self setDraggedItem:nil];
    }
}

@end
