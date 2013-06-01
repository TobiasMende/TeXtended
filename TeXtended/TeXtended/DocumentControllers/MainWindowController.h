//
//  MainWindowController.h
//  TeXtended
//
//  Created by Tobias Mende on 26.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WindowControllerProtocol.h"
@class DocumentController, FileOutlineView, FileViewController;
@interface MainWindowController : NSWindowController<WindowControllerProtocol> {
    
}
@property (weak) IBOutlet NSSplitView *sidebar;
@property (weak) IBOutlet NSSplitView *left;
@property (weak) IBOutlet NSSplitView *middle;
@property (weak) IBOutlet NSSplitView *right;
@property (strong, nonatomic) DocumentController *documentController;
@property (strong) FileViewController *fileViewController;
@property (weak) IBOutlet NSView *fileViewArea;



@end
