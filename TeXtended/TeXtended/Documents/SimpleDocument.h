//
//  SimpleDocument.h
//  TeXtended
//
//  Created by Tobias Mende on 17.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainDocument.h"
@class DocumentModel, MainWindowController, DocumentController;
@interface SimpleDocument : NSDocument <MainDocument> {
    
}
@property (strong) NSManagedObjectContext *context;
@property (strong) DocumentModel *model;
@property (strong) MainWindowController *mainWindowController;
@property (strong) DocumentController *documentController;

@end
