//
//  WindowControllerProtocol.h
//  TeXtended
//
//  Created by Tobias Mende on 26.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DocumentController;

/**
 * This is a protocol for controller for windows.
 *
 * **Author:** Tobias Mebde
 */
@protocol WindowControllerProtocol <NSObject>

/**
 * Set the document controller for the window controller.
 *
 * @param dc the DocumentController
 */
- (void) setDocumentController:(DocumentController *) dc;

/**
 * Clear all document view i.e. removes the views.
 *
 */
- (void) clearAllDocumentViews;

@optional

/**
 * Adds a TextView to the window.
 *
 * @param view is the TextView to add
 */
- (void) addTextView:(NSView *) view;

/**
 * Adds a PDFViewsView to the window.
 *
 * @param view is the PDFViewsView to add
 */
- (void) addPDFViewsView:(NSView *) view;

/**
 * Adds a ConsoleViewsView to the window.
 *
 * @param view is the ConsoleViewsView to add
 */
- (void) addConsoleViewsView:(NSView *) view;

/**
 * Adds a OutlineView to the window.
 *
 * @param view is the OutlineView to add
 */
- (void) addOutlineView:(NSView *) view;

/**
 * Makes the given view the first responder.
 *
 * @param view
 */
- (void) makeFirstResponder:(NSView*)view;

@end
