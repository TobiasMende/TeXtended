//
//  PreviewView.m
//  TeXtended
//
//  Created by Tobias Mende on 18.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "TMTQuickLookView.h"


@interface TMTQuickLookView ()
- (BOOL)shouldDelegateEvent:(NSEvent *)event;
@end
@implementation TMTQuickLookView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame style:QLPreviewViewStyleCompact];
    if (self) {
        // Initialization code here.
    }
    return self;
}


- (void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
    if (self.mouseDownHandler && [self shouldDelegateEvent:theEvent]) {
        self.mouseDownHandler(theEvent);
    }
}

- (BOOL)shouldDelegateEvent:(NSEvent *)event {
    NSPoint localLocation = [self convertPoint:event.locationInWindow fromView:nil];
    NSRect forbidden = NSMakeRect(25.5, 11.5, 69.5, 30);
    return !NSPointInRect(localLocation, forbidden);
}




@end
