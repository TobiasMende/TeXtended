//
//  FileOutLineView.m
//  TeXtended
//
//  Created by Tobias Hecht on 01.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "FileOutlineView.h"

@implementation FileOutlineView



- (void)keyDown:(NSEvent *)theEvent {
    // Arrow keys are associated with the numeric keypad
    unsigned short key = [theEvent keyCode];
    
    if(key == 36)
    {
        NSLog(@"Return");
    }
}

@end
