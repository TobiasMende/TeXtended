//
//  PreviewController.m
//  SimpleLatexEditor
//
//  Created by Tobias Mende on 04.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "PreviewController.h"
#import "LatexDocument.h"

@implementation PreviewController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)updateView:(id)sender {
    [self.pdfView setDocument:nil];
    NSURL *url = [NSURL fileURLWithPath:[self.latex pdfPath]];
    NSLog(@"PDFView: %@", self.pdfView);
    PDFDocument *pdfDoc = [[PDFDocument alloc] initWithURL:url];
    [self.pdfView setDocument:pdfDoc];
    
}

@end
