//
//  Document.h
//  SimpleLatexEditor
//
//  Created by Tobias Mende on 03.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <NoodleLineViewForML/NoodleLineViewForML.h>
@class LatexDocument, PreviewController, NoodleLineNumberView, DockableView;
@interface Document : NSDocument <NSTextViewDelegate>{
    PreviewController *previewController;
    DockableView *dockViewController;
    NoodleLineNumberView	*lineNumberView;
}
- (IBAction)showPDF:(id)sender;
@property (unsafe_unretained) IBOutlet NSTextView *editorView;
@property (strong) LatexDocument *latex;
@property (assign) BOOL canCompile;
@property (assign) BOOL autoCompile;

- (IBAction)compile:(id)sender;
@property (strong) IBOutlet NSWindow *editorWindow;
@property (weak) IBOutlet NSScrollView *scrollView;
@end
