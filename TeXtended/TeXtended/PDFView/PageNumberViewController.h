//
//  PageNumberViewController.h
//  TeXtended
//
//  Created by Max Bannach on 30.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PDFDocument, PDFView;
@interface PageNumberViewController : NSViewController {
    __weak PDFView* pdfView;
}
@property (assign) IBOutlet NSBox *theBox;
@property (assign) IBOutlet NSTextField *theLabel;
- (id) initInPdfView:(PDFView*) view;
- (void) update;
@end
