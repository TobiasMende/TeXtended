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
- (void) unbindAll;
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
    if (self.model.faultingState > 0) {
        return;
    }
    [self clearTabView];
    

    NSMutableSet *tmp = [[NSMutableSet alloc] init];
    for (DocumentModel* m in [self.model mainDocuments]) {
        ExtendedPDFViewController *pdfViewController = [[ExtendedPDFViewController alloc] initWithParent:self];
        [pdfViewController setModel:m];

        // add the view to the tab view
        NSTabViewItem *item = [[NSTabViewItem alloc] init];
        if (m.pdfName) {
            [item setLabel:m.pdfName];
        } else {
            [item setLabel:NSLocalizedString(@"Untitled", @"Untitled")];
        }
        [item bind:@"label" toObject:m withKeyPath:@"pdfName" options:nil];
        [item setView:[pdfViewController view]];
        [self.tabView addTabViewItem:item];
        
        [tmp addObject:pdfViewController];
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
    if ([object isEqualTo:self.model]  && self.model.faultingState == 0) {
        if ([keyPath isEqualToString:@"mainDocuments"]) {
            [self loadPDFs:[self documentController]];
        }
    }
}


#pragma mark -
#pragma mark Responder Chain
- (BOOL)respondsToSelector:(SEL)aSelector {
    if (aSelector == @selector(printDocument:)) {
        NSTabViewItem *item = [self.tabView selectedTabViewItem];
        return [[item view] respondsToSelector:@selector(print:)];
    }
    return [super respondsToSelector:aSelector];
}

- (id)performSelector:(SEL)aSelector {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (aSelector == @selector(printDocument:)) {
        NSTabViewItem *item = [self.tabView selectedTabViewItem];
        return [[item view] performSelector:@selector(print:)];
    }
    return [super performSelector:aSelector];
#pragma clang diagnostic pop
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
