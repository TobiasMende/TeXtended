//
//  InfoWindowController.h
//  TeXtended
//
//  Created by Tobias Hecht on 09.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class DocumentModel;

@interface InfoWindowController : NSWindowController <NSTableViewDataSource> {
}

@property (weak) IBOutlet NSTableView *table;
@property (weak) DocumentModel* doc;
@property (weak) IBOutlet NSTextField *lblName;
@property (weak) IBOutlet NSTextField *lblType;
@property (weak) IBOutlet NSTextField *lblCompile;
@property (weak) IBOutlet NSTextField *lblChange;
@property (weak) IBOutlet NSTextField *lblPath;

- (void)loadDocument:(DocumentModel*) document;
@end
