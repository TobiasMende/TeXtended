//
//  TemplatePlaceholderController.m
//  TeXtended
//
//  Created by Tobias Mende on 18.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "TemplatePlaceholderController.h"
#import <Quartz/Quartz.h>
#import "Template.h"
@interface TemplatePlaceholderController ()

@end

@implementation TemplatePlaceholderController

- (id)init {
    self = [super initWithNibName:@"TemplatePlaceholder" bundle:nil];
    if (self) {
        
    }
    return  self;
}

- (void)loadView {
    [super loadView];
    if ([self.representedObject hasPreviewPDF]) {
        [self.pdfView setDocument:[self.representedObject previewPDF]];
    }
}

@end
