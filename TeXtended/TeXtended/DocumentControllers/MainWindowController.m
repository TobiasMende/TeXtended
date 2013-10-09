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
#import "Compilable.h"
#import "MainDocument.h"
#import "TextViewController.h"
#import "TMTLog.h"
#import "StatsPanelController.h"
#import "TMTTabViewWindow.h"

static const int REFRESH_LIVE_VIEW_TAG = 1001;
@interface MainWindowController ()

@end

@implementation MainWindowController

- (NSString *)windowNibName {
    return @"MainWindow";
}

- (id)initWithMainDocument:(id<MainDocument>) document {
    self = [super initWithWindowNibName:@"MainWindow"];
    if (self) {
        DDLogVerbose(@"Init");
        self.mainDocument = document;
        self.mainCompilable = self.mainDocument.model;
        self.documentControllers = [NSMutableSet new];
        for (DocumentModel *m in self.mainCompilable.mainDocuments) {
            DocumentController *dc = [[DocumentController alloc] initWithDocument:m andMainWindowController:self];
            
            [self.documentControllers addObject:dc];
        }
    }
    return self;
}

- (void)windowDidLoad
{

    [super windowDidLoad];
    
    self.fileViewController = [[FileViewController alloc] init];
    
    [self.fileViewArea setContentView:self.fileViewController.view];
    [self.fileViewController setDocument:self.activeDocumentController.model];
    
    self.statsPanel = [[StatsPanelController alloc] init];
    //[self.sidebarViewToggle setState:[[NSUserDefaultsController sharedUserDefaultsController] integerForKey:TMT_LEFT_TABVIEW_COLLAPSED]];
    //[self.secondViewToggle setState:[[NSUserDefaultsController sharedUserDefaultsController] integerForKey:TMT_RIGHT_TABVIEW_COLLAPSED]];
    
    [self.mainView setMaxSize:200 ofSubviewAtIndex:0];
    [self.mainView setEventsDelegate:self];
    
    //[self.contentView setSubviewsResizeMode:DMSplitViewResizeModeUniform];
    [self.contentView setEventsDelegate:self];
    [self.contentView setCanCollapse:YES subviewAtIndex:1];
    
    [self setTemplateController:[[TemplateController alloc] init]];
    
    ((NSBox *)[[self.contentView subviews] objectAtIndex:0]).contentView = [[self.activeDocumentController textViewController] view];
    
    
    tabWindow1 = [[TMTTabViewWindow alloc] init];
    tabWindow2 = [[TMTTabViewWindow alloc] init];
    [tabWindow1 showWindow:nil];
    [tabWindow2 showWindow:nil];
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
    [self.activeDocumentController refreshLiveView];
    // TODO: Get DC for active view and do live compile
}

- (IBAction)draftCompile:(id)sender {
    [self.activeDocumentController draftCompile];
}

- (ExportCompileWindowController *)exportWindow {
    DocumentController *current = self.activeDocumentController;
    if (current && (!_exportWindow || ![_exportWindow.controller isEqualTo:current])) {
        self.exportWindow = [[ExportCompileWindowController alloc] initWithDocumentController:current];
    }
    return _exportWindow;
}

- (IBAction)finalCompile:(id)sender {
    [self.exportWindow setModel:self.activeDocumentController.model];
    self.exportWindow.window.isVisible = YES;
}

- (DocumentController *)activeDocumentController {
    // FIXME: get the active DC
    DocumentController *dc = [[self.documentControllers allObjects] objectAtIndex:0];
    return dc;
}

- (void)genericAction:(id)sender {
    if ([sender tag] == REFRESH_LIVE_VIEW_TAG) {
        
        [self.activeDocumentController refreshLiveView];
    }
}

- (IBAction)toggleSidebarView:(id)sender {
    [self.mainView collapseOrExpandSubviewAtIndex:0 animated:YES];
}


- (IBAction)toggleSecondView:(id)sender {
    [self.contentView collapseOrExpandSubviewAtIndex:1 animated:YES];
}

- (IBAction)showStatistics:(id)sender {
    [self.statsPanel showStatistics:self.mainCompilable.path];
}

- (void)makeFirstResponder:(NSView *)view {
    DDLogInfo(@"%@", view);
    [[view window] setInitialFirstResponder:view];
}


- (NSApplicationPresentationOptions)window:(NSWindow *)window willUseFullScreenPresentationOptions:(NSApplicationPresentationOptions)proposedOptions {
    return proposedOptions|NSApplicationPresentationAutoHideToolbar;
}

#pragma mark - ViewControllerProtocol

- (void)breakUndoCoalescing {
    for (DocumentController *dc in self.documentControllers) {
        [dc breakUndoCoalescing];
    }
}


#pragma mark - DMSplitViewDelegate


- (void)splitView:(DMSplitView *)splitView divider:(NSInteger)dividerIndex movedAt:(CGFloat)newPosition {
    if (splitView == self.mainView) {
        if (dividerIndex == 0) {
            if (newPosition < 1.1f) {
                if (self.sidebarViewToggle.state != NSOffState) {
                    self.sidebarViewToggle.state = NSOffState;
                }
            } else if(self.sidebarViewToggle.state != NSOnState) {
                self.sidebarViewToggle.state = NSOnState;
            }
        }
    }
    
    if (splitView == self.contentView) {
        CGFloat hiddenPosition = (self.contentView.isVertical ? NSWidth(self.contentView.bounds) : NSHeight(self.contentView.bounds));
        if (fabs(newPosition - hiddenPosition) < 1.1f) {
            if (self.secondViewToggle.state != NSOffState) {
                self.secondViewToggle.state = NSOffState;
            }
        } else if(self.secondViewToggle.state != NSOnState) {
            self.secondViewToggle.state = NSOnState;
        }
    }
    
}

#pragma mark - Terminate


-(void)dealloc {
    DDLogVerbose(@"dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //[self.document removeObserver:self forKeyPath:@"self.mainCompilable.path"];

}


@end
