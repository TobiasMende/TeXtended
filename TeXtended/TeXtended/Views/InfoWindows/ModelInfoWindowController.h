//
//  ModelInfoWindowController.h
//  TeXtended
//
//  Created by Tobias Mende on 17.05.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ModelInfoViewController.h"


@class Compilable, CompilerPreferencesViewController;

@interface ModelInfoWindowController : NSWindowController

    @property (nonatomic) Compilable *model;


#pragma mark - ViewController

    @property NSViewController <ModelInfoViewController> *infoViewController;

    @property CompilerPreferencesViewController *liveCompilePrefs;

    @property CompilerPreferencesViewController *draftCompilePrefs;

    @property CompilerPreferencesViewController *finalCompilePrefs;


#pragma mark - Views

    @property (strong) IBOutlet NSBox *liveCompilerView;

    @property (strong) IBOutlet NSBox *draftCompilerView;

    @property (strong) IBOutlet NSBox *finalCompilerView;

    @property (strong) IBOutlet NSTableView *bibFiles;

    @property (strong) IBOutlet NSTableView *mainDocuments;

    @property (strong) IBOutlet NSArrayController *mainDocumentsController;

    @property (strong) IBOutlet NSArrayController *bibFilesController;

    @property (strong) IBOutlet NSBox *infoView;


#pragma mark - Actions

    - (IBAction)addBibFiles:(id)sender;

    - (IBAction)addMainDocument:(id)sender;

    - (BOOL)canRemoveMainDocument;

@end
