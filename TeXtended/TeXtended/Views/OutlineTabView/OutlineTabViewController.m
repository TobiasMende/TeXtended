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
#import <TMTHelperCollection/TMTLog.h>

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
    self.messageOutlineViewController = [[MessageOutlineViewController alloc] initWithModel:self.mainWindowController.mainDocument.model];
    [self.boxView setContentView:self.messageOutlineViewController.view];
}

@end
