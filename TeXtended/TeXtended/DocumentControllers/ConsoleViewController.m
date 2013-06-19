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
#import "DocumentControllerProtocol.h"
#import "DocumentController.h"

@interface ConsoleViewController ()
- (void)configureReadHandle;
- (void)compilerDidStartCompiling:(NSNotification*)notification;
- (void)compilerDidEndCompiling:(NSNotification*)notification;
@end

@implementation ConsoleViewController


- (id) initWithParent:(id<DocumentControllerProtocol>) parent {
    self = [super initWithNibName:@"ConsoleView" bundle:nil];
    if (self) {
        _parent = parent;
    }
    return self;
}

- (void)setModel:(DocumentModel *)model {
    if(_model) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:TMTCompilerDidStartCompiling object:_model];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:TMTCompilerDidEndCompiling object:_model];
    }
    [self willChangeValueForKey:@"model"];
    _model = model;
    [self didChangeValueForKey:@"model"];
    if(_model) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(compilerDidStartCompiling:) name:TMTCompilerDidStartCompiling object:_model];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(compilerDidEndCompiling:) name:TMTCompilerDidEndCompiling object:_model];
    }
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

}

- (void) breakUndoCoalescing {
    
}

- (void)handleOutput: (NSNotification*)notification {
    //[self.model.outputPipe.fileHandleForReading readInBackgroundAndNotify] ;
    NSData *data = [[notification userInfo] objectForKey: NSFileHandleNotificationDataItem];
    NSString *str = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] ;
    if (str && data.length > 0) {
        self.outputView.string = [self.outputView.string stringByAppendingString:str];
        [self.outputView scrollToEndOfDocument:self];
        // Do whatever you want with str
    }
    if (data.length > 0) {
        [readHandle readInBackgroundAndNotify];
        self.consoleActive = YES;
    } else {
        self.consoleActive = NO;
    }
}

- (void)configureReadHandle {
    
    if (readHandle && readHandle != [self.model.consoleOutputPipe fileHandleForReading]) {
        [[NSNotificationCenter defaultCenter]removeObserver:self name:NSFileHandleReadCompletionNotification object:readHandle];
        [self.outputView setString:@""];
    }
    readHandle = [self.model.consoleOutputPipe fileHandleForReading];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handleOutput:) name: NSFileHandleReadCompletionNotification object: readHandle] ;
    [readHandle readInBackgroundAndNotify] ;
    self.consoleActive = YES;

    
}

#pragma mark -
#pragma mark Notification Observer

- (void)compilerDidStartCompiling:(NSNotification *)notification {
    [self configureReadHandle];
}

- (void)compilerDidEndCompiling:(NSNotification *)notification {
    [self.inputView setStringValue:@""];
    self.consoleActive = NO;
}

#pragma mark -
#pragma mark NSTextFieldDelegate Methods

-(void)controlTextDidEndEditing:(NSNotification *)notification {
    if ( [[[notification userInfo] objectForKey:@"NSTextMovement"] intValue] == NSReturnTextMovement )
    {
        NSFileHandle *handle = self.model.consoleInputPipe.fileHandleForWriting;
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
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


@end
