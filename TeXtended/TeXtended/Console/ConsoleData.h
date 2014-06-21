//
//  ConsoleData.h
//  TeXtended
//
//  Created by Tobias Mende on 03.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "CompileProcessHandler.h"

@class DocumentModel, DocumentController;

@interface ConsoleData : NSObject
    {
        /** A file handle for reading the console output */
        NSFileHandle *readHandle;

        NSTimer *logMessageUpdateTimer;
    }

    @property (strong, nonatomic) DocumentModel *model;

    @property (assign) id <CompileProcessHandler> firstResponderDelegate;

/** Flag for showing whether the console is active or not */
    @property (nonatomic) BOOL consoleActive;

    @property BOOL compileRunning;

    @property BOOL showConsole;

    @property NSRange selectedRange;

    @property NSString *output;

    @property NSString *input;

/** The messages extracted from the latex log */
    @property (nonatomic) NSArray *consoleMessages;

    @property CompileMode compileMode;

    - (void)updateLogMessages;

    - (void)commitInput;

    - (void)remove;

    - (void)refreshCompile;

    - (NSComparisonResult)compareConsoleData:(ConsoleData *)other;
@end
