//
//  DocumentControllerProtocol.h
//  TeXtended
//
//  Created by Tobias Mende on 16.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DocumentController;
/**
 View Controller displaying views of the document should implement this protocol.
 
 **Author:** Tobias Mende
 
 */
@protocol DocumentControllerProtocol <NSObject>

/**
 * Constructor, init a node with the perent.
 */
- (id) initWithParent:(id<DocumentControllerProtocol>) parent;

/**
 * Get parent in the controler tree, nil if root.
 * @return id <DocumentControllerProtocol> the parent
 */
- (id <DocumentControllerProtocol>) parent;

/**
 * Get the documentController i.e. the root of the controler tree.
 * Will call the samemethod on the parent unless it is called on the root.
 * @return id <DocumentControllerProtocol> the root
 */
- (DocumentController * ) documentController;

/**
 * Get a set of the childrens in the controler tree.
 * @return NSSet<DocumentControllerProtocol> * pointer to the set of children
 */
- (NSSet<DocumentControllerProtocol> *) children;

/**
 * Perform operations that are required if the document has changed
 * and will call the same method on all children.
 */
- (void) documentHasChangedAction;

- (void) breakUndoCoalescing;

@end
