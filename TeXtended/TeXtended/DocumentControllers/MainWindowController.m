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
#import "DMSplitView.h"
#import "Compilable.h"
#import "MainDocument.h"
#import "TextViewController.h"
#import <TMTHelperCollection/TMTLog.h>
#import "TMTTabViewController.h"
#import "DocumentModel.h"
#import "ExtendedPDFViewController.h"
#import "OutlineTabViewController.h"
#import "ApplicationController.h"

static const int REFRESH_LIVE_VIEW_TAG = 1001;
@interface MainWindowController ()
- (void)updateFirstResponderDelegate:(NSResponder*)firstResponder;
@end

@implementation MainWindowController

- (NSString *)windowNibName {
    return @"MainWindow";
}

- (id)initForDocument:(MainDocument*)document {
    self.mainDocument = document;
    self = [super initWithWindowNibName:@"MainWindow"];
    if (self) {
        DDLogVerbose(@"Init");
        self.firsTabViewController = [TMTTabViewController new];
        self.secondTabViewController = [TMTTabViewController new];
        self.fileViewController = [FileViewController new];
        self.outlineController = [[OutlineTabViewController alloc] initWithMainWindowController:self];
        [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:TMTViewOrderAppearance options:0 context:NULL];
    }
    return self;
}

- (void)windowDidLoad
{
    DDLogVerbose(@"windowDidLoad");
    [super windowDidLoad];
    BOOL flag = [[NSUserDefaults standardUserDefaults] integerForKey:TMTViewOrderAppearance] == TMTVertical;
    self.firsTabViewController.closeWindowForLastTabDrag = NO;
    self.secondTabViewController.closeWindowForLastTabDrag = NO;
    [self.contentView setVertical:flag];
    [self.contentView setSubviews:@[self.firsTabViewController.view, self.secondTabViewController.view]];
    
    self.outlineViewArea.contentView = self.outlineController.view;
    
    [self.fileViewArea setContentView:self.fileViewController.view];
    [self.fileViewController setCompilable:self.mainDocument.model];
    self.fileViewController.mainDocument = self.mainDocument;
    
    [self.mainView setMaxSize:200 ofSubviewAtIndex:0];
    [self.mainView setEventsDelegate:self];
    
    [self.contentView setSubviewsResizeMode:DMSplitViewResizeModeUniform];
    [self.contentView setEventsDelegate:self];
    [self.contentView setCanCollapse:YES subviewAtIndex:1];
    
    [self.mainDocument windowControllerDidLoadNib:self];
}

- (void)windowWillClose:(NSNotification *)notification {
    [self.fileViewController.infoWindowController close];
}

- (IBAction)reportBug:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://dev.tobsolution.de/projects/textended-feedback-support/issues/new"];
    [[NSWorkspace sharedWorkspace] openURL:url];
}


- (IBAction)toggleSidebarView:(id)sender {
    [self.mainView collapseOrExpandSubviewAtIndex:0 animated:YES];
}


- (IBAction)toggleSecondView:(id)sender {
    [self.contentView collapseOrExpandSubviewAtIndex:1 animated:YES];
}


- (NSApplicationPresentationOptions)window:(NSWindow *)window willUseFullScreenPresentationOptions:(NSApplicationPresentationOptions)proposedOptions {
    return proposedOptions|NSApplicationPresentationAutoHideToolbar;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:TMTViewOrderAppearance] && [object isEqualTo:[NSUserDefaults standardUserDefaults]]) {
        BOOL flag = [[NSUserDefaults standardUserDefaults] integerForKey:TMTViewOrderAppearance] == TMTVertical;
        [self.contentView setVertical:flag];
        [self.contentView adjustSubviews];
    }
}



#pragma mark - DMSplitViewDelegate


- (void)splitView:(DMSplitView *)splitView divider:(NSInteger)dividerIndex movedAt:(CGFloat)newPosition {
    if (splitView == self.mainView) {
        if (dividerIndex == 0) {
            if (newPosition < 1.1f) {
                [[NSUserDefaultsController sharedUserDefaultsController] setValue:@(NSOffState) forKeyPath:[@"values." stringByAppendingString:TMT_LEFT_TABVIEW_COLLAPSED]];
            } else if(self.sidebarViewToggle.state != NSOnState) {
                if ([[[NSUserDefaultsController sharedUserDefaultsController] valueForKeyPath:[@"values." stringByAppendingString:TMT_LEFT_TABVIEW_COLLAPSED]] integerValue] == NSOnState) {
                    [[NSUserDefaultsController sharedUserDefaultsController] setValue:@(NSOnState) forKeyPath:[@"values." stringByAppendingString:TMT_LEFT_TABVIEW_COLLAPSED]];
                }
            }
        }
    }
    
    if (splitView == self.contentView) {
        CGFloat hiddenPosition = (self.contentView.isVertical ? NSWidth(self.contentView.bounds) : NSHeight(self.contentView.bounds));
        if (fabs(newPosition - hiddenPosition) < 1.1f) {
            [[NSUserDefaultsController sharedUserDefaultsController] setValue:@(NSOffState) forKeyPath:[@"values." stringByAppendingString:TMT_RIGHT_TABVIEW_COLLAPSED]];
        } else if(self.secondViewToggle.state != NSOnState) {
            if ([[[NSUserDefaultsController sharedUserDefaultsController] valueForKeyPath:[@"values." stringByAppendingString:TMT_RIGHT_TABVIEW_COLLAPSED]] integerValue] == NSOnState) {
                [[NSUserDefaultsController sharedUserDefaultsController] setValue:@(NSOnState) forKeyPath:[@"values." stringByAppendingString:TMT_RIGHT_TABVIEW_COLLAPSED]];
            }
        }
    }
    
}


- (void)showDocument:(DocumentController *)dc {
    DDLogVerbose(@"showDocument");
    self.myCurrentFirstResponderDelegate = dc;
}

- (void)addTabViewItemToFirst:(TMTTabViewItem *)item {
    DDLogVerbose(@"addTabViewItemToFirst: first = %@, item = %@", self.firsTabViewController, item);
    [self.firsTabViewController addTabViewItem:item];
}

- (void)addTabViewItemToSecond:(TMTTabViewItem *)item {
    [self.secondTabViewController addTabViewItem:item];
}


- (void)windowDidBecomeKey:(NSNotification *)notification {
    [self updateFirstResponderDelegate:self.window.firstResponder];
    [ApplicationController sharedApplicationController].currentFirstResponderDelegate = self.myCurrentFirstResponderDelegate;
}


- (void)windowDidUpdate:(NSNotification *)notification {
    if (self.window.isKeyWindow) {
        [self updateFirstResponderDelegate:self.window.firstResponder];
    }
}

- (void)updateFirstResponderDelegate:(NSResponder *)firstResponder {
    if ([firstResponder respondsToSelector:@selector(firstResponderDelegate)]) {
        id<FirstResponderDelegate> del = [firstResponder performSelector:@selector(firstResponderDelegate)];
        if (![del isEqual:self.myCurrentFirstResponderDelegate]) {
            self.myCurrentFirstResponderDelegate = del;
        }
    }
}

#pragma mark - Terminate



-(void)dealloc {
    DDLogVerbose(@"dealloc");
    self.myCurrentFirstResponderDelegate = nil;
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:TMTViewOrderAppearance];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //[[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self forKeyPath:[@"values." stringByAppendingString:TMT_LEFT_TABVIEW_COLLAPSED]];
    //[[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self forKeyPath:[@"values." stringByAppendingString:TMT_RIGHT_TABVIEW_COLLAPSED]];
    

}




@end
