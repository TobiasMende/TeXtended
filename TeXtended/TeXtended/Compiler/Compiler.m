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

@implementation Compiler

- (id)initWithDocumentController:(DocumentController*) controller {
    self = [super init];
    if (self) {
        [self setAutoCompile:NO];
        _documentController = controller;
        
        // get the settings and observe them
        _draftSettings = [[controller model] draftCompiler];
        _liveSettings = [[controller model] liveCompiler];
        _finalSettings = [[controller model] finalCompiler];
        
        [[[controller model] draftCompiler] addObserver:self forKeyPath:@"draftSetting" options:0 context:NULL];
        [[[controller model] liveCompiler] addObserver:self forKeyPath:@"liveSetting" options:0 context:NULL];
        [[[controller model] finalCompiler] addObserver:self forKeyPath:@"finalSetting" options:0 context:NULL];
    }
    return self;
}


- (void) compile:(bool)draft {
    
    NSSet *mainDocuments = [self.documentController.model mainDocuments];
    for (DocumentModel *model in mainDocuments) {
        
        CompileSetting *settings = [CompileSetting alloc];
        NSTask *task   = [[NSTask alloc] init];
        NSPipe *pipe = [[NSPipe alloc] init];
        NSFileHandle *handle;
        NSString *consoleOutput;
        NSString *path = [NSString alloc];
        NSString *arguments = [NSString alloc];
        
        
        if (draft) {
            settings = [model draftCompiler];
            path = [[CompileFlowHandler path] stringByAppendingPathComponent:[settings compilerPath]];
            arguments = [NSString stringWithFormat:@"%@ %@ %@ %@ %@", [model texPath], [model pdfPath], [settings numberOfCompiles], [settings compileBib], [settings customArgument]];
        }
        
        NSLog(arguments);
        
        [task setLaunchPath:path];
    }
    
    
    
    
    [self.documentController documentHasChangedAction];
}



@end
