//
//  TMTTabViewDummy.m
//  TeXtended
//
//  Created by Max Bannach on 28.09.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "TMTTabViewDummy.h"

@implementation TMTTabViewDummy

- (id) initWithColor:(NSColor*) color {
    self = [super init];
    if (self) {
        backgroundColor = color;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	NSRect rect = NSMakeRect(0, 0, 500, 300);
    [backgroundColor set];
    NSRectFill(rect);
}

@end
