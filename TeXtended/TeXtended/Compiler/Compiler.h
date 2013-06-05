//
//  Compiler.h
//  TeXtended
//
//  Created by Max Bannach on 26.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DocumentController.h"
#import "CompileSetting.h"

@interface Compiler : NSObject

@property (strong) DocumentController *documentController;
@property (assign) CompileSetting* draftSettings;
@property (assign) CompileSetting* liveSettings;
@property (assign) CompileSetting* finalSettings;

/**
 * Constructor
 */
- (id)initWithDocumentController:(DocumentController*) controller;

/**
 * Calls the compile method on the document.
 * @param draft is true, if the draft compile should be used and false for a final compile.
 */
- (void) compile:(bool)draft;

/**
 * Yes, if autocompile is activated.
 */
@property (atomic) BOOL autoCompile;

@end
