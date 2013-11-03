//
//  ConsoleViewController.m
//  TeXtended
//
//  Created by Tobias Mende on 05.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "ConsoleViewController.h"
#import "DocumentModel.h"
#import "Constants.h"
#import "DocumentController.h"
#import "LogfileParser.h"
#import "MessageCollection.h"
#import "ConsoleOutputView.h"
#import "TMTLog.h"
#import "TMTNotificationCenter.h"
#import "ConsoleData.h"


static const NSTimeInterval LOG_MESSAGE_UPDATE_INTERVAL = 0.2;

@interface ConsoleViewController ()
- (void)configureReadHandle;
- (void)compilerDidStartCompiling:(NSNotification*)notification;
- (void)compilerDidEndCompiling:(NSNotification*)notification;
- (void)updateLogMessages;
@end

@implementation ConsoleViewController


- (id) init {
    self = [super initWithNibName:@"ConsoleView" bundle:nil];
    if (self) {
    }
    return self;
}

- (void)loadView {
    [super loadView];
    self.outputView.controller = self;
}


- (void)handleOutput: (NSNotification*)notification {
    //[self.model.outputPipe.fileHandleForReading readInBackgroundAndNotify] ;
    NSData *data = [[notification userInfo] objectForKey: NSFileHandleNotificationDataItem];
    NSString *str = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] ;
    if (str && data.length > 0) {
        self.outputView.string = [self.outputView.string stringByAppendingString:str];
        [self.outputView scrollToEndOfDocument:self];
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
        self.console.consoleActive = YES;
    } else {
        self.console.consoleActive = NO;
    }
}


- (void)setConsole:(ConsoleData *)console {
    if (console != _console) {
        if (_console) {
            [_console removeObserver:self forKeyPath:@"self.model"];
        }
        _console = console;
        if (_console) {
            [_console addObserver:self forKeyPath:@"self.model" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:NULL];
        }
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isEqualTo:self.console]) {
        id old = [change objectForKey:NSKeyValueChangeOldKey];
        if (old && [old isKindOfClass:[DocumentModel class]]) {
            [[TMTNotificationCenter centerForCompilable:old] removeObserver:self name:TMTCompilerDidStartCompiling object:old];
            [[TMTNotificationCenter centerForCompilable:old] removeObserver:self name:TMTCompilerDidEndCompiling object:old];
        }
        if (self.console.model) {
            [[TMTNotificationCenter centerForCompilable:self.console.model] addObserver:self selector:@selector(compilerDidStartCompiling:) name:TMTCompilerDidStartCompiling object:self.console.model];
            [[TMTNotificationCenter centerForCompilable:self.console.model] addObserver:self selector:@selector(compilerDidEndCompiling:) name:TMTCompilerDidEndCompiling object:self.console.model];
        }
    }
}

- (void)updateLogMessages {
    LogfileParser *parser = [LogfileParser new];
    MessageCollection *collection = [parser parseContent:self.outputView.string forDocument:self.console.model.texPath];
    self.console.consoleMessages = [self.console.consoleMessages merge:collection];
}


- (void)configureReadHandle {
    
    if (readHandle && readHandle != [self.console.model.consoleOutputPipe fileHandleForReading]) {
        [[NSNotificationCenter defaultCenter]removeObserver:self name:NSFileHandleReadCompletionNotification object:readHandle];
        [self.outputView setString:@""];
    }
    readHandle = [self.console.model.consoleOutputPipe fileHandleForReading];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handleOutput:) name: NSFileHandleReadCompletionNotification object: readHandle] ;
    [readHandle readInBackgroundAndNotify] ;
    self.console.consoleActive = YES;

    
}

#pragma mark -
#pragma mark Notification Observer

- (void)compilerDidStartCompiling:(NSNotification *)notification {
    [self configureReadHandle];
    self.console.consoleMessages = [MessageCollection new];
}

- (void)compilerDidEndCompiling:(NSNotification *)notification {
    [self.inputView setStringValue:@""];
    self.console.consoleActive = NO;
}

#pragma mark -
#pragma mark NSTextFieldDelegate Methods

-(void)controlTextDidEndEditing:(NSNotification *)notification {
    if ( [[[notification userInfo] objectForKey:@"NSTextMovement"] intValue] == NSReturnTextMovement )
    {
        NSFileHandle *handle = self.console.model.consoleInputPipe.fileHandleForWriting;
        NSString *command = [[self.inputView stringValue] stringByAppendingString:@"\n"];
        [handle writeData:[command dataUsingEncoding:NSUTF8StringEncoding]];
        [self.inputView setStringValue:@""];
    }
}

#pragma mark -
#pragma mark Dealloc etc.

- (void)dealloc {
    DDLogVerbose(@"dealloc");
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


@end
