//
//  QuickPreviewManager.h
//  TeXtended
//
//  Created by Tobias Mende on 05.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FirstResponderDelegate.h"
#import "CompileProcessHandler.h"
@class HighlightingTextView, TextViewController, ExtendedPDFViewController, DocumentModel, Compiler;
@interface QuickPreviewManager : NSWindowController<FirstResponderDelegate,CompileProcessHandler,NSWindowDelegate>

@property (assign) HighlightingTextView *parentView;
@property TextViewController *textViewController;
@property ExtendedPDFViewController *pvc;

@property DocumentModel *model;
@property (strong) IBOutlet NSPopUpButton *mainCompilableSelection;

@property (strong) Compiler* compiler;
@property (strong) NSArray *mainDocuments;
@property (strong) NSString *currentHeader;

@property (strong) IBOutlet NSSplitView *splitView;
- (IBAction)insertCode:(id)sender;
- (IBAction)cancel:(id)sender;

- (id) initWithParentView:(HighlightingTextView *)parent;
@end
