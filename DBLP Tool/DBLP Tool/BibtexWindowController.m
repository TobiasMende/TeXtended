//
//  BibtexWindowController.m
//  DBLP Tool
//
//  Created by Tobias Mende on 14.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "BibtexWindowController.h"

@interface BibtexWindowController ()

@end

@implementation BibtexWindowController

- (id)initWithPublication:(DBLPPublication *)publication {
    self = [super initWithWindowNibName:@"BibtexWindow"];
    
    if (self) {
        _publication = publication;
    }
    return  self;
}

- (void)windowDidLoad {
    [self.bibtexView setTextColor:[NSColor controlLightHighlightColor]];
}

- (void)showPublication:(DBLPPublication *)publication {
    self.publication = publication;
    [self showWindow:self];
}

@end
