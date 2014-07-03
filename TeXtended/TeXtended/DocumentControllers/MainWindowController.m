//
//  MainWindowController.m
//  TeXtended
//
//  Created by Tobias Mende on 26.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "MainWindowController.h"
#import "MainDocument.h"
#import "FileViewController.h"
#import <TMTHelperCollection/TMTLog.h>
#import "TMTTabViewController.h"
#import "OutlineTabViewController.h"
#import "NSFileManager+TMTExtension.h"
#import "TMTTabViewItem.h"
#import "TMTTabManager.h"


@interface MainWindowController ()
@end

@implementation MainWindowController

    - (NSString *)windowNibName
    {
        return @"MainWindow";
    }

    - (id)initForDocument:(MainDocument *)document
    {
        self = [super initWithWindowNibName:@"MainWindow"];
        if (self) {
            self.mainDocument = document;

        }
        return self;
    }

    - (void)windowDidLoad
    {
        DDLogVerbose(@"windowDidLoad");
        [super windowDidLoad];
        

        self.firsTabViewController = [TMTTabViewController new];
        self.secondTabViewController = [TMTTabViewController new];
        self.outlineController = [[OutlineTabViewController alloc] initWithMainWindowController:self];
        self.fileViewController = [FileViewController new];
        [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:TMTViewOrderAppearance options:0 context:NULL];

        BOOL flag = [[NSUserDefaults standardUserDefaults] integerForKey:TMTViewOrderAppearance] == TMTVertical;
        self.firsTabViewController.closeWindowForLastTabDrag = NO;
        self.secondTabViewController.closeWindowForLastTabDrag = NO;
        [self.contentView setVertical:flag];
        [self.contentView setSubviews:@[self.firsTabViewController.view, self.secondTabViewController.view]];

        self.outlineViewArea.contentView = self.outlineController.view;
        self.fileViewArea.contentView = self.fileViewController.view;
        [self.mainView setMaxSize:200 ofSubviewAtIndex:0];
        [self.mainView setEventsDelegate:self];

        [self.contentView setSubviewsResizeMode:DMSplitViewResizeModeUniform];
        [self.contentView setEventsDelegate:self];
        [self.contentView setCanCollapse:YES subviewAtIndex:1];

        [self.mainDocument windowControllerDidLoadNib:self];

        [self.shareButton sendActionOn:NSLeftMouseDownMask];
        self.fileViewController.document = self.document;
        
    }

- (void)windowDidBecomeKey:(NSNotification *)notification {
    if (!wasMainWindow) {
        [self.window makeFirstResponder:self.firsTabViewController.tabView.selectedTabViewItem.view];
        wasMainWindow = YES;
    }
   
}


    - (void)setDocument:(NSDocument *)document
    {
        [super setDocument:document];
        self.fileViewController.document = document;
    }


    - (IBAction)reportBug:(id)sender
    {
        NSURL *url = [NSURL URLWithString:@"http://dev.tobsolution.de/projects/textended-feedback-support/issues/new"];
        [[NSWorkspace sharedWorkspace] openURL:url];
    }


    - (IBAction)toggleSidebarView:(id)sender
    {
        [self.mainView collapseOrExpandSubviewAtIndex:0 animated:YES];
    }


    - (IBAction)toggleSecondView:(id)sender
    {
        [self.contentView collapseOrExpandSubviewAtIndex:1 animated:YES];
    }



    - (IBAction)deleteTemporaryFiles:(id)sender
    {
        NSArray *dms = self.mainDocument.model.mainDocuments;

        for (DocumentModel *dm in dms) {
            [[NSFileManager defaultManager] removeTemporaryFilesAtPath:[dm.texPath stringByDeletingLastPathComponent]];
        }
    }


    - (NSApplicationPresentationOptions)window:(NSWindow *)window willUseFullScreenPresentationOptions:(NSApplicationPresentationOptions)proposedOptions
    {
        return proposedOptions | NSApplicationPresentationAutoHideToolbar;
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


    - (void)splitView:(DMSplitView *)splitView divider:(NSInteger)dividerIndex movedAt:(CGFloat)newPosition
    {
        if (splitView == self.mainView) {
            if (dividerIndex == 0) {
                if (newPosition < 1.1f) {
                    [[NSUserDefaultsController sharedUserDefaultsController] setValue:@(NSOffState) forKeyPath:[@"values." stringByAppendingString:TMT_LEFT_TABVIEW_COLLAPSED]];
                } else if (self.sidebarViewToggle.state != NSOnState) {
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
            } else if (self.secondViewToggle.state != NSOnState) {
                if ([[[NSUserDefaultsController sharedUserDefaultsController] valueForKeyPath:[@"values." stringByAppendingString:TMT_RIGHT_TABVIEW_COLLAPSED]] integerValue] == NSOnState) {
                    [[NSUserDefaultsController sharedUserDefaultsController] setValue:@(NSOnState) forKeyPath:[@"values." stringByAppendingString:TMT_RIGHT_TABVIEW_COLLAPSED]];
                }
            }
        }

    }


    - (void)addTabViewItemToFirst:(TMTTabViewItem *)item
    {
        DDLogVerbose(@"addTabViewItemToFirst: first = %@, item = %@", self.firsTabViewController, item);
        [self.firsTabViewController addTabViewItem:item];
    }

    - (void)addTabViewItemToSecond:(TMTTabViewItem *)item
    {
        [self.secondTabViewController addTabViewItem:item];
    }

#pragma mark - Terminate



    - (void)dealloc
    {
        DDLogVerbose(@"dealloc [%@]", self.window.title);
        [self.outlineController windowIsGoingToDie];
        [[TMTTabManager sharedTabManager] removeTabViewController:self.firsTabViewController];
        [[TMTTabManager sharedTabManager] removeTabViewController:self.secondTabViewController];
        
        [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:TMTViewOrderAppearance];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        

    }


@end
