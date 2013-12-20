//
//  TMTTABViewViewController.h
//  TeXtended
//
//  Created by Max Bannach on 26.10.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MMTabBarView/MMTabBarView.h>

@class TMTTabViewItem;
@interface TMTTabViewController : NSViewController <MMTabBarViewDelegate> {
    __unsafe_unretained IBOutlet MMTabBarView *tabBar;
}

@property BOOL closeWindowForLastTabDrag;
@property IBOutlet NSTabView *tabView;
- (void)addTabViewItem:(TMTTabViewItem*) item;
- (void)addNewTabWithTitle:(NSString *)aTitle;
- (MMTabBarView *)tabBar;

@end

