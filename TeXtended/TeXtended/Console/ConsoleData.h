//
//  ConsoleData.h
//  TeXtended
//
//  Created by Tobias Mende on 03.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
@class DocumentModel, MessageCollection, DocumentController;
@interface ConsoleData : NSObject {
    /** A file handle for reading the console output */
    NSFileHandle *readHandle;
    NSTimer *logMessageUpdateTimer;
}
@property (weak, nonatomic) DocumentModel *model;
@property (weak) DocumentController *documentController;

/** Flag for showing whether the console is active or not */
@property BOOL consoleActive;

@property BOOL compileRunning;

@property (nonatomic) BOOL showConsole;

@property NSRange selectedRange;

@property NSString *output;
@property NSString *input;

/** The messages extracted from the latex log */
@property (nonatomic) MessageCollection *consoleMessages;

@property CompileMode compileMode;

- (void)updateLogMessages;
- (void)commitInput;
- (void)remove;
@end
