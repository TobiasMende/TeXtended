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
@interface ConsoleViewController : NSViewController <DocumentControllerProtocol> {
    NSFileHandle *readHandle;
}
@property (weak) id<DocumentControllerProtocol> parent;
@property (weak) DocumentModel *model;
@property (unsafe_unretained) IBOutlet NSTextView *textView;

- (void) handleOutput: (NSNotification*)notification;
@end
