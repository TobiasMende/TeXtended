//
//  SimpleDocument.h
//  TeXtended
//
//  Created by Tobias Mende on 17.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LineNumberView.h"
@class HighlightingTextView, DocumentModel, FileViewController;
@interface SimpleDocument : NSDocument {
    /** Extention of NSRulerView to show line numbers. */
    LineNumberView *lineNumberView;
    NSString *temporaryTextStorage;
}
@property (weak) IBOutlet NSSplitView *leftSidebar;
@property (weak) IBOutlet NSScrollView *editorScrollView;
@property (unsafe_unretained) IBOutlet HighlightingTextView *editorView;
@property (strong) IBOutlet FileViewController *fileViewController;
@property (strong) NSManagedObjectContext *context;
@property (strong) DocumentModel *model;
@end
