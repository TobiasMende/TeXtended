//
//  FileOutlineView.m
//  TeXtended
//
//  Created by Tobias Mende on 03.05.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "FileOutlineView.h"
#import <TMTHelperCollection/TMTLog.h>
@implementation FileOutlineView

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent {
    if(![self.contextualMenu performKeyEquivalent:theEvent]) {
        return [super performKeyEquivalent:theEvent];
    }
    return YES;
    
}


- (NSMenu *)menuForEvent:(NSEvent *)event {
    NSMenu *menu = [super menuForEvent:event];
    if (event.type == NSRightMouseDown && self.clickedRow < 0 && self.backgroundMenu) {
        menu = self.backgroundMenu;
    }
    
    return menu;
}

@end
