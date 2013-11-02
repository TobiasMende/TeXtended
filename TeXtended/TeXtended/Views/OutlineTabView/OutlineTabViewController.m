//
//  OutlineTabViewController.m
//  TeXtended
//
//  Created by Tobias Mende on 26.10.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "OutlineTabViewController.h"
#import "MessageOutlineViewController.h"
#import "MainWindowController.h"
#import "MainDocument.h"
#import "TMTLog.h"

@interface OutlineTabViewController ()

@end

@implementation OutlineTabViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (id)initWithMainWindowController:(MainWindowController *)mwc {
    self = [super initWithNibName:@"OutlineTabView" bundle:nil];
    if (self) {
        self.mainWindowController = mwc;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    self.tabView = (NSTabView*)self.view;
    self.messageOutlineViewController = [[MessageOutlineViewController alloc] initWithModel:self.mainWindowController.mainDocument.model];
    [[self.tabView tabViewItemAtIndex:0] setView:self.messageOutlineViewController.view];
}

@end
