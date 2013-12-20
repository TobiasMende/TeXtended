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
#import <TMTHelperCollection/TMTLog.h>
#import "TMTNotificationCenter.h"
#import "ConsoleData.h"
#import "ConsoleManager.h"
#import "MainDocument.h"
@interface Compiler ()
- (void) updateDocumentController;
- (void) finishedCompilationTask:(NSTask*)task forData:(ConsoleData*)data;
@end

@implementation Compiler

- (id)initWithDocumentController:(DocumentController*) controller {
    self = [super init];
    DDLogVerbose(@"init");
    if (self) {
        [self setAutoCompile:NO];
        self.documentController = controller;
        currentTasks = [NSMutableSet new];
        weakSelf = self;
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
        console.consoleActive = YES;
        model.isCompiling = YES;
        
        CompileSetting *settings;
        NSTask *currentTask   = [[NSTask alloc] init];
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
        environment[@"max_print_line"] = @"1000";
        environment[@"error_line"] = @"254";
        environment[@"half_error_line"] = @"238";
        [currentTask setEnvironment:environment];
        [currentTask setLaunchPath:path];
        NSNumber *compileMode = [NSNumber numberWithInt:mode];
        NSMutableArray *arguments = [NSMutableArray arrayWithObjects:[model.texPath stringByDeletingPathExtension], model.pdfPath, settings.numberOfCompiles.stringValue, compileMode.stringValue, settings.compileBib.stringValue, nil];
        if (settings.customArgument && settings.customArgument.length > 0) {
            [arguments addObject:[NSString stringWithFormat:@"\"%@\"", settings.customArgument]];
        }
        [currentTask setArguments:arguments];
        [[TMTNotificationCenter centerForCompilable:model] postNotificationName:TMTCompilerDidStartCompiling object:model];
        [currentTask setTerminationHandler:^(NSTask *task) {
            [weakSelf finishedCompilationTask:task forData:console];
            task.terminationHandler = nil;
        }];
        self.documentController.mainDocument.numberOfCompilingDocuments += 1;
        [currentTasks addObject:currentTask];
        @try {
            [currentTask launch];
        }
        @catch (NSException *exception) {
            DDLogError(@"Cant'start compiler task %@. Exception: %@ (%@)", currentTask, exception.reason, exception.name);
            DDLogVerbose(@"%@", [NSThread callStackSymbols]);
            [currentTasks removeObject:currentTask];
            self.documentController.mainDocument.numberOfCompilingDocuments -= 1;
        }
    }
}

- (void)finishedCompilationTask:(NSTask *)task forData:(ConsoleData*)data{
    data.documentController.mainDocument.numberOfCompilingDocuments -= 1;
    data.model.isCompiling = NO;
    [[TMTNotificationCenter centerForCompilable:data.model] postNotificationName:TMTCompilerDidEndCompiling object:data.model];
    data.model.lastCompile = [NSDate new];
    data.compileRunning = NO;
    if (data.compileMode == final && [data.model.openOnExport boolValue]) {
        [[NSWorkspace sharedWorkspace] openFile:data.model.pdfPath];
    }
    [currentTasks removeObject:task];
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

- (void)terminateAndKill {
    weakSelf = nil;
    for(NSTask *task in currentTasks) {
        task.terminationHandler = nil;
        if (task.isRunning) {
            [task terminate];
            if (task.isRunning) {
                [task interrupt];
            }
            self.documentController.mainDocument.numberOfCompilingDocuments -= 1;
        }
    }
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self.documentController.textViewController removeDelegateObserver:self];
    self.documentController = NULL;
}

- (void)dealloc {
    DDLogVerbose(@"dealloc");
    [self terminateAndKill];
    
}

@end
