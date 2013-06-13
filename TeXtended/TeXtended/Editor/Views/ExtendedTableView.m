//
//  ExtendedTableView.m
//  TeXtended
//
//  Created by Tobias Mende on 12.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "ExtendedTableView.h"

@implementation ExtendedTableView

- (void)keyDown:(NSEvent *)theEvent {
    char keyChar = [[theEvent characters] characterAtIndex:0];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (keyChar == NSEnterCharacter || keyChar == NSCarriageReturnCharacter) {
        [self.delegate performSelector:self.enterAction];
        return;
    }
#pragma clang diagnostic pop
    [super keyDown:theEvent];
}


@end
