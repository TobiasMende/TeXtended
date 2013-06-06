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
@property (unsafe_unretained) IBOutlet HighlightingTextView *textView;
@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) id<DocumentControllerProtocol> parent;

- (NSString *)content;
- (void) setContent:(NSString*) content;

@end
