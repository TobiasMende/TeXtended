//
//  ProjectDocument.h
//  TeXtended
//
//  Created by Tobias Mende on 17.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainDocument.h"
@class MainWindowController, ProjectModel;

/**
 The ProjectDocument is a NSDocument instance holding all information, model and controller connections for a project.
 In general a ProjectDocument has a single ProjectModel containing multiple DocumentModel and other attributes.
 
 **Author:** Tobias Mende
 
 */
@interface ProjectDocument : NSPersistentDocument<MainDocument>

/** The controller of the documents main window */
@property (strong) MainWindowController *mainWindowController;

/** A set of all document controllers of the project */
@property (strong) NSMutableSet *documentControllers;

/** The model of the project. */
@property (strong) ProjectModel *projectModel;

@end
