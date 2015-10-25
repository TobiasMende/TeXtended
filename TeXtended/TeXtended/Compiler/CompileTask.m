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
    DocumentModel *_model;
    ConsoleData *_data;
    id <CompileTaskDelegate> _delegate;
    NSTask *_compileTask;
}

+ (void)initialize {
    LOGGING_LOAD
}

- (id)initWithDocument:(DocumentModel *)model forMode:(CompileMode)mode withDelegate:(id <CompileTaskDelegate>)delegate {
    self = [super init];
    if (self) {
        self->_model = model;
        self->_delegate = delegate;
        self->_compileTask = [NSTask new];
        self->_data = [self consoleData:model forMode:mode];
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
    return _compileTask.running;
}

- (void)abort {
    if (self.isRunning) {
        [_compileTask terminate];
        if (self.isRunning) {
            [_compileTask interrupt];
        }
    }
}

- (BOOL)shouldOpenPDF {
    return _data.compileMode == final && [_data.model.openOnExport boolValue];
}

- (NSString *)pdfPath {
    return _model.pdfPath;
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
    [_compileTask setTerminationHandler:^(NSTask *task) {
        [weakSelf finishedCompilationTask];
    }];
}

- (void)configureArguments {
    CompilerArgumentBuilder *argumentBuilder = [[CompilerArgumentBuilder alloc] initWithData:_data];
    [_compileTask setArguments:[argumentBuilder build]];
}

- (void)configureCompilerPath {
    NSString *path = [[CompileFlowHandler path] stringByAppendingPathComponent:[_data.compileSetting compilerPath]];
    [_compileTask setLaunchPath:path];
}

- (void)configurePipes {
    NSPipe *outPipe = [NSPipe pipe];
    NSPipe *inPipe = [NSPipe pipe];
    if (!outPipe || !inPipe) {
        DDLogError(@"One of the pipes could not be initialized. Aborting compile for model %@", _model);
        return;
    }

    _model.consoleOutputPipe = outPipe;
    _model.consoleInputPipe = inPipe;
    [_compileTask setStandardOutput:_model.consoleOutputPipe];
    [_compileTask setStandardInput:_model.consoleInputPipe];
}

- (void)configureEnvironment {
    NSMutableDictionary *environment = [NSMutableDictionary dictionaryWithDictionary:[[NSProcessInfo processInfo] environment]];
    environment[@"max_print_line"] = @"1000";
    environment[@"error_line"] = @"254";
    environment[@"half_error_line"] = @"238";
    [_compileTask setEnvironment:environment];
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
    [_delegate compilationStarted:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:TMTCompilerDidStartCompiling object:_model];
    [self updateDataOnStart];
    [_compileTask launch];
}

- (void)failCompilation:(NSException *)exception {
    DDLogError(@"Cant'start compiler task %@. Exception: %@ (%@)", exception, exception.reason, exception.name);
    DDLogDebug(@"%@", [NSThread callStackSymbols]);
    [self updateDataOnEnd];
    [_delegate compilationFailed:self];
}

- (void)finishedCompilationTask {
    TMT_TRACE
    [self updateDataOnEnd];
    [[NSNotificationCenter defaultCenter] postNotificationName:TMTCompilerDidEndCompiling object:_model];
    [_delegate compilationFinished:self];
}

- (void)updateDataOnStart {
    _data.compileRunning = YES;
    _data.consoleActive = YES;
    _model.isCompiling = YES;
}

- (void)updateDataOnEnd {
    _model.isCompiling = NO;
    _model.lastCompile = [NSDate new];
    _data.compileRunning = NO;
}

@end