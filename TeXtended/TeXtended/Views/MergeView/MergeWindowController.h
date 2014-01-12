//
//  MergeWindowController.h
//  TeXtended
//
//  Created by Tobias Hecht on 12.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MergeWindowController : NSWindowController

@property NSArray* popUpElements;
@property NSArray* popUpIdentifier;

- (NSString*)getMergedContentOfFile:(NSString*)path withBase:(NSString*)base;

@end
