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
@property (atomic) int idleTimeForLiveCompile;
@property (weak) DocumentController *documentController;
@property (weak) CompileSetting* draftSettings;
@property (weak) CompileSetting* liveSettings;
@property (weak) CompileSetting* finalSettings;

/**
 * Constructor
 */
- (id)initWithDocumentController:(DocumentController*) controller;

/**
 * Calls the compile method on the document.
 * @param CompileMode defines, in which mode the compiler should run.
 */
- (void) compile:(CompileMode)mode;

/**
 * Call for a live compile perform.
 */
-(void) liveCompile;

/**
 * Yes, if autocompile is activated.
 */
@property  BOOL autoCompile;

@end
