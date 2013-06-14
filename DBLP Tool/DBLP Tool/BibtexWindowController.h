//
//  BibtexWindowController.h
//  DBLP Tool
//
//  Created by Tobias Mende on 14.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Publication;
@interface BibtexWindowController : NSWindowController
@property (unsafe_unretained) IBOutlet NSTextView *bibtexView;
@property Publication *publication;

- (id)initWithPublication:(Publication *)publication;
- (void) showPublication:(Publication *)publication;
@end
