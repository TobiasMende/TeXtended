//
//  PDFViewController.m
//  TeXtended
//
//  Created by Max Bannach on 01.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "ExtendedPDFViewController.h"

@implementation ExtendedPDFViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    
    return self;
}

- (id)initWithParent:(id<DocumentControllerProtocol>)parent {
    self = [super initWithNibName:@"PDFViewsView" bundle:nil];
    if (self) {
        self.parent = parent;
    }
    return self;
}


- (DocumentController * ) documentController {
    return [self.parent documentController];
}

- (NSSet<DocumentControllerProtocol> *)children {
    return [NSSet setWithObject:nil];
}


- (void) documentHasChangedAction {
    if ([self pdfPath] != nil) {
        NSURL *url = [NSURL fileURLWithPath:[self pdfPath]];
        PDFDocument *pdfDoc;
        pdfDoc = [[PDFDocument alloc] initWithURL:url];
        [self.pdfView setDocument:pdfDoc];
    }
}

- (void) breakUndoCoalescing {}

@end
