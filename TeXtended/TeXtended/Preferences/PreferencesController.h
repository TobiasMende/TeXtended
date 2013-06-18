//
//  PreferencesController.h
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 09.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class CompletionsController;
@interface PreferencesController : NSWindowController <NSWindowDelegate, NSToolbarDelegate> {
    __weak IBOutlet NSView *generalPreferencesView;
    __weak IBOutlet NSView *colorPreferencesView;
    __weak IBOutlet NSView *codeAssistantPreferencesView;
    __weak IBOutlet NSView *previewPreferencesView;
    __weak IBOutlet NSToolbar *toolbar;
    NSUInteger currentViewTag;
    
 IBOutlet CompletionsController *completionsController;
}


- (CompletionsController *)completionsController;
-(NSView *)viewForTag:(NSUInteger)tag;
-(IBAction)switchView:(id)sender;
-(NSRect)newFrameForNewContentView:(NSView *)view;
- (void)applicationWillTerminate:(NSNotification *)notification;
- (IBAction)openCompileFlowFolder:(id)sender;

@end
