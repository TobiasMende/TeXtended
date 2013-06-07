//
//  PDFViewsController.m
//  TeXtended
//
//  Created by Tobias Mende on 26.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "PDFViewsController.h"
#import "DocumentController.h"
#import "ExtendedPDFViewController.h"
#import "DocumentModel.h"

@interface PDFViewsController ()

@end

@implementation PDFViewsController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initialize];
    }
    
    return self;
}

- (id)initWithParent:(id<DocumentControllerProtocol>)parent {
    self = [super initWithNibName:@"PDFViewsView" bundle:nil];
    if (self) {
        self.parent = parent;
        [self initialize];
    }
    return self;
}

- (void) initialize {
    _model = [[self.parent documentController] model];
}

- (void)loadView {
    [super loadView];
    [self loadPDFs:self.documentController];
    [self.model addObserver:self forKeyPath:@"mainDocuments" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:NULL];
}

- (void) loadPDFs:(DocumentController*) controller {
    [self clearTabView];
    
    NSMutableSet *tmp = [[NSMutableSet alloc] init];
    for (DocumentModel* m in [self.model mainDocuments]) {
        ExtendedPDFViewController *pdfViewController = [[ExtendedPDFViewController alloc] initWithParent:self];
        [pdfViewController setPdfPath:[m pdfPath]];

        // add the view to the tab view
        NSTabViewItem *item = [[NSTabViewItem alloc] init];
        [item setLabel:pdfViewController.getPdfName];
        [item setView:[pdfViewController pdfView]];
        [self.tabView addTabViewItem:item];
        
        [tmp addObject:pdfViewController];
    }
    if ([[self.model mainDocuments] count] > 1) {
        [self.tabView setTabViewType:NSTopTabsBezelBorder];
    } else {
        [self.tabView setTabViewType:NSNoTabsNoBorder];
    }
    [self setChildren:tmp];
}

- (DocumentController * ) documentController {
    return [self.parent documentController];
}

- (void) documentModelHasChangedAction : (DocumentController*) controller {
    for (id<DocumentControllerProtocol> c in self.children) {
        [c documentModelHasChangedAction:controller];
    }
}

- (void) documentHasChangedAction {
    for (id<DocumentControllerProtocol> c in self.children) {
        [c documentHasChangedAction];
    }
}

- (void) breakUndoCoalescing{
}

/**
 * Clear the tabView, i.e. removes all tabs.
 */
- (void) clearTabView {
    for (NSTabViewItem *item in [self.tabView tabViewItems]) {
        [self.tabView removeTabViewItem:item];
    }
}


#pragma mark -
#pragma mark Observers

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isEqualTo:self.model]) {
        if ([keyPath isEqualToString:@"mainDocuments"]) {
            [self loadPDFs:[self documentController]];
        }
    }
}

#pragma mark -
#pragma mark Dealloc etc.

-(void)dealloc {
#ifdef DEBUG
    NSLog(@"PDFViewsController dealloc");
#endif
    [self.model removeObserver:self forKeyPath:@"mainDocuments"];
}
@end
