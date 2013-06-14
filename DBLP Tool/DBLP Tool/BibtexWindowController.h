//
//  BibtexWindowController.h
//  DBLP Tool
//
//  Created by Tobias Mende on 14.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DBLPPublication;
@interface BibtexWindowController : NSWindowController
@property (unsafe_unretained) IBOutlet NSTextView *bibtexView;
@property DBLPPublication *publication;

- (id)initWithPublication:(DBLPPublication *)publication;
- (void) showPublication:(DBLPPublication *)publication;
@end
