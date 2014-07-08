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
#import "CompileSetting.h"
#import "DocumentController.h"
#import "TextViewController.h"
#import <TMTHelperCollection/TMTLog.h>
#import "ConsoleData.h"
#import "ConsoleManager.h"
#import "MainDocument.h"

@interface Compiler ()

    - (void)finishedCompilationTask:(NSTask *)task forData:(ConsoleData *)data;
@end

@implementation Compiler

    - (id)initWithCompileProcessHandler:(id <CompileProcessHandler>)controller
    {
        self = [super init];
        if (self) {
            self.compileProcessHandler = controller;
            currentTasks = [NSMutableSet new];
            // get the settings and observe them
            self.idleTimeForLiveCompile = 1.5;
        }
        return self;
    }

    - (void)compile:(CompileMode)mode
    {
        [self.liveTimer invalidate];
        NSArray *mainDocuments = [self.compileProcessHandler.model mainDocuments];
        [[NSNotificationCenter defaultCenter] postNotificationName:TMTCompilerWillStartCompilingMainDocuments object:self.compileProcessHandler.model];
        for (DocumentModel *model in mainDocuments) {
            if (!model.texPath) {
                continue;
            }

            ConsoleData *console = [[ConsoleManager sharedConsoleManager] consoleForModel:model];
            console.firstResponderDelegate = self.compileProcessHandler;
            console.compileMode = mode;
            console.compileRunning = YES;
            console.consoleActive = YES;
            model.isCompiling = YES;

            CompileSetting *settings;
            NSTask *currentTask = [[NSTask alloc] init];
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
            [[NSNotificationCenter defaultCenter] postNotificationName:TMTCompilerDidStartCompiling object:model];
            __unsafe_unretained id weakSelf = self;
            [currentTask setTerminationHandler:^(NSTask *task)
            {
                [weakSelf finishedCompilationTask:task forData:console];
                task.terminationHandler = nil;
            }];
            [self.compileProcessHandler.mainDocument incrementNumberOfCompilingDocuments];
            [currentTasks addObject:currentTask];
            @try {
                [currentTask launch];
            }
            @catch (NSException *exception) {
                DDLogError(@"Cant'start compiler task %@. Exception: %@ (%@)", currentTask, exception.reason, exception.name);
                DDLogVerbose(@"%@", [NSThread callStackSymbols]);
                [currentTasks removeObject:currentTask];
                [self.compileProcessHandler.mainDocument decrementNumberOfCompilingDocuments];
            }
        }
    }

    - (void)finishedCompilationTask:(NSTask *)task forData:(ConsoleData *)data
    {
        [data.firstResponderDelegate.mainDocument decrementNumberOfCompilingDocuments];
        data.model.isCompiling = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:TMTCompilerDidEndCompiling object:data.model];
        data.model.lastCompile = [NSDate new];
        data.compileRunning = NO;
        if (data.compileMode == final && [data.model.openOnExport boolValue]) {
            [[NSWorkspace sharedWorkspace] openFile:data.model.pdfPath];
        }
        [currentTasks removeObject:task];
    }

    - (void)liveCompile
    {
        if (self.compileProcessHandler.model.texPath) {
            [self.compileProcessHandler liveCompile:nil];
        }

    }

    - (void)liveCompile:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void *)context
    {
        if (self.compileProcessHandler.model.texPath) {
            [self compile:live];
        }
    }

    - (void)textDidChange:(NSNotification *)notification
    {
        if (![[self.compileProcessHandler.model liveCompile] boolValue]) {
            return; // live compile deactivated
        }

        if ([self.liveTimer isValid]) {
            [self.liveTimer invalidate];
        }

        [self setLiveTimer:[NSTimer scheduledTimerWithTimeInterval:[self idleTimeForLiveCompile]
                                                            target:self
                                                          selector:@selector(liveCompile)
                                                          userInfo:nil
                                                           repeats:NO]];
    }


    - (void)abort
    {
        for (NSTask *task in currentTasks) {
            task.terminationHandler = nil;
            if (task.isRunning) {
                [task terminate];
                if (task.isRunning) {
                    [task interrupt];
                }
                [self.compileProcessHandler.mainDocument decrementNumberOfCompilingDocuments];
            }
        }
    }

    - (void)terminateAndKill
    {
        [self abort];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self.compileProcessHandler.textViewController removeDelegateObserver:self];
        self.compileProcessHandler = NULL;
    }

    - (void)dealloc
    {
        DDLogVerbose(@"dealloc [%@]", currentTasks);
        [self terminateAndKill];

    }

@end
