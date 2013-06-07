//
//  ConsoleViewController.h
//  TeXtended
//
//  Created by Tobias Mende on 05.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DocumentControllerProtocol.h"

@class DocumentModel;
@interface ConsoleViewController : NSViewController <DocumentControllerProtocol,NSTextFieldDelegate> {
    NSFileHandle *readHandle;
}
@property (weak) IBOutlet NSTextField *inputView;
@property (weak) id<DocumentControllerProtocol> parent;
@property (weak,nonatomic) DocumentModel *model;
@property (unsafe_unretained) IBOutlet NSTextView *outputView;
@property BOOL consoleActive;

- (void) handleOutput: (NSNotification*)notification;
@end
