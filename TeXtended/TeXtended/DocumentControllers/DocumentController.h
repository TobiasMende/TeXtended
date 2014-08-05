//
//  DocumentController.h
//  TeXtended
//
//  Created by Tobias Mende on 16.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewControllerProtocol.h"
#import "FirstResponderDelegate.h"
#import "CompileProcessHandler.h"
#import "Constants.h"

@class DocumentModel, TextViewController, Compiler, MainDocument,ModelInfoWindowController;

/**
 * The DocumentController holds a DocumentModel and the view representations for this model. It only exists if the current document model ist displayed by any views.
 *
 * **Author:** Tobias Mende
 *
 */
@interface DocumentController : NSObject <ViewControllerProtocol, FirstResponderDelegate, CompileProcessHandler>
    {
        ModelInfoWindowController *modelInfoWindow;
    }

/** The model handeld by this controller. */
    @property (strong, readonly) DocumentModel *model;

/** Controller for the TextView. */
    @property (strong, readonly) TextViewController *textViewController;

    @property (strong) NSMutableSet *pdfViewControllers;

    @property (strong) NSMutableSet *consoleViewControllers;


/** The compiler that will be used to compile the main documents. */
    @property (strong) Compiler *compiler;

/** The main document. */
    @property (assign) MainDocument *mainDocument;

/**
 * Init the class with a model and a main document.
 *
 * @param model the DocumentModel
 */
    - (id)initWithDocument:(DocumentModel *)model andMainDocument:(MainDocument *)mainDocument;

/**
 * Save the handeld document.
 *
 * @param outError a pointer to NSError in which the error log is written
 * @return ´YES´ if the save was succsesfull
 */
    - (BOOL)saveDocumentModel:(NSError **)outError;


    - (void)closeDocument;


/**
 * Calls draft compile on the compiler if the file was saved before (didSave is ´YES´).
 *
 * @param doc not used by this method (framework stuff)
 * @param didSave should be ´YES´ if the document was saved before
 * @param context not used by this method (framework stuff)
 */
    - (void)draftCompile:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void *)context;

/**
 * Calls final compile on the compiler if the file was saved before (didSave is ´YES´).
 *
 * @param doc not used by this method (framework stuff)
 * @param didSave should be ´YES´ if the document was saved before
 * @param context not used by this method (framework stuff)
 */
    - (void)finalCompile:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void *)context;

/**
 * Calls live compile on the compiler if the file was saved before (didSave is ´YES´).
 *
 * @param doc not used by this method (framework stuff)
 * @param didSave should be ´YES´ if the document was saved before
 * @param context not used by this method (framework stuff)
 */
    - (void)liveCompile:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void *)context;

    - (void)compile:(CompileMode)mode;

    - (void)texViewDidClose:(NSNotification *)note;

    - (void)pdfViewDidClose:(NSNotification *)note;

    - (void)showPDFViews;

    - (void)loadViews;

- (BOOL)isDirty;
@end
