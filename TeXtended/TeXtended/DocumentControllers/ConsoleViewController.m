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

- (void)setModel:(DocumentModel *)model {
    if (model != _model) {
        if(_model) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:TMTCompilerDidStartCompiling object:_model];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:TMTCompilerDidEndCompiling object:_model];
        }
        _model = model;
        if(_model) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(compilerDidStartCompiling:) name:TMTCompilerDidStartCompiling object:_model];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(compilerDidEndCompiling:) name:TMTCompilerDidEndCompiling object:_model];
        }
    }
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
        self.consoleActive = YES;
    } else {
        self.consoleActive = NO;
    }
}

- (void)updateLogMessages {
    LogfileParser *parser = [LogfileParser new];
    MessageCollection *collection = [parser parseContent:self.outputView.string forDocument:self.model.texPath];
    self.consoleMessages = [self.consoleMessages merge:collection];
}

- (void)setConsoleMessages:(MessageCollection *)consoleMessages {
    if (consoleMessages != _consoleMessages) {
        _consoleMessages = consoleMessages;
        DocumentModel *model = [self.documentController model];
        if (model && consoleMessages) {
            [[NSNotificationCenter defaultCenter] postNotificationName:TMTLogMessageCollectionChanged object:model userInfo:[NSDictionary dictionaryWithObject:self.consoleMessages forKey:TMTMessageCollectionKey]];
        }
    }
}

- (void)configureReadHandle {
    
    if (readHandle && readHandle != [self.model.consoleOutputPipe fileHandleForReading]) {
        [[NSNotificationCenter defaultCenter]removeObserver:self name:NSFileHandleReadCompletionNotification object:readHandle];
        [self.outputView setString:@""];
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
    [self.inputView setStringValue:@""];
    self.consoleActive = NO;
}

#pragma mark -
#pragma mark NSTextFieldDelegate Methods

-(void)controlTextDidEndEditing:(NSNotification *)notification {
    if ( [[[notification userInfo] objectForKey:@"NSTextMovement"] intValue] == NSReturnTextMovement )
    {
        NSFileHandle *handle = self.model.consoleInputPipe.fileHandleForWriting;
        NSString *command = [[self.inputView stringValue] stringByAppendingString:@"\n"];
        [handle writeData:[command dataUsingEncoding:NSUTF8StringEncoding]];
        [self.inputView setStringValue:@""];
    }
}

#pragma mark -
#pragma mark Dealloc etc.

- (void)dealloc {
    DDLogVerbose(@"ConsoleViewController dealloc");
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


@end
