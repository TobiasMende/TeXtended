//
//  DBLPSearchViewController.h
//  DBLP Tool
//
//  Created by Tobias Mende on 19.12.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DBLPCallbackHandler.h"
#import "DBLPSearchCompletionHandler.h"
@class DBLPInterface,TMTTableView;
@interface DBLPSearchViewController : NSViewController<DBLPCallbackHandler, NSTableViewDelegate, NSTextFieldDelegate> {
    DBLPInterface *interface;
}

@property (assign) id<DBLPSearchCompletionHandler> handler;
@property (strong) IBOutlet NSPopUpButton *bibFileSelector;
@property NSArray *bibFilePaths;
@property BOOL searchinAuthor;
@property NSString *executeCitationLabel;
@property (assign) IBOutlet NSDictionaryController *authorsController;
@property (assign) IBOutlet TMTTableView *authorTable;
@property (assign) IBOutlet NSArrayController *publicationsController;
@property (assign) IBOutlet TMTTableView *publicationTable;

@property (assign) IBOutlet NSTextField *authorField;

- (IBAction)clickedAuthorTable:(id)sender;
- (IBAction)performDoubleClick;
- (IBAction)executeCitation:(id)sender;
- (void) finishInitialization;
@end
