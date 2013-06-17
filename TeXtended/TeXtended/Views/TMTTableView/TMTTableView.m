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
        if ([self.delegate respondsToSelector:self.enterAction]) {
            [self.delegate performSelector:self.enterAction withObject:self];
        }
        return;
    }
#pragma clang diagnostic pop
    [super keyDown:theEvent];
}


@end
