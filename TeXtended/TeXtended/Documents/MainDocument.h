//
//  MainDocument.h
//  TeXtended
//
//  Created by Tobias Mende on 02.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Compilable, MainWindowController;

@interface MainDocument : NSDocument

/** The context in which the associated DocumentModel and subobjects live in */
@property (strong) NSManagedObjectContext *context;
/** The controller of the documents main window */
@property (weak) MainWindowController *mainWindowController;

/** A set of all document controllers of the project */
@property (strong) NSMutableSet *documentControllers;

- (void) saveEntireDocumentWithDelegate:(id)delegate andSelector:(SEL)action;
- (Compilable *) model;
- (void)initializeDocumentControllers;
@end
