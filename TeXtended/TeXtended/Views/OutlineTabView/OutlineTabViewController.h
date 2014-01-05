//
//  OutlineTabViewController.h
//  TeXtended
//
//  Created by Tobias Mende on 26.10.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MainWindowController, MessageOutlineViewController;
@interface OutlineTabViewController : NSViewController
@property (assign) MainWindowController* mainWindowController;

@property MessageOutlineViewController* messageOutlineViewController;
@property (strong) IBOutlet NSBox *boxView;

- (id)initWithMainWindowController:(MainWindowController*) mwc;

@end
