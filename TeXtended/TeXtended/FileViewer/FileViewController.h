//
//  OutlineViewStaticAppDeligate.h
//  Sandbox
//
//  Created by Tobias Hecht on 16.04.13.
//  Copyright (c) 2013 Tobias Hecht. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileViewModel.h"
#import "InfoWindowController.h"
@class DocumentModel;

@interface FileViewController : NSViewController <NSOutlineViewDelegate, NSOutlineViewDataSource> {
    FileViewModel *nodes;
    NSMutableArray *pathsToWatch;
    FSEventStreamRef stream;
    NSDate* appStartedTimestamp;
    NSNumber* lastEventId;
    
    __weak IBOutlet NSOutlineView *outline;
    __weak IBOutlet NSBox *titleBox;
}

@property (weak) DocumentModel* doc;
@property (weak) IBOutlet NSTextField *titleLbl;
@property InfoWindowController *infoWindowController;

- (void)doubleClick:(id)object;
- (void)loadDocument:(DocumentModel*)document;

@end