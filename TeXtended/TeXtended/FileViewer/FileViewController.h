//
//  OutlineViewStaticAppDeligate.h
//  Sandbox
//
//  Created by Tobias Hecht on 16.04.13.
//  Copyright (c) 2013 Tobias Hecht. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DocumentModel, FileViewModel, InfoWindowController;

@interface FileViewController : NSViewController <NSOutlineViewDelegate, NSOutlineViewDataSource, NSTextDelegate> {
    FileViewModel *nodes;
    NSMutableArray *pathsToWatch;
    FSEventStreamRef stream;
    NSDate* appStartedTimestamp;
    NSNumber* lastEventId;
    
    __weak NSButton *_titleButton;
    __weak IBOutlet NSOutlineView *outline;
    __weak IBOutlet NSBox *titleBox;
}

@property (weak) DocumentModel* doc;
@property (weak) IBOutlet NSTextField *titleLbl;
@property InfoWindowController *infoWindowController;

- (void)doubleClick:(id)object;
- (void)loadDocument:(DocumentModel*)document;
- (IBAction)openInfoView:(id)sender;

@property (weak) IBOutlet NSButton *titleButton;
@end