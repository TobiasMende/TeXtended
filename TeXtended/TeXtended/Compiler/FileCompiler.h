//
//  FileCompiler.h
//  TeXtended
//
//  Created by Max Bannach on 09.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DocumentModel, CompileSetting;

@interface FileCompiler : NSObject

@property  BOOL autoCompile;
@property (strong) DocumentModel* model;

-(id)initWithDocumentModel:(DocumentModel*) model;

- (void) compile:(bool)draft;

@end
