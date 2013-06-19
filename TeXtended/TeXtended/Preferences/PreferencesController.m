//
//  PreferencesController.m
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 09.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "PreferencesController.h"
#import "CompletionsController.h"
#import "CompileFlowHandler.h"
@interface PreferencesController ()

/** Method for calculating a new matching frame for a given view.
 
 @param view the view to calculate a frame for.
 
 @return the new frame.
 
 */
-(NSRect)newFrameForNewContentView:(NSView *)view;
@end

@implementation PreferencesController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        [window setDelegate:self];
        completionsController = [[CompletionsController alloc] init];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [self.window setContentSize:[generalPreferencesView frame].size];
	[[self.window contentView] addSubview:generalPreferencesView];
	[toolbar setSelectedItemIdentifier:@"General"];
    [self.window center];
}

- (void)windowDidBecomeKey:(NSNotification *)notification {
    [[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
}

- (void)windowWillClose:(NSNotification *)notification {
    [[NSColorPanel sharedColorPanel] close];
    [completionsController saveCompletions];
}

- (void)windowDidResignKey:(NSNotification *)notification {
    [[NSColorPanel sharedColorPanel] close];
    
}


-(NSView *)viewForTag:(NSUInteger)tag {
    NSView *view = nil;
	switch(tag) {
		case 0: default: view = generalPreferencesView; break;
		case 1: view = colorPreferencesView; break;
		case 2: view = codeAssistantPreferencesView; break;
        case 3: view = previewPreferencesView; break;
	}
    return view;
}

-(NSRect)newFrameForNewContentView:(NSView *)view {
	
    NSRect newFrameRect = [self.window frameRectForContentRect:[view frame]];
    NSRect oldFrameRect = [self.window frame];
    NSSize newSize = newFrameRect.size;
    NSSize oldSize = oldFrameRect.size;
    NSRect frame = [self.window frame];
    frame.size = newSize;
    frame.origin.y -= (newSize.height - oldSize.height);
    
    return frame;
}


-(IBAction)switchView:(id)sender {
	
	NSUInteger tag = [sender tag];
	
	NSView *view = [self viewForTag:tag];
	NSView *previousView = [self viewForTag: currentViewTag];
	currentViewTag = tag;
	NSRect newFrame = [self newFrameForNewContentView:view];
	
	[NSAnimationContext beginGrouping];
	[[NSAnimationContext currentContext] setDuration:0.1];
	
	if ([[NSApp currentEvent] modifierFlags] & NSShiftKeyMask)
	    [[NSAnimationContext currentContext] setDuration:1.0];
	
	[[[self.window contentView] animator] replaceSubview:previousView with:view];
	[[self.window animator] setFrame:newFrame display:YES];
	
	[NSAnimationContext endGrouping];
	
}

- (CompletionsController *)completionsController {
    return completionsController;
}

-(NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)bar {
	return [[bar items] valueForKey:@"itemIdentifier"];
}


- (void)applicationWillTerminate:(NSNotification *)notification {
    [completionsController saveCompletions];
}

- (IBAction)openCompileFlowFolder:(id)sender {
    [[NSWorkspace sharedWorkspace] openFile:[CompileFlowHandler path]];
}


@end
