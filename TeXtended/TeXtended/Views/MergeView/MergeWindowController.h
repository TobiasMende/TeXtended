//
//  MergeWindowController.h
//  TeXtended
//
//  Created by Tobias Hecht on 12.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GraphController;

@interface MergeWindowController : NSWindowController
    {
        GraphController *graphController;
    }

    @property NSArray *popUpElements;

    @property NSArray *popUpPaths;

    @property (assign) IBOutlet NSPopUpButton *documentName;

    - (NSString *)getMergedContentOfFile:(NSString *)path withBase:(NSString *)base;

    - (void)reset;

@end
