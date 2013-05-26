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
        // Initialization code here.
        
    }
    
    return self;
}


- (IBAction)update:(id)sender {
    [[self pdfView] setNeedsDisplay:YES];
}

@end
