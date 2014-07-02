//
//  ApplicationController.h
//  TeXtended
//
//  Created by Tobias Mende on 17.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PreferencesController, DocumentCreationController, CompletionsController, TexdocPanelController, ConsoleWindowController, TemplateController, StartScreenWindowController;

/**
 The application controller is a singleton which represents the central instance of the TeXtended application.
 
 **Author:** Tobias Mende
 
 */

@interface ApplicationController : NSObject <NSApplicationDelegate>
    {
        /** references to the controller which handels the preferences window. */
        PreferencesController *preferencesController;

        /** reference to the controller handling the creation and management of all documents in this application */
        DocumentCreationController *documentCreationController;

        /** reference to the texdoc panel controller handling the app wide texdoc support */
        TexdocPanelController *texdocPanelController;

        ConsoleWindowController *consoleWindowController;

        TemplateController *templateController;
        
        StartScreenWindowController *startScreenController;
    }


/** Method for showing the texdoc panel to the user 
 
 @param sender the sender
 */
    - (IBAction)showTexdocPanel:(id)sender;

/** Method for showing the preferences window to the user 
 
 @param sender the sender
 */
    - (IBAction)showPreferences:(id)sender;

    - (IBAction)showConsoles:(id)sender;

    - (IBAction)showNewFromTemplate:(id)sender;

/** Getter for the completion controller handling code autocompletions 
 
 @return the completion controller
 */
    - (CompletionsController *)completionsController;

/** Getter for the shared instance of this singleton 
 
 @return the one and only instance of this class.
 */
    + (ApplicationController *)sharedApplicationController;

/** Getter for the absolute path to the current users application support directory
 @return the absolute path
 */
    + (NSString *)userApplicationSupportDirectoryPath;

    + (void)mergeCompileFlows:(BOOL)force;

    - (IBAction)togglePreviewPanel:(id)previewPanel;

- (void) updateRecentDocuments;
- (IBAction)openRecent:(id)sender;
- (NSArray *)addRecentSimpleDocumentsTo:(NSMenu *)menu;
- (NSArray *)addRecentProjectDocumentsTo:(NSMenu *)menu;
- (NSMenu *)fileMenu;
- (NSMenuItem *)openRecentMenuItem;
@end
