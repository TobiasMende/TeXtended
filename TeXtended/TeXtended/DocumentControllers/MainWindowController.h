//
//  MainWindowController.h
//  TeXtended
//
//  Created by Tobias Mende on 26.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DMSplitView.h"
#import "MainDocument.h"
#import "ViewControllerProtocol.h"
@class DocumentController, FileViewController, ExportCompileWindowController, TMTSplitView, TemplateWindowController, TemplateController, DMSplitView, OutlineViewController, Compilable, TMTTabViewWindow;

/**
 The MainWindowController is the controller of the main window of each document. 
 
 Maybe there are more than one window per document later, but this controller is the most important one, holding references to some other controller like the DocumentController and others.
 
 **Author:** Tobias Mende
 
 */

@interface MainWindowController : NSWindowController<NSWindowDelegate,DMSplitViewDelegate, ViewControllerProtocol> {
    TMTTabViewWindow* tabWindow1;
    TMTTabViewWindow* tabWindow2;
}


@property (strong) IBOutlet NSButton *sidebarViewToggle;
@property (strong) IBOutlet NSButton *secondViewToggle;


/** The main view containing the left and content view */
@property (strong) IBOutlet DMSplitView *mainView;

/** The left sidebar containing the file view and an outline view */
@property (strong) IBOutlet DMSplitView *sidebar;

/** The content split view (editor + pdf) */
@property  (assign) IBOutlet DMSplitView *contentView;


@property (assign) id<MainDocument> mainDocument;

/** the DocumentController controlling the current DocumentModel */
@property (strong) NSMutableSet *documentControllers;

@property (strong) Compilable *mainCompilable;

/** the FileViewController containing the file outline view */
@property  FileViewController *fileViewController;

/** The controller controlling the export window */
@property  (strong,nonatomic) ExportCompileWindowController* exportWindow;

/** Controller that handels the outlineView. */
@property (strong) OutlineViewController* outlineViewController;

/** Controller to a shett to choose templates */
@property (strong) TemplateController* templateController;


- (id)initWithMainDocument:(id<MainDocument>) document;

/** Action for opening the redmine ticket system in the default web browser 
 
 @param sender the sender
 */
- (IBAction)reportBug:(id)sender;

/** New file from template, opens the template selection */
- (IBAction) openTemplateSheet:(id)sender;

/** Action initiating the draft compile on the DocumentController 
 
 @param sender the sender
 */
- (IBAction)draftCompile:(id)sender;

/** Action initiating the final compile on the DocumentController 
 
 @param sender the sender
 */
- (IBAction)finalCompile:(id)sender;

/** Action initiating the live compile on the DocumentController 
 
 @param sender the sender
 */
- (IBAction)liveCompile:(id)sender;

/**
 A method for performing a general action which is determined by the sender in any instance. This method calls the method  with the same arguments.
 
 @warning This method is used to reduce the number of methods in the first responder. Use it only, if the action to perform is really clean and generate other action methods otherwise.
 
 @param sender the sender
 
 */
- (IBAction)genericAction:(id)sender;

- (IBAction)toggleSidebarView:(id)sender;
- (IBAction)toggleSecondView:(id)sender;


- (DocumentController *)activeDocumentController;

@end
