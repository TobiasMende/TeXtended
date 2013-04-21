//
//  PreferencesController.h
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 09.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PreferencesController : NSWindowController <NSWindowDelegate, NSToolbarDelegate> {
    IBOutlet NSView *generalPreferencesView;
    IBOutlet NSView *colorPreferencesView;
    IBOutlet NSView *codeAssistantPreferencesView;
    IBOutlet NSToolbar *toolbar;
    NSUInteger currentViewTag;
}

-(NSView *)viewForTag:(NSUInteger)tag;
-(IBAction)switchView:(id)sender;
-(NSRect)newFrameForNewContentView:(NSView *)view;

@end
