//
//  PreferencesController.m
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 09.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "PreferencesController.h"

@interface PreferencesController ()

@end

@implementation PreferencesController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        [window setDelegate:self];
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)windowDidBecomeKey:(NSNotification *)notification {
    [[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
}

- (void)windowWillClose:(NSNotification *)notification {
    [[NSColorPanel sharedColorPanel] close];
}

- (void)windowDidResignKey:(NSNotification *)notification {
    [[NSColorPanel sharedColorPanel] close];
}

@end
