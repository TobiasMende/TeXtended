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
@interface MainWindowController ()

@end

@implementation MainWindowController

- (NSString *)windowNibName {
    return @"MainWindow";
}

- (id)init {
    self = [super initWithWindowNibName:@"MainWindow"];
    if (self) {
        NSLog(@"WindowController: Init");
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.documentController setupWindowController];
    _fileViewController = [[FileViewController alloc] init];
    [self.fileViewArea setSubviews:[NSArray arrayWithObjects:self.fileViewController.view, nil]];
    [self.fileViewController loadDocument:self.documentController.model];
    [self.sidebar adjustSubviews];
    
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
    [self.sidebar adjustSubviews];
}

- (void)addPDFViewsView:(NSView *)view {
    [self.right addSubview:view];
    [self.right adjustSubviews];
}

@end
