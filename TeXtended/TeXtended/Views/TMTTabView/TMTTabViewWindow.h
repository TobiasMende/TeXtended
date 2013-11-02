//
//  TMTTabViewWindow.h
//  TeXtended
//
//  Created by Max Bannach on 28.09.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MMTabBarView/MMTabBarView.h>

@class TMTTabViewItem, TMTTabViewController;
@interface TMTTabViewWindow : NSWindowController

@property (strong) IBOutlet NSView *cview;
@property (strong) TMTTabViewController* tabView;

@end
