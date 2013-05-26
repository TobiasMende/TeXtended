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
@class DocumentModel, OutlineViewController, ConsoleViewsController, PDFViewsController, TextViewController;
/**
 The DocumentController holds a DocumentModel and the view representations for this model. It only exists if the current document model ist displayed by any views.
 
 
 
 **Author:** Tobias Mende
 
 */
@interface DocumentController : NSObject<DocumentControllerProtocol> {
    id<MainDocument> mainDocument;
}
@property (weak) DocumentModel *model;
@property (strong,nonatomic) id<WindowControllerProtocol> windowController;
@property (strong) TextViewController* textViewController;
@property (strong) PDFViewsController* pdfViewsController;
@property (strong) ConsoleViewsController* consolViewsController;
@property (strong) OutlineViewController* outlineViewController;

- initWithDocument:(DocumentModel *)model andMainDocument:(id<MainDocument>) document;

- (BOOL) saveDocument:(NSError**) outError;
- (BOOL) loadContent;

@end
