//
//  MainWindowController.h
//  TeXtended
//
//  Created by Tobias Mende on 26.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WindowControllerProtocol.h"
@class DocumentController, FileOutlineView, FileViewController, ExportCompileWindowController, TMTSplitView;
@interface MainWindowController : NSWindowController<WindowControllerProtocol, NSSplitViewDelegate, NSWindowDelegate> {
}
@property (weak) IBOutlet TMTSplitView *contentView;
@property (weak) IBOutlet NSSegmentedControl *splitviewControl;
@property (weak) IBOutlet TMTSplitView *mainView;
@property (weak) IBOutlet NSSplitView *sidebar;
@property (weak) IBOutlet NSSplitView *left;
@property (weak) IBOutlet NSSplitView *middle;
@property (weak) IBOutlet NSSplitView *right;
@property (weak, nonatomic) DocumentController *documentController;
@property (strong) FileViewController *fileViewController;
@property (strong) ExportCompileWindowController* exportWindow;
@property (weak) IBOutlet NSBox *fileViewArea;

- (IBAction)collapseView:(id)sender;

- (IBAction)reportBug:(id)sender;

- (IBAction)draftCompile:(id)sender;
- (IBAction)finalCompile:(id)sender;
- (IBAction)liveCompile:(id)sender;

- (IBAction)genericAction:(id)sender;
@end
