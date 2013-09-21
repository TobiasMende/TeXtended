//
//  MainWindowController.h
//  TeXtended
//
//  Created by Tobias Mende on 26.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WindowControllerProtocol.h"
#import "DMSplitView.h"
@class DocumentController, FileViewController, ExportCompileWindowController, TMTSplitView, TemplateWindowController, TemplateController, DMSplitView;

/**
 The MainWindowController is the controller of the main window of each document. 
 
 Maybe there are more than one window per document later, but this controller is the most important one, holding references to some other controller like the DocumentController and others.
 
 **Author:** Tobias Mende
 
 */

@interface MainWindowController : NSWindowController<WindowControllerProtocol,NSWindowDelegate,DMSplitViewDelegate> {
}

@property (strong) IBOutlet NSButton *leftViewToggle;
@property (strong) IBOutlet NSButton *bottomViewToggle;
@property (strong) IBOutlet NSButton *rightViewToggle;


/** The main view containing the left and content view */
@property (strong) IBOutlet DMSplitView *mainView;

/** The left sidebar containing the file view and an outline view */
@property (strong) IBOutlet DMSplitView *sidebar;

@property (strong) IBOutlet DMSplitView *contentView;

/** The middle view containing editor and console in most cases */
@property  (assign) IBOutlet DMSplitView *middle;

/** The right view containing the pdf view in most cases */
@property  (assign) IBOutlet DMSplitView *right;

/** the DocumentController controlling the current DocumentModel */
@property (strong, nonatomic) DocumentController *documentController;

/** the FileViewController containing the file outline view */
@property  FileViewController *fileViewController;

/** The controller controlling the export window */
@property  (strong,nonatomic) ExportCompileWindowController* exportWindow;

/** The area in which to show the file view itself */
@property (strong)  IBOutlet NSBox *fileViewArea;

/** Controller to a shett to choose templates */
@property (strong) TemplateController* templateController;

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

- (IBAction)toggleLeftView:(id)sender;
- (IBAction)toggleBottomView:(id)sender;
- (IBAction)toggleRightView:(id)sender;


@end
