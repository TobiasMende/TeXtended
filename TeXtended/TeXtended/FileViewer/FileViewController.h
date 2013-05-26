//
//  OutlineViewStaticAppDeligate.h
//  Sandbox
//
//  Created by Tobias Hecht on 16.04.13.
//  Copyright (c) 2013 Tobias Hecht. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileViewModel.h"
@class DocumentModel;

@interface FileViewController : NSViewController <NSOutlineViewDelegate, NSOutlineViewDataSource> {
    FileViewModel *nodes;
    NSMutableArray *pathsToWatch;
    FSEventStreamRef stream;
    NSDate* appStartedTimestamp;
    NSNumber* lastEventId;
    
    IBOutlet NSOutlineView *outline;
}

- (void) recursiveFileFinder: (NSURL*)url;
- (BOOL)loadPath: (NSURL*)url;
- (void)doubleClick:(id)object;
- (void)loadDocument:(DocumentModel*)document;

@end