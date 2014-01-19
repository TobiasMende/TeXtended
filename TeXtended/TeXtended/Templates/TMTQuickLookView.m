//
//  PreviewView.m
//  TeXtended
//
//  Created by Tobias Mende on 18.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "TMTQuickLookView.h"

@implementation TMTQuickLookView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame style:QLPreviewViewStyleCompact];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}

- (void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
    self.mouseDownHandler(theEvent);
}

@end
