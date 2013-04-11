//
//  PreviewController.h
//  SimpleLatexEditor
//
//  Created by Tobias Mende on 04.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
@class LatexDocument;
@interface PreviewController : NSWindowController
@property (strong) IBOutlet PDFView *pdfView;
@property (nonatomic) LatexDocument* latex;

- (IBAction)updateView:(id)sender;
@end
