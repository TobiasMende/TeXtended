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
 * The DocumentController holds a DocumentModel and the view representations for this model. It only exists if the current document model ist displayed by any views.
 *
 * **Author:** Tobias Mende
 *
 */
@interface DocumentController : NSObject<DocumentControllerProtocol> {
}
@property (strong,nonatomic) DocumentModel *model;
@property (weak,nonatomic) id<WindowControllerProtocol> windowController;

/** Controller for the TextView. */
@property (strong) TextViewController* textViewController;

/** Controller handeling all the pdfViews (one pdfViewController for each main document). */
@property (strong) PDFViewsController* pdfViewsController;

/** Controller handeling all the consoleViews (one for each main document). */
@property (strong) ConsoleViewsController* consolViewsController;

/** Controller that handels the outlineView. */
@property (strong) OutlineViewController* outlineViewController;

/** The compiler that will be used to compile the main documents. */
@property (strong) Compiler* compiler;

/** The main document. */
@property (weak, readonly) id<MainDocument> mainDocument;

/**
 * Init the class with a model and a main document.
 *
 * @param model the DocumentModel
 * @param document the main document
 */
- initWithDocument:(DocumentModel *)model andMainDocument:(id<MainDocument>) document;

/** Init all the window controller */
- (void)setupWindowController;

/**
 * Save the handeld document.
 *
 * @param outError a pointer to NSError in which the error log is written
 * @return ´YES´ if the save was succsesfull
 */
- (BOOL) saveDocument:(NSError**) outError;

/**
 * Load the content of the document.
 *
 * @return ´YES´ if the loading was succesfull
 */
- (BOOL) loadContent;

/**
 * Called if the document model has changed.
 */
- (void) documentModelDidChange;

/**
 * Called if the live view is refreshed.
 */
- (void)refreshLiveView;

/**
 * Draft compiles this document.
 */
- (void) draftCompile;

/**
 * Final compiles this document.
 */
- (void) finalCompile;


/**
 * Calls draft compile on the compiler if the file was saved before (didSave is ´YES´).
 *
 * @param doc not used by this method (framework stuff)
 * @param didSave should be ´YES´ if the document was saved before
 * @param context not used by this method (framework stuff)
 */
- (void)draftCompile:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void  *)context;

/**
 * Calls final compile on the compiler if the file was saved before (didSave is ´YES´).
 *
 * @param doc not used by this method (framework stuff)
 * @param didSave should be ´YES´ if the document was saved before
 * @param context not used by this method (framework stuff)
 */
- (void)finalCompile:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void  *)context;

/**
 * Calls live compile on the compiler if the file was saved before (didSave is ´YES´).
 *
 * @param doc not used by this method (framework stuff)
 * @param didSave should be ´YES´ if the document was saved before
 * @param context not used by this method (framework stuff)
 */
- (void)liveCompile:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void  *)context;

@end
