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


- (void)setModel:(DocumentModel *)model {
    if (self.model) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:TMTDocumentModelOutputPipeChangeNotification object:self.model];
    }
    [self willChangeValueForKey:@"model"];
    _model = model;
    [self didChangeValueForKey:@"model"];
    if (self.model) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configureReadHandle) name:TMTDocumentModelOutputPipeChangeNotification object:self.model];
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
    NSLog(@"data: %@", data);
    NSString *str = [[NSString alloc] initWithData: data encoding: NSASCIIStringEncoding] ;
    [self.textView setString:str];
    // Do whatever you want with str
    //[self.model.outputPipe.fileHandleForReading readInBackgroundAndNotify];
}

- (void)configureReadHandle {
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handleOutput:) name: NSFileHandleReadCompletionNotification object: self.model.outputPipe.fileHandleForReading] ;
    
}

@end
