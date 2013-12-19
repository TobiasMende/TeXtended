//
//  DBLPIntegrator.m
//  TeXtended
//
//  Created by Tobias Mende on 19.12.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "DBLPIntegrator.h"
#import "HighlightingTextView.h"
#import "BibFile.h"
#import "DBLPSearchViewController.h"
#import "CiteCompletion.h"
@implementation DBLPIntegrator

- (id)initWithTextView:(HighlightingTextView *)tv {
    self = [super initWithTextView:tv];
    if (self) {
        self.vc = [DBLPSearchViewController new];
        self.vc.executeCitationLabel = NSLocalizedString(@"Insert Citation", @"Insert Citation Button Label");
        self.vc.handler = self;
    }
    return self;
}

- (void)executeCitation:(TMTBibTexEntry *)citation forBibFile:(NSString *)path {
    [self dismissView];
    BibFile *file;
     NSArray *files = [[view.firstResponderDelegate model] bibFiles];
    for (BibFile *f in files) {
        if ([path isEqualToString:f.path]) {
            file = f;
            break;
        }
    }
    if (!file) {
        return;
    }
    if ([file insertEntry:citation]) {
        CiteCompletion *completion = [[CiteCompletion alloc] initWithBibEntry:citation];
        [view insertCompletion:completion forPartialWordRange:view.selectedRange movement:NSReturnTextMovement isFinal:YES];
    }
}

- (void)initializeDBLPView {
    NSArray *files = [[view.firstResponderDelegate model] bibFiles];
    NSMutableArray *paths = [NSMutableArray arrayWithCapacity:files.count];
    for (BibFile *file in files) {
        [paths addObject:file.path];
    }
    self.vc.bibFilePaths = paths;
    NSRect boundingRect = [view.layoutManager boundingRectForGlyphRange:NSMakeRange(view.selectedRange.location, 1) inTextContainer:view.textContainer];
    popover = [NSPopover new];
    popover.contentViewController = self.vc;
    popover.behavior = NSPopoverBehaviorSemitransient;
    [self.vc finishInitialization];
    [popover showRelativeToRect:boundingRect ofView:view preferredEdge:NSMaxXEdge];
}

- (void)dblpSearchAborted {
    [self dismissView];
}

- (void)dismissView {
    [popover close];
    popover = nil;
    [view.window makeKeyAndOrderFront:self];
}
@end
