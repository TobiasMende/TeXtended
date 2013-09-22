//
//  SimpleDocument.h
//  TeXtended
//
//  Created by Tobias Mende on 17.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainDocument.h"
@class DocumentModel, MainWindowController, DocumentController;

/**
 The SimpleDocument is a subclass of a NSDocument used for handling single file documents like exercise sheets etc.
 
 In general this document hold a DocumentModel, its controller and a MainWindowController and delegates different actions to them.
 
 **Author:** Tobias Mende
 
 */
@interface SimpleDocument : NSDocument <MainDocument> {
    
}

/** The context in which the associated DocumentModel and subobjects live in */
@property (strong) NSManagedObjectContext *context;

/** The model represented in this document holding all information about the current document */
@property (strong) DocumentModel *model;

/** The controller of the documents main window */
@property (strong) MainWindowController *mainWindowController;


@end
