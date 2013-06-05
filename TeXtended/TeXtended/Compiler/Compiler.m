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
        model.outputPipe = [NSPipe pipe];
        model.inputPipe = [NSPipe pipe];
        [task setStandardOutput:model.outputPipe];
        [task setStandardInput:model.inputPipe];
        NSString *path;
        [model.outputPipe.fileHandleForReading readInBackgroundAndNotify];
        
        if (draft) {
            settings = [model draftCompiler];
        } else {
            settings = [model finalCompiler];
        }
        path = [[CompileFlowHandler path] stringByAppendingPathComponent:[settings compilerPath]];
     
      
        
        [task setLaunchPath:path];
        [task setArguments:[NSArray arrayWithObjects:[model texPath], [model pdfPath], [NSString stringWithFormat:@"%@", [settings numberOfCompiles]],
                            [NSString stringWithFormat:@"%@", [settings compileBib]], [NSString stringWithFormat:@"%@", [settings customArgument]], nil]];
        [task launch];
       
        [[NSNotificationCenter defaultCenter] addObserver:self
                          selector:@selector(updateDocumentController)
                              name:NSTaskDidTerminateNotification
                            object:task];
        
    }
    [self updateDocumentController];
}

- (void) updateDocumentController {
    [self.documentController documentHasChangedAction];
}

@end
