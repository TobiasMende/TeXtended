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
        _model = [controller model];
        
        [self.model addObserver:self forKeyPath:@"mainDocuments" options:NSKeyValueObservingOptionNew context:NULL];
        
        [self loadFileCompiler];
    }
    return self;
}


- (void) compile:(bool)draft {
    for (FileCompiler* compiler in [self fileCompiler]) {
        [compiler compile:draft];
    }
}

- (void) loadFileCompiler {
    _fileCompiler = [[NSMutableSet alloc] init];
    for (DocumentModel* model in [self.model mainDocuments]) {
        FileCompiler *fc = [[FileCompiler alloc] initWithDocumentModel:model];
        [fc setAutoCompile:[self autoCompile]];
        [self.fileCompiler addObject:fc];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object {
    if (object == self.model && [keyPath isEqual: @"mainDocuments"]) {
        [self loadFileCompiler];
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
    [self.model removeObserver:self forKeyPath:@"mainDocuments"];
}

@end
