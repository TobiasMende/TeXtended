//
//  ConsoleViewController.m
//  TeXtended
//
//  Created by Tobias Mende on 05.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "ConsoleViewController.h"
#import "DocumentModel.h"
#import "Constants.h"
#import "DocumentController.h"
#import "MessageCollection.h"
#import "ConsoleOutputView.h"
#import "TMTLog.h"
#import "TMTNotificationCenter.h"
#import "ConsoleData.h"



@interface ConsoleViewController ()
@end

@implementation ConsoleViewController


- (id) init {
    self = [super initWithNibName:@"ConsoleView" bundle:nil];
    if (self) {
    }
    return self;
}

- (void)loadView {
    [super loadView];
    self.outputView.controller = self;
}




- (void)setConsole:(ConsoleData *)console {
    if (console != _console) {
        if (_console) {
            [_console removeObserver:self forKeyPath:@"self.output"];
            [_console removeObserver:self forKeyPath:@"self.consoleActive"];
        }
        _console = console;
        if (_console) {
            [_console addObserver:self forKeyPath:@"self.output" options:0 context:NULL];
            [_console addObserver:self forKeyPath:@"self.consoleActive" options:0 context:NULL];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isEqualTo:self.console]) {
        if ([keyPath isEqualToString:@"self.output"]) {
            [self.outputView scrollToEndOfDocument:nil];
        } else if([keyPath isEqualToString:@"self.consoleActive"] && !self.console.consoleActive) {
            [self.inputView setStringValue:@""];
        }
    }
}




#pragma mark -
#pragma mark NSTextFieldDelegate Methods

-(void)controlTextDidEndEditing:(NSNotification *)notification {
    if ( [[[notification userInfo] objectForKey:@"NSTextMovement"] intValue] == NSReturnTextMovement )
    {
        NSFileHandle *handle = self.console.model.consoleInputPipe.fileHandleForWriting;
        NSString *command = [[self.inputView stringValue] stringByAppendingString:@"\n"];
        [handle writeData:[command dataUsingEncoding:NSUTF8StringEncoding]];
        [self.inputView setStringValue:@""];
    }
}

#pragma mark -
#pragma mark Dealloc etc.

- (void)dealloc {
    DDLogVerbose(@"dealloc");
    [self.console removeObserver:self forKeyPath:@"self.output"];
    [self.console removeObserver:self forKeyPath:@"self.consoleActive"];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


@end
