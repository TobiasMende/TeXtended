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
#import "TextViewController.h"

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
        _idleTimeForLiveCompile = 1.5;
    }
    return self;
}




- (void) compile:(CompileMode)mode {
    [self.liveTimer invalidate];
    NSSet *mainDocuments = [self.documentController.model mainDocuments];
    for (DocumentModel *model in mainDocuments) {
        if (!model.texPath) {
            continue;
        }
        CompileSetting *settings;
        NSTask *task   = [[NSTask alloc] init];
        model.consoleOutputPipe = [NSPipe pipe];
        model.consoleInputPipe = [NSPipe pipe];
        [task setStandardOutput:model.consoleOutputPipe];
        [task setStandardInput:model.consoleInputPipe];
        NSString *path;
        
        if (mode == draft) {
            settings = [model draftCompiler];
        } else if (mode == final) {
            settings = [model finalCompiler];
        } else if (mode == live) {
            settings = [model liveCompiler];
        }
        path = [[CompileFlowHandler path] stringByAppendingPathComponent:[settings compilerPath]];
        NSMutableDictionary *environment = [NSMutableDictionary dictionaryWithDictionary:[[NSProcessInfo processInfo] environment]];
        [environment setObject:@"1000" forKey:@"max_print_line"];
        [environment setObject:@"254" forKey:@"error_line"];
        [environment setObject:@"238" forKey:@"half_error_line"];
        [task setEnvironment:environment];
        [task setLaunchPath:path];
        NSNumber *compileMode = [NSNumber numberWithInt:mode];
        NSMutableArray *arguments = [NSMutableArray arrayWithObjects:model.texPath, model.pdfPath, settings.numberOfCompiles.stringValue, compileMode.stringValue, settings.compileBib.stringValue, nil];
        if (settings.customArgument && settings.customArgument.length > 0) {
            [arguments addObject:[NSString stringWithFormat:@"\"%@\"", settings.customArgument]];
        }
        [task setArguments:arguments];
        [[NSNotificationCenter defaultCenter] postNotificationName:TMTCompilerDidStartCompiling object:model];
        
        [task setTerminationHandler:^(NSTask *task) {
                [[NSNotificationCenter defaultCenter] postNotificationName:TMTCompilerDidEndCompiling object:model];
            model.lastCompile = [NSDate new];
            if (mode == final && [model.openOnExport boolValue]) {
                [[NSWorkspace sharedWorkspace] openFile:model.pdfPath];
            }
        }];
        
        [task launch];
    }
}

-(void) liveCompile {
    if (self.documentController.model.texPath) {
        [self.documentController.mainDocument saveEntireDocumentWithDelegate:self andSelector:@selector(liveCompile:didSave:contextInfo:)];
    }
    
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
    [self.documentController.textViewController removeDelegateObserver:self];
}

@end
