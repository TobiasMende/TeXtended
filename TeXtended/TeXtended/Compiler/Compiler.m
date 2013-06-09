//
//  Compiler.m
//  TeXtended
//
//  Created by Max Bannach on 26.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "Compiler.h"
#import "DocumentModel.h"
#import "CompileFlowHandler.h"
#import "Constants.h"
#import "FileCompiler.h"

@interface Compiler ()
- (void) updateDocumentController;
@end

@implementation Compiler

- (id)initWithDocumentController:(DocumentController*) controller {
    self = [super init];
    NSLog(@"Compiler init");
    if (self) {
        [self setAutoCompile:NO];
        _documentController = controller;
        [self loadFileCompiler];
    }
    return self;
}


- (void) compile:(bool)draft {
    
    
}


- (void) loadFileCompiler {
    _fileCompiler = [[NSSet alloc] init];
    for (DocumentModel* model in [self.documentController.model mainDocuments]) {
        FileCompiler *fc = [[FileCompiler alloc] initWithDocumentModel:model];
        [self.fileCompiler insertValue:fc inPropertyWithKey:nil];
    }
    
    
}

- (void) updateDocumentController {
    [self.documentController documentHasChangedAction];
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"Compiler dealloc");
#endif

    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
