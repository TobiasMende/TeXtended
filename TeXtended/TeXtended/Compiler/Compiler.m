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
#import "TMTLog.h"
#import "TMTNotificationCenter.h"
#import "ConsoleData.h"
#import "ConsoleManager.h"
@interface Compiler ()
- (void) updateDocumentController;
@end

@implementation Compiler

- (id)initWithDocumentController:(DocumentController*) controller {
    self = [super init];
    DDLogVerbose(@"init");
    if (self) {
        [self setAutoCompile:NO];
        self.documentController = controller;
        
        // get the settings and observe them
        _draftSettings = [[controller model] draftCompiler];
        _liveSettings = [[controller model] liveCompiler];
        _finalSettings = [[controller model] finalCompiler];
        _idleTimeForLiveCompile = 2;
    }
    return self;
}

- (void) compile:(CompileMode)mode {
    [self.liveTimer invalidate];
    NSSet *mainDocuments = [self.documentController.model mainDocuments];
    [[TMTNotificationCenter centerForCompilable:self.documentController.model] postNotificationName:TMTCompilerWillStartCompilingMainDocuments object:self.documentController.model];
    for (DocumentModel *model in mainDocuments) {
        if (!model.texPath) {
            continue;
        }
        
        ConsoleData *console = [[ConsoleManager sharedConsoleManager] consoleForModel:model];
        console.documentController = self.documentController;
        console.compileMode = mode;
        console.compileRunning = YES;
        
        CompileSetting *settings;
        currentTask   = [[NSTask alloc] init];
        NSPipe *outPipe = [NSPipe pipe];
        NSPipe *inPipe = [NSPipe pipe];
        if (!outPipe || !inPipe) {
            DDLogError(@"One of the pipes could not be initialized. Aborting compile for model %@", model);
            continue;
        }
        model.consoleOutputPipe = outPipe;
        model.consoleInputPipe = inPipe;
        [currentTask setStandardOutput:model.consoleOutputPipe];
        [currentTask setStandardInput:model.consoleInputPipe];
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
        [currentTask setEnvironment:environment];
        [currentTask setLaunchPath:path];
        NSNumber *compileMode = [NSNumber numberWithInt:mode];
        NSMutableArray *arguments = [NSMutableArray arrayWithObjects:model.texPath, model.pdfPath, settings.numberOfCompiles.stringValue, compileMode.stringValue, settings.compileBib.stringValue, nil];
        if (settings.customArgument && settings.customArgument.length > 0) {
            [arguments addObject:[NSString stringWithFormat:@"\"%@\"", settings.customArgument]];
        }
        [currentTask setArguments:arguments];
        [[TMTNotificationCenter centerForCompilable:model] postNotificationName:TMTCompilerDidStartCompiling object:model];
        
        [currentTask setTerminationHandler:^(NSTask *task) {
                [[TMTNotificationCenter centerForCompilable:model] postNotificationName:TMTCompilerDidEndCompiling object:model];
            model.lastCompile = [NSDate new];
            ConsoleData *console = [[ConsoleManager sharedConsoleManager] consoleForModel:model byCreating:NO];
            console.compileRunning = NO;
            if (mode == final && [model.openOnExport boolValue]) {
                [[NSWorkspace sharedWorkspace] openFile:model.pdfPath];
            }
        }];
        
        [currentTask launch];
    }
}

-(void) liveCompile {
    if (self.documentController.model.texPath) {
        [self.documentController liveCompile:nil];
    }
    
}

- (void)liveCompile:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void *)context {
    if (self.documentController.model.texPath) {
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
    DDLogVerbose(@"dealloc");
    [currentTask terminate];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self.documentController.textViewController removeDelegateObserver:self];
}

@end
