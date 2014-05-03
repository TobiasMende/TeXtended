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

@end
