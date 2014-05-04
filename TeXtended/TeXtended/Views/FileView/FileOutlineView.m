//
//  FileOutlineView.m
//  TeXtended
//
//  Created by Tobias Mende on 03.05.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "FileOutlineView.h"
#import <TMTHelperCollection/TMTLog.h>
@implementation FileOutlineView

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent {
    if(![self.contextualMenu performKeyEquivalent:theEvent]) {
        return [super performKeyEquivalent:theEvent];
    }
    return YES;
    
}


- (NSMenu *)menuForEvent:(NSEvent *)event {
    NSMenu *menu = [super menuForEvent:event];
    if (event.type == NSRightMouseDown && self.clickedRow < 0 && self.backgroundMenu) {
        menu = self.backgroundMenu;
    }
    
    return menu;
}

// The returned array can then be archived.
- (NSArray *)expandedItems;
{
	NSMutableArray *expandedItemsArray = [NSMutableArray array];
	NSInteger row, numberOfRows = [self numberOfRows];
    
	for (row = 0 ; row < numberOfRows ; row++)
	{
		id item = [self itemAtRow:row];
		if ([self isItemExpanded:item]) {
			// create an array of only the expanded items in the list
			[expandedItemsArray addObject:[item representedObject]];
			// If the items you use in the outline view are large
			// this can significantly increase the size of your save files.
			// In this case you could add a unique identifier to your objects,
			// store that and compare the IDs instead of using -isEqual: below.
		}
	}
    
	return [expandedItemsArray copy];
}


// Passing the (now unarchived) array to the method below will expand them again.
- (void)restoreExpandedStateWithArray:(NSArray *)array;
{
	NSInteger row, numberOfRows = [self numberOfRows];
	for (id savedItem in array) {
		for (row = 0 ; row < numberOfRows ; row++) {
			id item = [self itemAtRow:row];
			id realObject = [item representedObject];
			if ([realObject isEqual:savedItem]) {
				[self expandItem:item];
				numberOfRows = [self numberOfRows];
				break;
			}
		}
	}
}


@end
