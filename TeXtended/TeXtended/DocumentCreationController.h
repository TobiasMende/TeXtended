//
//  DocumentController.h
//  TeXtended
//
//  Created by Tobias Mende on 17.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class EncodingController, ProjectCreationWindowController, Compilable, DocumentModel;

@interface DocumentCreationController : NSDocumentController{
    
}

@property ProjectCreationWindowController *projectCreationWindowController;
@property EncodingController *encController;
- (void) newProject:(id)sender;
- (void) showTexDocumentForPath:(NSString *)path andCompletionHandler:(void (^) (DocumentModel *))completionHandler;
- (void) showTexDocumentForPath:(NSString *)path withReferenceModel:(Compilable*)model andCompletionHandler:(void (^) (DocumentModel *))completionHandler;

- (void)openDocumentForCompilable:(Compilable *)compilable display:(BOOL)displayDocument andError:(NSError **)error;
@end
