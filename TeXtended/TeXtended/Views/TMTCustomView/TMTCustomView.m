//
//  TMTCustomView.m
//  TeXtended
//
//  Created by Tobias Mende on 30.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "TMTCustomView.h"

@implementation TMTCustomView

    - (void)drawRect:(NSRect)dirtyRect
    {
        // set any NSColor for filling, say white:
        if (self.backgroundColor) {
            [self.backgroundColor setFill];
            NSRectFill(dirtyRect);
        }
        [super drawRect:dirtyRect];
    }

- (BOOL)allowsVibrancy {
    return YES;
}
@end
