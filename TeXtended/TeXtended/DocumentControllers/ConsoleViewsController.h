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
@interface ConsoleViewsController : NSViewController<DocumentControllerProtocol>
@property (weak) IBOutlet MessageDataSource *messageDataSource;

@property (weak) id<DocumentControllerProtocol> parent;
@property (strong) NSSet* children;
@property (weak) IBOutlet NSTabView *tabView;
@property (weak) IBOutlet NSTableView *messageOutline;
@property (weak) DocumentModel *model;

@end
