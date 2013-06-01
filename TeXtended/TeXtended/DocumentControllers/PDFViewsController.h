//
//  PDFViewsController.h
//  TeXtended
//
//  Created by Tobias Mende on 26.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DocumentControllerProtocol.h"
#import "DocumentController.h"
#import "DocumentModel.h"
#import "ExtendedPDFViewController.h"

@interface PDFViewsController : NSViewController<DocumentControllerProtocol>

@property (weak) IBOutlet NSTabView *tabView;
@property (strong) id<DocumentControllerProtocol> parent;
@property (strong) NSSet* children;

@end
