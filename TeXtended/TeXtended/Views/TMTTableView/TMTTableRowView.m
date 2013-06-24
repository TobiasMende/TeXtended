//
//  TMTTableRowView.m
//  TeXtended
//
//  Created by Tobias Mende on 24.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "TMTTableRowView.h"

@implementation TMTTableRowView


- (void)drawSeparatorInRect:(NSRect)dirtyRect
{
    // Define our drawing colors
    NSColor *bg = [self backgroundColor];
    NSColor *normalColor = [bg colorWithAlphaComponent:1.0];
    NSColor *selectedTopColor = [NSColor colorWithCalibratedWhite:0.60 alpha:1.0]; // Color of the top separator line of selected row
    NSColor *selectedBottomColor = [NSColor colorWithCalibratedWhite:0.60 alpha:1.0]; // Color of the bottom separator line of selected row
    
    // Define coordinates of separator line
    NSRect drawingRect = [self frame]; // Ignore dirtyRect
    drawingRect.origin.y = drawingRect.size.height - 1.0;
    drawingRect.size.height = 1.0; // Height of the separator line we're going to draw at the bottom of the row
    
    // Get the table view and info on row index numbers
    NSTableView *tableView = (NSTableView*)[self superview]; // The table view the row is part of
    NSInteger selectedRowNumber = [tableView selectedRow];
    NSInteger ownRowNumber = [tableView rowForView:self];
    
    // Set the color of the separator line
    [normalColor set]; // Default
    if (([self isSelected]) && ((selectedRowNumber + 1) < [tableView numberOfRows])) [selectedBottomColor set]; // If the row is selected, use selectedBottomColor
    if ((![self isSelected]) && (selectedRowNumber > 0) && (ownRowNumber == (selectedRowNumber-1))) [selectedTopColor set]; // If the row is followed by the selected row, draw its bottom separator line in selectedTopColor
    
    // Draw separator line
    NSRectFill (drawingRect);
    
    // If the row is selected, tell the preceding row to redraw its bottom separator line (which is also the top line of the selected row)
    if (([self isSelected]) && (selectedRowNumber > 0)) [tableView setNeedsDisplayInRect:[tableView rectOfRow:selectedRowNumber-1]];
}

@end
