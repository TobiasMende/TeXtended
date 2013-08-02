//
//  MainWindowController.m
//  TeXtended
//
//  Created by Tobias Mende on 26.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "MainWindowController.h"
#import "DocumentController.h"
#import "FileViewController.h"
#import "InfoWindowController.h"
#import "ExportCompileWindowController.h"
#import "TMTSplitView.h"
#import "ApplicationController.h"

static const int REFRESH_LIVE_VIEW_TAG = 1001;
@interface MainWindowController ()

@end

@implementation MainWindowController

- (NSString *)windowNibName {
    return @"MainWindow";
}

- (id)init {
    self = [super initWithWindowNibName:@"MainWindow"];
    if (self) {
#ifdef DEBUG
        NSLog(@"WindowController: Init");
#endif
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.documentController setupWindowController];
    
    _fileViewController = [[FileViewController alloc] init];
    
    //[self.fileViewArea setContentView:self.fileViewController.view];
    //[self.fileViewController setDocument:self.documentController.model];
    [self.splitviewControl setSelected:YES forSegment:0];
    [self.splitviewControl setSelected:YES forSegment:1];
    [self.splitviewControl setSelected:YES forSegment:2];
}

- (void)clearAllDocumentViews {
    [self.left setSubviews:[NSArray arrayWithObjects: nil]];
    [self.middle setSubviews:[NSArray arrayWithObjects: nil]];
    [self.right setSubviews:[NSArray arrayWithObjects: nil]];
    
}

- (void)addConsoleViewsView:(NSView *)view {
    [self.middle addSubview:view];
}

- (void)addTextView:(NSView *)view {
    [self.middle addSubview:view];
}

- (void)addOutlineView:(NSView *)view {
    [self.left addSubview:view];
}

- (void)addPDFViewsView:(NSView *)view {
    [self.right addSubview:view];
}

- (IBAction)collapseView:(id)sender {
    NSSegmentedControl *control = sender;
    BOOL s0 = [control isSelectedForSegment:0];
    BOOL s1 = [control isSelectedForSegment:1];
    BOOL s2 = [control isSelectedForSegment:2];
    
    if (s0 == [self.mainView isCollapsed:0]) {
        [self.mainView toggleCollapseFor:0];
    }
    if (s1 == [self.middle isCollapsed:1]) {
        [self.middle toggleCollapseFor:1];
    }
    if (s2 == [self.mainView isCollapsed:2]) {
        [self.mainView toggleCollapseFor:2];
    }
    
    [control setSelected:![self.mainView isCollapsed:0] forSegment:0];
    [control setSelected:![self.middle isCollapsed:1] forSegment:1];
    [control setSelected:![self.mainView isCollapsed:2] forSegment:2];
}

- (void)windowDidBecomeMain:(NSNotification *)notification {
    [[ApplicationController sharedApplicationController] setDelegate:self];
}


- (void)windowWillClose:(NSNotification *)notification {
    if ([[ApplicationController sharedApplicationController] delegate] == self) {
        [[ApplicationController sharedApplicationController] setDelegate:nil];
    }
    [self.fileViewController.infoWindowController.window close];
    [self.exportWindow.window close];
}


- (IBAction)reportBug:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://dev.tobsolution.de/projects/textended-feedback-support/issues/new"];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (IBAction)liveCompile:(id)sender {
    [self.documentController refreshLiveView];
}

- (IBAction)draftCompile:(id)sender {
    [self.documentController draftCompile];
}

- (IBAction)finalCompile:(id)sender {
    if (!self.exportWindow) {
        _exportWindow = [[ExportCompileWindowController alloc] initWithDocumentController:self.documentController];
        [self.exportWindow setModel:self.documentController.model];
        [self.exportWindow showWindow:nil];
    }
    else
    {
        if (self.exportWindow.window.isVisible) {
            [self.exportWindow setModel:self.documentController.model];
        }
    }
}

- (void)genericAction:(id)sender {
    if ([sender tag] == REFRESH_LIVE_VIEW_TAG) {
        
        [self.documentController refreshLiveView];
    }
}

- (void)makeFirstResponder:(NSView *)view {
    NSLog(@"%@", view);
    [[view window] setInitialFirstResponder:view];
}


- (NSApplicationPresentationOptions)window:(NSWindow *)window willUseFullScreenPresentationOptions:(NSApplicationPresentationOptions)proposedOptions {
    return proposedOptions|NSApplicationPresentationAutoHideToolbar;
}


- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview {

    if (splitView == self.middle) {
        if (![self.splitviewControl isSelectedForSegment:1]) {
            return YES;
        }
    }
    
    if (splitView == self.mainView) {
        if (![self.splitviewControl isSelectedForSegment:[self.mainView.subviews indexOfObject:subview]]) {
            return YES;
        }
    }
    
    if (splitView == self.sidebar) {
        return YES;
    }
    return NO;
}

-(void)dealloc {
#ifdef DEBUG
    NSLog(@"MainWindowController dealloc");
#endif
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}


@end
