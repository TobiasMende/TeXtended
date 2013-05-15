//
//  OutlineViewStaticAppDeligate.h
//  Sandbox
//
//  Created by Tobias Hecht on 16.04.13.
//  Copyright (c) 2013 Tobias Hecht. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileViewController : NSViewController <NSOutlineViewDelegate, NSOutlineViewDataSource> {
    NSArray *nodes;
    
    IBOutlet NSOutlineView *outline;
}

- (NSArray*) recursiveFileFinder: (NSURL*)url;
- (BOOL)loadPath: (NSURL*)url;
- (void)doubleClick:(id)object;

@end