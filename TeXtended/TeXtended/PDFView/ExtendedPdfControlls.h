//
//  ExtendedPdfControlls.h
//  TeXtended
//
//  Created by Max Bannach on 22.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface ExtendedPdfControlls : NSViewController

@property (assign) PDFView *pdfView;

- (IBAction)update:(id)sender;

@end
