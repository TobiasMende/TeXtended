//
//  MatrixViewController.m
//  TeXtended
//
//  Created by Tobias Hecht on 15.10.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "MatrixViewController.h"
#import "EnvironmentCompletion.h"

@interface MatrixViewController ()

    - (NSString *)placeholderForPosition:(NSUInteger)row andCol:(NSUInteger)col;

@end

@implementation MatrixViewController

    - (id)initWithWindow:(NSWindow *)window
    {
        self = [super initWithWindow:window];
        if (self) {
            // Initialization code here.
        }
        return self;
    }

    - (id)init
    {
        self = [super initWithWindowNibName:@"MatrixView"];
        if (self) {
            _minimumTableSize = 1;
            self.rows = _minimumTableSize;
            self.columns = _minimumTableSize;
            _type = @"array";
            _alignment = NO;
        }
        return self;
    }

    - (void)windowDidLoad
    {
        [super windowDidLoad];

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

    - (EnvironmentCompletion *)matrixCompletion
    {
        EnvironmentCompletion *completion = [[EnvironmentCompletion alloc] initWithInsertion:self.type];

        if (self.alignment) {
            NSMutableString *firstLine = [NSMutableString new];
            [firstLine appendString:@"{"];
            for (NSUInteger i = 0 ; i < self.columns ; i++) {
                [firstLine appendString:@"c"];
            }
            [firstLine appendString:@"}"];
            completion.firstLineExtension = firstLine;
        }
        NSMutableString *extension = [NSMutableString new];

        for (NSUInteger i = 0 ; i < self.rows - 1 ; i++) {
            for (NSUInteger j = 0 ; j < self.columns - 1 ; j++) {
                [extension appendFormat:@"%@ & ", [self placeholderForPosition:i andCol:j]];
            }
            [extension appendFormat:@"%@\\\\\\n\\t", [self placeholderForPosition:i andCol:self.columns - 1]];
        }

        for (NSUInteger j = 0 ; j < self.columns - 1 ; j++) {
            [extension appendFormat:@"%@ & ", [self placeholderForPosition:self.rows - 1 andCol:j]];
        }
        [extension appendString:[self placeholderForPosition:self.rows - 1 andCol:self.columns - 1]];

        completion.extension = extension;
        return completion;

    }

    - (NSString *)placeholderForPosition:(NSUInteger)row andCol:(NSUInteger)col
    {
        return [NSString stringWithFormat:@"@@a-%ld,%ld@@", row, col];
    }

    - (IBAction)cancelSheet:(id)sender
    {
        [NSApp stopModal];
        [NSApp endSheet:self.window returnCode:NSRunAbortedResponse];
        [self.window orderOut:self];
    }

    - (IBAction)OKSheet:(id)sender
    {
        [[self window] makeFirstResponder:self.OKButton];
        [NSApp stopModal];
        [NSApp endSheet:self.window];
        [self.window orderOut:self];
    }

@end
