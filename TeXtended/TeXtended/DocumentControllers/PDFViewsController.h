//
//  PDFViewsController.h
//  TeXtended
//
//  Created by Tobias Mende on 26.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DocumentControllerProtocol.h"

@class DocumentModel;

/**
 * This class handels pdf view controllser for all pdf views of all main documents.
 * It implements the DocumentControllerProtocol.
 *
 * @author Max Bannach
 */
@interface PDFViewsController : NSViewController<DocumentControllerProtocol>

/** A tabview holds a PDFView for every MainDocument */
@property (strong) IBOutlet NSTabView *tabView;

/** Parent in the document controller tree */ 
@property (weak) id<DocumentControllerProtocol> parent;

/** Children in the document controller tree */
@property (strong) NSSet* children;
@property (strong) DocumentModel *model;
@end
