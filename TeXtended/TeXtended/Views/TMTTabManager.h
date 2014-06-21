//
//  TMTTabViewWindowManager.h
//  TeXtended
//
//  Created by Tobias Mende on 02.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TMTTabViewWindow, TMTTabViewController;

@interface TMTTabManager : NSObject
    {
        NSMutableSet *windowSet;

        NSMutableSet *tabViewControllers;

    }

    + (TMTTabManager *)sharedTabManager;

    - (void)addTabViewWindow:(TMTTabViewWindow *)window;

    - (void)removeTabViewWindow:(TMTTabViewWindow *)window;

    - (void)addTabViewController:(TMTTabViewController *)controller;

    - (void)removeTabViewController:(TMTTabViewController *)controller;

    - (NSTabViewItem *)tabViewItemForIdentifier:(NSString *)identifier;
@end
