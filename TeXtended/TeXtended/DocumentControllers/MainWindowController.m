//
//  MainWindowController.m
//  TeXtended
//
//  Created by Tobias Mende on 26.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "MainWindowController.h"
#import "DocumentController.h"
#import "FileOutlineView.h"
#import "FileViewController.h"
#import "ExportCompileWindowController.h"

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
    [self.fileViewArea setContentView:self.fileViewController.view];
    [self.fileViewController loadDocument:self.documentController.model];
}

- (void)clearAllDocumentViews {
    [self.left setSubviews:[NSArray arrayWithObjects: nil]];
    [self.middle setSubviews:[NSArray arrayWithObjects: nil]];
    [self.right setSubviews:[NSArray arrayWithObjects: nil]];
}

- (void)addConsoleViewsView:(NSView *)view {
    [self.middle addSubview:view];
    [self.middle adjustSubviews];
}

- (void)addTextView:(NSView *)view {
    [self.middle addSubview:view];
    [self.middle adjustSubviews];
}

- (void)addOutlineView:(NSView *)view {
    [self.left addSubview:view];
    [self.left adjustSubviews];
}

- (void)addPDFViewsView:(NSView *)view {
    [self.right addSubview:view];
    [self.right adjustSubviews];
}

- (IBAction)reportBug:(id)sender {
    NSURL *url = [NSURL URLWithString:@"https://dev.tobsolution.de/projects/textended-feedback-support/issues/new"];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (IBAction)draftCompile:(id)sender {
    [self.documentController draftCompile];
}

- (IBAction)finalCompile:(id)sender {
    [self.exportWindow.window makeKeyAndOrderFront:[self.exportWindow window]];
}

- (void)genericAction:(id)sender {
    if ([sender tag] == REFRESH_LIVE_VIEW_TAG) {
        
        [self.documentController refreshLiveView];
    }
}

- (void)makeFirstResponder:(NSView *)view {
    [[view window] setInitialFirstResponder:view];
}

-(void)dealloc {
#ifdef DEBUG
    NSLog(@"MainWindowController dealloc");
#endif
}


@end
