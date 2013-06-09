//
//  ExportCompileWindowController.m
//  TeXtended
//
//  Created by Max Bannach on 09.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "ExportCompileWindowController.h"
#import "DocumentController.h"

@interface ExportCompileWindowController ()

@end

@implementation ExportCompileWindowController

-(id)init {
    self = [super initWithWindowNibName:@"ExportCompileWindow"];
    if (self) {
        
    }
    return self;
}

- (IBAction)export:(id)sender {
    if (self.controller) {
        [self.controller finalCompile];
        [self.window orderOut:nil];
    }
}
@end
