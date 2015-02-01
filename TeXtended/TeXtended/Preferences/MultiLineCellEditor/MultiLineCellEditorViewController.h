//
//  MultiLineCellEditorViewController.h
//  TeXtended
//
//  Created by Tobias Mende on 02.07.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Completion,LightHighlightingTextView;
@interface MultiLineCellEditorViewController : NSViewController<NSTextViewDelegate> {
    NSValueTransformer *transformer;
    NSUndoManager *undoManager;
}

- (id)initWithCompletion:(Completion *)completion andKeyPath:(NSString *)keyPath;

@property Completion *completion;
@property NSString *keyPath;
@property (strong) IBOutlet LightHighlightingTextView *textView;
@property (assign) NSPopover* popover;
- (void) close:(id)sender;
@end
