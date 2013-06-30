//
//  FileCompiler.h
//  TeXtended
//
//  Created by Max Bannach on 09.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DocumentModel, CompileSetting;

/**
 * This class handels compile tasks for a single file.
 *
 * @author Max Bannach
 */
@interface FileCompiler : NSObject

@property  BOOL autoCompile;
@property (strong) DocumentModel* model;

/** Init with the given model */
-(id)initWithDocumentModel:(DocumentModel*) model;

/**
 * Compile the file corresponding to the handeld model.
 *
 * @param draft is ´YES´ if draft settings should be used, otherwise final settings are used.
 */
- (void) compile:(bool)draft;

@end
