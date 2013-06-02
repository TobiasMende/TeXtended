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
#import "Constants.h"


@interface DocumentController ()

@end
@implementation DocumentController


- initWithDocument:(DocumentModel *)model andMainDocument:(id<MainDocument>) document {
    self = [super init];
    if (self) {
        NSLog(@"DocumentController: Init");
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
    [self.windowController setDocumentController:self];
    
}

- (void)setupWindowController {
    NSLog(@"Setup WindowController");
    [self.windowController clearAllDocumentViews];
    [self.windowController setDocumentController:self];
    [self.windowController addOutlineView:self.outlineViewController.view];
    [self.windowController addTextView:self.textViewController.view];
    [self.windowController addConsoleViewsView:self.consolViewsController.view];
    [self.windowController addPDFViewsView:self.pdfViewsController.view];
    [self loadContent];
    [self.windowController makeFirstResponder:self.textViewController.view];
}

- (id <DocumentControllerProtocol>) parent {
    return nil;
}

- (DocumentController * ) documentController {
    return self;
}

- (NSSet *) children {
    NSSet<DocumentControllerProtocol> *children = [NSSet setWithObjects:
                       [self textViewController],
                       [self pdfViewsController],
                       [self consolViewsController],
                       [self outlineViewController], nil];
    return children;
}

- (void) documentModelHasChangedAction : (DocumentController*) controller {
    [[self textViewController] documentModelHasChangedAction:self];
    [[self pdfViewsController] documentModelHasChangedAction:self];
    [[self consolViewsController] documentModelHasChangedAction:self];
    [[self outlineViewController] documentModelHasChangedAction:self];
}

- (void) documentHasChangedAction {
    [[self textViewController] documentHasChangedAction];
    [[self pdfViewsController] documentHasChangedAction];
    [[self consolViewsController] documentHasChangedAction];
    [[self outlineViewController] documentHasChangedAction];
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


- (void)setModel:(DocumentModel *)model {
    if (self.model) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:TMTDocumentModelDidChangeNotification object:self.model];
    }
    [self willChangeValueForKey:@"model"];
    _model = model;
    [self didChangeValueForKey:@"model"];
    if (self.model) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentModelDidChange) name:TMTDocumentModelDidChangeNotification object:self.model];
    }
}

- (void) draftCompile {
    //TODO: compile the document
}

- (void)documentModelDidChange {
    [self documentModelHasChangedAction:self];
}

- (void)dealloc {
    NSLog(@"dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
