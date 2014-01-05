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
    __unsafe_unretained IBOutlet NSView *generalPreferencesView;
    
    /** Reference to the view showing the color preferences */
    __unsafe_unretained IBOutlet NSView *colorPreferencesView;
    
    /** Reference to the code assistant preferences */
    __unsafe_unretained IBOutlet NSView *codeAssistantPreferencesView;
    
    /** Reference to the preview settings */
    __unsafe_unretained IBOutlet NSView *previewPreferencesView;
    
    /** Reference to the drop assistant settings */
    __unsafe_unretained IBOutlet NSView *dropAssistantPreferenceView;
    
    /** The toolbar of the preferences window */
    __unsafe_unretained IBOutlet NSToolbar *toolbar;
    
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

/** Method for switching the preference windows subviews 
 
 @param sender the sender
 */
-(IBAction)switchView:(id)sender;

/**
 Method for notifiing the preferences controller that the application is going to terminante
 
 @param notification the notification object
 */
- (void)applicationWillTerminate:(NSNotification *)notification;

/** Action for opening the compile flow folder in the default application (e.g. Finder) 
 
 @param sender the sender
 */
- (IBAction)openCompileFlowFolder:(id)sender;
- (IBAction)resetCompilers:(id)sender;

@end
