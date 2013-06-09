//
//  FileViewTitle.m
//  TeXtended
//
//  Created by Tobias Hecht on 01.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "FileViewTitle.h"

@implementation FileViewTitle

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
    NSLog(@"Box");
    return;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    NSLog(@"hh");
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    NSLog(@"aa");
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

@end
