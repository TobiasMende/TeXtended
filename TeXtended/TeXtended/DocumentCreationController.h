//
//  DocumentController.h
//  TeXtended
//
//  Created by Tobias Mende on 17.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class EncodingController, ProjectCreationWindowController;

@interface DocumentCreationController : NSDocumentController {
    ProjectCreationWindowController *projectCreationWindowConmtroller;
    
}

@property EncodingController *encController;
- (void) newProject:(id)sender;

@end
