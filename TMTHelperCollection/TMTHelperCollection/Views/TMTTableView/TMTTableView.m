//
//  ExtendedTableView.m
//  TeXtended
//
//  Created by Tobias Mende on 12.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "TMTTableView.h"

@implementation TMTTableView

- (void)keyDown:(NSEvent *)theEvent {
    char keyChar = [[theEvent characters] characterAtIndex:0];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (keyChar == NSEnterCharacter || keyChar == NSCarriageReturnCharacter) {
        if (self.enterAction && [self.delegate respondsToSelector:self.enterAction]) {
            [self.delegate performSelector:self.enterAction withObject:self];
        }
        return;
    }
#pragma clang diagnostic pop
    [super keyDown:theEvent];
}

- (void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (theEvent.clickCount < 2 && self.singleClickAction && [self.delegate respondsToSelector:self.singleClickAction]) {
        [self.delegate performSelector:self.singleClickAction withObject:self];
    }
  #pragma clang diagnostic pop  
}

- (BOOL)isOpaque {
    return _opaque;
}

- (void)drawBackgroundInClipRect:(NSRect)clipRect {
    if (!self.opaque) {
        return;
    }
    [super drawBackgroundInClipRect:clipRect];
}


@end
