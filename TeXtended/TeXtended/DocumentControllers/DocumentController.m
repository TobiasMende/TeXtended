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
#import "Constants.h"
#import "Compiler.h"
#import "ViewControllerProtocol.h"
#import "MainWindowController.h"
#import "DDLog.h"
#import "TMTLog.h"
#import "ExtendedPDFViewController.h"
#import "TMTNotificationCenter.h"
#import "MainDocument.h"
#import "FirstResponderDelegate.h"

@interface DocumentController ()
- (void) updateViewsAfterModelChange;
@end
@implementation DocumentController

+ (void)initialize {
    if (self == [DocumentController class]) {
        
        /* put initialization code here */
        
    }
}

- (id)initWithDocument:(DocumentModel *)model andMainDocument:(MainDocument *)mainDocument {
    self = [super init];
    if (self) {
        DDLogVerbose(@"Init");
        self.model = model;
        self.mainDocument = mainDocument;
        self.consoleViewControllers = [NSMutableSet new];
        
        self.compiler = [[Compiler alloc] initWithDocumentController:self];
        [self.textViewController addObserver:self.compiler];
    }
    return self;
}

- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context {
    [super addObserver:observer forKeyPath:keyPath options:options context:context];
}


- (BOOL) saveDocumentModel:(NSError *__autoreleasing *)outError {
    return [self.model saveContent:[self.textViewController content] error:outError];
}


- (void)breakUndoCoalescing {
    [self.textViewController breakUndoCoalescing];
}


- (void)setModel:(DocumentModel *)model {
    if (model != _model) {
        if (self.model) {
            [[TMTNotificationCenter centerForCompilable:self.model] removeObserver:self name:TMTDocumentModelDidChangeNotification object:self.model];
        }
        _model = model;
        
        [self updateViewsAfterModelChange];
        if (self.model) {
            [[TMTNotificationCenter centerForCompilable:self.model] addObserver:self selector:@selector(documentModelDidChange) name:TMTDocumentModelDidChangeNotification object:self.model];
        }
    }
}

- (void)updateViewsAfterModelChange {
    _textViewController = [[TextViewController alloc] initWithDocumentController:self];
    [self.textViewController setFirstResponderDelegate:self];
    self.pdfViewControllers = [NSMutableSet new];
    for(DocumentModel *model in self.model.mainDocuments) {
        ExtendedPDFViewController *cont = [[ExtendedPDFViewController alloc] initWithDocumentController:self];
        cont.model = model;
        [cont setFirstResponderDelegate:self];
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

#pragma mark - First Responder Delegate

- (void)saveDocument:(id)sender {
    [self.mainDocument saveDocument:self];
}

- (void)liveCompile:(id)sender {
    [self.mainDocument saveEntireDocumentWithDelegate:self andSelector:@selector(liveCompile:didSave:contextInfo:)];
}

- (void)draftCompile:(id)sender {
    [self.mainDocument saveEntireDocumentWithDelegate:self andSelector:@selector(draftCompile:didSave:contextInfo:)];
}

- (void)finalCompile:(id)sender {
    [self.mainDocument finalCompileForDocumentController:self];
}

- (void)showStatistics:(id)sender {
    [self.mainDocument showStatisticsForModel:self];
}

- (BOOL)isLiveCompileEnabled {
    return self.model.liveCompile.boolValue;
}

- (void)setLiveCompileEnabled:(BOOL)enable {
    [self willChangeValueForKey:@"liveCompileEnabled"];
    self.model.liveCompile = [NSNumber numberWithBool:enable];
    [self didChangeValueForKey:@"liveCompileEnabled"];
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
    DDLogVerbose(@"dealloc");
    [[TMTNotificationCenter centerForCompilable:self.model] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
