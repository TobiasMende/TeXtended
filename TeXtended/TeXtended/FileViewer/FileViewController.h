//
//  OutlineViewStaticAppDeligate.h
//  Sandbox
//
//  Created by Tobias Hecht on 16.04.13.
//  Copyright (c) 2013 Tobias Hecht. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DocumentModel, FileViewModel, InfoWindowController, DocumentController;

@interface FileViewController : NSViewController <NSOutlineViewDelegate, NSOutlineViewDataSource, NSTextDelegate> {
    FileViewModel *nodes;
    NSMutableArray *pathsToWatch;
    FSEventStreamRef stream;
    NSDate* appStartedTimestamp;
    NSNumber* lastEventId;
    NSArray* draggedItems;
    
    __weak NSButton *_titleButton;
    __weak IBOutlet NSOutlineView *outline;
    __weak IBOutlet NSBox *titleBox;
}

@property (weak) DocumentModel* doc;
@property (weak) IBOutlet NSTextField *titleLbl;
@property InfoWindowController *infoWindowController;
@property (weak) DocumentController *docController;

- (void)doubleClick:(id)object;
- (void)loadDocument:(DocumentModel*)document;
- (IBAction)openInfoView:(id)sender;
- (IBAction)openFolderinFinder:(id)sender;
- (IBAction)newFile:(id)sender;
- (IBAction)newFolder:(id)sender;
- (IBAction)duplicate:(id)sender;
- (IBAction)renameFile:(id)sender;
- (IBAction)deleteFile:(id)sender;

@property (weak) IBOutlet NSButton *titleButton;
@end