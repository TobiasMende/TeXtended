//
//  DocumentController.m
//  TeXtended
//
//  Created by Tobias Mende on 16.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "DocumentController.h"
#import "DocumentModel.h"
#import "TextViewController.h"
#import "PDFViewsController.h"
#import "ConsoleViewsController.h"
#import "OutlineViewController.h"


@interface DocumentController ()
- (void)setupWindowController;

@end
@implementation DocumentController


- initWithDocument:(DocumentModel *)model andMainDocument:(id<MainDocument>) document {
    self = [super init];
    if (self) {
        self.model = model;
        mainDocument = document;
        _textViewController = [[TextViewController alloc] initWithParent:self];
        _pdfViewsController = [[PDFViewsController alloc] initWithParent:self];
        _consolViewsController = [[ConsoleViewsController alloc] initWithParent:self];
        _outlineViewController = [[OutlineViewController alloc] initWithParent:self];
    }
    return self;
}

- (id) initWithParent:(id<DocumentControllerProtocol>) parent {
    return nil;
}

- (void)setWindowController:(id<WindowControllerProtocol>)windowController {
    _windowController = windowController;
    
    if (_windowController) {
        [self setupWindowController];
        
    }
}

- (void)setupWindowController {
    [self.windowController setDocumentController:self];
    [self.windowController addOutlineView:self.outlineViewController.view];
    [self.windowController addTextView:self.textViewController.view];
    [self.windowController addConsoleViewsView:self.consolViewsController.view];
    [self.windowController addPDFViewsView:self.pdfViewsController.view];
}

- (id <DocumentControllerProtocol>) parent {
    return nil;
}

- (DocumentController * ) documentController {
    return self;
}

- (NSSet<DocumentControllerProtocol> *) children {
    NSSet<DocumentControllerProtocol> *children = [NSSet setWithObjects:
                       [self textViewController],
                       [self pdfViewsController],
                       [self consolViewsController],
                       [self outlineViewController], nil];
    return children;
}

- (void) documentHasChangedAction {
    //TODO: call on children
}

- (BOOL) saveDocument:(NSError *__autoreleasing *)outError {
    return [self.model saveContent:[self.textViewController content] error:outError];
}

-(BOOL)loadContent {
    NSString *content = [self.model loadContent];
    if (content) {
        [self.textViewController setContent:content];
    }
    return content != nil;
}

- (void)breakUndoCoalescing {
    [self.textViewController breakUndoCoalescing];
}

@end
