//
//  TMTTabView.m
//  TeXtended
//
//  Created by Tobias Mende on 22.09.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "TMTTabView.h"
#import "TMTLog.h"

static NSString *DRAG_TYPE = @"de.uniluebeck.isp.tmtproject.TMTTabViewItem";
static NSTabViewItem *CURRENT_DRAG_ITEM;
@implementation TMTTabView


- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self registerForDraggedTypes:[NSArray arrayWithObject:DRAG_TYPE]];
    }
    return self;
}

- (void)mouseDown:(NSEvent *)theEvent {
    NSPoint p = [self convertPoint:theEvent.locationInWindow fromView:nil];
    clickedItem = [self tabViewItemAtPoint:p];
}


- (void)mouseUp:(NSEvent *)theEvent {
    NSPoint p = [self convertPoint:theEvent.locationInWindow fromView:nil];
    NSTabViewItem *item = [self tabViewItemAtPoint:p];
    if (item == clickedItem) {
        [self selectTabViewItem:clickedItem];
    }
    clickedItem = nil;
}

- (void)mouseDragged:(NSEvent *)theEvent {
    NSPoint p = [self convertPoint:theEvent.locationInWindow fromView:nil];
    //  [super mouseDown:theEvent];
    NSTabViewItem *t = [self tabViewItemAtPoint:p];
    CURRENT_DRAG_ITEM = t;
    if (!t) {
        [super mouseDragged:theEvent];
        return;
    }
    [self selectTabViewItem:t];
    NSPasteboardItem *pbItem = [NSPasteboardItem new];
    /* Our pasteboard item will support public.tiff, public.pdf, and our custom UTI (see comment in -draggingEntered)
     * representations of our data (the image).  Rather than compute both of these representations now, promise that
     * we will provide either of these representations when asked.  When a receiver wants our data in one of the above
     * representations, we'll get a call to  the NSPasteboardItemDataProvider protocol method –pasteboard:item:provideDataForType:. */
    [pbItem setDataProvider:self forTypes:[NSArray arrayWithObject:DRAG_TYPE]];
    
    //create a new NSDraggingItem with our pasteboard item.
    NSDraggingItem *dragItem = [[NSDraggingItem alloc] initWithPasteboardWriter:pbItem];
    
    /* The coordinates of the dragging frame are relative to our view.  Setting them to our view's bounds will cause the drag image
     * to be the same size as our view.  Alternatively, you can set the draggingFrame to an NSRect that is the size of the image in
     * the view but this can cause the dragged image to not line up with the mouse if the actual image is smaller than the size of the
     * our view. */
    NSRect draggingRect = [t.view bounds];
    
    /* While our dragging item is represented by an image, this image can be made up of multiple images which
     * are automatically composited together in painting order.  However, since we are only dragging a single
     * item composed of a single image, we can use the convince method below. For a more complex example
     * please see the MultiPhotoFrame sample. */
    
    [t.view lockFocus];
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc]
                                initWithFocusedViewRect:[t.view bounds]];
    [t.view unlockFocus];
    
    NSImage *image = [[NSImage alloc] initWithSize:[t.view bounds].size];
    [image addRepresentation:bitmap];
    [dragItem setDraggingFrame:draggingRect contents:image];
    
    //create a dragging session with our drag item and ourself as the source.
    NSDraggingSession *draggingSession = [self beginDraggingSessionWithItems:[NSArray arrayWithObject:dragItem] event:theEvent source:self];
    //causes the dragging item to slide back to the source if the drag fails.
    draggingSession.animatesToStartingPositionsOnCancelOrFail = YES;
    
    draggingSession.draggingFormation = NSDraggingFormationNone;
}

#pragma mark - NSDraggingDestination Methods

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    DDLogInfo(@"Entering %@", self);
     if ( [sender draggingSource] != self ) {
         return NSDragOperationMove;
     }
    return NSDragOperationNone;
}


- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    /*------------------------------------------------------
     method to determine if we can accept the drop
     --------------------------------------------------------*/
    //finished with the drag so remove any highlighting
    //highlight=NO;
    
    [self setNeedsDisplay: YES];
    
    //check to see if we can accept the data
    return YES;
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender {
    return NSDragOperationMove;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    /*------------------------------------------------------
     method that should handle the drop data
     --------------------------------------------------------*/
    if ( [sender draggingSource] != self ) {
        
        //set the image using the best representation we can get from the pasteboard
            NSString *pointer = [[sender draggingPasteboard] stringForType:DRAG_TYPE];
            if (!pointer) {
                return NO;
            }
        NSTabViewItem *current = CURRENT_DRAG_ITEM;
        NSTabView *other = current.tabView;
        [other removeTabViewItem:current];
        [self addTabViewItem:current];
        [self selectTabViewItem:current];
        return YES;
        
        //if the drag comes from a file, set the window title to the filename
    }
    
    return NO;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
    return YES;
}
#pragma mark - NSDraggingSource Methods

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context {
    return NSDragOperationMove;
}

#pragma mark - NSPasteboardItemDataProvider Methods

- (void)pasteboard:(NSPasteboard *)pasteboard item:(NSPasteboardItem *)item provideDataForType:(NSString *)type {
    if ([type isEqualToString:DRAG_TYPE]) {
        
        [pasteboard setString:@"TROLL" forType:DRAG_TYPE];
    }
}

@end
