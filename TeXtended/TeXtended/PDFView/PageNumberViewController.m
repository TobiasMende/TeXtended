//
//  PageNumberViewController.m
//  TeXtended
//
//  Created by Max Bannach on 30.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "PageNumberViewController.h"
#import <Quartz/Quartz.h>

@interface PageNumberViewController ()

@end

@implementation PageNumberViewController


- (id) initInPdfView:(PDFView*) view {
    self = [super initWithNibName:@"PageNumberView" bundle:nil];
    if (self) {
        pdfView = view;
    }
    return self;
}

- (void) awakeFromNib {
    [super awakeFromNib];
    [self.theBox setBorderWidth:0];
    [self.theBox setCornerRadius:10];
    [self update];
}

- (void) update {
    NSString* label = [NSString stringWithFormat:@"%lu/%lu", [pdfView.document indexForPage:pdfView.currentPage]+1, [pdfView.document pageCount]];
    [self.theLabel setStringValue:label];
    [self.view setNeedsDisplay:YES];
}

@end
