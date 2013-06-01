//
//  PDFViewsController.m
//  TeXtended
//
//  Created by Tobias Mende on 26.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "PDFViewsController.h"

@interface PDFViewsController ()

@end

@implementation PDFViewsController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initialize];
    }
    
    return self;
}

- (id)initWithParent:(id<DocumentControllerProtocol>)parent {
    self = [super initWithNibName:@"PDFViewsView" bundle:nil];
    if (self) {
        self.parent = parent;
        [self initialize];
    }
    return self;
}

- (void) initialize {
    [self loadPDFs:self.documentController];
}

- (void) loadPDFs:(DocumentController*) controller {
    NSMutableSet *tmp = [[NSMutableSet alloc] init];
    DocumentModel *mainModel = [controller model];
    for (DocumentModel* model in [mainModel mainDocuments]) {
        ExtendedPDFViewController *pdfViewController = [[ExtendedPDFViewController alloc] init];
        
        [pdfViewController setPdfPath:[model pdfPath]];
        [tmp addObject:pdfViewController];
    }
    [self setChildren:tmp];
}

- (DocumentController * ) documentController {
    return [self.parent documentController];
}

- (void) documentModelHasChangedAction : (DocumentController*) controller {
    [self loadPDFs:controller];
    for (id<DocumentControllerProtocol> c in self.children) {
        [c documentModelHasChangedAction:controller];
    }
}

- (void) documentHasChangedAction {
    for (id<DocumentControllerProtocol> c in self.children) {
        [c documentHasChangedAction];
    }
}

- (void) breakUndoCoalescing{
}

@end
