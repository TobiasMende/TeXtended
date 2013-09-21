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
#import "ApplicationController.h"
#import "TemplateController.h"
#import "DMSplitView.h"

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


- (void)setDocumentController:(DocumentController *)documentController {
    _documentController = documentController;
    
    ((NSBox *)[self.middle.subviews objectAtIndex:0]).contentView = ((NSViewController*)documentController.textViewController).view;
    ((NSBox *)[self.middle.subviews objectAtIndex:1]).contentView = ((NSViewController*)documentController.consolViewsController).view;
    //((NSBox *)[self.right.subviews objectAtIndex:0]).contentView = ((NSViewController*)documentController.pdfViewsController).view;
    // ((NSBox *)[self.sidebar.subviews objectAtIndex:1]).contentView = ((NSViewController*)documentController.outlineViewController).view;
}

- (void)windowDidLoad
{

    [super windowDidLoad];
    
    
    
    
    [self.mainView setMinSize:150 ofSubviewAtIndex:0];
    [self.mainView setCanCollapse:NO subviewAtIndex:0];
    self.mainView.eventsDelegate = self;
    [self.mainView setCanCollapse:NO subviewAtIndex:1];
    
    
    [self.middle setMinSize:150 ofSubviewAtIndex:1];
    [self.middle setMaxSize:300 ofSubviewAtIndex:1];
    [self.middle setCanCollapse:NO subviewAtIndex:0];
    [self.middle setCanCollapse:YES subviewAtIndex:1];
    
    self.contentView.subviewsResizeMode = DMSplitViewResizeModeUniform;
    
    [self.documentController setupWindowController];
    NSLog(@"%@", self.documentController);
    self.fileViewController = [[FileViewController alloc] init];
    
    _fileViewController = [[FileViewController alloc] init];
    
    [self.fileViewController setDocument:self.documentController.model];
    [self.fileViewArea setContentView:self.fileViewController.view];
    
    [self.leftViewToggle setState:NSOnState];
    [self.bottomViewToggle setState:NSOnState];
    [self.rightViewToggle setState:NSOnState];
    
    [self setTemplateController:[[TemplateController alloc] init]];
}

- (void)windowDidBecomeMain:(NSNotification *)notification {
    [[ApplicationController sharedApplicationController] setDelegate:self];
}


- (void)windowWillClose:(NSNotification *)notification {
    if ([[ApplicationController sharedApplicationController] delegate] == self) {
        [[ApplicationController sharedApplicationController] setDelegate:nil];
    }
    [self.fileViewController.infoWindowController close];
    [self.exportWindow close];
}


- (IBAction)reportBug:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://dev.tobsolution.de/projects/textended-feedback-support/issues/new"];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (IBAction) openTemplateSheet:(id)sender {
    [self.templateController openSheetIn:[self window]];
}

- (IBAction)liveCompile:(id)sender {
    [self.documentController refreshLiveView];
}

- (IBAction)draftCompile:(id)sender {
    [self.documentController draftCompile];
}

- (ExportCompileWindowController *)exportWindow {
    if (!_exportWindow) {
        self.exportWindow = [[ExportCompileWindowController alloc] initWithDocumentController:self.documentController];
    }
    return _exportWindow;
}

- (IBAction)finalCompile:(id)sender {
    if (!self.exportWindow) {
        _exportWindow = [[ExportCompileWindowController alloc] initWithDocumentController:self.documentController];
        [self.exportWindow setModel:self.documentController.model];
    }
    else {
        [self.exportWindow setModel:self.documentController.model];
    }
    self.exportWindow.window.isVisible = YES;
}

- (void)genericAction:(id)sender {
    if ([sender tag] == REFRESH_LIVE_VIEW_TAG) {
        
        [self.documentController refreshLiveView];
    }
}

- (IBAction)toggleLeftView:(id)sender {
    [self.mainView collapseOrExpandSubviewAtIndex:0 animated:YES];
}

- (IBAction)toggleBottomView:(id)sender {
    [self.middle collapseOrExpandSubviewAtIndex:1 animated:YES];
}

- (IBAction)toggleRightView:(id)sender {
    [self.contentView collapseOrExpandSubviewAtIndex:1 animated:YES];
}

- (void)splitView:(DMSplitView *)splitView subview:(NSUInteger)subviewIndex stateChanged:(DMSplitViewState)newState {
    NSLog(@"TEST");
    if (splitView == self.middle) {
        if (subviewIndex == 1) {
            [self.bottomViewToggle setState:(newState == DMSplitViewStateCollapsed ? NSOffState : NSOnState)];
        }
    } else if (splitView == self.mainView) {
        switch (subviewIndex) {
            case 0:
                [self.leftViewToggle setState:(newState == DMSplitViewStateCollapsed ? NSOffState : NSOnState)];
                break;
            case 2:
                [self.rightViewToggle setState:(newState == DMSplitViewStateCollapsed ? NSOffState : NSOnState)];
            default:
                break;
        }
    } else {
        NSLog(@"MainWindowController: unhandled split view change");
    }
}

- (void)makeFirstResponder:(NSView *)view {
    NSLog(@"%@", view);
    [[view window] setInitialFirstResponder:view];
}


- (NSApplicationPresentationOptions)window:(NSWindow *)window willUseFullScreenPresentationOptions:(NSApplicationPresentationOptions)proposedOptions {
    return proposedOptions|NSApplicationPresentationAutoHideToolbar;
}


-(void)dealloc {
#ifdef DEBUG
    NSLog(@"MainWindowController dealloc");
#endif
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}


@end
