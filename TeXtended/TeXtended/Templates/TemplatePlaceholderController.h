//
//  TemplatePlaceholderController.h
//  TeXtended
//
//  Created by Tobias Mende on 18.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PDFView;
@interface TemplatePlaceholderController : NSCollectionViewItem
@property (strong) IBOutlet PDFView *pdfView;

@end
