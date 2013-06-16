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
#import "CompileSetting.h"
#import "DocumentController.h"
#import "ForwardSynctex.h"

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
        
        // get the settings and observe them
        _draftSettings = [[controller model] draftCompiler];
        _liveSettings = [[controller model] liveCompiler];
        _finalSettings = [[controller model] finalCompiler];
        _idleTimeForLiveCompile = 1;
    }
    return self;
}




- (void) compile:(CompileMode)mode {
    [self.liveTimer invalidate];
    NSSet *mainDocuments = [self.documentController.model mainDocuments];
    for (DocumentModel *model in mainDocuments) {
        CompileSetting *settings;
        NSTask *task   = [[NSTask alloc] init];
        model.outputPipe = [NSPipe pipe];
        model.inputPipe = [NSPipe pipe];
        [task setStandardOutput:model.outputPipe];
        [task setStandardInput:model.inputPipe];
        NSString *path;
        
        if (mode == draft) {
            settings = [model draftCompiler];
        } else if (mode == final) {
            settings = [model finalCompiler];
        } else if (mode == live) {
            settings = [model liveCompiler];
        }
        
        path = [[CompileFlowHandler path] stringByAppendingPathComponent:[settings compilerPath]];
     
        [task setLaunchPath:path];
        [task setArguments:[NSArray arrayWithObjects:[model texPath], [model pdfPath], [NSString stringWithFormat:@"%@", [settings numberOfCompiles]],
                            [NSString stringWithFormat:@"%@", [settings compileBib]], [NSString stringWithFormat:@"%@", [settings customArgument]], nil]];
        [[NSNotificationCenter defaultCenter] postNotificationName:TMTCompilerDidStartCompiling object:model];
        
        [task setTerminationHandler:^(NSTask *task) {
            if ([NSNotificationCenter defaultCenter]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:TMTCompilerDidEndCompiling object:model];
            }
            
           
        }];
        
        [task launch];
    }
}

-(void) liveCompile {
    [self.documentController.mainDocument saveEntireDocumentWithDelegate:self andSelector:@selector(liveCompile:didSave:contextInfo:)];
    
}

- (void)liveCompile:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void *)context {
    if (didSave) {
        [self compile:live];
    }
}

- (void)textDidChange:(NSNotification *)notification {
    if (![[self.documentController.model liveCompile] boolValue]) {
        return; // live compile deactivated
    }
        
    if ([self.liveTimer isValid]) {
        [self.liveTimer invalidate];
    }
    
    [self setLiveTimer:[NSTimer scheduledTimerWithTimeInterval: [self idleTimeForLiveCompile]
                                                        target: self
                                                      selector:@selector(liveCompile)
                                                      userInfo: nil
                                                       repeats: NO]];
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
