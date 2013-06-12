//
//  TexdocPanelController.h
//  TeXtended
//
//  Created by Tobias Mende on 12.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TexdocHandlerProtocol.h"

@class TexdocViewController;
@interface TexdocPanelController : NSWindowController<NSTextFieldDelegate,TexdocHandlerProtocol>
@property (weak) IBOutlet NSBox *contentBox;
@property (weak) IBOutlet NSView *view;
@property (weak) IBOutlet NSTextField *packageField;
@property (strong) IBOutlet TexdocViewController *texdocViewController;
@property (strong) IBOutlet NSView *searchPanel;
@property BOOL searching;
- (IBAction)startTexdoc:(id)sender;
- (IBAction)clearSearch:(id)sender;


@end
