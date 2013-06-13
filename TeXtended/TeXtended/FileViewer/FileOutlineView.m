//
//  FileOutLineView.m
//  TeXtended
//
//  Created by Tobias Hecht on 01.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "FileOutlineView.h"

@implementation FileOutlineView

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    }
    return self;
}

/*- (BOOL)performDragOperation:(id < NSDraggingInfo >)sender {
    NSLog(@"Perform");
    NSArray *draggedFilenames = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
    for(NSInteger i = 0; i < [draggedFilenames count]; i++)
        if(![[[draggedFilenames objectAtIndex:0] pathExtension] isEqualToString:@"tex"])
            return NO;
    return YES;
}*/

/*-(void)draggingExited:(id<NSDraggingInfo>)sender
{
    [self setNeedsDisplay: NO];
}*/

/*- (void)concludeDragOperation:(id <NSDraggingInfo>)sender{
    NSLog(@"Conclude");
    NSArray *draggedFilenames = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
    //for(NSInteger i = 0; i < [draggedFilenames count]; i++)
        //[self]
}*/

@end
