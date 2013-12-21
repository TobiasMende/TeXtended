//
//  ApplicationController.h
//  TeXtended
//
//  Created by Tobias Mende on 17.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FirstResponderDelegate.h"
@class PreferencesController,DocumentCreationController, CompletionsController,TexdocPanelController, ConsoleWindowController;

/**
 The application controller is a singleton which represents the central instance of the TeXtended application.
 
 **Author:** Tobias Mende
 
 */

@interface ApplicationController : NSObject <NSApplicationDelegate> {
    /** references to the controller which handels the preferences window. */
    PreferencesController *preferencesController;
    
    /** reference to the controller handling the creation and management of all documents in this application */
    DocumentCreationController *documentCreationController;
    
    /** reference to the texdoc panel controller handling the app wide texdoc support */
    TexdocPanelController *texdocPanelController;
    
    ConsoleWindowController *consoleWindowController;
}

@property (assign) id<FirstResponderDelegate> currentFirstResponderDelegate;

/** Method for showing the texdoc panel to the user 
 
 @param sender the sender
 */
- (IBAction)showTexdocPanel:(id)sender;

/** Method for showing the preferences window to the user 
 
 @param sender the sender
 */
- (IBAction)showPreferences:(id)sender;

- (IBAction)showConsoles:(id)sender;

/** Getter for the completion controller handling code autocompletions 
 
 @return the completion controller
 */
- (CompletionsController*) completionsController;

/** Getter for the shared instance of this singleton 
 
 @return the one and only instance of this class.
 */
+ (ApplicationController*) sharedApplicationController;

/** Getter for the absolute path to the current users application support directory
 @return the absolute path
 */
+ (NSString*) userApplicationSupportDirectoryPath;
+ (void)mergeCompileFlows:(BOOL)force;
@end
