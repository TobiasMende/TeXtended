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
#import <TMTHelperCollection/TMTLog.h>
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
            _console.selectedRange = [self.outputView selectedRange];
        }
        _console = console;
    }
}

- (void)scrollToCurrentPosition {
    if(self.console.selectedRange.location != NSNotFound && NSMaxRange(self.console.selectedRange) < self.outputView.string.length) {
        [self.outputView setSelectedRange:self.console.selectedRange];
        [self.outputView scrollRangeToVisible:self.console.selectedRange];
    } else {
        [self.outputView scrollToEndOfDocument:nil];
    }
    
}

- (IBAction)cancelCompiling:(id)sender {
    [self.console.firstResponderDelegate abort];
}


#pragma mark -
#pragma mark NSTextFieldDelegate Methods

-(void)controlTextDidEndEditing:(NSNotification *)notification {
    if ( [[notification userInfo][@"NSTextMovement"] intValue] == NSReturnTextMovement )
    {
        [self.console commitInput];
    }
}

#pragma mark -
#pragma mark Dealloc etc.

- (void)dealloc {
    DDLogVerbose(@"dealloc");
    self.console = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


@end
