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
@interface PDFViewsController : NSViewController<DocumentControllerProtocol>

@property (strong) IBOutlet NSTabView *tabView;
@property (weak) id<DocumentControllerProtocol> parent;
@property (strong) NSSet* children;
@property (weak) DocumentModel *model;
@end
