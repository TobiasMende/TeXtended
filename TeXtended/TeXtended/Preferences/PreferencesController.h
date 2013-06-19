//
//  PreferencesController.h
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 09.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class CompletionsController;

/**
 The preferences controller is a window controller handling the preferences window and the different views in it.
 
 **Author:** Tobias Mende
 
 */
@interface PreferencesController : NSWindowController <NSWindowDelegate, NSToolbarDelegate> {
    /** A reference to the view showing general preferences */
    __weak IBOutlet NSView *generalPreferencesView;
    
    /** Reference to the view showing the color preferences */
    __weak IBOutlet NSView *colorPreferencesView;
    
    /** Reference to the code assistant preferences */
    __weak IBOutlet NSView *codeAssistantPreferencesView;
    
    /** Reference to the preview settings */
    __weak IBOutlet NSView *previewPreferencesView;
    
    /** The toolbar of the preferences window */
    __weak IBOutlet NSToolbar *toolbar;
    
    /** Storage for the currents view tag */
    NSUInteger currentViewTag;
    
    /** Reference to the completions controller handling the auto completions for commands end environments */
    IBOutlet CompletionsController *completionsController;
}

/** Getter for the completion controller */
- (CompletionsController *)completionsController;

/** Method for getting the subview by its tag.
 
 @param tag the subviews tag
 
 @return the subview
*/
-(NSView *)viewForTag:(NSUInteger)tag;

/** Method for switching the preference windows subviews */
-(IBAction)switchView:(id)sender;

/**
 Method for notifiing the preferences controller that the application is going to terminante
 
 @param notification the notification object
 */
- (void)applicationWillTerminate:(NSNotification *)notification;

/** Action for opening the compile flow folder in the default application (e.g. Finder) */
- (IBAction)openCompileFlowFolder:(id)sender;

@end
