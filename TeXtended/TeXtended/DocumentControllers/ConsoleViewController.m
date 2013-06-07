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

@interface ConsoleViewController ()
- (void)configureReadHandle;
@end

@implementation ConsoleViewController


- (id) initWithParent:(id<DocumentControllerProtocol>) parent {
    self = [super initWithNibName:@"ConsoleView" bundle:nil];
    if (self) {
        
    }
    return self;
}



- (DocumentController * ) documentController {
    return [self.parent documentController];
}

- (NSSet *) children {
    return [NSSet setWithObjects: nil];
}

- (void) documentModelHasChangedAction : (DocumentController*) controller {
    
}

- (void) documentHasChangedAction {
    [self configureReadHandle];
}

- (void) breakUndoCoalescing {
    
}

- (void)handleOutput: (NSNotification*)notification {
    //[self.model.outputPipe.fileHandleForReading readInBackgroundAndNotify] ;
    NSData *data = [[notification userInfo] objectForKey: NSFileHandleNotificationDataItem];
    NSString *str = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] ;
    if (str) {
        [self.outputView.textStorage appendAttributedString:[[NSAttributedString alloc] initWithString:str]];
        [self.outputView scrollToEndOfDocument:self];
        // Do whatever you want with str
    }
    if (data.length > 0) {
        [readHandle readInBackgroundAndNotify];
        self.consoleActive = TRUE;
    } else {
        self.consoleActive = FALSE;
    }
}

- (void)configureReadHandle {
    
    if (readHandle && readHandle != [self.model.outputPipe fileHandleForReading]) {
        [[NSNotificationCenter defaultCenter]removeObserver:self name:NSFileHandleReadCompletionNotification object:readHandle];
        [self.outputView setString:@""];
    }
    readHandle = [self.model.outputPipe fileHandleForReading];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handleOutput:) name: NSFileHandleReadCompletionNotification object: readHandle] ;
    [readHandle readInBackgroundAndNotify] ;
    self.consoleActive = TRUE;

    
}

#pragma mark -
#pragma mark NSTextFieldDelegate Methods

-(void)controlTextDidEndEditing:(NSNotification *)notification {
    if ( [[[notification userInfo] objectForKey:@"NSTextMovement"] intValue] == NSReturnTextMovement )
    {
        NSFileHandle *handle = self.model.inputPipe.fileHandleForWriting;
        NSString *command = [[self.inputView stringValue] stringByAppendingString:@"\n"];
        [handle writeData:[command dataUsingEncoding:NSUTF8StringEncoding]];
        [self.inputView setStringValue:@""];
    }
}

#pragma mark -
#pragma mark Dealloc etc.

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"ConsoleViewController dealloc");
#endif
}


@end
