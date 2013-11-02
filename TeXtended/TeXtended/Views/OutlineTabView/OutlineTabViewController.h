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
@property (weak) MainWindowController* mainWindowController;

@property MessageOutlineViewController* messageOutlineViewController;
@property (weak) IBOutlet NSTabView *tabView;

- (id)initWithMainWindowController:(MainWindowController*) mwc;

@end
