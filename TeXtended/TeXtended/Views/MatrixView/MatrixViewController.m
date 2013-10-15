//
//  MatrixViewController.m
//  TeXtended
//
//  Created by Tobias Hecht on 15.10.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "MatrixViewController.h"
#import "TMTLog.h"

@interface MatrixViewController ()

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

- (id)init {
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

-(NSString*)matrixTemplate
{
    NSString* retTemplate;
    retTemplate = @"\\begin{";
    retTemplate = [retTemplate stringByAppendingString:self.type];
    retTemplate = [retTemplate stringByAppendingString:@"}"];
    
    if (self.alignment) {
        retTemplate = [retTemplate stringByAppendingString:@"{"];
        for (NSInteger i = 0; i < self.columns; i++) {
            retTemplate = [retTemplate stringByAppendingString:@"c"];
        }
        retTemplate = [retTemplate stringByAppendingString:@"}"];
    }
    
    retTemplate = [retTemplate stringByAppendingString:@"\n"];
    
    for (NSInteger i = 0; i < self.rows-1; i++) {
        for (NSInteger j = 0; j < self.columns-1; j++) {
            retTemplate = [retTemplate stringByAppendingString:@"@@entry@@ & "];
        }
        retTemplate = [retTemplate stringByAppendingString:@"@@entry@@\\\\\n"];
    }
    
    for (NSInteger j = 0; j < self.columns-1; j++) {
        retTemplate = [retTemplate stringByAppendingString:@"@@entry@@ & "];
    }
    retTemplate = [retTemplate stringByAppendingString:@"@@entry@@\n"];
    
    retTemplate = [retTemplate stringByAppendingString:@"\\end{"];
    retTemplate = [retTemplate stringByAppendingString:self.type];
    retTemplate = [retTemplate stringByAppendingString:@"}\n"];
    
    _matrixTemplate = retTemplate;
    
    return _matrixTemplate;
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
