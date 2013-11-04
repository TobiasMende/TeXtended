//
//  ConsoleViewController.h
//  TeXtended
//
//  Created by Tobias Mende on 05.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ViewControllerProtocol.h"

@class DocumentModel, MessageCollection, ConsoleOutputView, DocumentController, ConsoleData;

/**
 Viewcontroller for handling interaction with a single console view
 
 **Author:** Tobias Mende
 
 */
@interface ConsoleViewController : NSViewController <NSTextFieldDelegate, ViewControllerProtocol> {
}

@property (weak, nonatomic) ConsoleData *console;

/** The input view for sending messages to the compiler */
@property (strong) IBOutlet NSTextField *inputView;


/** The output view for showing the compilers output to the user */
@property (strong) IBOutlet ConsoleOutputView *outputView;

@end
