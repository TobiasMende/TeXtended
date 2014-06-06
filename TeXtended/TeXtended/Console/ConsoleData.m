//
//  ConsoleData.m
//  TeXtended
//
//  Created by Tobias Mende on 03.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "ConsoleData.h"
#import "DocumentModel.h"
#import "ConsoleViewController.h"
#import "LogfileParser.h"
#import "ConsoleManager.h"

static const NSTimeInterval LOG_MESSAGE_UPDATE_INTERVAL = 0.4;

@interface ConsoleData ()

    - (void)compilerDidEndCompiling:(NSNotification *)note;

    - (void)compilerDidStartCompiling:(NSNotification *)note;

    - (void)handleOutput:(NSNotification *)notification;

    - (void)configureReadHandle;
@end

@implementation ConsoleData

    - (id)init
    {
        self = [super init];
        if (self) {
            self.output = @"";
            self.input = @"";
            self.showConsole = YES;
            self.selectedRange = NSMakeRange(NSNotFound, 0);
        }
        return self;
    }


    - (void)setModel:(DocumentModel *)model
    {
        if (model != _model) {
            if (_model) {
                [[NSNotificationCenter defaultCenter] removeObserver:self name:TMTCompilerDidStartCompiling object:_model];
                [[NSNotificationCenter defaultCenter] removeObserver:self name:TMTCompilerDidEndCompiling object:_model];
            }
            _model = model;
            if (_model) {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(compilerDidStartCompiling:) name:TMTCompilerDidStartCompiling object:_model];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(compilerDidEndCompiling:) name:TMTCompilerDidEndCompiling object:_model];
            }
        }
    }


    - (void)setConsoleMessages:(NSArray *)consoleMessages
    {
        if (consoleMessages != _consoleMessages) {
            _consoleMessages = consoleMessages;
            if (self.model && consoleMessages) {
                [self.model updateMessages:consoleMessages forType:TMTLogFileParser];
            }
        }
    }

    - (void)updateLogMessages
    {
        LogfileParser *parser = [LogfileParser new];
        self.consoleMessages = [parser parseContent:self.output forDocument:self.model.texPath];
    }

    - (void)configureReadHandle
    {

        if (readHandle && readHandle != [self.model.consoleOutputPipe fileHandleForReading]) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleReadCompletionNotification object:readHandle];
            self.output = @"";
        }
        readHandle = [self.model.consoleOutputPipe fileHandleForReading];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOutput:) name:NSFileHandleReadCompletionNotification object:readHandle];
        [readHandle readInBackgroundAndNotify];
        self.consoleActive = YES;


    }

    - (void)refreshCompile
    {
        [self.firstResponderDelegate compile:self.compileMode];
    }

    - (void)commitInput
    {
        NSFileHandle *handle = self.model.consoleInputPipe.fileHandleForWriting;
        NSString *command = [self.input stringByAppendingString:@"\n"];
        [handle writeData:[command dataUsingEncoding:NSUTF8StringEncoding]];
        self.input = @"";
    }


#pragma mark -
#pragma mark Notification Observer

    - (void)compilerDidStartCompiling:(NSNotification *)notification
    {
        [self configureReadHandle];
    }

    - (void)compilerDidEndCompiling:(NSNotification *)notification
    {
        self.consoleActive = NO;
    }


    - (void)setConsoleActive:(BOOL)consoleActive
    {
        _consoleActive = consoleActive;
        if (!_consoleActive) {
            self.input = @"";
        }
    }


    - (void)handleOutput:(NSNotification *)notification
    {
        //[self.model.outputPipe.fileHandleForReading readInBackgroundAndNotify] ;
        NSData *data = [notification userInfo][NSFileHandleNotificationDataItem];
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (str && data.length > 0) {
            self.output = [self.output stringByAppendingString:str];
            if ([logMessageUpdateTimer isValid]) {
                [logMessageUpdateTimer invalidate];
            }
            logMessageUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:LOG_MESSAGE_UPDATE_INTERVAL
                                                                     target:self
                                                                   selector:@selector(updateLogMessages)
                                                                   userInfo:nil
                                                                    repeats:NO];

            // Do whatever you want with str
        }
        if (data.length > 0) {
            [readHandle readInBackgroundAndNotify];
            self.selectedRange = NSMakeRange(NSNotFound, 0);
            self.consoleActive = YES;
        } else {
            self.consoleActive = NO;
        }
    }

    - (void)dealloc
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }

    - (void)remove
    {
        [[ConsoleManager sharedConsoleManager] removeConsoleForModel:self.model];
    }


    - (NSComparisonResult)compareConsoleData:(ConsoleData *)other
    {
        return [self.model.texName compare:other.model.texName];

    }


@end
