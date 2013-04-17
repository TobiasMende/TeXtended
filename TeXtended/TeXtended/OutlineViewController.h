//
//  OutlineViewStaticAppDeligate.h
//  Sandbox
//
//  Created by Tobias Hecht on 16.04.13.
//  Copyright (c) 2013 Tobias Hecht. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OutlineViewStaticAppDeligate : NSObject <NSApplicationDelegate> {
    NSArray *nodes;
}

- (NSArray*) recursiveFileFinder: (NSURL*)path;
- (BOOL)loadPath: (NSURL*)path;

@end
