//
// Created by Tobias Mende on 25.10.15.
// Copyright (c) 2015 Tobias Mende. All rights reserved.
//

#import "CompileTask.h"
#import "DocumentModel.h"
#import "ConsoleManager.h"
#import "ConsoleData.h"
#import "CompileFlowHandler.h"
#import "CompileSetting.h"
#import "CompileTaskDelegate.h"
#import "CompilerArgumentBuilder.h"
#import <TMTHelperCollection/TMTLog.h>

LOGGING_DEFAULT_DYNAMIC

@interface CompileTask ()
- (ConsoleData *)consoleData:(DocumentModel *)model forMode:(CompileMode)mode;

- (void)configureTask;
- (void)configureTerminationHandler;
- (void)configureArguments;
- (void)configureCompilerPath;
- (void)configurePipes;
- (void)configureEnvironment;

- (void)tryToStartCompilation;
- (void)failCompilation:(NSException *)exception;
- (void)startCompilation;
- (void)finishedCompilationTask;

- (void)updateDataOnStart;
- (void)updateDataOnEnd;
@end

@implementation CompileTask {
    DocumentModel *model;
    ConsoleData *data;
    id <CompileTaskDelegate> delegate;
    NSTask *compileTask;
}

+ (void)initialize {
    LOGGING_LOAD
}

- (id)initWithDocument:(DocumentModel *)model forMode:(CompileMode)mode withDelegate:(id <CompileTaskDelegate>)delegate {
    self = [super init];
    if (self) {
        self->model = model;
        self->delegate = delegate;
        self->compileTask = [NSTask new];
        self->data = [self consoleData:model forMode:mode];
    }
    return self;
}

- (ConsoleData *)consoleData:(DocumentModel *)model forMode:(CompileMode)mode {
    ConsoleData *data;
    data = [[ConsoleManager sharedConsoleManager] consoleForModel:model];
    data.compileMode = mode;
    return data;
}

- (BOOL)isRunning {
    return compileTask.running;
}

- (void)abort {
    if (self.isRunning) {
        [compileTask terminate];
        if (self.isRunning) {
            [compileTask interrupt];
        }
    }
}

- (BOOL)shouldOpenPDF {
    return data.compileMode == final && [data.model.openOnExport boolValue];
}

- (NSString *)pdfPath {
    return model.pdfPath;
}

- (void)execute {
    [self configureTask];
    [self tryToStartCompilation];
}

- (void)configureTask {
    [self configurePipes];
    [self configureEnvironment];
    [self configureCompilerPath];
    [self configureArguments];
    [self configureTerminationHandler];
}

- (void)configureTerminationHandler {
    __weak id weakSelf = self;
    [compileTask setTerminationHandler:^(NSTask *task) {
        [weakSelf finishedCompilationTask];
    }];
}

- (void)configureArguments {
    CompilerArgumentBuilder *argumentBuilder = [[CompilerArgumentBuilder alloc] initWithData:data];
    [compileTask setArguments:[argumentBuilder build]];
}

- (void)configureCompilerPath {
    NSString *path = [[CompileFlowHandler path] stringByAppendingPathComponent:[data.compileSetting compilerPath]];
    [compileTask setLaunchPath:path];
}

- (void)configurePipes {
    NSPipe *outPipe = [NSPipe pipe];
    NSPipe *inPipe = [NSPipe pipe];
    if (!outPipe || !inPipe) {
        DDLogError(@"One of the pipes could not be initialized. Aborting compile for model %@", model);
        return;
    }

    model.consoleOutputPipe = outPipe;
    model.consoleInputPipe = inPipe;
    [compileTask setStandardOutput:model.consoleOutputPipe];
    [compileTask setStandardInput:model.consoleInputPipe];
}

- (void)configureEnvironment {
    NSMutableDictionary *environment = [NSMutableDictionary dictionaryWithDictionary:[[NSProcessInfo processInfo] environment]];
    environment[@"max_print_line"] = @"1000";
    environment[@"error_line"] = @"254";
    environment[@"half_error_line"] = @"238";
    [compileTask setEnvironment:environment];
}

- (void)tryToStartCompilation {
    @try {
        [self startCompilation];
    }
    @catch (NSException *exception) {
        [self failCompilation:exception];
    }
}

- (void)startCompilation {
    [delegate compilationStarted:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:TMTCompilerDidStartCompiling object:model];
    [self updateDataOnStart];
    [compileTask launch];
}

- (void)failCompilation:(NSException *)exception {
    DDLogError(@"Cant'start compiler task %@. Exception: %@ (%@)", exception, exception.reason, exception.name);
    DDLogDebug(@"%@", [NSThread callStackSymbols]);
    [self updateDataOnEnd];
    [delegate compilationFailed:self];
}

- (void)finishedCompilationTask {
    TMT_TRACE
    [self updateDataOnEnd];
    [[NSNotificationCenter defaultCenter] postNotificationName:TMTCompilerDidEndCompiling object:model];
    [delegate compilationFinished:self];
}

- (void)updateDataOnStart {
    data.compileRunning = YES;
    data.consoleActive = YES;
    model.isCompiling = YES;
}

- (void)updateDataOnEnd {
    model.isCompiling = NO;
    model.lastCompile = [NSDate new];
    data.compileRunning = NO;
}

@end