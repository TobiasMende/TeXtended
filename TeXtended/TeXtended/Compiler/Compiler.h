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
@interface Compiler : NSObject <TextViewObserver> {
}

typedef NS_ENUM(NSInteger, CompileMode) {
    live,
    draft,
    final
};

@property (strong) NSTimer *liveTimer;
@property int idleTimeForLiveCompile;
@property (weak) DocumentController *documentController;
@property (weak) CompileSetting* draftSettings;
@property (weak) CompileSetting* liveSettings;
@property (weak) CompileSetting* finalSettings;

/**
 * Constructor initializing a new compiler for a given DocumentController.
 
 @param controller the document controller
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
 Callback method for the autosave answer when starting live compile
 
 @param doc the document which was saved
 @param didSave `YES` if the document was saved succesfull, `NO` otherwise.
 @param context `NULL` in most cases.
 
 */
- (void)liveCompile:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void  *)context;

/**
 * `YES`, if autocompile is activated.
 */
@property  BOOL autoCompile;

@end
