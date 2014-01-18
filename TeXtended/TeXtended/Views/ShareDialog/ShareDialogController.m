//
//  ShareDialogController.m
//  TeXtended
//
//  Created by Tobias Hecht on 18.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "ShareDialogController.h"

@interface ShareDialogController ()

@end

@implementation ShareDialogController

- (id)init {
    self = [super initWithWindowNibName:@"ShareDialog"];
    if (self) {
        
    }
    return self;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)cancelSheet:(id)sender {
    [NSApp stopModal];
    [NSApp endSheet: self.window returnCode:NSRunAbortedResponse];
    [self.window orderOut: self];
}

- (IBAction)OKSheet:(id)sender {
    [NSApp stopModal];
    [NSApp endSheet: self.window];
    [self.window orderOut: self];
}

@end
