//
//  ApplicationController.h
//  TeXtended
//
//  Created by Tobias Mende on 17.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PreferencesController,DocumentCreationController, CompletionsController,TexdocPanelController;

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
}

/** The delegate is in most cases the window controller of the top most window to which some menu actions should be directed. The controllers must set themselfe as delegate when they become a key window.*/
@property (assign) NSWindowController *delegate;

/** Method for showing the texdoc panel to the user 
 
 @param sender the sender
 */
- (IBAction)showTexdocPanel:(id)sender;

/** Method for showing the preferences window to the user 
 
 @param sender the sender
 */
- (IBAction)showPreferences:(id)sender;

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

@end
