//
//  ExtendedPdfControlls.m
//  TeXtended
//
//  Created by Max Bannach on 22.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "ExtendedPdfControlls.h"
#import "ExtendedPdf.h"

@interface ExtendedPdfControlls ()

@end

@implementation ExtendedPdfControlls

- (id)initWithExtendedPdf:(ExtendedPdf*) extedendPdf
{
    self = [super initWithNibName:@"ExtendedPdfControlls" bundle:nil];
    if (self) {
        [self setExtendedPdf:extedendPdf];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.extendedPdf setPageAlpha:NO];
    [self.shineThrough setState:NSOffState];
}

- (void)checkShineThrough:(id)sender {
    [self.extendedPdf setPageAlpha:!self.extendedPdf.pageAlpha];
    [self.extendedPdf layoutDocumentView];
}

- (IBAction)update:(id)sender {
    /* set the size of the sliders so that they cover the current page */
    NSSize size = [[self.extendedPdf currentPage] boundsForBox:kPDFDisplayBoxMediaBox].size;
    double scalingFactor = [self.extendedPdf getScalingFactor];
    [self.gridHSpacingSlider setMaxValue:size.height / scalingFactor + 1];
    [self.gridHOffsetSlider  setMaxValue:size.height];
    [self.gridVSpacingSlider setMaxValue:size.width / scalingFactor + 1];
    [self.gridVOffsetSlider  setMaxValue:size.width];

    [self.view setNeedsDisplay:YES];
}

@end
