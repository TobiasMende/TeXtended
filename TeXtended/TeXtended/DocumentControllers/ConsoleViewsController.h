//
//  ConsoleViewsController.h
//  TeXtended
//
//  Created by Tobias Mende on 26.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DocumentControllerProtocol.h"
@class DocumentModel, MessageDataSource;

/**
 * This class handels the view controller for all consoles.
 * It implements the DocumentControllerProtocol.
 *
 * @author TObias MEnde
 */
@interface ConsoleViewsController : NSViewController<DocumentControllerProtocol>

/** The data source for messages */
@property (weak) IBOutlet MessageDataSource *messageDataSource;

/** Parent in the document controller tree.*/
@property (weak) id<DocumentControllerProtocol> parent;

/** Children in the document controller tree. */
@property (strong) NSSet* children;

/** A tabView holding the views for all consoles. */
@property (strong) IBOutlet NSTabView *tabView;

/** A tableview holding outline informations for messages like warnings. */
@property (strong) IBOutlet NSTableView *messageOutline;

/** The DocumentModel the console views are for. */
@property (weak) DocumentModel *model;

@end
