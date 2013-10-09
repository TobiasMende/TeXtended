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
#import "OutlineViewController.h"
#import "Constants.h"
#import "Compiler.h"
#import "ViewControllerProtocol.h"
#import "MainWindowController.h"
#import "DDLog.h"
#import "TMTLog.h"
#import "ExtendedPDFViewController.h"

static const NSSet *SELECTORS_HANDLED_BY_PDF;
static NSUInteger calls = 0;

@interface DocumentController ()
- (void) updateViewsAfterModelChange;
@end
@implementation DocumentController

+ (void)initialize {
    if (self == [DocumentController class]) {
        
        /* put initialization code here */
        
        calls++;
        SELECTORS_HANDLED_BY_PDF = [NSSet setWithObjects:NSStringFromSelector(@selector(printDocument:)), nil];
    }
    assert(calls < 2);
}

- (id)initWithDocument:(DocumentModel *)model andMainWindowController:(MainWindowController *) wc {
    self = [super init];
    if (self) {
        DDLogVerbose(@"DocumentController: Init");
        self.model = model;
        _windowController = wc;
        // FIXME: Set main document
        
        _consoleViewControllers = [NSMutableSet new];
        
        // TODO: init my view controllers by asking the MainWindowController
        _compiler = [[Compiler alloc] initWithDocumentController:self];
        [self.textViewController addObserver:self.compiler];
    }
    return self;
}

- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context {
    [super addObserver:observer forKeyPath:keyPath options:options context:context];
}



- (BOOL) saveDocument:(NSError *__autoreleasing *)outError {
    return [self.model saveContent:[self.textViewController content] error:outError];
}


- (void)breakUndoCoalescing {
    [self.textViewController breakUndoCoalescing];
}


- (void)setModel:(DocumentModel *)model {
    if (model != _model) {
        if (self.model) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:TMTDocumentModelDidChangeNotification object:self.model];
        }
        _model = model;
        
        [self updateViewsAfterModelChange];
        if (self.model) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentModelDidChange) name:TMTDocumentModelDidChangeNotification object:self.model];
        }
    }
}

- (void)updateViewsAfterModelChange {
    _textViewController = [[TextViewController alloc] initWithDocumentController:self];
    self.pdfViewControllers = [NSMutableSet new];
    for(DocumentModel *model in self.model.mainDocuments) {
        ExtendedPDFViewController *cont = [[ExtendedPDFViewController alloc] initWithDocumentController:self];
        cont.model = model;
        [self.pdfViewControllers addObject:cont];
    }
}

- (void) draftCompile {
    [self.mainDocument saveEntireDocumentWithDelegate:self andSelector:@selector(draftCompile:didSave:contextInfo:)];
    
}

- (void)draftCompile:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void *)context {
    if (self.model.texPath) {
        [self.compiler compile:draft];
    }
}

- (void) finalCompile {
    [self.mainDocument saveEntireDocumentWithDelegate:self andSelector:@selector(finalCompile:didSave:contextInfo:)];
   
}

- (void)finalCompile:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void *)context {
    if (self.model.texPath) {
         [self.compiler compile:final];
    }
}

- (void)refreshLiveView {
    [self.mainDocument saveEntireDocumentWithDelegate:self andSelector:@selector(liveCompile:didSave:contextInfo:)];
    
}

- (void)liveCompile:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void *)context {
    if (self.model.texPath) {
        [self.compiler compile:live];
    }
}

- (void)documentModelDidChange {
    [self documentModelHasChangedAction:self];
}

- (void)documentModelHasChangedAction:(DocumentController *)dc {
    // TODO: call on all children
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
    DDLogVerbose(@"dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
