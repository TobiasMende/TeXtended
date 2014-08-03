//
//  TMTAppDelegate.m
//  TMTLatexTableExample
//
//  Created by Tobias Mende on 03.08.14.
//  Copyright (c) 2014 TeXtended. All rights reserved.
//

#import "TMTAppDelegate.h"
#import "TMTLatexTableViewController.h"

@implementation TMTAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    _window.contentView = _controller.view;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    _controller = [TMTLatexTableViewController new];
    
}

@end
