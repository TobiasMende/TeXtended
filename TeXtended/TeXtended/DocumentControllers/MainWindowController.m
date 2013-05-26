//
//  MainWindowController.m
//  TeXtended
//
//  Created by Tobias Mende on 26.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "MainWindowController.h"

@interface MainWindowController ()

@end

@implementation MainWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)init {
    self = [super initWithWindowNibName:@"MainWindow"];
    if (self) {
        
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)clearAllDocumentViews {
    [self.left setSubviews:[NSArray arrayWithObject: nil]];
    [self.middle setSubviews:[NSArray arrayWithObject: nil]];
    [self.right setSubviews:[NSArray arrayWithObject: nil]];
}

- (void)addConsoleViewsView:(NSView *)view {
    [self.middle addSubview:view];
    [self.middle adjustSubviews];
}

- (void)addTextView:(NSView *)view {
    [self.middle addSubview:view];
    [self.middle adjustSubviews];
}

- (void)addOutlineView:(NSView *)view {
    [self.left addSubview:view];
    [self.left adjustSubviews];
}

- (void)addPDFViewsView:(NSView *)view {
    [self.right addSubview:view];
    [self.right adjustSubviews];
}

@end
