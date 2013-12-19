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
@class DBLPInterface;
@interface DBLPSearchViewController : NSViewController<DBLPCallbackHandler, NSTableViewDelegate, NSTextFieldDelegate> {
    DBLPInterface *interface;
}

@property (weak) id<DBLPSearchCompletionHandler> handler;
@property (strong) IBOutlet NSPopUpButton *bibFileSelector;
@property NSArray *bibFilePaths;
@property BOOL searchinAuthor;
@property NSString *executeCitationLabel;
@property (weak) IBOutlet NSDictionaryController *authorsController;
@property (weak) IBOutlet NSTableView *authorTable;
@property (weak) IBOutlet NSArrayController *publicationsController;
@property (weak) IBOutlet NSTableView *publicationTable;

@property (weak) IBOutlet NSTextField *authorField;

- (IBAction)clickedAuthorTable:(id)sender;
- (IBAction)performDoubleClick;
- (IBAction)executeCitation:(id)sender;
- (void) finishInitialization;
@end
