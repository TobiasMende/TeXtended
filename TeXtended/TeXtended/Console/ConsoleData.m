//
//  ConsoleData.m
//  TeXtended
//
//  Created by Tobias Mende on 03.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "ConsoleData.h"
#import "Constants.h"
#import "DocumentModel.h"
#import "TMTNotificationCenter.h"
#import "TMTLog.h"
#import "MessageCollection.h"
#import "ConsoleViewController.h"
#import "LogfileParser.h"
#import "ConsoleManager.h"
static const NSTimeInterval LOG_MESSAGE_UPDATE_INTERVAL = 0.4;

@interface ConsoleData ()
- (void)compilerDidEndCompiling:(NSNotification*)note;
- (void)compilerDidStartCompiling:(NSNotification*)note;
- (void)handleOutput: (NSNotification*)notification;
- (void)configureReadHandle;
@end

@implementation ConsoleData

- (id)init {
    self = [super init];
    if (self) {
        self.output = @"";
        self.showConsole = YES;
    }
    return self;
}

- (void)setShowConsole:(BOOL)showConsole {
    _showConsole = showConsole;
    [[NSNotificationCenter defaultCenter] postNotificationName:TMT_CONSOLE_MANAGER_CHANGED object:[ConsoleManager sharedConsoleManager]];
}

- (void)setModel:(DocumentModel *)model {
    if (model != _model) {
        if(_model) {
            [[TMTNotificationCenter centerForCompilable:_model] removeObserver:self name:TMTCompilerDidStartCompiling object:_model];
            [[TMTNotificationCenter centerForCompilable:_model] removeObserver:self name:TMTCompilerDidEndCompiling object:_model];
        }
        _model = model;
        if(_model) {
            [[TMTNotificationCenter centerForCompilable:_model] addObserver:self selector:@selector(compilerDidStartCompiling:) name:TMTCompilerDidStartCompiling object:_model];
            [[TMTNotificationCenter centerForCompilable:_model] addObserver:self selector:@selector(compilerDidEndCompiling:) name:TMTCompilerDidEndCompiling object:_model];
        }
    }
}



- (void)setConsoleMessages:(MessageCollection *)consoleMessages {
    if (consoleMessages != _consoleMessages) {
        _consoleMessages = consoleMessages;
        if (self.model && consoleMessages) {
            [[TMTNotificationCenter centerForCompilable:self.model] postNotificationName:TMTLogMessageCollectionChanged object:self.model userInfo:[NSDictionary dictionaryWithObject:self.consoleMessages forKey:TMTMessageCollectionKey]];
        }
    }
}

- (void)updateLogMessages {
    LogfileParser *parser = [LogfileParser new];
    MessageCollection *collection = [parser parseContent:self.output forDocument:self.model.texPath];
    self.consoleMessages = [self.consoleMessages merge:collection];
}

- (void)configureReadHandle {
    
    if (readHandle && readHandle != [self.model.consoleOutputPipe fileHandleForReading]) {
        [[NSNotificationCenter defaultCenter]removeObserver:self name:NSFileHandleReadCompletionNotification object:readHandle];
        self.output = @"";
    }
    readHandle = [self.model.consoleOutputPipe fileHandleForReading];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handleOutput:) name: NSFileHandleReadCompletionNotification object: readHandle] ;
    [readHandle readInBackgroundAndNotify] ;
    self.consoleActive = YES;
    
    
}


#pragma mark -
#pragma mark Notification Observer

- (void)compilerDidStartCompiling:(NSNotification *)notification {
    [self configureReadHandle];
    self.consoleMessages = [MessageCollection new];
}

- (void)compilerDidEndCompiling:(NSNotification *)notification {
    self.consoleActive = NO;
}


- (void)handleOutput: (NSNotification*)notification {
    //[self.model.outputPipe.fileHandleForReading readInBackgroundAndNotify] ;
    NSData *data = [[notification userInfo] objectForKey: NSFileHandleNotificationDataItem];
    NSString *str = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] ;
    if (str && data.length > 0) {
        self.output = [self.output stringByAppendingString:str];
        if ([logMessageUpdateTimer isValid]) {
            [logMessageUpdateTimer invalidate];
        }
        logMessageUpdateTimer = [NSTimer scheduledTimerWithTimeInterval: LOG_MESSAGE_UPDATE_INTERVAL
                                                                 target: self
                                                               selector:@selector(updateLogMessages)
                                                               userInfo: nil
                                                                repeats: NO];
        
        // Do whatever you want with str
    }
    if (data.length > 0) {
        [readHandle readInBackgroundAndNotify];
        self.consoleActive = YES;
    } else {
        self.consoleActive = NO;
    }
}

- (void)dealloc {
    DDLogVerbose(@"dealloc");
    [[TMTNotificationCenter centerForCompilable:self.model] removeObserver:self];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)remove {
    [[ConsoleManager sharedConsoleManager] removeConsoleForModel:self.model];
}


@end
