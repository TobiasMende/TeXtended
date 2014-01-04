//
//  ExtendedPdfControlls.m
//  TeXtended
//
//  Created by Max Bannach on 22.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "ExtendedPdfControlls.h"

@interface ExtendedPdfControlls ()

@end

@implementation ExtendedPdfControlls

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (IBAction)update:(id)sender {
    /* set the size of the sliders so that they cover the current page */
    NSSize size = [[self.pdfView currentPage] boundsForBox:kPDFDisplayBoxMediaBox].size;
    if (self.gridHOffsetSlider.maxValue != size.height) {
        [self.gridHSpacingSlider setMaxValue:size.height];
        [self.gridHOffsetSlider  setMaxValue:size.height];
        [self.gridVSpacingSlider setMaxValue:size.width];
        [self.gridVOffsetSlider  setMaxValue:size.width];
    }

    [self.view setNeedsDisplay:YES];
    [[self pdfView] setNeedsDisplay:YES];
}

@end
