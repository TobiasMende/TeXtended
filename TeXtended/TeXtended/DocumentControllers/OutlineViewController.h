//
//  OutlineViewController.h
//  TeXtended
//
//  Created by Tobias Mende on 26.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DocumentControllerProtocol.h"

/**
 * This class handels the outlineView.
 */
@interface OutlineViewController : NSViewController<DocumentControllerProtocol>

/** Parent the document controller tree. */
@property (assign) id<DocumentControllerProtocol> parent;

@end
