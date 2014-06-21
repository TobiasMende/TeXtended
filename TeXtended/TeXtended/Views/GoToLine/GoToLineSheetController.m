//
//  GoToLineSheetController.m
//  TeXtended
//
//  Created by Tobias Mende on 17.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "GoToLineSheetController.h"

@interface GoToLineSheetController ()

@end

@implementation GoToLineSheetController

    - (id)init
    {
        self = [super initWithWindowNibName:@"GoToLineSheet"];
        if (self) {

        }
        return self;
    }

    - (void)windowDidLoad
    {
        [super windowDidLoad];

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

    - (IBAction)cancelSheet:(id)sender
    {
        [NSApp stopModal];
        [NSApp endSheet:self.window returnCode:NSRunAbortedResponse];
        [self.window orderOut:self];
    }

    - (IBAction)goToLine:(id)sender
    {
        [NSApp stopModal];
        [NSApp endSheet:self.window];
        [self.window orderOut:self];
    }
@end
