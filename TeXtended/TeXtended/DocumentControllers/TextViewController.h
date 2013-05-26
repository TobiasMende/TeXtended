//
//  TextViewController.h
//  TeXtended
//
//  Created by Tobias Mende on 26.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DocumentControllerProtocol.h"
@class HighlightingTextView, LineNumberView;
@interface TextViewController : NSViewController<DocumentControllerProtocol> {
    LineNumberView *lineNumberView;
}
@property (strong) IBOutlet HighlightingTextView *textView;
@property (strong) IBOutlet NSScrollView *scrollView;
@property (strong) id<DocumentControllerProtocol> parent;

- (NSString *)content;
- (void) setContent:(NSString*) content;

- (void) documentWasSaved;
@end
