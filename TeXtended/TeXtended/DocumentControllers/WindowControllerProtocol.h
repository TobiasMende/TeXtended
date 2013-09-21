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
 * Makes the given view the first responder.
 *
 * @param view
 */
- (void) makeFirstResponder:(NSView*)view;

@end
