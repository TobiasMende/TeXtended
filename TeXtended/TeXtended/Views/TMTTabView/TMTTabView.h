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
@interface TMTTabView : NSViewController <MMTabBarViewDelegate> {
    IBOutlet MMTabBarView *tabBar;
    IBOutlet NSTabView *tabView;
}

- (void) addTMTTabViewItem:(TMTTabViewItem*) item;
- (void)addDefaultTabs;
- (void)addNewTabWithTitle:(NSString *)aTitle;
- (MMTabBarView *)tabBar;

@end
