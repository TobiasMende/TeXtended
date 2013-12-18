//
//  BibtexWindowController.h
//  DBLP Tool
//
//  Created by Tobias Mende on 14.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TMTBibTexEntry;
@interface BibtexWindowController : NSWindowController
@property (unsafe_unretained) IBOutlet NSTextView *bibtexView;
@property TMTBibTexEntry *publication;

- (id)initWithPublication:(TMTBibTexEntry *)publication;
- (void) showPublication:(TMTBibTexEntry *)publication;
@end
