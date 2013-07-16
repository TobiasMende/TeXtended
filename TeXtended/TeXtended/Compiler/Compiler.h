//
//  Compiler.h
//  TeXtended
//
//  Created by Max Bannach on 26.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TextViewObserver.h"
@class DocumentController,CompileSetting;

/**
 * This class handels the compile flow for the main documents of
 * the model of a given DocumentController.
 * It proviedes methods to compile this documents in draft and final mode
 * and gives the possibility to handle the compile by it self for live compile.
 *
 * @author Max Bannach
 */
@interface Compiler : NSObject <TextViewObserver> {
}

/** Defines the different compilemodes that are possible */
typedef enum {
    live = 0,
    draft = 1,
    final = 2
} CompileMode;



/** Timer that trigger a liveCompile when in live mode. */
@property (strong) NSTimer *liveTimer;

/**
 * Time that has to pass to a action on the textView until this class will
 * compile the documents when in live mode.
 */
@property int idleTimeForLiveCompile;

/** The DocumentController from which this class handels the MainDocuments. */
@property (weak) DocumentController *documentController;

/** CompileSettings for compiling in draft mode. */
@property (weak) CompileSetting* draftSettings;

/** CompileSettings for compiling in live mode. */
@property (weak) CompileSetting* liveSettings;

/** CompileSettings for compiling in final mode. */
@property (weak) CompileSetting* finalSettings;

/**
 * Constructor initializing a new compiler for a given DocumentController.
 * @param controller the document controller
 */
- (id)initWithDocumentController:(DocumentController*) controller;

/**
 * Calls the compile method on the document.
 * @param mode defines, in which mode the compiler should run.
 */
- (void) compile:(CompileMode)mode;

/**
 * Call for a live compile perform.
 */
-(void) liveCompile;

/**
 * Callback method for the autosave answer when starting live compile
 * @param doc the document which was saved
 * @param didSave `YES` if the document was saved succesfull, `NO` otherwise.
 * @param context `NULL` in most cases.
 */
- (void)liveCompile:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void  *)context;

/**
 * `YES`, if autocompile is activated.
 */
@property  BOOL autoCompile;

@end
