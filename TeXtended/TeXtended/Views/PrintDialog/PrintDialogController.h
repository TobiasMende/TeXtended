//
//  PrintDialogController.h
//  TeXtended
//
//  Created by Tobias Hecht on 04.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PrintDialogController : NSWindowController

@property (assign) IBOutlet NSPopUpButton *documentType;
@property (assign) IBOutlet NSPopUpButton *documentName;

@end
