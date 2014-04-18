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
#import "NSFileManager+TMTExtension.h"

static const int REFRESH_LIVE_VIEW_TAG = 1001;
@interface MainWindowController ()
@end

@implementation MainWindowController

- (NSString *)windowNibName {
    return @"MainWindow";
}

- (id)initForDocument:(MainDocument*)document {
    self.mainDocument = document;
    self = [super initWithWindowNibName:@"MainWindow"];
    if (self) {
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
    
    [self.shareButton sendActionOn:NSLeftMouseDownMask];
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

-(IBAction)showInformation:(id)sender {
    [self.fileViewController showInformation];
}

- (IBAction)deleteTemporaryFiles:(id)sender {
    NSArray *dms = self.mainDocument.model.mainDocuments;
    
    for (DocumentModel *dm in dms) {
        [[NSFileManager defaultManager] removeTemporaryFilesAtPath:[dm.texPath stringByDeletingLastPathComponent]];
    }
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


- (void)addTabViewItemToFirst:(TMTTabViewItem *)item {
    DDLogVerbose(@"addTabViewItemToFirst: first = %@, item = %@", self.firsTabViewController, item);
    [self.firsTabViewController addTabViewItem:item];
}

- (void)addTabViewItemToSecond:(TMTTabViewItem *)item {
    [self.secondTabViewController addTabViewItem:item];
}

#pragma mark - Terminate



-(void)dealloc {
    [self.outlineController windowIsGoingToDie];
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:TMTViewOrderAppearance];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}




@end
