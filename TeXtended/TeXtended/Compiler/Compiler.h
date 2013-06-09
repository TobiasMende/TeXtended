//
//  Compiler.h
//  TeXtended
//
//  Created by Max Bannach on 26.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DocumentController.h"


@interface Compiler : NSObject {
}

@property (weak) DocumentController *documentController;
@property (strong) NSSet* fileCompiler;

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
@property  BOOL autoCompile;

@end
