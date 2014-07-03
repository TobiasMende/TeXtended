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

    - (id)init
    {
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

        [self.okButton sendActionOn:NSLeftMouseDownMask];
    }

    - (void)setContent:(NSArray *)content
    {
        _content = content;
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:[content count]];

        for (NSUInteger i = 0 ; i < [content count] ; i++) {
            [temp setObject:[[content objectAtIndex:i] lastPathComponent] atIndexedSubscript:i];
        }

        [self willChangeValueForKey:@"fileNames"];
        _fileNames = temp;
        [self didChangeValueForKey:@"fileNames"];
    }

    - (NSArray *)choice
    {
        NSMutableArray *temp = [NSMutableArray new];

        for (NSInteger i = 0 ; i < self.table.numberOfRows ; i++) {
            NSButton *checkBox = [self.table viewAtColumn:0 row:i makeIfNecessary:YES];
            if (checkBox.state == NSOnState) {
                [temp addObject:[[NSURL alloc] initFileURLWithPath:[self.content objectAtIndex:i]]];
            }
        }

        return temp;
    }

    - (IBAction)cancelSheet:(id)sender
    {
        [NSApp stopModal];
        [NSApp endSheet:self.window returnCode:NSRunAbortedResponse];
        [self.window orderOut:self];
    }

    - (IBAction)OKSheet:(id)sender
    {
        [NSApp stopModal];
        [NSApp endSheet:self.window];
        [self.window orderOut:self];
    }

@end
