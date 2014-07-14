//
//  PrintDialogController.m
//  TeXtended
//
//  Created by Tobias Hecht on 04.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "PrintDialogController.h"

@interface PrintDialogController ()

@end

@implementation PrintDialogController

    - (id)init
    {
        self = [super initWithWindowNibName:@"PrintDialog"];
        return self;
    }


    - (IBAction)cancelDialog:(id)sender
    {
        [NSApp stopModal];
        [NSApp endSheet:self.window returnCode:NSRunAbortedResponse];
        [self.window orderOut:self];
        [self.window close];
    }

    - (IBAction)OKDialog:(id)sender
    {
        [NSApp stopModal];
        [NSApp endSheet:self.window];
        [self.window orderOut:self];
        [self.window close];
    }

@end
