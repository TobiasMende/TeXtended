//
//  Compiler.m
//  TeXtended
//
//  Created by Max Bannach on 26.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "Compiler.h"
#import "DocumentModel.h"
#import "DocumentController.h"
#import "TextViewController.h"
#import "MainDocument.h"
#import "CompileTask.h"

#import <TMTHelperCollection/TMTLog.h>

LOGGING_DEFAULT_DYNAMIC

@interface Compiler ()

- (void)compileAllDocuments:(CompileMode)mode;

- (void)compileDocument:(DocumentModel *)model withMode:(CompileMode)mode;

- (void)finish:(CompileTask *)compileTask;

- (BOOL)shouldRestartLiveCompile;

- (void)restartLiveCompilerTimer;

- (BOOL)isLiveCompileActive;
@end

@implementation Compiler

+ (void)initialize {
    LOGGING_LOAD
}

- (id)initWithCompileProcessHandler:(id <CompileProcessHandler>)controller {
    self = [super init];
    if (self) {
        self.compileProcessHandler = controller;
        currentTasks = [NSMutableSet new];
        self.idleTimeForLiveCompile = 1.5;
    }
    return self;
}

- (void)compile:(CompileMode)mode {
    [self.liveTimer invalidate];
    self.dirty = NO;
    [self abort];
    [[NSNotificationCenter defaultCenter] postNotificationName:TMTCompilerWillStartCompilingMainDocuments object:self.compileProcessHandler.model];
    [self compileAllDocuments:mode];
}

- (void)compileAllDocuments:(CompileMode)mode {
    NSArray *mainDocuments = [self.compileProcessHandler.model mainDocuments];
    for (DocumentModel *model in mainDocuments) {
        if (!model.texPath) {
            continue;
        }
        [self compileDocument:model withMode:mode];
    }
}

- (void)compileDocument:(DocumentModel *)model withMode:(CompileMode)mode {
    CompileTask *task = [[CompileTask alloc] initWithDocument:model forMode:mode withDelegate:self];
    [currentTasks addObject:task];
    [task execute];
}

- (void)finish:(CompileTask *)compileTask {
    [self.compileProcessHandler.mainDocument decrementNumberOfCompilingDocuments];
    [currentTasks removeObject:compileTask];
}

- (BOOL)shouldRestartLiveCompile {
    return self.dirty && !self.isCompiling && self.compileProcessHandler.model.liveCompile.boolValue;
}

- (void)liveCompile {
    if (self.compileProcessHandler.model.texPath) {
        [self.compileProcessHandler liveCompile:nil];
    }
}

- (void)liveCompile:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void *)context {
    if (self.compileProcessHandler.model.texPath) {
        [self compile:live];
    }
}

- (void)textDidChange:(NSNotification *)notification {
    if (!self.isLiveCompileActive) {
        return;
    }

    if (self.isCompiling) {
        self.dirty = YES;
        return;
    }

    [self restartLiveCompilerTimer];

}

- (void)restartLiveCompilerTimer {
    if (self.liveTimer.valid) {
        [self.liveTimer invalidate];
    }

    [self setLiveTimer:[NSTimer scheduledTimerWithTimeInterval:[self idleTimeForLiveCompile]
                                                        target:self
                                                      selector:@selector(liveCompile)
                                                      userInfo:nil
                                                       repeats:NO]];
}

- (BOOL)isLiveCompileActive {
    return [[self.compileProcessHandler.model liveCompile] boolValue];
}

- (BOOL)isCompiling {
    for (CompileTask *task in currentTasks) {
        if (task.isRunning) {
            return YES;
        }
    }
    return NO;
}

- (void)abort {
    for (CompileTask *task in currentTasks) {
        [task abort];
    }
}

- (void)terminateAndKill {
    [self abort];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.compileProcessHandler.textViewController removeDelegateObserver:self];
    self.compileProcessHandler = NULL;
}

- (void)dealloc {
    DDLogDebug(@"dealloc [%@]", currentTasks);
    [self terminateAndKill];
}

#pragma mark -
#pragma mark CompilerTaskDelegate implementation

- (void)compilationStarted:(CompileTask *)compileTask {
    [self.compileProcessHandler.mainDocument incrementNumberOfCompilingDocuments];
}

- (void)compilationFailed:(CompileTask *)compileTask {
    [self finish:compileTask];
}

- (void)compilationFinished:(CompileTask *)compileTask {
    TMT_TRACE
    [self finish:compileTask];
    if ([compileTask shouldOpenPDF]) {
        [[NSWorkspace sharedWorkspace] openFile:compileTask.pdfPath];
    } else if ([self shouldRestartLiveCompile]) {
        [self liveCompile];
    }
}

@end
