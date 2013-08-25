//
//  AppDelegate.h
//  DBLP Tool
//
//  Created by Tobias Mende on 14.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DBLPCallbackHandler.h"

@class DBLPInterface, BibtexWindowController;
@interface AppDelegate : NSObject <NSApplicationDelegate, DBLPCallbackHandler, NSTextFieldDelegate, NSTableViewDelegate> {
    DBLPInterface *dblp;
    BibtexWindowController *bc;
}
@property (weak) IBOutlet NSTextField *resultLabel;
@property BOOL searchinAuthor;
@property (weak) IBOutlet NSDictionaryController *authorsController;
@property (weak) IBOutlet NSTableView *authorTable;
@property (weak) IBOutlet NSArrayController *publicationsController;
@property (weak) IBOutlet NSTableView *publicationTable;

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *authorField;
- (IBAction)clickedAuthorTable:(id)sender;

@end
