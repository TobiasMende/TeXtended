//
//  ExportCompileWindowController.m
//  TeXtended
//
//  Created by Max Bannach on 09.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "ExportCompileWindowController.h"
#import "DocumentController.h"
#import "DocumentModel.h"

@interface ExportCompileWindowController ()

@end

@implementation ExportCompileWindowController

-(id)initWithDocumentController:(DocumentController*) controller {
    self = [super initWithWindowNibName:@"ExportCompileWindow"];
    if (self) {
        _controller = controller;
    }
    return self;
}

- (void) showWindow:(id)sender {

    
    [super showWindow:sender];
}

- (IBAction)export:(id)sender {
    if (self.controller) {
        [self.controller finalCompile];
        [self.window orderOut:nil];
    }
}
@end
