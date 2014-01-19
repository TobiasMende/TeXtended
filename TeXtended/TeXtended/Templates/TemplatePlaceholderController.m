//
//  TemplatePlaceholderController.m
//  TeXtended
//
//  Created by Tobias Mende on 18.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "TemplatePlaceholderController.h"
#import "Template.h"
#import "TMTQuickLookView.h"
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
        [self.quickLook setPreviewItem:[NSURL fileURLWithPath:[self.representedObject previewPath]]];
        __unsafe_unretained TemplatePlaceholderController *weakSelf = self;
        self.quickLook.mouseDownHandler = ^(NSEvent *theEvent) {
            weakSelf.selected = YES;
        };
    }
}

@end
