//
//  DocumentController.h
//  TeXtended
//
//  Created by Tobias Mende on 16.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainDocument.h"
#import "DocumentControllerProtocol.h"
#import "TextViewController.h"
#import "PDFViewsController.h"
#import "ConsoleViewsController.h"
#import "OutlineViewController.h"
@class DocumentModel;
/**
 The DocumentController holds a DocumentModel and the view representations for this model. It only exists if the current document model ist displayed by any views.
 
 
 
 **Author:** Tobias Mende
 
 */
@interface DocumentController : NSObject<DocumentControllerProtocol>

@property (assign) TextViewController* textViewController;
@property (assign) PDFViewsController* pdfViewsController;
@property (assign) ConsoleViewsController* consolViewsController;
@property (assign) OutlineViewController* outlineViewController;

- initWithDocument:(DocumentModel *)model andMainDocument:(id<MainDocument>) document;

- (bool) saveDocument:(NSError**) outError;

@end
