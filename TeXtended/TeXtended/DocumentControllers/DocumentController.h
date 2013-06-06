//
//  DocumentController.h
//  TeXtended
//
//  Created by Tobias Mende on 16.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainDocument.h"
#import "WindowControllerProtocol.h"
#import "DocumentControllerProtocol.h"

@class DocumentModel, OutlineViewController, ConsoleViewsController, PDFViewsController, TextViewController, Compiler;
/**
 The DocumentController holds a DocumentModel and the view representations for this model. It only exists if the current document model ist displayed by any views.
 
 
 
 **Author:** Tobias Mende
 
 */
@interface DocumentController : NSObject<DocumentControllerProtocol> {
    __weak id<MainDocument> mainDocument;
}
@property (weak,nonatomic) DocumentModel *model;
@property (nonatomic) id<WindowControllerProtocol> windowController;
@property (strong) TextViewController* textViewController;
@property (strong) PDFViewsController* pdfViewsController;
@property (strong) ConsoleViewsController* consolViewsController;
@property (strong) OutlineViewController* outlineViewController;
@property (strong) Compiler* compiler;

- initWithDocument:(DocumentModel *)model andMainDocument:(id<MainDocument>) document;
- (void)setupWindowController;
- (BOOL) saveDocument:(NSError**) outError;
- (BOOL) loadContent;
- (void) documentModelDidChange;

/**
 * Draft compiles this document.
 */
- (void) draftCompile;

@end
