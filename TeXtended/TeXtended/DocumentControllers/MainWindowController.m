//
//  MainWindowController.m
//  TeXtended
//
//  Created by Tobias Mende on 26.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "MainWindowController.h"
#import "DocumentController.h"
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

@end
