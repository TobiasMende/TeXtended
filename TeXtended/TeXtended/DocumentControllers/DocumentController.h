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
}
@property (strong,nonatomic) DocumentModel *model;
@property (weak,nonatomic) id<WindowControllerProtocol> windowController;
@property (strong) TextViewController* textViewController;
@property (strong) PDFViewsController* pdfViewsController;
@property (strong) ConsoleViewsController* consolViewsController;
@property (strong) OutlineViewController* outlineViewController;
@property (strong) Compiler* compiler;
@property (weak, readonly) id<MainDocument> mainDocument;

- initWithDocument:(DocumentModel *)model andMainDocument:(id<MainDocument>) document;
- (void)setupWindowController;
- (BOOL) saveDocument:(NSError**) outError;
- (BOOL) loadContent;
- (void) documentModelDidChange;

- (void)refreshLiveView;

/**
 * Draft compiles this document.
 */
- (void) draftCompile;

/**
 * Final compiles this document.
 */
- (void) finalCompile;

- (void)draftCompile:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void  *)context;
- (void)finalCompile:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void  *)context;
- (void)liveCompile:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void  *)context;

@end
