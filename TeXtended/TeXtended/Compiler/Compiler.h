//
//  Compiler.h
//  TeXtended
//
//  Created by Max Bannach on 26.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TextViewObserver.h"
#import "Constants.h"
#import "CompileProcessHandler.h"
#import "CompileTaskDelegate.h"

@class DocumentController, CompileSetting;

/**
 * This class handels the compile flow for the main documents of
 * the model of a given DocumentController.
 * It provides methods to compile this documents in draft and final mode
 * and gives the possibility to handle the compile by it self for live compile.
 *
 * @author Max Bannach, Tobias Mende
 */
@interface Compiler : NSObject <TextViewObserver, CompileTaskDelegate>
    {
        NSMutableSet *currentTasks;


    }


/** Timer that trigger a liveCompile when in live mode. */
    @property (strong) NSTimer *liveTimer;

/**
 * Time that has to pass to a action on the textView until this class will
 * compile the documents when in live mode.
 */
    @property float idleTimeForLiveCompile;

/** The DocumentController from which this class handels the MainDocuments. */
    @property (assign) id <CompileProcessHandler> compileProcessHandler;


/**
 * Constructor initializing a new compiler for a given DocumentController.
 * @param controller the document controller
 */
    - (id)initWithCompileProcessHandler:(id <CompileProcessHandler>)controller;


    - (void)compile:(CompileMode)mode;

    - (void)liveCompile;

/**
 * Callback method for the autosave answer when starting live compile
 * @param doc the document which was saved
 * @param didSave `YES` if the document was saved succesfull, `NO` otherwise.
 * @param context `NULL` in most cases.
 */
    - (void)liveCompile:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void *)context;

    - (void)terminateAndKill;

    - (void)abort;

- (BOOL)isCompiling;

/**
 * `YES`, if autocompile is activated.
 */
    @property BOOL autoCompile;
    @property BOOL dirty;

@end
